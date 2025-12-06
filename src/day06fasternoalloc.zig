const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve() !void {
    _ = try solveWithFile(std.heap.page_allocator, "input_06.txt");
}

const Operator = enum { Add, Multiply, Unknown };

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

    const lineitems = lines.items;
    const rows = lineitems.len - 1;
    const cols = lineitems[0].len;
    var numbers = [_]u128{0} ** 5;

    var result2: u128 = 0;
    var operator: Operator = Operator.Unknown;

    for (0..cols) |col| {
        var columnDelimiterOrEnd = true;
        var number: u128 = 0;
        for (0..rows) |row| {
            const c = lineitems[row][col];
            if (c == ' ') {
                continue;
            }
            columnDelimiterOrEnd = false;
            const val = @as(u128, c - '0');
            numbers[row] = numbers[row] * 10 + val;
            number = number * 10 + val;
        }
        if (operator == Operator.Unknown) {
            switch (lineitems[rows][col]) {
                '+' => {
                    operator = .Add;
                    result2 = 0;
                },
                '*' => {
                    operator = .Multiply;
                    result2 = 1;
                },
                else => {},
            }
        }
        if (!columnDelimiterOrEnd) {
            switch (operator) {
                .Add => result2 += number,
                .Multiply => result2 *= number,
                else => {},
            }
        }
        columnDelimiterOrEnd = columnDelimiterOrEnd or col == cols - 1;
        if (columnDelimiterOrEnd) {
            var result1: u128 = switch (operator) {
                .Add => 0,
                .Multiply => 1,
                else => 0,
            };

            switch (operator) {
                .Add => {
                    for (0..rows) |i| {
                        result1 += numbers[i];
                        //numbers[i] = 0;
                    }
                },
                .Multiply => {
                    for (0..rows) |i| {
                        result1 *= numbers[i];
                        //numbers[i] = 0;
                    }
                },
                else => {},
            }
            @memset(&numbers, 0);

            part1 += result1;
            operator = Operator.Unknown;
            part2 += result2;
        }
    }

    const t1 = try std.time.Instant.now();
    const diff = std.time.Instant.since(t1, t0);
    std.debug.print("Day 6 (fasternoalloc) solved in {d} ns\n", .{diff});

    std.debug.print("Day 6 (fasternoalloc), Part 1: {d}\n", .{part1});
    std.debug.print("Day 6 (fasternoalloc), Part 2: {d}\n", .{part2});

    return .{ part1, part2 };
}

test "day6 solve test" {
    const result = try solveWithFile(std.testing.allocator, "input_test_06_01.txt");
    try std.testing.expectEqual(4277556, result[0]);
    try std.testing.expectEqual(3263827, result[1]);
}
