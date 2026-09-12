/* Diagnostic consumer of the pinned LGMP frame stream, not the QXL console.
 * Build with the LGMP and LGProtocol headers/sources from the pinned LG source.
 * Reads one BGRA/packed-BGR frame, releases its lease, and writes a PPM.
 */
#include <lgmp/client.h>
#include <LGProtocol/KVMFR.h>
#include <LGProtocol/LGMPConfig.h>
#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>

int main(int argc, char **argv) {
    if (argc != 2) return 2;
    const size_t size = 128ul * 1024 * 1024;
    int fd = open("/dev/kvmfr0", O_RDWR | O_CLOEXEC);
    if (fd < 0) { perror("kvmfr"); return 1; }
    unsigned char *memory = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    assert(memory != MAP_FAILED);
    PLGMPClient client = NULL;
    PLGMPClientQueue queue = NULL;
    assert(lgmpClientInit(memory, size, &client) == LGMP_OK);
    uint32_t dataSize, clientID, remoteVersion;
    uint8_t *data;
    assert(lgmpClientSessionInit(client, &dataSize, &data, &clientID, &remoteVersion) == LGMP_OK);
    assert(lgmpClientSubscribe(client, LGMP_Q_FRAME, &queue) == LGMP_OK);
    int result = 1;
    for (int tries = 0; tries < 1000; ++tries) {
        LGMPMessage message;
        LGMP_STATUS status = lgmpClientProcess(queue, &message);
        if (status == LGMP_ERR_QUEUE_EMPTY) { usleep(10000); continue; }
        if (status != LGMP_OK) { fprintf(stderr, "LGMP status %d\n", status); break; }
        KVMFRFrame *frame = message.mem;
        /* The pinned IDD's CRGB24Effect packs consecutive B,G,R bytes into
         * FRAME_TYPE_BGR_32 rows, with pitch including alignment padding. */
        const unsigned pixelBytes = frame->type == FRAME_TYPE_BGR_32 ? 3 : 4;
        const size_t bytes = (size_t)frame->pitch * frame->dataHeight;
        const size_t offset = (unsigned char *)frame - memory + frame->offset;
        if ((frame->type != FRAME_TYPE_BGRA && frame->type != FRAME_TYPE_BGR_32) || !frame->frameWidth || !frame->frameHeight ||
            frame->frameWidth > 16384 || frame->frameHeight > frame->dataHeight ||
            frame->pitch < frame->frameWidth * pixelBytes || offset + 4 + bytes > size) {
            lgmpClientMessageDone(queue); usleep(10000); continue;
        }
        KVMFRFrameBuffer *buffer = (KVMFRFrameBuffer *)(memory + offset);
        int ready;
        for (ready = 0; ready < 1000 && atomic_load_explicit(&buffer->wp, memory_order_acquire) < bytes; ++ready)
            usleep(1000);
        if (ready == 1000) { lgmpClientMessageDone(queue); break; }
        FILE *output = fopen(argv[1], "wb");
        assert(output);
        fprintf(output, "P6\n%u %u\n255\n", frame->frameWidth, frame->frameHeight);
        for (uint32_t y = 0; y < frame->frameHeight; ++y)
            for (uint32_t x = 0; x < frame->frameWidth; ++x) {
                unsigned char *pixel = buffer->data + (size_t)y * frame->pitch + x * pixelBytes;
                unsigned char rgb[3] = {pixel[2], pixel[1], pixel[0]};
                fwrite(rgb, 3, 1, output);
            }
        fclose(output);
        printf("Captured LGMP frame %u: %ux%u, %s, client %u\n", frame->frameSerial, frame->frameWidth, frame->frameHeight, pixelBytes == 3 ? "packed BGR" : "BGRA", clientID);
        lgmpClientMessageDone(queue);
        result = 0;
        break;
    }
    lgmpClientUnsubscribe(&queue);
    lgmpClientFree(&client);
    munmap(memory, size); close(fd);
    return result;
}
