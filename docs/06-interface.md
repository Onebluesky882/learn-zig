# Interface: Go เทียบ Zig

Go มี `interface` เป็น keyword ในตัวภาษา ใช้ structural typing (duck typing แบบมี runtime dispatch)
Zig **ไม่มี keyword `interface` เลย** เพราะเป้าหมายของ Zig คือ "no hidden control flow" —
Go interface มี runtime cost ที่ซ่อนอยู่ (vtable lookup, boxing) ซึ่ง Zig ไม่อยากซ่อนสิ่งนั้นไว้

Zig มี 2 วิธีแทน แล้วแต่ว่าต้องการ runtime polymorphism จริงหรือไม่:

| ต้องการ | วิธีใน Zig | cost |
|---|---|---|
| รู้ type ทั้งหมดตอน compile (เช่น generic function) | `anytype` + comptime duck typing | **0 runtime cost** — compiler generate โค้ดแยกให้แต่ละ type (คล้าย C++ template) |
| ต้องการเก็บ object ต่าง type ไว้ใน list เดียว / เลือก implementation ตอน runtime จริงๆ | Manual vtable (struct + function pointers) | เหมือน Go interface เป๊ะ (pointer indirection ตอนเรียก) |

## 1. กรณีรู้ type ตอน compile — ใช้ `anytype` (เจอบ่อยสุด)

**Go**
```go
type Shape interface {
    Area() float64
}

type Circle struct{ R float64 }
func (c Circle) Area() float64 { return math.Pi * c.R * c.R }

type Square struct{ Side float64 }
func (s Square) Area() float64 { return s.Side * s.Side }

func printArea(s Shape) {
    fmt.Println(s.Area())
}

printArea(Circle{R: 2})
printArea(Square{Side: 3})
```

**Zig**
```zig
const Circle = struct {
    r: f64,
    fn area(self: Circle) f64 {
        return std.math.pi * self.r * self.r;
    }
};

const Square = struct {
    side: f64,
    fn area(self: Square) f64 {
        return self.side * self.side;
    }
};

fn printArea(shape: anytype) void {
    std.debug.print("{d}\n", .{shape.area()});
}

printArea(Circle{ .r = 2 });
printArea(Square{ .side = 3 });
```
> `printArea` ไม่ใช่ function เดียว — compiler จะ **generate function แยกกันคนละตัวสำหรับ `Circle` และ `Square`**
> ตอน compile time (monomorphization เหมือน Rust/C++ generics) ไม่มี vtable ไม่มี pointer indirection เลย
> เร็วกว่า Go interface แต่แลกกับ binary size ที่ใหญ่ขึ้นถ้ามีหลาย type

ข้อจำกัด: **เก็บ `Circle` กับ `Square` ปนกันใน slice/array เดียวกันไม่ได้** เพราะมันคนละ type จริงๆ
(ต่างจาก Go ที่ `[]Shape` เก็บ Circle กับ Square ปนกันได้เลย) — ถ้าต้องการแบบนั้นต้องใช้วิธีที่ 2

## 2. กรณีต้องการ runtime polymorphism จริง — Manual vtable

นี่คือสิ่งที่ Go interface ทำอยู่ "ข้างใน" อยู่แล้วโดยที่คุณไม่เห็น (Go ซ่อน vtable ไว้ให้)
ส่วน Zig ให้คุณเขียน vtable เอง เห็นทุก byte ที่เกิดขึ้นจริง

```zig
const Shape = struct {
    ptr: *anyopaque,
    areaFn: *const fn (ptr: *anyopaque) f64,

    fn area(self: Shape) f64 {
        return self.areaFn(self.ptr);
    }
};

const Circle = struct {
    r: f64,

    fn area(ptr: *anyopaque) f64 {
        const self: *Circle = @ptrCast(@alignCast(ptr));
        return std.math.pi * self.r * self.r;
    }

    fn shape(self: *Circle) Shape {
        return .{ .ptr = self, .areaFn = area };
    }
};

const Square = struct {
    side: f64,

    fn area(ptr: *anyopaque) f64 {
        const self: *Square = @ptrCast(@alignCast(ptr));
        return self.side * self.side;
    }

    fn shape(self: *Square) Shape {
        return .{ .ptr = self, .areaFn = area };
    }
};

pub fn main() void {
    var c = Circle{ .r = 2 };
    var s = Square{ .side = 3 };

    // ตอนนี้เก็บปนกันใน list เดียวได้แล้ว เหมือน Go's []Shape
    const shapes = [_]Shape{ c.shape(), s.shape() };
    for (shapes) |shape| {
        std.debug.print("{d}\n", .{shape.area()});
    }
}
```
> `*anyopaque` คือ pointer ที่ไม่รู้ type (เทียบเท่า `void*` ใน C, หรือ `interface{}`/`any` ใน Go)
> `@ptrCast(@alignCast(ptr))` คือการ cast กลับเป็น type จริง — จุดนี้แหละที่ Go compiler generate ให้เอง
> อัตโนมัติตอนสร้าง interface value แต่ Zig ให้คุณเขียนเอง

Zig standard library เองก็ใช้ pattern นี้ทั่วไป เช่น `std.mem.Allocator` และ `std.Io.Writer`
ก็คือ vtable struct แบบนี้เป๊ะ ๆ (ลอง grep source ของ std ดูได้เป็นตัวอย่างจริง)

## 3. สรุป

- ส่วนใหญ่ในโค้ด Zig จริง **ใช้วิธีที่ 1 (`anytype`) เป็นหลัก** เพราะเร็วกว่าและเขียนง่ายกว่า
- ใช้วิธีที่ 2 (vtable) เฉพาะตอนที่จำเป็นต้องเก็บ type ต่างกันไว้ใน collection เดียวกันจริงๆ
  หรือเลือก implementation ตอน runtime (เช่น plugin system, `Allocator`, `Writer`)
- กฎง่ายๆ ที่ใช้ตัดสินใจ: **"รู้ type ตอน compile ไหม?"** รู้ → `anytype`, ไม่รู้/ต้องเปลี่ยนตอน runtime → vtable

---
กลับไปหน้าแรก: [README](./README.md)
