const std = @import("std");

// pointer and a length

pub fn sliceDemo(slice: []const u8) void {
    const slice_length = slice.len;
    std.debug.print("{s} '{s}'\n", .{ "slice :", slice });
    std.debug.print("{s} '{}'\n", .{ "length of slice:", slice_length });
}

pub var chars: [5]u8 = .{ 'h', 'e', 'i', '0', 'u' };
pub const slice_new: []u8 = &chars;

pub fn sliceTest() void {
    slice_new[0] = 'H';
}
