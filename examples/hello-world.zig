const std = @import("std");
pub fn hello() !void {
    std.debug.print("hello world {} {} {}\n", .{ 10, 20, 30 });
}
// ใช้ try or catch

// ! ใช้ try เป็นค่าเริ่มต้น
//  try hello.hello();

// ! และใช้ catch เมื่อคุณ ต้องการจัดการ error ที่จุดนั้น

// hello.hello() catch |err| {
//     std.debug.print("error :{}\n", .{err});
// };
