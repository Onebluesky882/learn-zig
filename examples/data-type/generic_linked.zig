const std = @import("std");

// LinkedList() คือ function ที่รับ Type เข้าไป แล้วสร้าง Type ใหม่ออกมา
// function
//      ↓
// รับ type ตอน compile time
//      ↓
//  สร้าง type
//      ↓
//  return type

// ใช้เพื่ออะไร  — หลัก ๆ คือ ทำให้ Linked List ตัวเดียวรองรับข้อมูลหลายชนิด โดยไม่ต้องเขียนโค้ดซ้ำ

// เราเขียนครั้งเดียว

//           LinkedList(T
//
//     ┌──────────┼──────────
//     ↓          ↓
//  i32          User      strin
//     ↓          ↓
// IntList     UserList   StringList

fn Node(comptime T: type) type {
    return struct {
        data: T,

        next: ?*Node(T),
    };
}

const IntNode = Node(i32);

const FloatNode = Node(f64);

const StringNode = Node([]const u8);

fn linkedList(comptime T: type) type {
    return struct {
        source_node: ?*Node(T),
    };
}
