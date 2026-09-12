// Pure checks: no D-Bus, device access, or display changes. Fail closed on
// unsupported/ambiguous topologies (including multi-tile connector mappings).
export function assertConsistent(snapshot, resources) {
    const refuse = reason => {
        throw new Error(`Unsafe GNOME display state: ${reason}; no display changes made`);
    };
    if (snapshot.serial !== resources.serial)
        refuse('monitor topology changed during inspection');
    const monitors = new Map();
    for (const [spec] of snapshot.monitors) {
        if (monitors.has(spec[0])) refuse(`ambiguous monitor ${spec[0]}`);
        monitors.set(spec[0], spec);
    }
    const seen = new Set();
    for (const output of resources.outputs) {
        const name = output[4];
        const props = output[7];
        if (seen.has(name)) refuse(`ambiguous connector ${name}`);
        seen.add(name);
        const spec = monitors.get(name);
        if (!spec) refuse(`connector ${name} has no matching monitor`);
        if (['vendor', 'product', 'serial'].some((key, i) => props[key] !== spec[i + 1]))
            refuse(`connector ${name} identity differs between display lists`);
    }
    for (const [name] of monitors)
        if (!seen.has(name)) refuse(`monitor ${name} has no matching connector`);
    for (const logical of snapshot.logical) {
        for (const spec of logical[5]) {
            if (JSON.stringify(monitors.get(spec[0])) !== JSON.stringify(spec))
                refuse(`active monitor ${spec[0]} has an inconsistent identity`);
        }
    }
}

// The injected read/apply functions make refusal-before-mutation testable.
// Pin the bus instance AND unique owner: a fresh bus can reuse an old name.
// Mutter's own serial check covers topology races after these reads. This guard
// is not a fix for Mutter's GPU lifecycle itself.
export function guardedApply(config, read, apply) {
    const {snapshot, resources} = read();
    assertConsistent(snapshot, resources);
    if (config.serial !== snapshot.serial)
        throw new Error('Monitor topology changed since planning; no display changes made');
    if (!config.displayOwner || config.displayOwner !== snapshot.displayOwner
        || !config.displayBusId || config.displayBusId !== snapshot.displayBusId
        || !Number.isInteger(config.shellPid) || config.shellPid <= 0
        || config.shellPid !== snapshot.shellPid)
        throw new Error('GNOME session changed since planning; no display changes made');
    return apply(config);
}
