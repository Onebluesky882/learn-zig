const std = @import("std");


//* orelse ใน Zig ใช้กับ Optional (?T) โดยความหมายง่าย ๆ คือ:
//* ถ้ามีค่า → ใช้ค่านั้น / ถ้าเป็น null → ใช้ค่าที่กำหนดไว้แทน

// *  function ต้องการ return แบบ Optional 

// fn functionName() ?T {
//     ...
// }

// ?t
// ?i32
// ?[]const u8
// return null

//javascript  const result = value ?? defaultValue;
//zig         const result = value orelse defaultValue;
// javascript const result = value ? true : false;
fn fidnStudent(student: []const u8) ?u8 {
    for (student) |value| {
        if (value == 'g') {
            return value;
        }
    }
    return null;
}

// student[0..]  → Slice
// &student  → Pointer to Array
pub fn optionalCondition() void {
    const student: [5]u8 = .{ "a", "b", "c", "d" };
    const result = fidnStudent(&student);
    if (result) |value| {
        std.debug.print("found {c}\n", .{value});
    } else |err| {
        std.debug.print("Not found : {} \n", .{err});
    }
}

