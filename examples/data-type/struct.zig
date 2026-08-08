const std = @import("std");

// ! enum type != string

pub const JobType = enum { Doctor, Lawyer, Receptionist, Teacher, Scientist };

pub const User = struct {
    name: []const u8, // field
    age: usize, // field
    occupation: JobType,
    address: Address,

    const Secret = struct { id: []const u8 = "secret key" }; // private type

    pub const Address = struct { // public type
        city: []const u8,
    };

    fn privateFn(self: User) void {
        _ = self; // autofix
    }

    pub fn print(self: *const User) void {
        _ = self; // autofix
    }
};

// * @This() ใน Zig คือ builtin ที่คืน type ปัจจุบัน

// * @This() คือ “type ที่ฉันกำลังอยู่ข้างในตอนนี้”

// pub const User = struct {

//     name: []const u8,

//     age: usize,

//     pub fn print(self: *@This()) void {}

// };

//? ---------------------- union ----------------------------

// * ใช้ union เมื่อคุณต้องการให้ ข้อมูลหนึ่งก้อนสามารถเป็นได้หลาย type/หลายรูปแบบ
// * แต่ ณ เวลาเดียวกันใช้เพียงแบบเดียว และต้องการประหยัด memory
// ! union(enum) ≈ switch case ที่แต่ละ case สามารถมีข้อมูลของตัวเองติดมาด้วย

const Result = union(enum) {
    success: []const u8,
    not_success: []const u8,
};

pub fn unionFn() void {
    const success_message: Result = .{
        .success = "Hello",
    };

    switch (success_message) {
        .success => |message| {
            std.debug.print("Success: {s}\n", .{message});
        },

        .not_success => |message| {
            std.debug.print("Error: {s}\n", .{message});
        },
    }
}
