const std = @import("std");

// * Step 1 — สร้าง Allocator ฝึกตอนนี้ใช้ DebugAllocator
//  var debug_allocator = std.heap.DebugAllocator(.{}){};

// * Step 2 — init / เอา allocator ออกมา
// const allocator = debug_allocator.allocator();

// * Step 3 — เปิดไฟล์
// var file = try std.fs.cwd().openFile("example.txt", .{.mode = .read_only});

// * Step 4 — อ่านไฟล์
// const content = try file.readToEndAlloc( allocator,1024 * 1024);

// * step 5 — ใช้ข้อมูล
// std.debug.print("{s}\n", .{content});

// * Step 6 — คืน memory
// defer allocator.free(content);

// * Step 7 — ปิด DebugAllocator
// defer _ = debug_allocator.deinit();


// const allocator = debug_allocator.allocator(); คือ ขอ  allocator interface 
// DebugAllocator = Allocator + เครื่องมือช่วยตรวจสอบ


pub fn openFile() !void {
    // 1. Create allocator
    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer _ = debug_allocator.deinit();

    // 2. Get allocator
    const allocator = debug_allocator.allocator();

    // 3. Open file
    var file = try std.fs.cwd().openFile("example.txt", .{
        .mode = .read_only,
    });
    defer file.close();

    // 4. Read entire file
    const content = try file.readToEndAlloc(
        allocator,
        1024 * 1024,
    );
    defer allocator.free(content);

    // 5. Use data
    std.debug.print("{s}\n", .{content});
}
