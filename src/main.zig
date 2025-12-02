const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn newPosition(current: i32, code: aoc2025zig.Code) struct { i32, u8 } {
    var pos = current;
    var wraps: u8 = 0;
    if (code.dir == .left) {
        var steps = code.steps;
        while (pos - steps < 0) {
            steps -= 100;
            wraps += 1;
        }
        pos -= steps;
        if (current == 0) {
            wraps -= 1;
        }
    } else {
        var steps = code.steps;
        while (pos + steps > 99) {
            steps -= 100;
            wraps += 1;
        }
        pos += steps;
        if (pos == 0) {
            wraps -= 1;
        }
    }

    return .{ pos, @as(u8, wraps) };
}

test "newPosition basic tests" {
    const pos1 = newPosition(50, aoc2025zig.Code{ .dir = .left, .steps = 68 });
    try std.testing.expect(pos1[0] == 82);
    try std.testing.expect(pos1[1] == 1);

    const pos2 = newPosition(82, aoc2025zig.Code{ .dir = .left, .steps = 30 });
    try std.testing.expect(pos2[0] == 52);
    try std.testing.expect(pos2[1] == 0);

    const pos3 = newPosition(52, aoc2025zig.Code{ .dir = .right, .steps = 48 });
    try std.testing.expect(pos3[0] == 0);
    try std.testing.expect(pos3[1] == 0);

    const pos4 = newPosition(0, aoc2025zig.Code{ .dir = .left, .steps = 5 });
    try std.testing.expect(pos4[0] == 95);
    try std.testing.expect(pos4[1] == 0);

    const pos5 = newPosition(95, aoc2025zig.Code{ .dir = .right, .steps = 60 });
    try std.testing.expect(pos5[0] == 55);
    try std.testing.expect(pos5[1] == 1);

    const pos6 = newPosition(55, aoc2025zig.Code{ .dir = .left, .steps = 55 });
    try std.testing.expect(pos6[0] == 0);
    try std.testing.expect(pos6[1] == 0);

    const pos7 = newPosition(0, aoc2025zig.Code{ .dir = .left, .steps = 1 });
    try std.testing.expect(pos7[0] == 99);
    try std.testing.expect(pos7[1] == 0);

    const pos8 = newPosition(99, aoc2025zig.Code{ .dir = .left, .steps = 99 });
    try std.testing.expect(pos8[0] == 0);
    try std.testing.expect(pos8[1] == 0);

    const pos9 = newPosition(0, aoc2025zig.Code{ .dir = .right, .steps = 14 });
    try std.testing.expect(pos9[0] == 14);
    try std.testing.expect(pos9[1] == 0);

    const pos10 = newPosition(14, aoc2025zig.Code{ .dir = .left, .steps = 82 });
    try std.testing.expect(pos10[0] == 32);
    try std.testing.expect(pos10[1] == 1);
}

pub fn day1() !void {
    // const lines = try aoc2025zig.readFileLines(std.heap.page_allocator, "input_test_01_01.txt");
    // const lines = try aoc2025zig.readFileLines(std.heap.page_allocator, "input_test_01_02.txt");
    const lines = try aoc2025zig.readFileLines(std.heap.page_allocator, "input_01.txt");

    const codes = try aoc2025zig.parseDay1(std.heap.page_allocator, lines);
    var position: i32 = 50;
    var zeroes: i32 = 0;
    var part2: i32 = 0;
    for (codes.items) |code| {
        const new_pos, const new_wraps = newPosition(position, code);
        position = new_pos;
        part2 += @as(i32, new_wraps);
        if (position == 0) {
            zeroes += 1;
        }
    }
    std.debug.print("Day 1, Part 1: {d}\n", .{zeroes});
    std.debug.print("Day 1, Part 2: {d}\n", .{part2 + zeroes});
}

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

pub fn day2() !void {
    // const lines = try aoc2025zig.readFileLines(std.heap.page_allocator, "input_test_02_01.txt");
    // const lines = try aoc2025zig.readFileLines(std.heap.page_allocator, "input_test_01_02.txt");
    const lines = try aoc2025zig.readFileLines(std.heap.page_allocator, "input_02.txt");
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

    std.debug.print("Day 2, Part 1: {d}\n", .{sum});
    std.debug.print("Day 2, Part 2: {d}\n", .{sum2});
}

pub fn main() !void {
    try day1();
    try day2();
}
