const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve() !void {
    _ = try solveWithFile(std.heap.page_allocator, "input_04.txt");
}

pub fn checkNeighbors(grid: std.ArrayList([]const u8), x: usize, y: usize, width: usize, height: usize) u8 {
    var count: u8 = 0;
    for (@max(@as(i32, @intCast(x)) - 1, 0)..@min(x + 1, width - 1) + 1) |nx| {
        for (@max(@as(i32, @intCast(y)) - 1, 0)..@min(y + 1, height - 1) + 1) |ny| {
            if (nx == x and ny == y) continue;
            if (grid.items[ny][nx] == '@') {
                count += 1;
            }
        }
    }
    return count;
}

pub fn solveWithFile(allocator: std.mem.Allocator, path: []const u8) !struct { u64, u64 } {
    var lines = try aoc2025zig.readFileLines(allocator, path);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    var sum: u64 = 0;
    var sum2: u64 = 0;

    sum += 0;
    sum2 += 0;

    const width = lines.items[0].len;
    const height = lines.items.len;

    for (0..height) |y| {
        for (0..width) |x| {
            if (lines.items[y][x] != '@') continue;
            const occupiedNeighbors = checkNeighbors(lines, x, y, width, height);
            std.debug.print("Pos ({d},{d}) = {d}\n", .{ x, y, occupiedNeighbors });
            if (occupiedNeighbors < 4) {
                sum += 1;
                std.debug.print("OK positions ({d},{d}) = {d}\n", .{ x, y, occupiedNeighbors });
            }
        }
    }

    std.debug.print("Day 4, Part 1: {d}\n", .{sum});
    std.debug.print("Day 4, Part 2: {d}\n", .{sum2});

    return .{ sum, sum2 };
}

test "day3 solve test" {
    const result = try solveWithFile(std.testing.allocator, "input_test_04_01.txt");
    try std.testing.expect(result[0] == 13);
    try std.testing.expect(result[1] == 0);
}
