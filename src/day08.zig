const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve() !void {
    _ = try solveWithFile(std.heap.page_allocator, "input_08.txt");
}

const Point = struct { x: u32, y: u32, z: u32 };

const Distance = struct { a: usize, b: usize, distance: u128 };

fn distanceLessThan(context: void, a: Distance, b: Distance) bool {
    _ = context;
    return a.distance < b.distance;
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

    var distances: [1000000 / 2]Distance = undefined;
    var points: [1000]Point = undefined;
    var pointCount: usize = 0;
    for (lines.items, 0..) |line, i| {
        var it = std.mem.tokenizeScalar(u8, line, ',');
        const x = try std.fmt.parseInt(u32, it.next().?, 10);
        const y = try std.fmt.parseInt(u32, it.next().?, 10);
        const z = try std.fmt.parseInt(u32, it.next().?, 10);
        points[i] = .{ .x = x, .y = y, .z = z };
        pointCount += 1;
    }
    var distanceCount: usize = 0;
    for (0..pointCount) |a| {
        // std.debug.print("Point {d}: ({d},{d},{d})\n", .{ a, points[a].x, points[a].y, points[a].z });
        for (a + 1..pointCount) |b| {
            const dx = @as(i64, points[a].x) - @as(i64, points[b].x);
            const dy = @as(i64, points[a].y) - @as(i64, points[b].y);
            const dz = @as(i64, points[a].z) - @as(i64, points[b].z);
            const dist = dx * dx + dy * dy + dz * dz;
            distances[distanceCount] = .{ .a = a, .b = b, .distance = @intCast(dist) };
            distanceCount += 1;
        }
    }
    const usedDistances = distances[0..distanceCount];
    std.mem.sort(Distance, usedDistances, {}, distanceLessThan);

    var networkIds: [1000]usize = undefined;
    for (0..pointCount) |i| {
        networkIds[i] = i;
    }

    var networkSizes: [1000]usize = .{0} ** 1000;

    const iterations: usize = if (pointCount < 1000) 10 else 1000;
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
        if (i == iterations - 1) {
            for (0..pointCount) |id| {
                networkSizes[networkIds[id]] += 1;
            }
        }
    }

    // for (0..pointCount) |id| {
    //     if (networkSizes[id] > 0) {
    //         std.debug.print("Network ID {d} has size {d}\n", .{ id, networkSizes[id] });
    //     }
    // }

    std.mem.sort(usize, &networkSizes, {}, comptime std.sort.desc(usize));
    // std.debug.print("Largest network size: {d}\n", .{networkSizes[0]});
    // std.debug.print("Largest network size: {d}\n", .{networkSizes[1]});
    // std.debug.print("Largest network size: {d}\n", .{networkSizes[2]});
    part1 += networkSizes[0] * networkSizes[1] * networkSizes[2];
    part2 += 0;

    const t1 = try std.time.Instant.now();
    const diff = std.time.Instant.since(t1, t0);
    std.debug.print("Day 8 solved in {d} ns\n", .{diff});

    std.debug.print("Day 8, Part 1: {d}\n", .{part1});
    std.debug.print("Day 8, Part 2: {d}\n", .{part2});

    return .{ part1, part2 };
}

test "day8 solve test" {
    const result = try solveWithFile(std.testing.allocator, "input_test_08_01.txt");
    try std.testing.expectEqual(40, result[0]);
    try std.testing.expectEqual(25272, result[1]);
}
