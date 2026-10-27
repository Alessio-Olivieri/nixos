"""Keep logind-managed sleep out of the complete NVIDIA ownership lifecycle."""
from contextlib import contextmanager
import os


@contextmanager
def inhibit_sleep():
    import dbus

    bus = dbus.SystemBus(private=True)
    fd = None
    try:
        manager = bus.get_object('org.freedesktop.login1', '/org/freedesktop/login1')
        # The lid normally ignores high-level sleep inhibitors. Hold its
        # low-level inhibitor too; GNOME still observes the sleep blocker.
        fd = manager.Inhibit(
            'sleep:handle-lid-switch', 'Windows Gaming',
            'Windows owns NVIDIA or Linux GPU/display recovery is in progress',
            'block', dbus_interface='org.freedesktop.login1.Manager').take()
        os.set_inheritable(fd, False)
        # An inhibitor cannot cancel a suspend already being prepared.
        if manager.Get('org.freedesktop.login1.Manager', 'PreparingForSleep',
                       dbus_interface='org.freedesktop.DBus.Properties'):
            raise RuntimeError('System sleep is already being prepared; NVIDIA handoff was not started')
        yield
    finally:
        if fd is not None:
            os.close(fd)
        bus.close()
