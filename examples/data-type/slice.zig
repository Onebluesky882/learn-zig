const std = @import("std");

// pointer and a length

pub fn sliceDemo(slice: []const u8) void {
    const slice_length = slice.len;
    std.debug.print("{s} '{s}'\n", .{ "slice :", slice });
    std.debug.print("{s} '{}'\n", .{ "length of slice:", slice_length });
}
