const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn newPosition(oldPos: i32, code: aoc2025zig.Code) struct { i32, u32 } {
    var newPos = oldPos;
    var wraps: u32 = 0;
    if (code.dir == .left) {
        const steps = code.steps;
        newPos -= steps;
        newPos = @mod(newPos, 100);
        if (steps > oldPos) {
            wraps += @as(u32, @intCast(steps - oldPos)) / 100 + 1;

            if (newPos == 0 or oldPos == 0) {
                wraps -= 1;
            }
        }
    } else {
        const steps = code.steps;
        newPos += steps;
        newPos = @mod(newPos, 100);
        if (oldPos + steps > 99) {
            wraps += @as(u32, @intCast(oldPos + steps - 100)) / 100 + 1;

            if (newPos == 0) {
                wraps -= 1;
            }
        }
    }

    return .{ newPos, wraps };
}

test "newPosition basic tests" {
    var pos = newPosition(50, aoc2025zig.Code{ .dir = .left, .steps = 68 });
    try std.testing.expect(std.meta.eql(pos, .{ 82, 1 }));

    pos = newPosition(82, aoc2025zig.Code{ .dir = .left, .steps = 30 });
    try std.testing.expect(std.meta.eql(pos, .{ 52, 0 }));

    pos = newPosition(52, aoc2025zig.Code{ .dir = .right, .steps = 48 });
    try std.testing.expect(std.meta.eql(pos, .{ 0, 0 }));

    pos = newPosition(0, aoc2025zig.Code{ .dir = .left, .steps = 5 });
    try std.testing.expect(std.meta.eql(pos, .{ 95, 0 }));

    pos = newPosition(95, aoc2025zig.Code{ .dir = .right, .steps = 60 });
    try std.testing.expect(std.meta.eql(pos, .{ 55, 1 }));

    pos = newPosition(55, aoc2025zig.Code{ .dir = .left, .steps = 55 });
    try std.testing.expect(std.meta.eql(pos, .{ 0, 0 }));

    pos = newPosition(0, aoc2025zig.Code{ .dir = .left, .steps = 1 });
    try std.testing.expect(std.meta.eql(pos, .{ 99, 0 }));

    pos = newPosition(99, aoc2025zig.Code{ .dir = .left, .steps = 99 });
    try std.testing.expect(std.meta.eql(pos, .{ 0, 0 }));

    pos = newPosition(0, aoc2025zig.Code{ .dir = .right, .steps = 14 });
    try std.testing.expect(std.meta.eql(pos, .{ 14, 0 }));

    pos = newPosition(14, aoc2025zig.Code{ .dir = .left, .steps = 82 });
    try std.testing.expect(std.meta.eql(pos, .{ 32, 1 }));

    pos = newPosition(99, aoc2025zig.Code{ .dir = .right, .steps = 1 });
    try std.testing.expect(std.meta.eql(pos, .{ 0, 0 }));

    pos = newPosition(99, aoc2025zig.Code{ .dir = .right, .steps = 2 });
    try std.testing.expect(std.meta.eql(pos, .{ 1, 1 }));

    pos = newPosition(99, aoc2025zig.Code{ .dir = .right, .steps = 100 });
    try std.testing.expect(std.meta.eql(pos, .{ 99, 1 }));

    pos = newPosition(99, aoc2025zig.Code{ .dir = .right, .steps = 101 });
    try std.testing.expect(std.meta.eql(pos, .{ 0, 1 }));

    pos = newPosition(99, aoc2025zig.Code{ .dir = .left, .steps = 100 });
    try std.testing.expect(std.meta.eql(pos, .{ 99, 1 }));

    pos = newPosition(99, aoc2025zig.Code{ .dir = .left, .steps = 101 });
    try std.testing.expect(std.meta.eql(pos, .{ 98, 1 }));

    pos = newPosition(99, aoc2025zig.Code{ .dir = .left, .steps = 200 });
    try std.testing.expect(std.meta.eql(pos, .{ 99, 2 }));

    pos = newPosition(99, aoc2025zig.Code{ .dir = .left, .steps = 199 });
    try std.testing.expect(std.meta.eql(pos, .{ 0, 1 }));
}

pub fn solve(runBenchmark: bool) !void {
    // const lines = try aoc2025zig.readFileLines(std.heap.page_allocator, "input_test_01_01.txt");
    // const lines = try aoc2025zig.readFileLines(std.heap.page_allocator, "input_test_01_02.txt");
    try solveWithFile(runBenchmark, std.heap.page_allocator, "input_01.txt");
}

fn solveWithFile(runBenchmark: bool, allocator: std.mem.Allocator, path: []const u8) !void {
    var lines = try aoc2025zig.readFileLines(allocator, path, false);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    const t0 = try std.time.Instant.now();
    _ = runBenchmark;

    var codes = try aoc2025zig.parseDay1(allocator, lines);
    defer {
        codes.deinit(allocator);
    }
    var position: i32 = 50;
    var zeroes: u32 = 0;
    var part2: u32 = 0;
    for (codes.items) |code| {
        const new_pos, const new_wraps = newPosition(position, code);
        position = new_pos;
        part2 += new_wraps;
        if (position == 0) {
            zeroes += 1;
        }
    }

    const t1 = try std.time.Instant.now();
    const diff = std.time.Instant.since(t1, t0);
    std.debug.print("Day 1 solved in {d} ns\n", .{diff});

    std.debug.print("Day 1, Part 1: {d}\n", .{zeroes});
    std.debug.print("Day 1, Part 2: {d}\n", .{part2 + zeroes});
}

test "day1 solve test" {
    try solveWithFile(false, std.testing.allocator, "input_test_01_01.txt");
}
