# Concurrency: Goroutine เทียบ Thread ใน Zig

## หลักการสากล (universal concepts) ก่อนเข้าโค้ด

ไม่ว่าภาษาไหน concurrency ก็วนอยู่กับปัญหาชุดเดียวกัน:

1. **Unit of execution** — สิ่งที่รันขนานกัน (goroutine, thread, process, coroutine)
2. **Scheduling** — ใครตัดสินใจว่าตัวไหนรันตอนไหน (OS scheduler เทียบกับ language runtime scheduler)
3. **Communication** — หน่วยงานเหล่านั้นคุยกันยังไง (shared memory + lock, หรือ message passing)
4. **Synchronization** — ป้องกัน race condition ยังไง (mutex, atomic, channel, semaphore)
5. **Cost** — สร้าง/สลับ unit หนึ่งตัวแพงแค่ไหน (kilobytes stack, context switch cost)

Go กับ Zig เลือกจุดที่ต่างกันสุดขั้วในแกนเหล่านี้:

| แกน | Go | Zig |
|---|---|---|
| Unit | Goroutine (green thread, stack เริ่ม ~2KB ขยายเองได้) | OS Thread ตรงๆ (`std.Thread`) stack คงที่ตั้งแต่แรก (default ~16MB) |
| Scheduler | Go runtime มี M:N scheduler ของตัวเอง (ซ่อนอยู่หลัง `go func()`) | ไม่มี — ใช้ OS scheduler ตรงๆ ไม่มี runtime มาคั่นกลาง |
| Communication หลัก | Channel (`chan`) — "share memory by communicating" | Shared memory + Mutex/Atomic ตรงๆ (แบบ C/pthread) |
| จำนวนที่สร้างได้ | หลักแสน-ล้าน goroutine ได้สบาย (เบามาก) | หลักพัน-หมื่น thread (หนักกว่ามาก เพราะเป็น OS thread จริง) |

**สรุป 1 บรรทัด**: goroutine คือ "abstraction ที่ runtime สร้างภาพลวงตาของ thread เบาๆ ให้"
ส่วน Zig ไม่มี abstraction ชั้นนั้น คุณคุยกับ OS thread ตรงๆ เหมือนเขียน C ด้วย pthread

## 1. สร้าง thread / goroutine

**Go**
```go
go func() {
    fmt.Println("running in goroutine")
}()
```

**Zig**
```zig
const std = @import("std");

fn worker() void {
    std.debug.print("running in thread\n", .{});
}

pub fn main() !void {
    const t = try std.Thread.spawn(.{}, worker, .{});
    t.join(); // ต้อง join เอง ไม่งั้น process จบก่อน thread ทำงานเสร็จ
}
```
> Go ไม่มี `.join()` ให้เห็นตรงๆ (ปกติใช้ `sync.WaitGroup` แทนเพื่อรอ goroutine จบ)
> Zig ให้ handle ของ thread กลับมาตรงๆ แล้วเรียก `.join()` เอง (เหมือน pthread_join)

## 2. รอหลายงานพร้อมกัน (WaitGroup เทียบ join หลาย thread)

**Go**
```go
var wg sync.WaitGroup
for i := 0; i < 5; i++ {
    wg.Add(1)
    go func(i int) {
        defer wg.Done()
        fmt.Println(i)
    }(i)
}
wg.Wait()
```

**Zig**
```zig
fn worker(i: usize) void {
    std.debug.print("{d}\n", .{i});
}

pub fn main() !void {
    var threads: [5]std.Thread = undefined;
    for (&threads, 0..) |*t, i| {
        t.* = try std.Thread.spawn(.{}, worker, .{i});
    }
    for (threads) |t| {
        t.join();
    }
}
```
> ไม่มี `WaitGroup` สำเร็จรูปให้ใช้ ต้องเก็บ handle ของ thread ไว้เองแล้ว join ทีละตัว
> (หรือใช้ `std.Thread.Pool` ถ้าอยากได้ pattern คล้าย worker pool)

## 3. Mutex — ป้องกัน race condition

**Go**
```go
var mu sync.Mutex
counter := 0

mu.Lock()
counter++
mu.Unlock()
```

**Zig**
```zig
var mutex = std.Thread.Mutex{};
var counter: i32 = 0;

mutex.lock();
counter += 1;
mutex.unlock();
```
> concept เหมือนกันเป๊ะ ต่างแค่ syntax เท่านั้น

## 4. Channel — จุดที่ Zig "ไม่มีของสำเร็จรูปให้"

Go มี `chan` เป็น first-class citizen ในตัวภาษา ส่ง/รับข้อมูลข้าม goroutine ได้เลย:

**Go**
```go
ch := make(chan int)
go func() {
    ch <- 42
}()
val := <-ch
fmt.Println(val)
```

**Zig** ไม่มี channel ในตัวภาษาหรือใน standard library (ต่างจาก Go ชัดเจนตรงนี้)
ต้องประกอบเองจาก mutex + condition variable (หรือใช้ library แยกจาก community เช่น `zap`, `zigcoro`)
```zig
const Channel = struct {
    mutex: std.Thread.Mutex = .{},
    cond: std.Thread.Condition = .{},
    value: ?i32 = null,

    fn send(self: *Channel, v: i32) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        self.value = v;
        self.cond.signal();
    }

    fn recv(self: *Channel) i32 {
        self.mutex.lock();
        defer self.mutex.unlock();
        while (self.value == null) {
            self.cond.wait(&self.mutex);
        }
        const v = self.value.?;
        self.value = null;
        return v;
    }
};
```
> นี่คือสิ่งที่ Go "ซ่อนความซับซ้อนนี้ไว้ให้" แต่ Zig ให้เห็นทุกชิ้นส่วนตรงๆ — ถ้าอยากได้ channel
> ใน Zig ปัจจุบันแนะนำให้ประกอบเองแบบนี้ หรือดึง library จาก community มาใช้

## 5. เรื่อง `async`/`await` ที่เคยมีใน Zig

Zig เคยมี `async`/`await` ในตัวภาษาสำหรับ coroutine แบบ stackless (คล้าย green thread เบาๆ)
แต่ถูก**ถอดออกชั่วคราว**ตั้งแต่ราวๆ 0.11 เพื่อออกแบบใหม่ให้เข้ากับ I/O model ใหม่ของภาษา
ปัจจุบัน (0.15–0.16) แนวทางหลักในการทำ concurrency ที่เบากว่า OS thread เต็มรูปแบบ
ยังอยู่ระหว่างพัฒนา (`std.Io` interface) — ตอนนี้ทางที่ stable และใช้งานจริงได้คือ `std.Thread` ตรงๆ
ตามที่แสดงในเอกสารนี้ ถ้าจะเทียบกับ Go: **Zig ตอนนี้ไม่มี goroutine-equivalent ที่เบาในตัวภาษา
ทุกอย่างคือ OS thread เต็มรูปแบบ**

---
กลับไปหน้าแรก: [README](./README.md)
