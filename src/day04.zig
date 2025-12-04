const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve() !void {
    _ = try solveWithFile(std.heap.page_allocator, "input_04.txt");
}

const Point = struct { x: usize, y: usize };

pub fn checkNeighbors(grid: std.ArrayList([]const u8), removed: std.AutoHashMap(Point, bool), x: usize, y: usize, width: usize, height: usize) u8 {
    var count: u8 = 0;
    for (@max(@as(i32, @intCast(x)) - 1, 0)..@min(x + 1, width - 1) + 1) |nx| {
        for (@max(@as(i32, @intCast(y)) - 1, 0)..@min(y + 1, height - 1) + 1) |ny| {
            if (nx == x and ny == y) continue;
            if (grid.items[ny][nx] == '@' and !removed.contains(Point{ .x = nx, .y = ny })) {
                count += 1;
            }
        }
    }
    return count;
}

pub fn getRemovableRolls(allocator: std.mem.Allocator, removed: std.AutoHashMap(Point, bool), grid: std.ArrayList([]const u8), width: usize, height: usize) !std.ArrayList(Point) {
    var result: std.ArrayList(Point) = .empty;
    for (0..height) |y| {
        for (0..width) |x| {
            const pos = Point{ .x = x, .y = y };
            if (grid.items[y][x] != '@' or removed.contains(pos)) continue;
            const occupiedNeighbors = checkNeighbors(grid, removed, x, y, width, height);
            // std.debug.print("Pos ({d},{d}) = {d}\n", .{ x, y, occupiedNeighbors });
            if (occupiedNeighbors < 4) {
                // std.debug.print("OK positions ({d},{d}) = {d}\n", .{ x, y, occupiedNeighbors });
                try result.append(allocator, Point{ .x = x, .y = y });
            }
        }
    }
    // try result.append(allocator, Point{ .x = 0, .y = 0 });
    return result;
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

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arenaAllocator = arena.allocator();

    var removed = std.AutoHashMap(Point, bool).init(arenaAllocator);
    var removable = try getRemovableRolls(arenaAllocator, removed, lines, width, height);
    sum = @as(u64, removable.items.len);
    sum2 = sum;
    while (removable.items.len > 0) {
        for (removable.items) |pos| {
            try removed.put(pos, true);
        }
        removable = try getRemovableRolls(arenaAllocator, removed, lines, width, height);
        sum2 += @as(u64, removable.items.len);
    }

    std.debug.print("Day 4, Part 1: {d}\n", .{sum});
    std.debug.print("Day 4, Part 2: {d}\n", .{sum2});

    return .{ sum, sum2 };
}

test "day3 solve test" {
    const result = try solveWithFile(std.testing.allocator, "input_test_04_01.txt");
    try std.testing.expect(result[0] == 13);
    try std.testing.expect(result[1] == 43);
}
