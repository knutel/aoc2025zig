const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve() !void {
    _ = try solveWithFile(std.heap.page_allocator, "input_06.txt");
}

const Operator = enum { Add, Multiply };

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

    var operator: Operator = undefined;
    var numbers: std.ArrayList(u128) = .empty;
    for (0..lines.items.len - 1) |_| {
        try numbers.append(allocator, 0);
    }
    defer numbers.deinit(allocator);

    for (0..lines.items[0].len) |col| {
        var columnDelimiterOrEnd = true;
        for (0..lines.items.len - 1) |row| {
            const c = lines.items[row][col];
            if (c == ' ') {
                continue;
            }
            columnDelimiterOrEnd = false;
            numbers.items[row] = numbers.items[row] * 10 + @as(u128, c - '0');
        }
        operator = switch (lines.items[lines.items.len - 1][col]) {
            '+' => .Add,
            '*' => .Multiply,
            else => operator,
        };
        columnDelimiterOrEnd = columnDelimiterOrEnd or col == lines.items[0].len - 1;
        if (columnDelimiterOrEnd) {
            var result: u128 = switch (operator) {
                .Add => 0,
                .Multiply => 1,
            };

            for (numbers.items) |*num| {
                switch (operator) {
                    .Add => result += num.*,
                    .Multiply => result *= num.*,
                }
                num.* = 0;
            }

            part1 += result;
        }
    }

    var result: u128 = 0;
    for (0..lines.items[0].len) |col| {
        var columnDelimiterOrEnd = true;
        var number: u128 = 0;
        for (0..lines.items.len - 1) |row| {
            const c = lines.items[row][col];
            if (c == ' ') {
                continue;
            }
            columnDelimiterOrEnd = false;
            number = number * 10 + @as(u128, c - '0');
        }
        //std.debug.print("Number: {d}\n", .{number});
        switch (lines.items[lines.items.len - 1][col]) {
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
        if (!columnDelimiterOrEnd) {
            switch (operator) {
                .Add => result += number,
                .Multiply => result *= number,
            }
        }
        columnDelimiterOrEnd = columnDelimiterOrEnd or col == lines.items[0].len - 1;
        if (columnDelimiterOrEnd) {
            operator = undefined;
            part2 += result;
        }
    }

    const t1 = try std.time.Instant.now();
    const diff = std.time.Instant.since(t1, t0);
    std.debug.print("Day 6 (fast) solved in {d} ns\n", .{diff});

    std.debug.print("Day 6 (fast), Part 1: {d}\n", .{part1});
    std.debug.print("Day 6 (fast), Part 2: {d}\n", .{part2});

    return .{ part1, part2 };
}

test "day6 solve test" {
    const result = try solveWithFile(std.testing.allocator, "input_test_06_01.txt");
    try std.testing.expectEqual(4277556, result[0]);
    try std.testing.expectEqual(3263827, result[1]);
}
