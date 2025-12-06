const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve() !void {
    _ = try solveWithFile(std.heap.page_allocator, "input_05.txt");
}

const Range = struct { start: u64, end: u64 };

fn rangeLessThan(context: void, a: Range, b: Range) bool {
    _ = context;
    return a.start < b.start;
}

fn mergeOverlappingRangesSlow(ranges: *std.ArrayList(Range)) void {
    std.mem.sort(Range, ranges.items, {}, rangeLessThan);
    var length = ranges.items.len;
    while (true) {
        for (ranges.items[0 .. ranges.items.len - 1], ranges.items[1..], 0..) |*a, b, i| {
            if (a.end >= b.start) {
                a.end = @max(a.end, b.end);
                _ = ranges.orderedRemove(i + 1);
                break;
            }
        }
        if (length == ranges.items.len) {
            break;
        }
        length = ranges.items.len;
    }
}

const ParseState = enum { InRanges, InIngredients, EOF };

fn parseInput(allocator: std.mem.Allocator, lines: *std.ArrayList([]const u8), ranges: *std.ArrayList(Range), ingredients: *std.ArrayList(u64)) !void {
    var state = ParseState.InRanges;
    for (lines.items) |line| {
        switch (state) {
            .InRanges => {
                if (line.len == 0) {
                    state = ParseState.InIngredients;
                    continue;
                }
                var it = std.mem.splitScalar(u8, line, '-');
                const first = it.next() orelse return error.InvalidInput;
                const second = it.next() orelse return error.InvalidInput;
                const first_num = try std.fmt.parseInt(u64, first, 10);
                const second_num = try std.fmt.parseInt(u64, second, 10);
                try ranges.append(allocator, Range{ .start = first_num, .end = second_num });
            },
            .InIngredients => {
                if (line.len == 0) {
                    state = ParseState.EOF;
                    continue;
                }
                const num = try std.fmt.parseInt(u64, line, 10);
                try ingredients.append(allocator, num);
            },
            .EOF => return,
        }
    }
}

fn solveWithFile(allocator: std.mem.Allocator, path: []const u8) !struct { u64, u64 } {
    var lines = try aoc2025zig.readFileLines(allocator, path);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    const t0 = try std.time.Instant.now();
    var ranges: std.ArrayList(Range) = .empty;
    defer ranges.deinit(allocator);
    var ingredients: std.ArrayList(u64) = .empty;
    defer ingredients.deinit(allocator);

    try parseInput(allocator, &lines, &ranges, &ingredients);

    mergeOverlappingRangesSlow(&ranges);

    var part1: u64 = 0;
    var part2: u64 = 0;

    for (ingredients.items) |ing| {
        var valid = false;
        for (ranges.items) |range| {
            if (ing >= range.start and ing <= range.end) {
                valid = true;
                break;
            }
        }
        if (valid) {
            part1 += 1;
        }
    }

    for (ranges.items) |range| {
        part2 += range.end - range.start + 1;
    }

    const t1 = try std.time.Instant.now();
    const diff = std.time.Instant.since(t1, t0);
    std.debug.print("Day 5 solved in {d} ns\n", .{diff});

    std.debug.print("Day 5, Part 1: {d}\n", .{part1});
    std.debug.print("Day 5, Part 2: {d}\n", .{part2});

    return .{ part1, part2 };
}

test "day5 solve test" {
    const result = try solveWithFile(std.testing.allocator, "input_test_05_01.txt");
    try std.testing.expect(result[0] == 3);
    try std.testing.expect(result[1] == 14);
}
