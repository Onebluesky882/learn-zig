# Zig สำหรับคนที่มาจาก Go

เอกสารชุดนี้เทียบ syntax และแนวคิดของ Zig กับ Go แบบคู่กัน (side-by-side)
เพื่อให้คนที่คุ้นเคยกับ Go อยู่แล้วเรียนรู้ Zig ได้เร็วขึ้น

## สารบัญ

1. [Loop](./01-loops.md) — for / while / range
2. [Memory](./02-memory.md) — GC vs Allocator
3. [Concurrency](./03-concurrency.md) — Goroutine vs Thread
4. [Data Type](./04-data-types.md) — primitive / string / struct / error
5. [Map / Array / Lookup](./05-collections.md) — slice / ArrayList / HashMap
6. [Interface](./06-interface.md) — interface vs anytype / vtable
7. [Function](./07-functions.md) — multiple return / closure / generic / variadic
8. [pub / Visibility](./08-visibility.md) — public/private เทียบ Go

## ปรัชญาหลักที่ต่างกัน (สรุปสั้นๆ)

| เรื่อง | Go | Zig |
|---|---|---|
| Memory | มี GC จัดการให้อัตโนมัติ | ไม่มี GC — ต้องขอ/คืน memory เองผ่าน allocator |
| Concurrency | มี goroutine + channel ในตัวภาษา | ไม่มี green thread ในตัวภาษา ใช้ OS thread (`std.Thread`) ตรงๆ |
| Error handling | คืนค่า `error` เป็นค่าที่สอง, เช็คด้วย `if err != nil` | มี error union type (`!T`) และ `try`/`catch` ในตัวภาษา |
| Compile-time | ไม่มี generics แบบ compile-time metaprogramming (มี generics แบบจำกัดตั้งแต่ 1.18) | มี `comptime` ที่ทรงพลังมาก ใช้แทน generics และ macro ได้ |
| Runtime | มี runtime + scheduler ของ goroutine | แทบไม่มี runtime, compile ไปเป็นเครื่องจริงตรงๆ (คล้าย C) |

แนวคิดสำคัญที่สุดที่ต้องปรับ mindset: **Go ซ่อนความซับซ้อนของ memory และ concurrency ไว้ให้ runtime จัดการ
ส่วน Zig ให้ผู้เขียนโค้ดควบคุมและรับผิดชอบเองทั้งหมด แลกกับ performance และความสามารถในการคาดเดาพฤติกรรมได้แม่นยำ**
