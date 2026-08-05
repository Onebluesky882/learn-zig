# Function: Go เทียบ Zig

## 1. ประกาศ function พื้นฐาน

**Go**
```go
func add(a int, b int) int {
    return a + b
}
```

**Zig**
```zig
fn add(a: i32, b: i32) i32 {
    return a + b;
}
```
> โครงสร้างคล้ายกันมาก ต่างแค่ keyword (`func` → `fn`) และ Zig ใส่ `:` คั่นชื่อ-type ของ parameter เสมอ
> (Go ก็ทำได้เหมือนกันถ้า type ต่างกัน แต่ Zig บังคับเขียนแบบนี้เท่านั้น ไม่มี syntax ย่อแบบ `a, b int`)

## 2. คืนค่าหลายตัว (Multiple return values) — จุดต่างสำคัญ

Go มี multiple return value เป็น feature หลักของภาษา ใช้บ่อยมากโดยเฉพาะคู่กับ error

**Go**
```go
func divide(a, b int) (int, error) {
    if b == 0 {
        return 0, errors.New("divide by zero")
    }
    return a / b, nil
}

result, err := divide(10, 2)
```

**Zig ไม่มี multiple return value** ใช้ 2 วิธีแทน:

**วิธีที่ 1 — error union (`!T`)** เหมาะกับ pattern "ค่า หรือ error" แบบเดียวกับ Go's `(T, error)`
```zig
fn divide(a: i32, b: i32) !i32 {
    if (b == 0) return error.DivideByZero;
    return @divTrunc(a, b);
}

const result = try divide(10, 2);
```
> นี่คือ **การแทนที่ตรงตัวของ `(T, error)` ใน Go** — สั้นกว่าและ compiler บังคับ handle เสมอ (ดู [04-data-types.md](./04-data-types.md#6-error-handling--ต่างกันสุดขั้ว))

**วิธีที่ 2 — คืนค่าเป็น struct** เหมาะเมื่อต้องการคืนหลายค่าที่ไม่ใช่ error pattern
```go
// Go
func minMax(nums []int) (int, int) {
    // ...
    return min, max
}
mn, mx := minMax(nums)
```
```zig
// Zig
const MinMax = struct { min: i32, max: i32 };

fn minMax(nums: []const i32) MinMax {
    // ...
    return .{ .min = mn, .max = mx };
}

const result = minMax(nums);
// result.min, result.max
```
> `.{ .min = mn, .max = mx }` คือ anonymous struct literal — Zig infer type จาก return type ของฟังก์ชันให้เอง
> ไม่ต้องเขียน `MinMax{ .min = mn, .max = mx }` ซ้ำ (สั้นกว่าที่คิด)

## 3. Named return values — Go มี, Zig ไม่มี

**Go** มี named return + naked `return` (ใช้บ้างแต่บางทีมองว่าอ่านยาก)
```go
func split(sum int) (x, y int) {
    x = sum * 4 / 9
    y = sum - x
    return // naked return — คืนค่า x, y ที่ตั้งไว้ข้างบน
}
```

**Zig ไม่มี concept นี้เลย** ต้อง return ค่าตรงๆ เสมอ ชัดเจนทุกจุด (ตรงกับปรัชญา "no hidden control flow")
```zig
const Split = struct { x: i32, y: i32 };

fn split(sum: i32) Split {
    const x = sum * 4 / 9;
    const y = sum - x;
    return .{ .x = x, .y = y };
}
```

## 4. Function เป็น value / function pointer

**Go**
```go
var op func(int, int) int = add
result := op(1, 2)

funcs := map[string]func(int, int) int{
    "add": add,
}
```

**Zig**
```zig
const op: *const fn (i32, i32) i32 = add;
const result = op(1, 2);
```
> Zig ต้องระบุว่าเป็น **pointer ไปยัง function** (`*const fn (...)...`) เสมอ ไม่มี bare `func` type ลอยๆ แบบ Go
> เพราะ function ใน Zig ไม่ใช่ first-class value ที่ copy ได้แบบ closure — ต้องอ้างผ่าน pointer เท่านั้น
>
> สังเกตว่าใช้ `const` ไม่ใช่ `var` — เพราะตัวแปรนี้ไม่ได้ถูกเปลี่ยนค่าอีกหลังประกาศ
> ถ้าใช้ `var` ทั้งที่ไม่มีการ reassign ทีหลัง **compiler จะ error ทันที** (`local variable is never mutated, consider using 'const'`)
> ต่างจาก Go ที่ `var` เฉยๆ โดยไม่ reassign ก็ compile ผ่านได้สบาย — Zig เข้มงวดกว่าตรงนี้เพื่อบังคับให้เขียนโค้ดสื่อ intent ชัดเจนว่าอะไรแก้ไขได้จริง

## 5. Closure — Go มี, Zig ไม่มี (จุดต่างสำคัญอีกจุด)

**Go** closure จับตัวแปรรอบข้าง (capture) ได้อัตโนมัติ
```go
func counter() func() int {
    count := 0
    return func() int {
        count++
        return count
    }
}

next := counter()
next() // 1
next() // 2
```

**Zig ไม่มี closure ในตัวภาษา** — function ไม่สามารถ capture ตัวแปรรอบข้างได้เลย
ถ้าต้องการพฤติกรรมคล้ายกัน ต้องส่ง state ผ่าน struct เอง (explicit แทน implicit):
```zig
const Counter = struct {
    count: i32 = 0,

    fn next(self: *Counter) i32 {
        self.count += 1;
        return self.count;
    }
};

var c = Counter{};
_ = c.next(); // 1
_ = c.next(); // 2
```
> นี่คือความต่างเชิงปรัชญาอีกจุด: Go ซ่อน "การจับตัวแปร + allocate มันไว้บน heap" ไว้ให้ closure ทำงานได้
> Zig ไม่ยอมซ่อน allocation แบบนั้น เลยบังคับให้เขียน state เป็น struct ชัดๆ แทน

## 6. Method (function ผูกกับ struct)

**Go** ใช้ receiver แยกไว้หน้าชื่อฟังก์ชัน เลือกได้ระหว่าง value receiver กับ pointer receiver
```go
type Counter struct{ n int }

func (c *Counter) Inc() { // pointer receiver, แก้ไข field ได้
    c.n++
}

func (c Counter) Get() int { // value receiver, อ่านอย่างเดียว
    return c.n
}
```

**Zig** เขียน method เป็น function ธรรมดา**ข้างใน struct** โดย parameter แรกคือ `self` (ชื่ออะไรก็ได้ แต่ convention คือ `self`)
```zig
const Counter = struct {
    n: i32 = 0,

    fn inc(self: *Counter) void { // รับ pointer = แก้ไขได้ เทียบ Go pointer receiver
        self.n += 1;
    }

    fn get(self: Counter) i32 { // รับ value = อ่านอย่างเดียว เทียบ Go value receiver
        return self.n;
    }
};

var c = Counter{};
c.inc();          // Zig auto-ref ให้เอง ไม่ต้องเขียน (&c).inc()
_ = c.get();
```
> concept เหมือนกับ Go เป๊ะ (`*Counter` = pointer receiver, `Counter` = value receiver) ต่างแค่ syntax
> ที่ Zig เขียน method **อยู่ในตัว struct เลย** ไม่แยกไฟล์/แยกส่วนแบบ Go ที่เขียน `func (c *Counter) ...` ลอยๆ นอก struct ได้

## 7. Generic function

**Go** (ตั้งแต่ 1.18) ใช้ type parameter พร้อม constraint
```go
func Max[T cmp.Ordered](a, b T) T {
    if a > b {
        return a
    }
    return b
}
```

**Zig** ใช้ `comptime` parameter — ยืดหยุ่นกว่าเพราะรับ "type" เป็น value ได้ตรงๆ ไม่ต้องมี syntax generic พิเศษแยกออกมา
```zig
fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

const m = max(i32, 3, 7);
```
หรือใช้ `anytype` ให้ compiler infer type ให้เอง (ใช้บ่อยกว่าในโค้ดจริง):
```zig
fn max(a: anytype, b: anytype) @TypeOf(a, b) {
    return if (a > b) a else b;
}

const m = max(3, 7); // infer เป็น comptime_int
```
> `comptime T: type` คือหัวใจสำคัญของ Zig generics — "type" เป็นแค่ value ธรรมดาที่ส่งผ่าน parameter ได้
> ไม่ต้องมี syntax `[T any]` แยกต่างหากแบบ Go ดูเพิ่มที่ [06-interface.md](./06-interface.md) เรื่อง `anytype`

## 8. Variadic function (จำนวน argument ไม่แน่นอน)

**Go** มี `...T` ในตัวภาษา ใช้บ่อยมาก (เช่น `fmt.Println(args ...interface{})`)
```go
func sum(nums ...int) int {
    total := 0
    for _, n := range nums {
        total += n
    }
    return total
}

sum(1, 2, 3)
```

**Zig ไม่มี user-defined variadic function** (มีแต่สำหรับ extern C function เท่านั้น)
วิธีทดแทนที่ใช้กันคือส่ง **slice หรือ tuple** เข้าไปแทน:
```zig
fn sum(nums: []const i32) i32 {
    var total: i32 = 0;
    for (nums) |n| total += n;
    return total;
}

const total = sum(&[_]i32{ 1, 2, 3 });
```
> นี่คือเหตุผลที่ `std.debug.print("{d}\n", .{value})` ใน Zig ต้องมี `.{...}` ต่อท้ายเสมอ —
> มันคือ **tuple literal** ที่ใช้แทน variadic args (compile-time สร้าง struct นิรนามที่มีจำนวน field เท่ากับ argument)
> ไม่ใช่ variadic function จริงๆ แบบ Go's `fmt.Println`

## 9. สรุปตารางเทียบ

| เรื่อง | Go | Zig |
|---|---|---|
| Multiple return | มีในตัวภาษา `(T1, T2)` | ไม่มี — ใช้ struct หรือ error union (`!T`) แทน |
| Named return | มี (`func f() (x int)`) | ไม่มี |
| Closure (capture ตัวแปร) | มี | ไม่มี — ต้องส่ง state ผ่าน struct เอง |
| Method receiver | `func (r T) M()` แยกนอก struct | เขียน method ในตัว `struct { ... }` เลย |
| Generics | `[T constraint]` syntax เฉพาะ | `comptime T: type` หรือ `anytype` (type เป็น value ธรรมดา) |
| Variadic | `...T` ในตัวภาษา | ไม่มี — ใช้ slice หรือ tuple literal (`.{...}`) แทน |
| Function เป็น value | `func(int) int` ตรงๆ | ต้องเป็น pointer เสมอ `*const fn(i32) i32` |

---
กลับไปหน้าแรก: [README](./README.md)
