const std = @import("std");
const day1 = @import("day01.zig");
const day2 = @import("day02.zig");
const day3 = @import("day03.zig");
const day4 = @import("day04.zig");
const day5 = @import("day05.zig");
const day6 = @import("day06.zig");
const day6fast = @import("day06fast.zig");
const day6faster = @import("day06faster.zig");
const day6fasternoalloc = @import("day06fasternoalloc.zig");

pub fn main() !void {
    try day1.solve();
    try day2.solve();
    try day3.solve();
    try day4.solve();
    try day5.solve();
    try day6.solve();
    try day6fast.solve();
    try day6faster.solve();
    try day6fasternoalloc.solve();
}
