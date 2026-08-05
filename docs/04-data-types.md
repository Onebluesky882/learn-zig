# Data Type: Go เทียบ Zig

## 1. Primitive types

| Go | Zig | หมายเหตุ |
|---|---|---|
| `int8`,`int16`,`int32`,`int64` | `i8`,`i16`,`i32`,`i64` | ชื่อคล้ายกันแค่สลับ int↔i |
| `uint8`(`byte`),`uint16`,`uint32`,`uint64` | `u8`,`u16`,`u32`,`u64` | เหมือนกัน |
| `int`, `uint` | `isize`, `usize` | ขนาดตาม pointer ของเครื่อง (แต่ต่างจาก Go ตรงที่ Zig ใช้ `usize` เพื่อ index/size โดยเฉพาะ) |
| ไม่มี arbitrary-width int | `i3`, `u7`, `u24`, ... ได้ทุกความกว้างบิต | Zig กำหนดความกว้าง bit เองได้เป๊ะๆ เช่น `u1` (1 บิต) ใช้ทำ bit-packed struct |
| `float32`, `float64` | `f16`,`f32`,`f64`,`f80`,`f128` | Zig มีให้เลือกละเอียดกว่า |
| `bool` | `bool` | เหมือนกัน |
| `string` (immutable, UTF-8, มี built-in type) | ไม่มี `string` type จริงๆ ใช้ `[]const u8` แทน | ข้อต่างสำคัญ ดูหัวข้อ 3 |
| `rune` (alias ของ `int32`) | `u21` (ใช้แทน unicode codepoint เวลา decode UTF-8) | ไม่มี alias ชื่อ rune ให้ ต้องเขียน `u21` ตรงๆ |
| `error` (interface) | error set (`error{Foo,Bar}`) + error union (`!T`) | ต่างกันมากในเชิง type system ดู [Error handling] ด้านล่าง |

## 2. ตัวแปรและ constant

**Go**
```go
var x int = 10
y := 20        // infer type
const Pi = 3.14
```

**Zig**
```zig
var x: i32 = 10;      // mutable
const y = 20;         // immutable โดย default! ต่างจาก Go ที่ := เป็น mutable
const Pi: f64 = 3.14;
```
> **จุดต่างสำคัญที่สุด**: Zig แยก `var` (แก้ไขได้) กับ `const` (แก้ไขไม่ได้) ชัดเจนตั้งแต่ประกาศ
> และ **แนะนำให้ใช้ `const` เป็นค่า default เสมอ** ต่างจาก Go ที่ `:=` ปกติจะ mutable ทั้งหมด

## 3. String — ความต่างที่ทำให้งง

Go มี `string` เป็น type สำเร็จรูป (immutable, มี `len()`, บวกกันด้วย `+` ได้)

Zig **ไม่มี string type** เลย สิ่งที่เรียกว่า "string" ใน Zig คือ `[]const u8`
(slice ของ byte ที่ไม่ให้แก้ไข) — เป็นแค่ convention ไม่ใช่ type พิเศษ

**Go**
```go
s := "hello"
s2 := s + " world"
fmt.Println(len(s))
```

**Zig**
```zig
const s: []const u8 = "hello";       // string literal คือ *const [5:0]u8 ที่ coerce เป็น []const u8 ได้
const s2 = try std.fmt.allocPrint(allocator, "{s} world", .{s}); // ต้องต่อ string ผ่าน allocator
defer allocator.free(s2);
std.debug.print("{d}\n", .{s.len});
```
> ผลคือ: **การต่อ string ใน Zig ต้องคิดเรื่อง memory เสมอ** (ต่างจาก Go ที่ `+` ซ่อน allocation ไว้หลัง GC)

## 4. Struct

โครงสร้างคล้ายกันมาก แต่ Zig ผูก method เข้ากับ struct ได้ตรงๆ ในตัว (ไม่ต้องแยก receiver แบบ Go)

**Go**
```go
type Point struct {
    X, Y int
}

func (p Point) Sum() int {
    return p.X + p.Y
}
```

**Zig**
```zig
const Point = struct {
    x: i32,
    y: i32,

    fn sum(self: Point) i32 {
        return self.x + self.y;
    }
};
```
> Zig ไม่มี exported/unexported ผ่านตัวพิมพ์ใหญ่-เล็กเหมือน Go (`Point` vs `point`) แต่ใช้ `pub` แทน
> เช่น `pub const Point = struct { ... }` ถ้าอยากให้ file อื่น import ไปใช้ได้

## 5. Interface เทียบ Zig (จุดต่างเชิง design มากที่สุด)

Go มี `interface` เป็น structural typing (duck typing) ในตัวภาษาเลย

Zig **ไม่มี interface keyword** ใช้ 2 แนวทางแทน:
1. `comptime` + duck typing (ถ้ารู้ type ตอน compile) — เร็วสุด ไม่มี runtime cost
2. Manual vtable (struct ที่เก็บ `*anyopaque` + function pointers) — ถ้าต้องการ runtime polymorphism จริงๆ (เหมือนที่ Go interface ทำภายใน)

**Go**
```go
type Shape interface {
    Area() float64
}

type Circle struct{ R float64 }
func (c Circle) Area() float64 { return math.Pi * c.R * c.R }

func printArea(s Shape) {
    fmt.Println(s.Area())
}
```

**Zig (แบบ comptime duck typing — เหมาะเมื่อรู้ type ตอน compile)**
```zig
const Circle = struct {
    r: f64,
    fn area(self: Circle) f64 {
        return std.math.pi * self.r * self.r;
    }
};

fn printArea(shape: anytype) void {
    std.debug.print("{d}\n", .{shape.area()});
}
```
> `anytype` คือ generic parameter ที่ resolve ตอน compile-time — ไม่มี runtime dispatch cost เลย
> ต่างจาก Go interface ที่มี runtime cost จากการเก็บ type info + vtable ไว้ใน interface value

## 6. Error handling — ต่างกันสุดขั้ว

**Go**: error คือ "แค่ค่าปกติ" ที่คืนมาเป็นตัวที่สอง ต้องเช็คเอง ลืมเช็คได้ (compiler ไม่บังคับ)
```go
f, err := os.Open("file.txt")
if err != nil {
    return err
}
defer f.Close()
```

**Zig**: error เป็นส่วนหนึ่งของ type system จริงๆ ผ่าน "error union" (`!T`)
compiler **บังคับ**ให้ handle (จะ propagate ผ่าน `try` หรือจับด้วย `catch` เท่านั้น ลืมไม่ได้)
```zig
const f = try std.fs.cwd().openFile("file.txt", .{});
defer f.close();
```
> `try expr` คือ syntax sugar ของ `expr catch |err| return err` — สั้นกว่า Go's `if err != nil` มาก
> และคอมไพเลอร์ error ทันทีถ้าเรียกฟังก์ชันที่คืน error union แล้วไม่ได้ `try`/`catch`

---
ต่อไป: [Map / Array / Lookup](./05-collections.md)
