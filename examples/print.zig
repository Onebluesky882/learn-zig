const std = @import("std");

pub fn printString(input: []const u8) void {
    std.debug.print("{s}\n", .{input});
}

// ! parameter ต้อง ใส่ ใน args

// นี่เป็นแนวคิดที่สำคัญที่สุดอย่างหนึ่งของ Zig

// สรุปสั้น ๆ คือ

// * void = ฟังก์ชัน ไม่มีทางคืนค่า error
// * !void = ฟังก์ชัน อาจคืนค่า error ได้

// ! กฎง่าย ๆ ของ Zig คือ

// ถ้าฟังก์ชันไม่มีทางล้มเหลว ใช้ void

// ถ้า มี (เช่น I/O, Network, Memory allocation, Parsing, การตรวจสอบข้อมูล) →
// ใช้ !void หรือ !T แล้วให้ผู้เรียกเลือกว่าจะ try ส่งต่อ หรือ catch จัดการ error เอง

// !  Wrapper สำหรับพิมพ์ข้อความธรรมดา ที่รู้อยู่แล้วว่า จะใส่อะไรก่อน comptime
// * มักเป็น การ log print status ข้อดีคือไว
// pub fn info(comptime fmt: []const u8, args: anytype) void {

//     std.debug.print("[INFO] " ++ fmt, args);

// }

// ! Runtime String
// pub fn printString(msg: []const u8) void {
//     std.debug.print("{s}\n", .{msg});
// }

// const name = "John";
// printString(name);
