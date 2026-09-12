import {assertConsistent, guardedApply} from '../display-guard.js';

const panel = ['eDP-1', 'BOE', 'panel', 'internal'];
const hdmi = ['HDMI-1', 'GSM', 'LG FULL HD', 'external'];
function state() {
    const specs = [panel, hdmi];
    return {
        snapshot: {serial: 7, displayOwner: ':1.123', displayBusId: 'session-a', shellPid: 23329,
            monitors: specs.map(spec => [spec, [], {}]),
            logical: [[0, 0, 1, 0, true, [panel], {}]]},
        resources: {serial: 7, outputs: specs.map((spec, i) =>
            [i, i, -1, [], spec[0], [], [],
                {vendor: spec[1], product: spec[2], serial: spec[3]}])},
    };
}
const config = {serial: 7, displayOwner: ':1.123', displayBusId: 'session-a', shellPid: 23329};
let passed = 0;
function rejects(name, mutate, pattern) {
    const data = state();
    const plan = {...config};
    mutate(data, plan);
    let writes = 0;
    let error;
    try {
        guardedApply(plan, () => data, () => writes++);
    } catch (caught) {
        error = caught;
    }
    if (writes !== 0 || !error || !pattern.test(error.message))
        throw new Error(`FAIL ${name}: writes=${writes}, error=${error}`);
    passed++;
}
rejects('hot-added HDMI with no monitor (crash regression)',
    data => data.snapshot.monitors.pop(), /HDMI-1 has no matching monitor/);
rejects('output removed before monitor update',
    data => data.resources.outputs.pop(), /HDMI-1 has no matching connector/);
rejects('resources and monitor state have different serials',
    data => data.resources.serial++, /during inspection/);
rejects('plan is stale', (_, plan) => plan.serial++, /since planning/);
rejects('replacement GNOME reused serial',
    data => data.snapshot.displayOwner = ':1.999', /session changed/);
rejects('legacy unguarded snapshot', (_, plan) => delete plan.displayOwner, /session changed/);
rejects('replacement bus reused owner, serial and PID',
    data => data.snapshot.displayBusId = 'session-b', /session changed/);
rejects('replacement shell reused owner and serial',
    data => data.snapshot.shellPid = 77549, /session changed/);
rejects('legacy snapshot lacks bus identity',
    (_, plan) => delete plan.displayBusId, /session changed/);
rejects('legacy snapshot lacks shell identity',
    (_, plan) => delete plan.shellPid, /session changed/);
rejects('connector identity changed',
    data => data.resources.outputs[1][7].serial = 'other', /identity differs/);
rejects('ambiguous connector names on multiple GPUs',
    data => data.resources.outputs.push(data.resources.outputs[1]), /ambiguous connector/);
rejects('ambiguous monitor names',
    data => data.snapshot.monitors.push(data.snapshot.monitors[1]), /ambiguous monitor/);
rejects('logical monitor identity stale',
    data => data.snapshot.logical[0][5] = [['eDP-1', 'other', 'panel', 'internal']], /inconsistent identity/);
let writes = 0;
guardedApply(config, state, () => writes++);
if (writes !== 1) throw new Error('Valid state must apply exactly once');
passed++;
// An attached but disabled HDMI still has a MetaMonitor and is safe to inspect.
const valid = state();
assertConsistent(valid.snapshot, valid.resources);
passed++;
print(`${passed} display consistency tests passed`);
