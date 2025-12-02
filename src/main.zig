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

pub fn main() !void {
    try day1();
}
