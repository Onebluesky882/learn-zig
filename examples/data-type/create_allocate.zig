const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const string = []const u8;
const ArrayList = std.array_list;
const Child = std.process.Child;
const builtin = @import("builtin");
const print = std.debug.print;

pub fn arena() !void {
    const page_allocator: Allocator = std.heap.page_allocator;
    _ = page_allocator; // autofix

}

// create - one thing
// destroy - frees one thing

//* alloc creates a slice
// alloc → สร้าง “หลายตัว” → Slice
// const numbers = try allocator.alloc(i32, 5);

//* free frees the slice แล้วคืนด้วย:
// allocator.free(numbers);

//* แล้ว Slice คืออะไร? มันคือ pointer + length
// [10][20][30][40][50]

//* ทำไม alloc ถึงเกี่ยวกับ slice?
// เพราะ allocator ไม่รู้ว่าคุณต้องการ object แบบไหน

pub fn getPointer(allocate: Allocator) !*i32 {
    const number: *i32 = try allocate.create(i32);
    number.* = 10;
    return number;
}
