const std = @import("std");

// * comptime เข้ามาทำอะไร?

// fn createNumber(comptime T: type) T {
//     return 10;
// }
// T ต้องรู้ตอน compile time และ T เป็น type  ดังนั้น function กลายเป็น conceptually:
//* fn createNumber(i32) i32 {}

// ทำไมต้อง comptime?
// เพราะ compiler ต้องรู้ return type ก่อน compile
fn zero(comptime T: type) T {
    return 0;
}

const a = zero(i32);

const b = zero(f32);

const c = zero(u64);

// * สรุป  comptime = “สิ่งนี้ต้องถูกกำหนด/คำนวณให้รู้ก่อน runtime”
// หมายถึง type ที่ต้องการ return สิ่งที่ต้องรู้/คำนวณได้ตอน compile time 
// comptime ใช้กับ value คำนวณได้ด้วย


//              Zig

//                │

//        ┌───────┴────────┐

//        │                │

//     runtime          comptime

//        │                │

//  data / state       types / values

//                          │

//                          ▼

//                         type

//                          │

//                    comptime T: type

//                           │

//                           ▼

//                     generic function
