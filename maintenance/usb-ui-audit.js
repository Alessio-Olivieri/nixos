// Inspect only the task's viewer/chooser accessibility trees. Optional action
// is confined to an exact accessible name in the explicitly selected app.
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
const address = Gio.DBus.session.call_sync('org.a11y.Bus', '/org/a11y/bus',
    'org.a11y.Bus', 'GetAddress', null, null, 0, 2000, null).deepUnpack()[0];
const bus = Gio.DBusConnection.new_for_address_sync(address, 9, null, null);
function call(owner, path, iface, method, args = null) {
    return bus.call_sync(owner, path, iface, method, args, null, 0, 2000, null).deepUnpack()[0];
}
function name(owner, path) {
    return call(owner, path, 'org.freedesktop.DBus.Properties', 'Get',
        new GLib.Variant('(ss)', ['org.a11y.atspi.Accessible', 'Name'])).deepUnpack();
}
const app = ARGV[0] || 'remote-viewer';
if (!['remote-viewer', 'zenity'].includes(app)) throw Error('Unexpected application');
let acted = false;
function visit(owner, path, depth) {
    if (depth > 20) return;
    try {
        const text = name(owner, path);
        const role = call(owner, path, 'org.a11y.atspi.Accessible', 'GetRoleName');
        const description = call(owner, path, 'org.freedesktop.DBus.Properties', 'Get',
            new GLib.Variant('(ss)', ['org.a11y.atspi.Accessible', 'Description'])).deepUnpack();
        print(JSON.stringify({text, description, role, owner, path, depth}));
        if (ARGV[1] && text === ARGV[1] && !acted && (!ARGV[3] || path === ARGV[3])) {
            const actions = call(owner, path, 'org.a11y.atspi.Action', 'GetActions');
            print(JSON.stringify({actions}));
            if (ARGV[2] === 'activate' && actions.length) {
                acted = call(owner, path, 'org.a11y.atspi.Action', 'DoAction', new GLib.Variant('(i)', [0]));
                print(JSON.stringify({acted, text}));
            }
        }
        for (const [childOwner, childPath] of call(owner, path, 'org.a11y.atspi.Accessible', 'GetChildren'))
            visit(childOwner, childPath, depth + 1);
    } catch (_) {}
}
for (const [owner, path] of call('org.a11y.atspi.Registry', '/org/a11y/atspi/accessible/root',
    'org.a11y.atspi.Accessible', 'GetChildren')) {
    try { if (name(owner, path) === app) visit(owner, path, 0); } catch (_) {}
}
