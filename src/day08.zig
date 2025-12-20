const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve(runBenchmark: bool) !void {
    _ = try solveWithFile(runBenchmark, std.heap.page_allocator, "input_08.txt");
}

const Point = struct { x: i64, y: i64, z: i64 };

const Distance = struct { a: usize, b: usize, distance: i64 };

fn distanceLessThan(context: void, a: Distance, b: Distance) bool {
    _ = context;
    return a.distance < b.distance;
}

fn solveWithFile(runBenchmark: bool, allocator: std.mem.Allocator, path: []const u8) !struct { i64, i64 } {
    var lines = try aoc2025zig.readFileLines(allocator, path, true);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    var part1: i64 = 0;
    var part2: i64 = 0;

    const iterations: usize = if (runBenchmark) 100 else 1;
    var totalDuration: u64 = 0;
    for (0..iterations) |_| {
        const t0 = try std.time.Instant.now();

        part1 = 0;
        part2 = 0;

        var distances: [1000000 / 2]Distance = undefined;
        var points: [1000]Point = undefined;
        var pointCount: usize = 0;
        for (lines.items, 0..) |line, i| {
            var it = std.mem.tokenizeScalar(u8, line, ',');
            const x = try std.fmt.parseInt(i64, it.next().?, 10);
            const y = try std.fmt.parseInt(i64, it.next().?, 10);
            const z = try std.fmt.parseInt(i64, it.next().?, 10);
            points[i] = .{ .x = x, .y = y, .z = z };
            pointCount += 1;
        }

        var distanceCount: usize = 0;
        for (0..pointCount) |a| {
            // std.debug.print("Point {d}: ({d},{d},{d})\n", .{ a, points[a].x, points[a].y, points[a].z });
            for (a + 1..pointCount) |b| {
                const dx = points[a].x - points[b].x;
                const dy = points[a].y - points[b].y;
                const dz = points[a].z - points[b].z;
                const dist = dx * dx + dy * dy + dz * dz;
                distances[distanceCount] = .{ .a = a, .b = b, .distance = @intCast(dist) };
                distanceCount += 1;
            }
        }
        const usedDistances = distances[0..distanceCount];
        std.mem.sort(Distance, usedDistances, {}, distanceLessThan);

        var networkIds: [1000]u16 = undefined;
        for (0..pointCount) |i| {
            networkIds[i] = @intCast(i);
        }

        var networkSizes: [1000]u16 = .{0} ** 1000;

        const checkPoint: usize = if (pointCount < 1000) 10 else 1000;
        var networkCount: usize = pointCount;

        for (0..1000000) |i| {
            const distance = usedDistances[i];

            // std.debug.print("Connecting point {d} and point {d} with distance {d}\n", .{ distance.a, distance.b, distance.distance });

            if (networkIds[distance.a] != networkIds[distance.b]) {
                const oldNetworkId = networkIds[distance.b];
                const newNetworkId = networkIds[distance.a];
                for (0..pointCount) |j| {
                    if (networkIds[j] == oldNetworkId) {
                        networkIds[j] = newNetworkId;
                    }
                }
                networkCount -= 1;
                if (networkCount == 1) {
                    part2 = points[distance.a].x * points[distance.b].x;
                    break;
                }
            }
            if (i == checkPoint - 1) {
                for (0..pointCount) |id| {
                    networkSizes[networkIds[id]] += 1;
                }
            }
        }

        std.mem.sort(u16, &networkSizes, {}, comptime std.sort.desc(u16));

        part1 += networkSizes[0] * networkSizes[1] * networkSizes[2];
        part2 += 0;

        const t1 = try std.time.Instant.now();
        const diff = std.time.Instant.since(t1, t0);
        totalDuration += diff;
    }
    std.debug.print("Day 8 solved in {d} ns\n", .{totalDuration / iterations});

    std.debug.print("Day 8, Part 1: {d}\n", .{part1});
    std.debug.print("Day 8, Part 2: {d}\n", .{part2});

    return .{ part1, part2 };
}

test "day8 solve test" {
    const result = try solveWithFile(false, std.testing.allocator, "input_test_08_01.txt");
    try std.testing.expectEqual(40, result[0]);
    try std.testing.expectEqual(25272, result[1]);
}
