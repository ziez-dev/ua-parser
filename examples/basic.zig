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
