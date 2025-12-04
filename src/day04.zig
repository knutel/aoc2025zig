const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve() !void {
    _ = try solveWithFile(std.heap.page_allocator, "input_04.txt");
}

const Point = struct { x: usize, y: usize };

pub fn checkNeighbors(rolls: std.AutoHashMap(Point, bool), pos: Point) u8 {
    var count: u8 = 0;
    for (@max(@as(i32, @intCast(pos.x)) - 1, 0)..pos.x + 1 + 1) |nx| {
        for (@max(@as(i32, @intCast(pos.y)) - 1, 0)..pos.y + 1 + 1) |ny| {
            if (nx == pos.x and ny == pos.y) continue;
            if (rolls.contains(Point{ .x = nx, .y = ny })) {
                count += 1;
            }
        }
    }
    return count;
}

pub fn getRemovableRolls(allocator: std.mem.Allocator, rolls: std.AutoHashMap(Point, bool)) !std.ArrayList(Point) {
    var result: std.ArrayList(Point) = .empty;
    var item_iter = rolls.iterator();
    while (item_iter.next()) |roll| {
        const pos = roll.key_ptr;
        const occupiedNeighbors = checkNeighbors(rolls, Point{ .x = pos.x, .y = pos.y });
        // std.debug.print("Pos ({d},{d}) = {d}\n", .{ pos.x, pos.y, occupiedNeighbors });
        if (occupiedNeighbors < 4) {
            // std.debug.print("OK positions ({d},{d}) = {d}\n", .{ pos.x, pos.y, occupiedNeighbors });
            try result.append(allocator, Point{ .x = pos.x, .y = pos.y });
        }
    }

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

    var rolls = std.AutoHashMap(Point, bool).init(arenaAllocator);
    for (0..height) |y| {
        for (0..width) |x| {
            if (lines.items[y][x] == '@') {
                try rolls.put(Point{ .x = x, .y = y }, true);
            }
        }
    }
    var removable = try getRemovableRolls(arenaAllocator, rolls);
    sum = @as(u64, removable.items.len);
    sum2 = sum;
    while (removable.items.len > 0) {
        for (removable.items) |pos| {
            _ = rolls.remove(pos);
        }
        removable = try getRemovableRolls(arenaAllocator, rolls);
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
