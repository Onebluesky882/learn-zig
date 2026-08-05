# Map / Array / Lookup: Go เทียบ Zig

## 1. Fixed-size array

**Go** — array แบบ fixed size ใน Go แทบไม่ค่อยถูกใช้ตรงๆ (คนมักใช้ slice แทน) เพราะ pass by value ทั้ง array
```go
var arr [5]int
arr[0] = 1

arr2 := [3]int{1, 2, 3}
```

**Zig** — array เป็น value type เหมือนกัน แต่ขนาดเป็นส่วนหนึ่งของ type จริงๆ (`[5]i32` คือคนละ type กับ `[3]i32`)
```zig
var arr: [5]i32 = undefined;
arr[0] = 1;

const arr2 = [3]i32{ 1, 2, 3 };
// หรือให้ compiler นับให้เอง
const arr3 = [_]i32{ 1, 2, 3 };
```
> `undefined` คือค่าที่บอก compiler ว่า "ยังไม่ init ตอนนี้ อย่าเสียเวลา zero มันให้" — Go ไม่มี concept นี้
> (Go zero-init ให้เสมอแบบไม่มีทางเลือก ส่วน Zig ให้เลือกได้ว่าจะ pay cost การ init หรือไม่)

## 2. Slice (dynamic-length view)

**Go** — slice คือ (pointer, len, cap) และ `append` จะจัดการ realloc/grow ให้อัตโนมัติผ่าน GC
```go
s := []int{1, 2, 3}
s = append(s, 4)          // อาจ realloc ข้างใน ไม่ต้องยุ่งเรื่อง memory เอง
sub := s[1:3]              // sub-slice, share memory เดิม
```

**Zig** — แยกชัดเจนระหว่าง 2 concept ที่ Go มัดรวมกันไว้ใน slice เดียว:
- `[]T` = slice แบบ **fixed length, view เข้า memory ที่มีอยู่แล้ว** (ไม่โตเองได้ ไม่มี allocator ผูกอยู่)
- `std.ArrayList(T)` = dynamic array ที่โตได้จริง (เทียบเท่า Go slice + append) — ต้องผูก allocator เอง (ดู [Memory doc](./02-memory.md))

```zig
// slice ธรรมดา — แค่ "มองเห็น" memory ที่มีอยู่ ไม่โตเอง
const arr = [_]i32{ 1, 2, 3 };
const s: []const i32 = &arr;
const sub = s[1..3]; // sub-slice แบบเดียวกับ Go, share memory เดิม

// ต้องการ append/โตได้จริง ต้องใช้ ArrayList
var list = std.ArrayList(i32).init(allocator);
defer list.deinit();
try list.append(4);
```
> คนที่มาจาก Go มักงงตรงนี้ที่สุด: **`[]T` ใน Zig ไม่ใช่ตัวเดียวกับ Go slice**
> Go slice = Zig's `ArrayList` (โตได้) ไม่ใช่ Zig's `[]T` (fixed view เฉยๆ)

## 3. Map / Lookup table

**Go** — มี `map` เป็น built-in type ในตัวภาษา ใช้ `[key]` เข้าถึงได้ตรงๆ
```go
m := make(map[string]int)
m["a"] = 1
v, ok := m["a"]   // ok บอกว่ามี key นี้จริงไหม
delete(m, "a")

for k, v := range m {
    fmt.Println(k, v)
}
```

**Zig** — ไม่มี `map` syntax ในตัวภาษา ใช้ `std.HashMap` / `std.StringHashMap` (ตัวช่วยสำเร็จรูปสำหรับ key เป็น string) จาก std lib แทน ต้องผูก allocator เหมือนกัน
```zig
var m = std.StringHashMap(i32).init(allocator);
defer m.deinit();

try m.put("a", 1);

if (m.get("a")) |v| {
    std.debug.print("{d}\n", .{v});
}
_ = m.remove("a");

var it = m.iterator();
while (it.next()) |entry| {
    std.debug.print("{s} {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
}
```
> `m.get("a")` คืน `?i32` (optional) ไม่ใช่ `(value, ok)` สองค่าแบบ Go —
> ต้องใช้ `if (m.get("a")) |v| { ... }` เพื่อ unwrap ค่าออกมาแบบ null-safe
> (concept เดียวกับ Go's `v, ok := m["a"]` แต่ Zig ใช้ optional type แทน tuple)

ถ้า key เป็น type อื่นที่ไม่ใช่ string ต้องใช้ `std.AutoHashMap(KeyType, ValueType)` แทน (Zig สร้าง hash/eql function ให้อัตโนมัติสำหรับ type พื้นฐาน):
```zig
var m2 = std.AutoHashMap(i32, []const u8).init(allocator);
defer m2.deinit();
try m2.put(1, "one");
```

## 4. สรุปตารางเทียบ

| ต้องการ | Go | Zig |
|---|---|---|
| Array ขนาดคงที่ | `[N]T` | `[N]T` |
| View เข้า memory (อ่าน/แก้ ไม่โต) | `[]T` (slice) | `[]T` (slice) |
| Array ที่โตได้ (append) | `[]T` + `append()` | `std.ArrayList(T)` |
| Map ทั่วไป | `map[K]V` | `std.AutoHashMap(K, V)` |
| Map ที่ key เป็น string | `map[string]V` | `std.StringHashMap(V)` |
| เช็คว่ามี key ไหม | `v, ok := m[k]` | `m.get(k)` คืน `?V` |

---
กลับไปหน้าแรก: [README](./README.md)
