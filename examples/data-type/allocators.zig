const std = @import("std");
const Allocator = std.mem.Allocator;

//* ___PAGE_Allocator_____
// this allocator will make a system call every time you want to allocate and free
// so it's slow but more reliable

//* ___FIXED BUFFER Allocator_____
// will not allocate on the heap. if you know the amount
// of data complie time and want to be efficient, use this allocator.

//* ___ARENA_Allocator_____
// this is allows you to allocate memory multiple times and then free it.
// all at once.

//* ___DEBUG Allcator_____
// this is the safest allocator and has lots of safety for double

// Allocator              คิดว่าเป็นอะไร               ใช้เมื่อ
// PageAllocator          ขอ memory จาก OS          memory ก้อนใหญ่ / low-level
// * PageAllocator = “ขอ memory จาก OS โดยตรง”

// FixedBufferAllocator   มี buffer เตรียมไว้แล้ว       รู้ขนาด / predictable
// * FixedBufferAllocator = “ฉันมี memory ก้อนนี้ให้แล้ว ใช้เท่านี้ ห้ามเกิน” เหมาะกับเกม frame data
// ArenaAllocator         สร้างเยอะ แล้วทิ้งทีเดียว        request / parsing / AST
// *ArenaAllocator  ใช้บ่อยมากสำหรับงานที่มี object จำนวนมากและมี lifetime
// DebugAllocator         สำหรับนักพัฒนา debug.         development / งานทั่วไป

// * Allocator ไม่ใช่ Heap
// Allocator คือ เครื่องมือสำหรับจัดการ memory บน memory source ที่มันได้รับ/จัดการ

//------------------- Stack -------------------
//*  Stack ใช้กับสิ่งที่มี lifetime ผูกกับ function/scope
// เข้า test()
//       ↓
// ┌──────────────┐
// │ number = 10  │
// └──────────────┘
//       ↓
// ออกจาก test()
//       ↓
//* memory ของ local หมด lifetime เพราะ number เป็น local variable

//------------------- heap -------------------
//* Heap ใช้สำหรับ memory ที่เราต้องการให้ มี lifetime แยกออกจาก function
fn globalVarriable(allocator: std.mem.Allocator) !*i32 {
    const ptr = try allocator.create(i32);
    return ptr;
}

// const pointer compile time  stateless
// COMPLIE ข้อมูลที่ compiler รู้ล่วงหน้า สามารถคำนวณ / ตรวจสอบ / สร้าง code ได้
// RUNTIME  "ข้อมูลที่เกิดขึ้นขณะ program ทำงาน" มี state ของ program
pub fn getPointer() *const i32 {
    const number: i32 = 10;
    return &number;
}

//  เก็บ function เป็น function pointer
//  funtion ธรรมดา กับ funtion pointer ต่างกันอย่างไ ร
// * Function ธรรมดา
fn add(a: i32, b: i32) i32 {
    return a + b;
}
fn multiply(a: i32, b: i32) i32 {
    return a * b;
}

// เวลาเรียก
const result = add(10, 20);

//* Function pointer
// ความแตกต่างที่สำคัญ

fn multiFn() void {
    var operation: *const fn (i32, i32) i32 = &add;

    const result1 = operation(10, 20);

    // สามารถเปลี่ยน ฟังชั่นได้ หาก output type เดียวกัน
    // จำนวน arguments ต้องเท่ากันด้วย
    operation = &multiply;

    const result2 = operation(10, 20);
    std.debug.print("{d}\n", .{result1});

    std.debug.print("{d}\n", .{result2});
}

// struct
const MyAllocator = struct {
    const Self = @This();
    
    fn alloc(
        context: *anyopaque,
        len: usize,
        alignment: std.mem.Alignment,
        return_address: usize,
    ) ?[*]u8 {
        _ = context;

        _ = len;

        _ = alignment;

        _ = return_address;

        return null;
    }

    fn resize(
        context: *anyopaque,
        memory: []u8,
        alignment: std.mem.Alignment,
        new_len: usize,
        return_address: usize,
    ) bool {
        _ = context;

        _ = memory;

        _ = alignment;

        _ = new_len;

        _ = return_address;

        return false;
    }

    fn free(
        context: *anyopaque,
        memory: []u8,
        alignment: std.mem.Alignment,
        return_address: usize,
    ) void {
        _ = context;

        _ = memory;

        _ = alignment;

        _ = return_address;
    }

    fn remap(
        context: *anyopaque,
        memory: []u8,
        alignment: std.mem.Alignment,
        new_len: usize,
        return_address: usize,
    ) ?[*]u8 {
        _ = context;

        _ = memory;

        _ = alignment;

        _ = new_len;

        _ = return_address;

        return null;
    }

    pub fn allocatorSelf(self: *Self) Allocator {
        return .{
            .ptr = self,

            .vtable = &.{
                .remap = remap,

                .alloc = alloc,

                .resize = resize,

                .free = free,
            },
        };
    }
};
