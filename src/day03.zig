const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn largestDigit(startPos: usize, string: []const u8) struct { u8, usize } {
    var largest: u8 = 0;
    var pos: usize = startPos;
    for (startPos..string.len) |i| {
        const c = string[i] - '0';
        if (c > largest) {
            largest = c;
            pos = i;
        }
    }
    return .{ largest, pos };
}

test "largestDigit tests" {
    var result = largestDigit(0, "123456789");
    try std.testing.expect(result[0] == 9);
    try std.testing.expect(result[1] == 8);
    result = largestDigit(3, "123456789");
    try std.testing.expect(result[0] == 9);
    try std.testing.expect(result[1] == 8);
    result = largestDigit(5, "987654321");
    try std.testing.expect(result[0] == 4);
    try std.testing.expect(result[1] == 5);
    result = largestDigit(8, "000000009");
    try std.testing.expect(result[0] == 9);
    try std.testing.expect(result[1] == 8);
}

pub fn findLargestJoltage(line: []const u8, length: usize) u64 {
    // var largest = largestDigit(0, line);
    var joltage: u64 = 0;

    var pos: usize = 0;
    var digitsLeft = length;
    for (0..length) |_| {
        const result = largestDigit(pos, line[0 .. line.len - (digitsLeft - 1)]);
        joltage = joltage * 10 + @as(u64, result[0]);
        pos = result[1] + 1;
        digitsLeft -= 1;
    }

    return joltage;
}

pub fn solve() !void {
    // const lines = try aoc2025zig.readFileLines(std.heap.page_allocator, "input_test_03_01.txt");
    // const lines = try aoc2025zig.readFileLines(std.heap.page_allocator, "input_test_03_02.txt");
    try solveWithFile(std.heap.page_allocator, "input_03.txt");
}

pub fn solveWithFile(allocator: std.mem.Allocator, path: []const u8) !void {
    var lines = try aoc2025zig.readFileLines(allocator, path);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    var sum: u64 = 0;
    var sum2: u64 = 0;

    for (lines.items) |line| {
        const joltage1 = findLargestJoltage(line, 2);
        // std.debug.print("Joltage: {d}\n", .{joltage1});
        sum += joltage1;
        const joltage2 = findLargestJoltage(line, 12);
        // std.debug.print("Joltage: {d}\n", .{joltage2});
        sum2 += joltage2;
    }

    std.debug.print("Day 3, Part 1: {d}\n", .{sum});
    std.debug.print("Day 3, Part 2: {d}\n", .{sum2});
}

test "day3 solve test" {
    try solveWithFile(std.testing.allocator, "input_test_03_01.txt");
}
