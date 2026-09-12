// Read only the GPU indicator's accessible text from the live GNOME shell.
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';

const address = Gio.DBus.session.call_sync('org.a11y.Bus', '/org/a11y/bus',
    'org.a11y.Bus', 'GetAddress', null, null, Gio.DBusCallFlags.NONE, 2000, null).deepUnpack()[0];
const bus = Gio.DBusConnection.new_for_address_sync(address,
    Gio.DBusConnectionFlags.AUTHENTICATION_CLIENT | Gio.DBusConnectionFlags.MESSAGE_BUS_CONNECTION,
    null, null);
function call(owner, path, iface, method, args = null) {
    return bus.call_sync(owner, path, iface, method, args, null,
        Gio.DBusCallFlags.NONE, 2000, null).deepUnpack()[0];
}
function name(owner, path) {
    return call(owner, path, 'org.freedesktop.DBus.Properties', 'Get',
        new GLib.Variant('(ss)', ['org.a11y.atspi.Accessible', 'Name'])).deepUnpack();
}
let seen = 0;
function visit(owner, path, depth) {
    if (++seen > 10000 || depth > 25) return;
    try {
        const text = name(owner, path);
        if (/^(Intel|NVIDIA|GPU \?|GPU status|Applications holding|Ollama|Device ownership)/.test(text))
            print(JSON.stringify({text, role: call(owner, path, 'org.a11y.atspi.Accessible', 'GetRoleName'),
                states: call(owner, path, 'org.a11y.atspi.Accessible', 'GetState')}));
        for (const [childOwner, childPath] of call(owner, path, 'org.a11y.atspi.Accessible', 'GetChildren'))
            visit(childOwner, childPath, depth + 1);
    } catch (_) { /* An actor may disappear while reading the tree. */ }
}
for (const [owner, path] of call('org.a11y.atspi.Registry', '/org/a11y/atspi/accessible/root',
    'org.a11y.atspi.Accessible', 'GetChildren')) {
    if (name(owner, path) === 'gnome-shell') visit(owner, path, 0);
}
