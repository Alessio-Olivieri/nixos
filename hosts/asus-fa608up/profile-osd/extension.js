import Gio from 'gi://Gio';
import GLib from 'gi://GLib';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const PROFILES = [
    ['Balanced', 'power-profile-balanced-symbolic'],
    ['Performance', 'power-profile-performance-symbolic'],
    ['Quiet', 'power-profile-power-saver-symbolic'],
    ['Low Power', 'power-profile-power-saver-symbolic'],
    ['Custom', 'preferences-system-symbolic'],
];

export default class AsusProfileOsd extends Extension {
    enable() {
        this._lastProfile = null;
        this._cancel = new Gio.Cancellable();
        this._subscription = Gio.DBus.system.signal_subscribe(
            'xyz.ljones.Asusd',
            'org.freedesktop.DBus.Properties',
            'PropertiesChanged',
            '/xyz/ljones',
            'xyz.ljones.Platform',
            Gio.DBusSignalFlags.NONE,
            (_connection, _sender, _path, _iface, _signal, parameters) => {
                const [, changed] = parameters.deepUnpack();
                const value = changed.PlatformProfile?.get_uint32();
                if (value === undefined || !PROFILES[value] || value === this._lastProfile)
                    return;

                this._lastProfile = value;
                const [label, iconName] = PROFILES[value];
                // Use GNOME 50's native volume/brightness OSD. A profile has
                // no meaningful percentage, so omit the progress bar.
                Main.osdWindowManager.showAll(
                    new Gio.ThemedIcon({name: iconName}),
                    `Fan / power: ${label}`, null, -1);
            });

        // Seed the initial value without showing a popup at login. Keep any
        // real change already received while this asynchronous read ran.
        Gio.DBus.system.call(
            'xyz.ljones.Asusd', '/xyz/ljones',
            'org.freedesktop.DBus.Properties', 'Get',
            new GLib.Variant('(ss)', ['xyz.ljones.Platform', 'PlatformProfile']),
            null, Gio.DBusCallFlags.NONE, 3000, this._cancel,
            (connection, result) => {
                try {
                    const reply = connection.call_finish(result);
                    if (this._cancel && this._lastProfile === null)
                        this._lastProfile = reply.get_child_value(0).get_variant().get_uint32();
                } catch (error) {
                    if (!error.matches(Gio.IOErrorEnum, Gio.IOErrorEnum.CANCELLED))
                        console.warn(`ASUS profile OSD initial read: ${error.message}`);
                }
            });
    }

    disable() {
        this._cancel?.cancel();
        this._cancel = null;
        if (this._subscription)
            Gio.DBus.system.signal_unsubscribe(this._subscription);
        this._subscription = 0;
        this._lastProfile = null;
    }
}
