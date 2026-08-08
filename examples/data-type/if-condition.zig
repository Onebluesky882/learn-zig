const std = @import("std");

pub fn ifElseConditon() void {

    //  ! if/else → เงื่อนไข

    //  ! switch → เลือกจากหลายค่าที่เป็นไปได้

    const correct: bool = true;

    if (correct) {
        std.debug.print(" correct {} \n", .{});
    }
    if (!correct) {
        std.debug.print(" not correct {} \n", .{});
    }

    const Status = enum {
        pending,

        success,

        failed,
    };

    switch (Status) {
        .pending => {},

        .success => {},

        .failed => {},
    }
}
