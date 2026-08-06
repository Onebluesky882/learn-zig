const std = @import("std");

pub fn itoa(num: i32, buffer: []u8) ![]u8 {
    return try std.fmt.bufPrint(buffer, "{}", .{num});
}
