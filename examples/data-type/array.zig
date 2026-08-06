const std = @import("std");

const number_array = [5]u8{ 1, 2, 3, 4, 5 };
const number_array_any: []u8 = [5]u8{ 1, 2, 3, 4, 5 };
const arrayOne = [_]i32{ 1, 2, 3, 4, 5, 6 };
const array_two = []i32{ 1, 2, 3, 4, 5, 6 };
const array_slice_demo: []const i32 = array[0..];

pub var array = [_]i32{ 1, 2, 3, 4, 5 };

pub fn getSlice() []i32 {
    return array[0..];
}

//array[start..end]
//array[1..4]
// pub fn getSlice() []i32 {
//     return array[1..];
// }

// หมายถึง ตัดตัว หน้า index 0 ออก
