const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve() !void {
    _ = try solveWithFile(std.heap.page_allocator, "input_07.txt");
}

fn traverse(cache: *std.AutoHashMap(struct { usize, usize }, u64), lines: [][]u8, x: usize, y: usize) !u64 {
    if (y == lines.len) {
        return 1;
    }
    if (cache.contains(.{ x, y })) {
        return cache.get(.{ x, y }).?;
    }
    var sum: u64 = 0;
    if (lines[y][x] == '^') {
        if (x > 0) {
            sum += try traverse(cache, lines, x - 1, y);
        }
        if (x < lines[y].len - 1) {
            sum += try traverse(cache, lines, x + 1, y);
        }
    } else {
        sum = try traverse(cache, lines, x, y + 1);
    }
    try cache.put(.{ x, y }, sum);
    return sum;
}

fn solveWithFile(allocator: std.mem.Allocator, path: []const u8) !struct { u128, u128 } {
    var lines = try aoc2025zig.readFileLines(allocator, path, true);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    const t0 = try std.time.Instant.now();

    var part1: u128 = 0;
    var part2: u128 = 0;

    part1 += 0;
    part2 += 0;

    var startX: usize = 0;
    for (1..lines.items.len) |y| {
        const prevLine = lines.items[y - 1];
        var line = lines.items[y];
        for (0..line.len) |x| {
            if (prevLine[x] == 'S' and line[x] == '.') {
                startX = x; // Capture for part 2
                line[x] = '|';
            } else if (prevLine[x] == '|' and line[x] == '.') {
                line[x] = '|';
            } else if (prevLine[x] == '|' and line[x] == '^') {
                if (x > 0) {
                    line[x - 1] = '|';
                }
                if (x < line.len - 1) {
                    line[x + 1] = '|';
                }
                part1 += 1;
            }
        }
    }

    var cache = std.AutoHashMap(struct { usize, usize }, u64).init(allocator);
    try cache.ensureTotalCapacity(@intCast(part1));
    defer cache.deinit();
    part2 = try traverse(&cache, lines.items, startX, 0);

    const t1 = try std.time.Instant.now();
    const diff = std.time.Instant.since(t1, t0);
    std.debug.print("Day 7 solved in {d} ns\n", .{diff});

    std.debug.print("Day 7, Part 1: {d}\n", .{part1});
    std.debug.print("Day 7, Part 2: {d}\n", .{part2});

    return .{ part1, part2 };
}

test "day7 solve test" {
    const result = try solveWithFile(std.testing.allocator, "input_test_07_01.txt");
    try std.testing.expectEqual(21, result[0]);
    try std.testing.expectEqual(40, result[1]);
}
