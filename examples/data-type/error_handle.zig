const std = @import("std");

// ถ้า function สามารถ return error → ต้องประกาศ !T
// fn anotherFunction() !i32 {
//     const result = try findStudent();
//     return result;
// }

//* errors
pub fn handleError() void {
    const b: i32 = 0;
    std.debug.assert(b != 0);
}

const VALID_ADDRESS: [3][]const u8 = .{ "www.example.com", "www.google.com", "www.bbc.com" };
const HttpStatus = error{ Ok, BadRequest, Unauthorized, PaymentRequired, Forbidden, NotFound, MethodNotAllowed, NotAcceptable, RequestTimeout, InternalServerError };

fn openPage(page_url: []const u8) ![]const u8 {
    for (VALID_ADDRESS) |url| {
        if (std.mem.eql(u8, page_url, url)) {
            return url;
        }
    }

    return HttpStatus.NotFound;
}
pub fn errorHandle() !void {
    const pages: [3][]const u8 = .{ "www.example.com", "www.google.com", "www.bbk.com" };

    for (pages) |page| {
        std.debug.print("url: {s}\n", .{page});
        _ = try openPage(page);
    }
    std.debug.print(" \t  no error\n", .{});
}
