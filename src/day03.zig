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
    try std.testing.expect(std.meta.eql(result, .{ 9, 8 }));
    result = largestDigit(3, "123456789");
    try std.testing.expect(std.meta.eql(result, .{ 9, 8 }));
    result = largestDigit(5, "987654321");
    try std.testing.expect(std.meta.eql(result, .{ 4, 5 }));
    result = largestDigit(8, "000000009");
    try std.testing.expect(std.meta.eql(result, .{ 9, 8 }));
}

pub fn findLargestJoltage(line: []const u8, length: usize) u64 {
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
    _ = try solveWithFile(std.heap.page_allocator, "input_03.txt");
}

pub fn solveWithFile(allocator: std.mem.Allocator, path: []const u8) !struct { u64, u64 } {
    var lines = try aoc2025zig.readFileLines(allocator, path, false);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    const t0 = try std.time.Instant.now();

    var sum: u64 = 0;
    var sum2: u64 = 0;

    for (lines.items) |line| {
        var joltage = findLargestJoltage(line, 2);
        sum += joltage;
        joltage = findLargestJoltage(line, 12);
        sum2 += joltage;
    }

    const t1 = try std.time.Instant.now();
    const diff = std.time.Instant.since(t1, t0);
    std.debug.print("Day 3 solved in {d} ns\n", .{diff});

    std.debug.print("Day 3, Part 1: {d}\n", .{sum});
    std.debug.print("Day 3, Part 2: {d}\n", .{sum2});

    return .{ sum, sum2 };
}

test "day3 solve test" {
    const result = try solveWithFile(std.testing.allocator, "input_test_03_01.txt");
    try std.testing.expect(result[0] == 357);
    try std.testing.expect(result[1] == 3121910778619);
}
