const std = @import("std");
const aoc2025zig = @import("root.zig");
const day1 = @import("day01.zig");

fn isInvalidSequencePart1(number: u64) bool {
    var buffer: [20]u8 = undefined;
    const len = std.fmt.printInt(&buffer, number, 10, std.fmt.Case.upper, std.fmt.Options{});
    if (len % 2 != 0) return false;
    const half_len = len / 2;
    for (0..half_len) |i| {
        if (buffer[i] != buffer[i + half_len]) {
            return false;
        }
    }
    return true;
}

test "isInvalidSequence tests" {
    try std.testing.expect(isInvalidSequencePart1(1212) == true);
    try std.testing.expect(isInvalidSequencePart1(123123) == true);
    try std.testing.expect(isInvalidSequencePart1(1234) == false);
    try std.testing.expect(isInvalidSequencePart1(1111) == true);
    try std.testing.expect(isInvalidSequencePart1(123321) == false);
}

fn isInvalidSequencePart2(number: u64) bool {
    var buffer: [20]u8 = undefined;
    const len = std.fmt.printInt(&buffer, number, 10, std.fmt.Case.upper, std.fmt.Options{});

    const maxDivisions = len / 2;
    var foundInvalid = false;
    for (1..maxDivisions + 1) |division_size| {
        if (len % division_size != 0) continue;
        const num_divisions = len / division_size;
        var all_match = true;
        for (1..num_divisions) |i| {
            for (0..division_size) |j| {
                if (buffer[j] != buffer[i * division_size + j]) {
                    all_match = false;
                    break;
                }
            }
            if (!all_match) break;
        }
        if (all_match) {
            foundInvalid = true;
            break;
        }
    }
    return foundInvalid;
}

test "isInvalidSequencePart2 tests" {
    try std.testing.expect(isInvalidSequencePart2(1212) == true);
    try std.testing.expect(isInvalidSequencePart2(123123) == true);
    try std.testing.expect(isInvalidSequencePart2(123123123) == true);
    try std.testing.expect(isInvalidSequencePart2(1234) == false);
    try std.testing.expect(isInvalidSequencePart2(1111) == true);
    try std.testing.expect(isInvalidSequencePart2(123321) == false);
}

pub fn solve() !void {
    // const lines = try aoc2025zig.readFileLines(std.heap.page_allocator, "input_test_02_01.txt");
    // const lines = try aoc2025zig.readFileLines(std.heap.page_allocator, "input_test_01_02.txt");
    try solveWithFile(std.heap.page_allocator, "input_02.txt");
}
pub fn solveWithFile(allocator: std.mem.Allocator, path: []const u8) !void {
    var lines = try aoc2025zig.readFileLines(allocator, path);
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
        var it = std.mem.splitScalar(u8, line, ',');
        while (it.next()) |range| {
            var rit = std.mem.splitScalar(u8, range, '-');
            const first = rit.next() orelse return error.InvalidInput;
            const second = rit.next() orelse return error.InvalidInput;
            const first_num = try std.fmt.parseInt(u64, first, 10);
            const second_num = try std.fmt.parseInt(u64, second, 10);
            // std.debug.print("First: {d}, Second: {d}\n", .{ first_num, second_num });
            for (first_num..second_num + 1) |n| {
                //std.debug.print("  n: {d}\n", .{n});
                if (isInvalidSequencePart1(@intCast(n))) {
                    sum += @intCast(n);
                }
                if (isInvalidSequencePart2(@intCast(n))) {
                    sum2 += @intCast(n);
                }
            }
        }
    }

    const t1 = try std.time.Instant.now();
    const diff = std.time.Instant.since(t1, t0);
    std.debug.print("Day 2 solved in {d} ns\n", .{diff});

    std.debug.print("Day 2, Part 1: {d}\n", .{sum});
    std.debug.print("Day 2, Part 2: {d}\n", .{sum2});
}

test "day2 solve test" {
    try solveWithFile(std.testing.allocator, "input_test_02_01.txt");
}
