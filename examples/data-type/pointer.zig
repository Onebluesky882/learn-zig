var pointer_array = [5]i32{ 1, 2, 3, 4, 5 };

pub var ptr: *i32 = &pointer_array[0];

pub var pointer_ex: **i32 = &ptr;

//  image/pointer.png

pub fn pointerTest() void {
    pointer_ex.*.* = 100;
}
