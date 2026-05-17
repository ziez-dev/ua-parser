# ziez-ua-parser

User-Agent parser for Zig — standalone library with no [ziez](https://github.com/ziez-dev/ziez) dependency.

Parses browser name/version, OS name/version, and device type from User-Agent strings.

## Requirements

- Zig 0.16.0+

## Installation

In `build.zig.zon`:

```zig
.dependencies = .{
    .@"ziez-ua-parser" = .{
        .url = "https://github.com/ziez-dev/ua-parser/archive/refs/tags/v0.0.1.tar.gz",
        .hash = "1220b1fe03d61a1cc83ee28e918e1a2e4f0e0d6d1e23844e0c0e28194a8bbbe9d2e8",
    },
},
```

In `build.zig`:

```zig
const ua_dep = b.dependency("ziez-ua-parser", .{
    .target = target,
    .optimize = optimize,
});
exe_mod.addImport("ziez_ua_parser", ua_dep.module("ziez-ua-parser"));
```

## Quick Start

```zig
const std = @import("std");
const ua = @import("ziez_ua_parser");

pub fn main() !void {
    const result = ua.parse("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36");

    std.debug.print("Browser: {s} {s}\n", .{ result.browser.name, result.browser.version });
    std.debug.print("OS: {s} {s}\n", .{ result.os.name, result.os.version });
    if (result.device.type) |dt| {
        std.debug.print("Device: {s}\n", .{ua.deviceTypeToString(dt)});
    }
}
```

## API

**`ua.parse(agent_string)`** — Returns a `ParseResult` with:

| Field | Type | Description |
|---|---|---|
| `browser.name` | `[]const u8` | Browser name (e.g. "Chrome") |
| `browser.version` | `[]const u8` | Browser version (e.g. "120.0.0.0") |
| `os.name` | `[]const u8` | Operating system name (e.g. "Windows") |
| `os.version` | `[]const u8` | OS version (e.g. "10") |
| `device.type` | `?DeviceType` | Device type (`desktop`, `mobile`, `tablet`) |

**`ua.deviceTypeToString(device_type)`** — Converts `DeviceType` enum to string.

## Known Issue — Arch Linux

This library uses PCRE2 C bindings for regex matching. On Arch Linux, building with the default glibc target fails due to C library incompatibility. Use the MUSL target instead:

```bash
zig build -Dtarget=native-native-musl
zig build test -Dtarget=native-native-musl --summary all
```

This is a known issue with C interop on Arch's glibc and does not affect other platforms.

## Acknowledgments

Derived from [ua-parser-js](https://github.com/faisalman/ua-parser-js) (AGPL-3.0) by Faisal Salman. Regex parsing tables are adapted from the original project.

## License

AGPL-3.0 — This project uses regex tables derived from ua-parser-js, which is licensed under AGPL-3.0. As required by the license, this project is also distributed under AGPL-3.0.
