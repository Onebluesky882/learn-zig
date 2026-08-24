const std = @import("std");

const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn arrayList(allocator: Allocator) !void {
    var list = try ArrayList(i32).initCapacity(allocator, 10);
    defer list.deinit(allocator);

    try list.append(allocator, 10);
    try list.append(allocator, 20);
    try list.append(allocator, 30);

    for (list.items) |number| {
        std.debug.print(" number :{}\n ", .{number});
    }
}

