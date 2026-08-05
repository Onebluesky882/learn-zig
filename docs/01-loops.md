# Loop: Go เทียบ Zig

Go มี keyword เดียวคือ `for` ที่ใช้ได้หลายแบบ
Zig แยกเป็น `while` (loop ตามเงื่อนไข) กับ `for` (loop วนของ array/slice/range) คนละหน้าที่กันชัดเจน

## 1. Loop นับจำนวนธรรมดา (counter loop)

**Go**
```go
for i := 0; i < 10; i++ {
    fmt.Println(i)
}
```

**Zig** — ไม่มี C-style for แบบ 3 ส่วน ใช้ `while` แทน
```zig
var i: usize = 0;
while (i < 10) : (i += 1) {
    std.debug.print("{d}\n", .{i});
}
```
> `: (i += 1)` คือส่วน "continue expression" รันทุกครั้งก่อนวนรอบถัดไป เทียบเท่ากับ `i++` ใน Go

หรือใช้ `for` กับ range ก็ได้ (Zig 0.11+) แบบนี้จะสั้นกว่าและไม่ต้อง mutate ตัวแปรเอง:
```zig
for (0..10) |i| {
    std.debug.print("{d}\n", .{i});
}
```

## 2. Loop วน array / slice (range)

**Go**
```go
nums := []int{10, 20, 30}
for i, v := range nums {
    fmt.Println(i, v)
}
```

**Zig**
```zig
const nums = [_]i32{ 10, 20, 30 };
for (nums, 0..) |v, i| {
    std.debug.print("{d} {d}\n", .{ i, v });
}
```
> สังเกตว่า Zig สลับลำดับ: `(ค่า, index)` ส่วน Go คือ `(index, ค่า)`
> ถ้าไม่ต้องการ index ก็เขียนแค่ `for (nums) |v| { ... }`

## 3. Loop แบบไม่มีเงื่อนไข (infinite loop)

**Go**
```go
for {
    // ...
    if done {
        break
    }
}
```

**Zig**
```zig
while (true) {
    // ...
    if (done) break;
}
```

## 4. continue / break / labeled loop

Go และ Zig คล้ายกันมากในเรื่องนี้ ต่างกันที่ Zig ใช้ label นำหน้าด้วย `:` และเวลาอ้างถึงต้อง `break :label` / `continue :label`

**Go**
```go
outer:
for i := 0; i < 3; i++ {
    for j := 0; j < 3; j++ {
        if j == 1 {
            continue outer
        }
        fmt.Println(i, j)
    }
}
```

**Zig**
```zig
outer: for (0..3) |i| {
    for (0..3) |j| {
        if (j == 1) continue :outer;
        std.debug.print("{d} {d}\n", .{ i, j });
    }
}
```

## 5. loop เป็น expression (จุดที่ Zig ทำได้แต่ Go ทำไม่ได้)

`while` และ `for` ใน Zig สามารถ "คืนค่า" ออกมาได้เมื่อ break พร้อมค่า ซึ่ง Go ไม่มีความสามารถนี้เลย
ต้องใช้ตัวแปรชั่วคราวนอก loop แทน

**Go** (ต้องใช้ตัวแปรช่วย)
```go
found := -1
for i, v := range nums {
    if v == 20 {
        found = i
        break
    }
}
```

**Zig** (loop คืนค่าออกมาตรงๆ)
```zig
const found: i32 = for (nums, 0..) |v, i| {
    if (v == 20) break @as(i32, @intCast(i));
} else -1;
```
> `else` ต่อท้าย loop คือค่าที่ได้ถ้า loop จบโดยไม่มีการ `break` เลย (คล้าย `for...else` ของ Python
> แต่ Go ไม่มี syntax นี้)

---
ต่อไป: [Memory — GC vs Allocator](./02-memory.md)
