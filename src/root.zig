pub const ua_parser = @import("ua_parser.zig");
pub const parse = ua_parser.parse;
pub const ParseResult = ua_parser.ParseResult;
pub const BrowserInfo = ua_parser.BrowserInfo;
pub const OsInfo = ua_parser.OsInfo;
pub const DeviceInfo = ua_parser.DeviceInfo;
pub const deviceTypeToString = ua_parser.deviceTypeToString;
