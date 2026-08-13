const std = @import("std");
const hello = @import("hello-world.zig");
const print = @import("print.zig");
const addNumber = @import("fn/add.zig");
const transform = @import("fn/transform.zig");
const slice = @import("data-type/slice.zig");
const array = @import("data-type/array.zig");
const pointer = @import("data-type/pointer.zig");
const User = @import("data-type/struct.zig");
const unionFn = @import("data-type/struct.zig").unionFn;
const loop = @import("data-type/for_loop.zig");
const errorHandle = @import("data-type/error_handle.zig");

fn debugPrint(comptime string: []const u8, arg: anytype) void {
    std.debug.print(string, arg);
}

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

    const slice_array: []i32 = array.getSlice();
    slice_array[1] = 8;
    std.debug.print("{s} {any}\n", .{ "array[0] : ", slice_array });

    // pointer
    pointer.pointerTest();
    std.debug.print("{p}\n", .{pointer.ptr}); // address
    std.debug.print("{}\n", .{pointer.ptr.*}); // value = 1

    //slice Demo
    const sliceDemo: []const u8 = "string literal here";
    slice.sliceDemo(sliceDemo);
    slice.sliceTest();
    debugPrint("slice : {s} \n", .{slice.slice_new});

    // struct type

    const user: User.User = .{ .name = "John", .age = 12, .occupation = User.JobType.Doctor, .address = .{ .city = "Nan" } };

    debugPrint("struct : {any}\n", .{user});
    debugPrint("name : {s}\n", .{user.name});
    debugPrint("age : {}\n", .{user.age});
    debugPrint("enum job : {}\n", .{user.occupation});
    debugPrint("tagName : {s}\n", .{@tagName(user.occupation)});
    debugPrint("address : {s}\n", .{user.address.city});

    user.print();

    // union
    unionFn();

    // for loop
    loop.forLoop();

    loop.whileLoop();

    loop.openPages();

    // error_handle
    errorHandle.errorHandle() catch |err| {
        debugPrint("\t {} \n", .{err});
    };
}
