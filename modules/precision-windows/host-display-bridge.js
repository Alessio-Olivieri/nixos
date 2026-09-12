// Only documented monitor configuration calls. Never evaluate shell code,
// restart GNOME, change persistent monitors.xml, or touch the primary renderer.
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import {assertConsistent, guardedApply} from './display-guard.js';

function unpack(value) {
    if (value instanceof GLib.Variant) return unpack(value.deepUnpack());
    if (Array.isArray(value)) return value.map(unpack);
    if (value && typeof value === 'object')
        return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, unpack(v)]));
    return value;
}
function busCall(method, name, type) {
    return unpack(Gio.DBus.session.call_sync('org.freedesktop.DBus',
        '/org/freedesktop/DBus', 'org.freedesktop.DBus', method,
        name === null ? null : new GLib.Variant('(s)', [name]), new GLib.VariantType(type),
        Gio.DBusCallFlags.NONE, 2000, null))[0];
}
// Never let an old operation cross into a replacement GNOME session.
const displayOwner = busCall('GetNameOwner', 'org.gnome.Mutter.DisplayConfig', '(s)');
// A new session bus can reuse both the unique name and Mutter's serial.
// GetId identifies this bus instance, not merely the machine.
const displayBusId = busCall('GetId', null, '(s)');
function call(method, args = null) {
    return Gio.DBus.session.call_sync(displayOwner,
        '/org/gnome/Mutter/DisplayConfig', 'org.gnome.Mutter.DisplayConfig',
        method, args, null, Gio.DBusCallFlags.NONE, 2000, null);
}
function inspect() {
    // Both calls only read Mutter's cached state; no GPU probing or wakeups.
    const [resourceSerial, , outputs] = unpack(call('GetResources'));
    const [serial, monitors, logical, properties] = unpack(call('GetCurrentState'));
    const shellPid = busCall('GetConnectionUnixProcessID', displayOwner, '(u)');
    return {snapshot: {serial, monitors, logical, properties, shellPid, displayOwner, displayBusId},
        resources: {serial: resourceSerial, outputs}};
}
function apply(config) {
    const properties = {};
    if (config.layoutMode !== undefined)
        properties['layout-mode'] = new GLib.Variant('u', config.layoutMode);
    const logical = config.logical.map(([x, y, scale, transform, primary, monitors]) =>
        [x, y, scale, transform, primary, monitors.map(([connector, mode, settings]) => {
            const props = {};
            for (const key of ['underscanning', 'color-mode', 'rgb-range'])
                if (settings[key] !== undefined)
                    props[key] = new GLib.Variant(key === 'underscanning' ? 'b' : 'u', settings[key]);
            return [connector, mode, props];
        })]);
    call('ApplyMonitorsConfig', new GLib.Variant('(uua(iiduba(ssa{sv}))a{sv})',
        [config.serial, 1, logical, properties])); // 1 = temporary, not persistent.
}
if (ARGV[0] === 'snapshot') {
    const {snapshot, resources} = inspect();
    assertConsistent(snapshot, resources);
    print(JSON.stringify(snapshot));
} else if (ARGV[0] === 'apply') {
    guardedApply(JSON.parse(ARGV[1]), inspect, apply);
    print(JSON.stringify({applied: true}));
} else {
    throw new Error('Expected snapshot or apply');
}
