const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve(runBenchmark: bool) !void {
    _ = try solveWithFile(runBenchmark, std.heap.page_allocator, "input_06.txt");
}

const Operator = enum { Add, Multiply };

fn solveWithFile(runBenchmark: bool, allocator: std.mem.Allocator, path: []const u8) !struct { u128, u128 } {
    var lines = try aoc2025zig.readFileLines(allocator, path, true);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    const t0 = try std.time.Instant.now();
    _ = runBenchmark;

    var part1: u128 = 0;
    var part2: u128 = 0;

    part1 += 0;
    part2 += 0;

    const rows = lines.items.len - 1;
    const cols = lines.items[0].len;
    var numbers: std.ArrayList(u128) = .empty;
    for (0..rows) |_| {
        try numbers.append(allocator, 0);
    }
    defer numbers.deinit(allocator);

    var result: u128 = 0;
    var operator: Operator = undefined;
    var isFirstCol: bool = true;

    for (0..cols) |col| {
        var columnDelimiterOrEnd = true;
        var number: u128 = 0;
        for (0..rows) |row| {
            const c = lines.items[row][col];
            if (c == ' ') {
                continue;
            }
            columnDelimiterOrEnd = false;
            numbers.items[row] = numbers.items[row] * 10 + @as(u128, c - '0');
            number = number * 10 + @as(u128, c - '0');
        }
        if (isFirstCol) {
            switch (lines.items[rows][col]) {
                '+' => {
                    operator = .Add;
                    result = 0;
                },
                '*' => {
                    operator = .Multiply;
                    result = 1;
                },
                else => {},
            }
            isFirstCol = false;
        }
        if (!columnDelimiterOrEnd) {
            switch (operator) {
                .Add => result += number,
                .Multiply => result *= number,
            }
        }
        columnDelimiterOrEnd = columnDelimiterOrEnd or col == cols - 1;
        if (columnDelimiterOrEnd) {
            var result1: u128 = switch (operator) {
                .Add => 0,
                .Multiply => 1,
            };

            for (numbers.items) |*num| {
                switch (operator) {
                    .Add => result1 += num.*,
                    .Multiply => result1 *= num.*,
                }
                num.* = 0;
            }

            part1 += result1;
            operator = undefined;
            part2 += result;

            isFirstCol = true;
        }
    }

    const t1 = try std.time.Instant.now();
    const diff = std.time.Instant.since(t1, t0);
    std.debug.print("Day 6 (faster) solved in {d} ns\n", .{diff});

    std.debug.print("Day 6 (faster), Part 1: {d}\n", .{part1});
    std.debug.print("Day 6 (faster), Part 2: {d}\n", .{part2});

    return .{ part1, part2 };
}

test "day6 solve test" {
    const result = try solveWithFile(false, std.testing.allocator, "input_test_06_01.txt");
    try std.testing.expectEqual(4277556, result[0]);
    try std.testing.expectEqual(3263827, result[1]);
}
