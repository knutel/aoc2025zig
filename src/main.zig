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
const day7 = @import("day07.zig");
const day7optimized = @import("day07optimized.zig");
const day8 = @import("day08.zig");
const day9 = @import("day09.zig");
const day10 = @import("day10.zig");
const day11 = @import("day11.zig");
const day12 = @import("day12.zig");

pub fn main() !void {
    var argIter = try std.process.argsWithAllocator(std.heap.page_allocator);
    defer argIter.deinit();
    _ = argIter.next();
    const no = "no";
    const benchmark = argIter.next() orelse no;
    var runBenchmark = false;
    if (!std.mem.eql(u8, no, benchmark)) {
        runBenchmark = true;
    }
    std.debug.print("Run benchmark: {}\n", .{runBenchmark});
    try day1.solve(runBenchmark);
    try day2.solve(runBenchmark);
    try day3.solve(runBenchmark);
    try day4.solve(runBenchmark);
    try day5.solve(runBenchmark);
    if (runBenchmark) {
        try day6.solve(runBenchmark);
        try day6fast.solve(runBenchmark);
        try day6faster.solve(runBenchmark);
    }
    try day6fasternoalloc.solve(runBenchmark);
    if (runBenchmark) {
        try day7.solve(runBenchmark);
    }
    try day7optimized.solve(runBenchmark);
    try day8.solve(runBenchmark);
    try day9.solve(runBenchmark);
    try day10.solve(runBenchmark);
    try day11.solve(runBenchmark);
    try day12.solve(runBenchmark);
}
