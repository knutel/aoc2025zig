const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve() !void {
    _ = try solveWithFile(std.heap.page_allocator, "input_06.txt");
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

    var opIter = std.mem.tokenizeScalar(u8, lines.items[lines.items.len - 1], ' ');
    var operators: std.ArrayList(u8) = .empty;
    var results: std.ArrayList(u128) = .empty;
    defer results.deinit(allocator);
    defer operators.deinit(allocator);
    while (opIter.next()) |operator| {
        try operators.append(allocator, operator[0]);
        switch (operator[0]) {
            '+' => try results.append(allocator, 0),
            '*' => try results.append(allocator, 1),
            else => return error.InvalidOperator,
        }
    }

    for (lines.items[0 .. lines.items.len - 1]) |line| {
        var valueIter = std.mem.tokenizeScalar(u8, line, ' ');
        var index: usize = 0;
        while (valueIter.next()) |valueStr| {
            const value = try std.fmt.parseInt(u128, valueStr, 10);
            const operator = operators.items[index];
            // std.debug.print("Value: {d}, Operator: {c}\n", .{ value, operator });
            switch (operator) {
                '+' => results.items[index] += value,
                '*' => results.items[index] *= value,
                else => return error.InvalidOperator,
            }
            index += 1;
        }
    }

    for (results.items) |result| {
        part1 += result;
    }

    var newLines: std.ArrayList([]const u8) = .empty;
    defer {
        for (newLines.items) |line| {
            allocator.free(line);
        }
        newLines.deinit(allocator);
    }
    for (0..lines.items[0].len) |row| {
        var newLine = try allocator.alloc(u8, lines.items.len - 1);
        for (0..lines.items.len - 1) |col| {
            newLine[col] = lines.items[col][row];
        }
        // std.debug.print("NewLine: {s}\n", .{newLine});
        try newLines.append(allocator, newLine);
    }

    for (operators.items, results.items) |operator, *result| {
        switch (operator) {
            '+' => result.* = 0,
            '*' => result.* = 1,
            else => return error.InvalidOperator,
        }
    }

    var operatorIndex: usize = 0;
    for (newLines.items) |line| {
        if (std.mem.trim(u8, line, " ").len == 0) {
            operatorIndex += 1;
            continue;
        }
        // std.debug.print("Processing line: {s}\n", .{line});
        const value = try std.fmt.parseInt(u128, std.mem.trim(u8, line, " "), 10);
        const operator = operators.items[operatorIndex];
        // std.debug.print("Value: {d}, Operator: {c}\n", .{ value, operator });
        switch (operator) {
            '+' => results.items[operatorIndex] += value,
            '*' => results.items[operatorIndex] *= value,
            else => return error.InvalidOperator,
        }
    }

    for (results.items) |result| {
        part2 += result;
    }

    const t1 = try std.time.Instant.now();
    const diff = std.time.Instant.since(t1, t0);
    std.debug.print("Day 6 solved in {d} ns\n", .{diff});

    std.debug.print("Day 6, Part 1: {d}\n", .{part1});
    std.debug.print("Day 6, Part 2: {d}\n", .{part2});

    return .{ part1, part2 };
}

test "day6 solve test" {
    const result = try solveWithFile(std.testing.allocator, "input_test_06_01.txt");
    try std.testing.expectEqual(4277556, result[0]);
    try std.testing.expectEqual(3263827, result[1]);
}
