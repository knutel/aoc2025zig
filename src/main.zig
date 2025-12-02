const std = @import("std");
const day1 = @import("day01.zig");
const day2 = @import("day02.zig");

pub fn main() !void {
    try day1.solve();
    try day2.solve();
}
