import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import Shell from 'gi://Shell';
import St from 'gi://St';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';

const STATUS_PATH = '/run/gpu-indicator/status.json';

export default class GpuIndicator extends Extension {
    enable() {
        this._cancel = new Gio.Cancellable();
        this._reading = false;
        this._signature = null;
        this._indicator = new PanelMenu.Button(0.0, this.metadata.name);
        const box = new St.BoxLayout({style_class: 'panel-status-menu-box'});
        this._icon = new St.Icon({
            icon_name: 'video-display-symbolic',
            style_class: 'system-status-icon',
        });
        this._label = new St.Label({text: 'GPU ?', y_align: Clutter.ActorAlign.CENTER});
        box.add_child(this._icon);
        box.add_child(this._label);
        this._indicator.add_child(box);
        Main.panel.addToStatusArea(this.uuid, this._indicator);
        this._indicator.menu.connect('open-state-changed', (_menu, open) => {
            if (open)
                this._read();
        });
        this._read();
        this._timer = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 3, () => {
            this._read();
            return GLib.SOURCE_CONTINUE;
        });
    }

    _read() {
        if (this._reading || !this._indicator)
            return;
        this._reading = true;
        const cancel = this._cancel;
        const file = Gio.File.new_for_path(STATUS_PATH);
        file.load_contents_async(cancel, (source, response) => {
            // A callback from a previous enable/disable cycle must not touch new UI.
            if (cancel !== this._cancel || cancel.is_cancelled())
                return;
            this._reading = false;
            try {
                const [ok, bytes] = source.load_contents_finish(response);
                if (!ok || bytes.length > 256 * 1024)
                    throw new Error('Invalid status file');
                const status = JSON.parse(new TextDecoder().decode(bytes));
                if (status.version !== 1 || !Number.isFinite(status.updated_at)
                    || !Array.isArray(status.applications))
                    throw new Error('Unrecognized status data');
                const age = Date.now() / 1000 - status.updated_at;
                const staleAfter = Math.max(20, 3 * (Number(status.interval) || 5));
                if (age > staleAfter || age < -10) {
                    this._render({state: 'unknown', applications: [],
                        detail: 'GPU monitor has stopped updating.'});
                    return;
                }
                this._render(status);
            } catch (_error) {
                this._render({state: 'unknown', applications: [],
                    detail: 'GPU monitor unavailable. Check the gpu-indicator service.'});
            }
        });
    }

    _line(text, dim = false) {
        const row = new PopupMenu.PopupMenuItem(text, {reactive: false, can_focus: false});
        if (dim)
            row.label.add_style_class_name('gpu-indicator-detail');
        this._indicator.menu.addMenuItem(row);
    }

    _appName(app) {
        // Prefer GNOME desktop application names when this PID owns a window.
        for (const actor of global.get_window_actors()) {
            const window = actor.meta_window;
            if (app.pids?.includes(window.get_pid())) {
                // Application names are useful; private window titles are not.
                const desktopApp = Shell.WindowTracker.get_default().get_window_app(window);
                if (desktopApp)
                    return desktopApp.get_name();
            }
        }
        return String(app.name || 'Unnamed process').slice(0, 80);
    }

    _render(status) {
        if (!this._indicator)
            return;
        const signature = JSON.stringify({...status, updated_at: 0});
        if (signature === this._signature)
            return;
        this._signature = signature;
        const apps = status.applications || [];
        const hasVm = apps.some(app => app.kind === 'vm');
        let label;
        let title;
        switch (status.state) {
        case 'intel':
            label = 'Intel';
            title = 'Intel desktop · NVIDIA suspended';
            break;
        case 'nvidia':
            label = apps.length ? `NVIDIA · ${apps.length}` : 'NVIDIA';
            title = 'NVIDIA is awake';
            break;
        case 'passthrough':
            label = hasVm ? 'NVIDIA · VM' : 'NVIDIA · VFIO';
            title = hasVm ? 'NVIDIA held by a virtual machine' : 'NVIDIA reserved for passthrough';
            break;
        default:
            label = 'GPU ?';
            title = 'GPU status unavailable';
        }
        this._label.set_text(label);
        this._indicator.accessible_name = title;
        this._indicator.menu.removeAll();
        this._line(title);
        this._line(String(status.detail || ''), true);
        if (apps.length) {
            this._indicator.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
            this._line('Applications holding the GPU', true);
            for (const app of apps.slice(0, 12)) {
                const pids = Array.isArray(app.pids) ? app.pids.slice(0, 4).join(', ') : '';
                const more = Number(app.pid_count) > 4 ? ', …' : '';
                this._line(`${this._appName(app)}${pids ? `  ·  PID ${pids}${more}` : ''}`);
            }
            const remaining = Math.max(0, apps.length - 12) + (status.omitted_applications || 0);
            if (remaining)
                this._line(`${remaining} more applications`, true);
        }
        if (status.visibility?.scanned && !status.visibility.complete)
            this._line('Some processes could not be inspected.', true);
        this._indicator.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
        this._line('Device ownership, not a GPU utilization meter.', true);
    }

    disable() {
        if (this._timer) {
            GLib.Source.remove(this._timer);
            this._timer = 0;
        }
        this._cancel?.cancel();
        this._cancel = null;
        this._indicator?.destroy();
        this._indicator = null;
        this._label = null;
        this._icon = null;
        this._signature = null;
    }
}
