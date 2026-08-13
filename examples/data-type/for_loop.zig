const std = @import("std");

pub fn forLoop() void {
    const array: [5]i32 = .{ 1, 2, 3, 4, 5 };

    for (0..array.len) |i| {
        const value: i32 = array[i] + 1;
        std.debug.print("value : {} \n", .{value});
    }
}

pub fn whileLoop() void {
    var index: usize = 0;

    while (index < 10) {
        const num = index + 1;
        std.debug.print("value : {}\n", .{num});
        index += 1;
    }
}




// compair loop check url

pub fn slicesAreTheSame(a: []const u8, b: []const u8) bool {
    const a_lenght: usize = a.len;
    const b_lenght: usize = b.len;

    if (a_lenght != b_lenght) {
        return false;
    }
    for (0..a_lenght) |i| {
        if (a[i] != b[i]) {
            return false;
        }
    }
    return true;
}

const VaLID_ADDRESS: [3][]const u8 = .{ "www.example.com", "www.google.com", "www.bbc.com" };
const HttpStatus = enum(u16) { Ok = 200, BadRequest = 400, Unauthorized = 401, PaymentRequired = 402, Forbidden = 403, NotFound = 404, MethodNotAllowed = 405, NotAcceptable = 406, RequestTimeout = 408, InternalServerError = 500 };

pub fn openPage(page_url: []const u8) HttpStatus {
    for (VaLID_ADDRESS) |url| {
        if (slicesAreTheSame(page_url, url) == true) {
            return HttpStatus.Ok;
        }
    }
    return HttpStatus.NotFound;
}
pub fn openPages() void {
    const pages: [3][]const u8 = .{ "www.example.com", "www.google.com", "www.bbk.com" };

    for (pages) |page| {
        const status = openPage(page);
        std.debug.print("url : {s} \tstatus:{} \n", .{ page, status });
    }
}
