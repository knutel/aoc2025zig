const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve() !void {
    _ = try solveWithFile(std.heap.page_allocator, "input_09.txt");
}

const Point = struct { x: i64, y: i64 };

const Area = struct { a: usize, b: usize, area: i64 };

const Edge = struct { x0: i64, y0: i64, x1: i64, y1: i64 };

fn areaLargerThan(context: void, a: Area, b: Area) bool {
    _ = context;
    return a.area > b.area;
}

fn solveWithFile(allocator: std.mem.Allocator, path: []const u8) !struct { i64, i64 } {
    var lines = try aoc2025zig.readFileLines(allocator, path, true);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    var part1: i64 = 0;
    var part2: i64 = 0;

    const iterations = 1000;
    var totalDuration: u64 = 0;

    for (0..iterations) |_| {
        const t0 = try std.time.Instant.now();

        part1 = 0;
        part2 = 0;

        var areas: [(496 * 496) / 2]Area = undefined;
        var points: [497]Point = undefined;
        var pointCount: usize = 0;
        var leftmost: usize = 1000;

        for (lines.items, 0..) |line, i| {
            var it = std.mem.tokenizeScalar(u8, line, ',');
            const x = try std.fmt.parseInt(i64, it.next().?, 10);
            const y = try std.fmt.parseInt(i64, it.next().?, 10);
            points[i] = .{ .x = x, .y = y };
            pointCount += 1;
            if (leftmost == 1000 or points[leftmost].x > x) {
                leftmost = i;
            }
        }

        // Get all possible rectangles and pick the largest for part 1.
        var areaCount: usize = 0;
        for (0..pointCount) |a| {
            for (a + 1..pointCount) |b| {
                const width = @abs(points[a].x - points[b].x) + 1;
                const height = @abs(points[a].y - points[b].y) + 1;
                const area = width * height;
                areas[areaCount] = .{ .a = a, .b = b, .area = @intCast(area) };
                areaCount += 1;
            }
        }

        const usedAreas = areas[0..areaCount];
        std.mem.sort(Area, usedAreas, {}, areaLargerThan);

        part1 = usedAreas[0].area;

        // Make sure the starting edge and previous and next point are ordered counter clockwise.
        var beforeAIndex = (leftmost + pointCount - 1) % pointCount;
        var aIndex = leftmost;
        var bIndex = leftmost + 1;
        var afterBIndex = (bIndex + 1) % pointCount;
        var delta: usize = pointCount + 1;
        if (points[aIndex].x != points[bIndex].x) {
            beforeAIndex = (leftmost + pointCount - 2) % pointCount;
            aIndex = (leftmost + pointCount - 1) % pointCount;
            bIndex = leftmost;
            afterBIndex = (leftmost + 1) % pointCount;
        }
        if (points[aIndex].x != points[bIndex].x) {
            unreachable;
        }
        if (points[aIndex].y > points[bIndex].y) {
            var temp = aIndex;
            aIndex = bIndex;
            bIndex = temp;
            temp = beforeAIndex;
            beforeAIndex = afterBIndex;
            afterBIndex = temp;
            delta = pointCount - 1;
        }

        // Go around the perimeter and create an outer perimeter that is outside the polygon.
        var outerPerimeter: [496]Edge = undefined;

        for (0..pointCount) |edgeIndex| {
            const beforeA = points[beforeAIndex];
            const afterB = points[afterBIndex];
            const a = points[aIndex];
            const b = points[bIndex];
            var x0: i64 = undefined;
            var y0: i64 = undefined;
            var x1: i64 = undefined;
            var y1: i64 = undefined;

            if (a.x == b.x) {
                // Vertical
                if (a.y < b.y) {
                    // Down
                    x0 = a.x - 1;
                    x1 = a.x - 1;
                } else {
                    // Up
                    x0 = a.x + 1;
                    x1 = a.x + 1;
                }
                if (beforeA.x > a.x) {
                    // Came from left
                    y0 = a.y - 1;
                } else {
                    // Came from right
                    y0 = a.y + 1;
                }

                if (afterB.x > b.x) {
                    // Going left
                    y1 = b.y + 1;
                } else {
                    // Going right
                    y1 = b.y - 1;
                }
            } else if (a.y == b.y) {
                // Horizontal
                if (a.x < b.x) {
                    // Left
                    y0 = a.y + 1;
                    y1 = a.y + 1;
                } else {
                    // Right
                    y0 = a.y - 1;
                    y1 = a.y - 1;
                }
                if (beforeA.y > a.y) {
                    // Came from below
                    x0 = a.x + 1;
                } else {
                    // Came from above
                    x0 = a.x - 1;
                }

                if (afterB.y > b.y) {
                    // Going down
                    x1 = b.x - 1;
                } else {
                    // Going up
                    x1 = b.x + 1;
                }
            }
            outerPerimeter[edgeIndex] = .{ .x0 = x0, .y0 = y0, .x1 = x1, .y1 = y1 };

            beforeAIndex = (beforeAIndex + delta) % pointCount;
            aIndex = (aIndex + delta) % pointCount;
            bIndex = (bIndex + delta) % pointCount;
            afterBIndex = (afterBIndex + delta) % pointCount;
        }

        // Iterate over rectangles in decreasing size order and check if the outer perimeter overlap.
        // The outer perimeter is on the outside, so if overlap, the rectangle is not fully inside the polygon.
        for (usedAreas) |area| {
            const x0: usize = @intCast(@min(points[area.a].x, points[area.b].x));
            const y0: usize = @intCast(@min(points[area.a].y, points[area.b].y));
            const x1: usize = @intCast(@max(points[area.a].x, points[area.b].x));
            const y1: usize = @intCast(@max(points[area.a].y, points[area.b].y));

            var useable = true;

            for (outerPerimeter[0..pointCount]) |o| {
                if (o.x0 == o.x1) {
                    const y2: usize = @intCast(@min(o.y0, o.y1));
                    const y3: usize = @intCast(@max(o.y0, o.y1));

                    if (y2 > y1 or y3 < y0) {} else {
                        if (o.x0 >= x0 and o.x0 <= x1) {
                            useable = false;
                        }
                    }
                } else if (o.y0 == o.y1) {
                    const x2: usize = @intCast(@min(o.x0, o.x1));
                    const x3: usize = @intCast(@max(o.x0, o.x1));

                    if (x2 > x1 or x3 < x0) {} else {
                        if (o.y0 >= y0 and o.y0 <= y1) {
                            useable = false;
                        }
                    }
                } else {
                    unreachable;
                }
                if (!useable) {
                    break;
                }
            }
            if (useable) {
                part2 = area.area;
                break;
            }
        }

        const t1 = try std.time.Instant.now();
        const diff = std.time.Instant.since(t1, t0);
        totalDuration += diff;
    }
    std.debug.print("Day 9 solved in {d} ns\n", .{totalDuration / iterations});

    std.debug.print("Day 9, Part 1: {d}\n", .{part1});
    std.debug.print("Day 9, Part 2: {d}\n", .{part2});

    return .{ part1, part2 };
}

test "day9 solve test" {
    const result = try solveWithFile(std.testing.allocator, "input_test_09_01.txt");
    try std.testing.expectEqual(50, result[0]);
    try std.testing.expectEqual(24, result[1]);
}

test "day9 solve test reversed" {
    const result = try solveWithFile(std.testing.allocator, "input_test_09_02.txt");
    try std.testing.expectEqual(50, result[0]);
    try std.testing.expectEqual(24, result[1]);
}
