# Generated on the ASUS; keep these addresses local to this host.
{ ... }: {
  hardware.asus-fa608up = {
    configured = true;
    amdPciAddress = "0000:65:00.0";
    nvidiaPciAddress = "0000:01:00.0";
    # Verified GREY 360x360 IR capture interface, distinct from the RGB stream.
    irCamera = "/dev/v4l/by-path/pci-0000:65:00.4-usb-0:1:1.2-video-index0";
  };
}
