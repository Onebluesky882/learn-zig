# Memory: Go (GC) เทียบ Zig (Allocator)

นี่คือความต่างที่ใหญ่ที่สุดระหว่างสองภาษา

**Go**: มี Garbage Collector (GC) ทำงานอยู่เบื้องหลังตลอดเวลา เขียน `new(T)` หรือ `make([]T, n)`
แล้วไม่ต้องคิดเรื่องคืน memory เลย GC จะตามเก็บให้เอง

**Zig**: **ไม่มี GC**, ไม่มี hidden allocation ใดๆ ทั้งสิ้น ทุกจุดที่มีการขอ memory (heap) จะต้อง
"ขอผ่าน allocator ที่ส่งเข้ามาเอง" อย่างชัดเจน แล้วก็ต้อง "คืนเองด้วย" — ปรัชญาคือ "no hidden control flow, no hidden allocations"

## 1. สร้างตัวแปรเดี่ยวบน heap

**Go**
```go
p := new(int)   // heap allocate, GC ดูแลให้
*p = 42
```

**Zig**
```zig
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
defer _ = gpa.deinit();
const allocator = gpa.allocator();

const p = try allocator.create(i32); // ขอ memory ผ่าน allocator
defer allocator.destroy(p);          // ต้องคืนเองด้วย defer
p.* = 42;
```
> `try` เพราะ `create` อาจ fail (OutOfMemory) — Zig บังคับให้ handle error ตรงนี้เสมอ
> `defer allocator.destroy(p)` คือ pattern มาตรฐาน: "ขอบรรทัดไหน คืนบรรทัดถัดไปด้วย defer ทันที"

## 2. Slice / dynamic array

**Go**
```go
s := make([]int, 0, 10)
s = append(s, 1, 2, 3) // runtime โต growable array ให้เอง, GC คืน memory เก่าให้
```

**Zig** — ใช้ `std.ArrayList` (คล้าย Go slice แบบ growable) แต่ต้องผูก allocator เข้าไปเอง
```zig
var list = std.ArrayList(i32).init(allocator);
defer list.deinit(); // ต้องสั่งคืน memory เองตอนเลิกใช้

try list.append(1);
try list.append(2);
try list.append(3);
```

## 3. Allocator หลักๆ ที่ควรรู้จัก (Go ไม่มีสิ่งนี้เพราะมันมี GC ตัวเดียวตายตัว)

| Allocator | ใช้เมื่อไหร่ | เทียบกับ Go |
|---|---|---|
| `std.heap.GeneralPurposeAllocator` (GPA) | general purpose, ดี debug (จับ leak/double-free) | ใกล้เคียงพฤติกรรม default ของ Go มากสุด แต่ต้อง `deinit` เอง |
| `std.heap.ArenaAllocator` | ขอเยอะๆ แล้ว "คืนทีเดียวทั้งหมด" ท้าย scope | เหมือน pattern "request-scoped allocation" ที่ Go ทำผ่าน GC โดยอัตโนมัติ |
| `std.heap.page_allocator` | ขอตรงจาก OS เป็นหน้าๆ | ไม่มีเทียบตรงใน Go (runtime จัดการชั้นนี้ให้หมด) |
| `std.testing.allocator` | ใช้ใน unit test เท่านั้น จะ panic ถ้า leak | คล้าย `go test -race`/leak detector แต่เข้มกว่า |

ตัวอย่าง Arena — pattern ที่ใช้บ่อยมากใน Zig สำหรับ request/task ที่มีอายุสั้น:
```zig
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit(); // คืนทุก allocation ที่เกิดใน arena นี้ "ทีเดียว" ไม่ต้องไล่ free ทีละอัน
const allocator = arena.allocator();

const a = try allocator.alloc(u8, 100);
const b = try allocator.alloc(u8, 200);
_ = a;
_ = b;
// ไม่ต้อง free ทีละตัว — arena.deinit() ข้างบนจัดการหมด
```

## 4. สรุป mindset ที่ต้องปรับ

- ใน Go ฟังก์ชันไม่ต้องรับ allocator เป็น parameter เพราะ GC เป็น global service
- ใน Zig **ฟังก์ชันที่ต้อง allocate memory ควรรับ `allocator: std.mem.Allocator` เป็น parameter เสมอ**
  (เหมือน dependency injection) เพื่อให้ผู้เรียกเลือกได้ว่าจะใช้ allocator แบบไหน (GPA, arena, fixed buffer ฯลฯ)
- กฎทองคือ **"ใครขอ (`alloc`/`create`), คนนั้นต้องคืน (`free`/`destroy`) — และควรเขียน `defer` คู่กันทันทีที่ขอเสร็จ"**

---
ต่อไป: [Concurrency — Goroutine vs Thread](./03-concurrency.md)
