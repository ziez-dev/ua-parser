const std = @import("std");
const ua = @import("ziez_ua_parser");

test "parse - Chrome on Windows"
{
    const result = ua.parse("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36");
    try std.testing.expect(result.browser.name.len > 0);
    try std.testing.expect(result.os.name.len > 0);
}

test "parse - Safari on macOS"
{
    const result = ua.parse("Mozilla/5.0 (Macintosh; Intel Mac OS X 14_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15");
    try std.testing.expect(result.browser.name.len > 0);
}

test "parse - Firefox on Linux"
{
    const result = ua.parse("Mozilla/5.0 (X11; Linux x86_64; rv:121.0) Gecko/20100101 Firefox/121.0");
    try std.testing.expect(result.browser.name.len > 0);
}

test "parse - empty string"
{
    const result = ua.parse("");
    try std.testing.expectEqualStrings("", result.browser.name);
    try std.testing.expectEqualStrings("", result.os.name);
}

test "parse - mobile Android"
{
    const result = ua.parse("Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36");
    try std.testing.expect(result.browser.name.len > 0);
    try std.testing.expect(result.os.name.len > 0);
}

test "parse - curl"
{
    const result = ua.parse("curl/8.4.0");
    // curl may or may not be detected depending on UA database
    _ = result;
}

test "ParseResult has expected fields"
{
    const result = ua.parse("test");
    _ = result.browser.name;
    _ = result.browser.version;
    _ = result.os.name;
    _ = result.os.version;
    _ = result.device.type;
}
