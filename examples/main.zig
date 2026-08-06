const std = @import("std");
const hello = @import("hello-world.zig");
const print = @import("print.zig");
const addNumber = @import("fn/add.zig");
const transform = @import("fn/transform.zig");

pub fn main() !void {
    const add = addNumber.add(45, 45);
    std.debug.print("{s} {}\n", .{ "result", add });

    var buffer: [32]u8 = undefined;

    const result = try transform.itoa(1234, &buffer);
    std.debug.print("{s} {s}\n", .{ "convert to number", result });

    print.printString("hello");
    try hello.hello();

    hello.hello() catch |err| {
        std.debug.print("error :{}\n", .{err});
    };
}
