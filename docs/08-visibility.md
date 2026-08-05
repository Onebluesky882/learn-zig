# pub / Visibility: Go เทียบ Zig

## 1. หลักการพื้นฐาน

**Go** กำหนด public/private จาก**ตัวพิมพ์ใหญ่-เล็กของชื่อ** (ไม่มี keyword) และ scope คือระดับ **package**
```go
func PublicFunc() {}   // ขึ้นต้นตัวใหญ่ = public, เรียกจาก package อื่นได้
func privateFunc() {}  // ขึ้นต้นตัวเล็ก = private, เรียกได้แค่ใน package เดียวกัน (ข้ามไฟล์ในแพ็กเกจเดียวกันได้)
```

**Zig** กำหนด public/private ด้วย **keyword `pub`** ที่ใส่หน้า declaration และ scope คือระดับ **ไฟล์ (`.zig` ไฟล์เดียว)**
ไม่ใช่ package แบบ Go
```zig
pub fn publicFn() void {} // มี pub = เรียกจากไฟล์อื่นที่ import เข้ามาได้
fn privateFn() void {}    // ไม่มี pub (default) = เรียกได้แค่ในไฟล์นี้เท่านั้น
```

## 2. ทดสอบจริง — เรียกข้ามไฟล์

สมมติมี 2 ไฟล์: `mymod.zig` และ `main.zig`

```zig
// mymod.zig
pub fn publicFn() void { ... }   // pub
fn privateFn() void { ... }      // ไม่มี pub
```

```zig
// main.zig
const mymod = @import("mymod.zig");

pub fn main() void {
    mymod.publicFn();   // ✅ ผ่าน
    mymod.privateFn();  // ❌ compile error
}
```

ผลลัพธ์ตอน compile ถ้าเรียก `privateFn` จากไฟล์อื่น:
```
error: 'privateFn' is not marked 'pub'
```
> คอมไพเลอร์เช็คให้ตอน compile-time ทันที ไม่ใช่ convention เหมือน Go ที่แค่ "ไม่มีทางเรียกได้" เพราะ
> คนละ package (ถ้าอยู่ package เดียวกัน Go เรียก private function ข้ามไฟล์ได้เลยแม้ตัวเล็ก) —
> **Zig เข้มกว่า**: ต่อให้อยู่ project เดียวกัน แค่คนละไฟล์ก็ต้อง `pub` แล้ว

## 3. หน่วยของ scope ต่างกัน: package (Go) เทียบ ไฟล์ (Zig)

นี่คือความต่างที่สำคัญที่สุดของหัวข้อนี้:

| | Go | Zig |
|---|---|---|
| หน่วยของ "โมดูล" | package (รวมหลายไฟล์ในโฟลเดอร์เดียวกัน) | **1 ไฟล์ = 1 struct/namespace** (`@import("foo.zig")` คือการเอา struct ของไฟล์นั้นมาใช้) |
| private มองเห็นจากไหนได้บ้าง | ทุกไฟล์ใน package เดียวกัน | **เฉพาะไฟล์เดียวกันเท่านั้น** แม้จะอยู่โฟลเดอร์เดียวกัน คนละไฟล์ก็มองไม่เห็น |
| ใช้ตัวพิมพ์ใหญ่-เล็กกำหนด visibility ไหม | ใช่ (`Foo` vs `foo`) | ไม่ใช่ — ใช้ `pub` keyword เท่านั้น ตัวพิมพ์ใหญ่เล็กไม่มีผลต่อ visibility (แต่มี naming convention แยกต่างหาก ดูข้อ 5) |

พูดง่ายๆ คือ Zig ไม่มี concept "package" แบบ Go เลย — ถ้าอยากให้หลายไฟล์แชร์กันแบบ package
ต้องทำเองผ่านไฟล์ "รวม" (เช่น `root.zig` ที่ `pub` re-export ของจากไฟล์ย่อยๆ)

## 4. Struct field — จุดที่ Go มี "private" แต่ Zig ไม่มี

**Go**: struct field ก็ใช้กฎตัวพิมพ์ใหญ่-เล็กเหมือน function เป๊ะ ป้องกัน field จากไฟล์นอก package ได้จริง
```go
type Account struct {
    Balance int    // public, เข้าถึงจากนอก package ได้
    secret  string // private, เข้าถึงได้แค่ใน package เดียวกัน
}
```

**Zig**: **struct field ไม่มี concept private/public เลย** ไม่มี `pub` ใส่หน้า field ได้
ถ้ามองเห็น type ก็เข้าถึงทุก field ได้เสมอ ไม่ว่าไฟล์ไหนก็ตาม (ทดสอบจริงแล้วยืนยันพฤติกรรมนี้)
```zig
// mymod.zig
pub const Account = struct {
    balance: i32,
    secret: []const u8, // ไม่มีทางทำให้ field นี้ "private" ได้เลยในภาษา Zig
};
```
```zig
// main.zig
const mymod = @import("mymod.zig");
const a = mymod.Account{ .balance = 100, .secret = "shh" };
std.debug.print("{s}\n", .{a.secret}); // เข้าถึงได้ตรงๆ ไม่มีอะไรกัน
```
> ถ้าอยากได้ field ที่ "อ่านได้อย่างเดียวจากภายนอก" (encapsulation แบบ Go) ต้องทำเองด้วย convention
> เช่น ตั้งชื่อ field ขึ้นต้นด้วย `_` เพื่อ "บอกใบ้" ว่าอย่ายุ่ง (ไม่มีการบังคับจริงจาก compiler)
> แล้วให้เข้าถึงผ่าน `pub fn getSecret(self: Account) []const u8 { return self.secret; }` แทน

## 5. Naming convention (ไม่ใช่ visibility แต่มักสับสนกับ Go)

Zig มี convention เรื่องตัวพิมพ์ แต่ **ไม่เกี่ยวกับ public/private** เหมือน Go เลย เป็นแค่สไตล์การตั้งชื่อ:

| อะไร | Convention | ตัวอย่าง |
|---|---|---|
| ชื่อ type (`struct`, `enum`, `union`) | `PascalCase` | `Account`, `HashMap` |
| ชื่อ function, variable | `camelCase` | `getBalance`, `myCount` |
| ชื่อ constant ที่เป็น "type-like" | `PascalCase` | ถ้า const เก็บ struct/type |

ต่างจาก Go ที่ตัวพิมพ์ใหญ่ **คือ** visibility จริงๆ — ใน Zig ต่อให้ตั้งชื่อ `PascalCase`
ก็ยังต้องใส่ `pub` อยู่ดีถ้าอยากให้ไฟล์อื่นเรียกได้

## 6. สรุป

- Go: private/public = **ตัวพิมพ์ใหญ่-เล็ก**, scope = **package** (ข้ามไฟล์ในแพ็กเกจเดียวกันได้), มี field-level privacy
- Zig: private/public = **keyword `pub`**, scope = **ไฟล์เดียว** (เข้มกว่า Go มาก), **ไม่มี field-level privacy** เลย

---
กลับไปหน้าแรก: [README](./README.md)
