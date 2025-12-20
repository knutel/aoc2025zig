const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve(runBenchmark: bool) !void {
    _ = try solveWithFile(runBenchmark, std.heap.page_allocator, "input_11.txt", 0);
}

const Mapping = struct {
    from: [3]u8,
    to: [32][3]u8,
    toCount: usize,
};

fn findDistance(allocator: std.mem.Allocator, mappings: *std.StringHashMap(Mapping), position: []const u8, destination: []const u8) !usize {
    var path_count = std.StringHashMap(usize).init(allocator);
    defer {
        var keyIter = path_count.keyIterator();
        while (keyIter.next()) |key| {
            allocator.free(key.*);
        }
        path_count.deinit();
    }
    return try traverse(allocator, mappings, position, destination, &path_count);
}

fn traverse(allocator: std.mem.Allocator, mappings: *std.StringHashMap(Mapping), position: []const u8, destination: []const u8, path_count: *std.StringHashMap(usize)) !usize {
    if (std.mem.eql(u8, position[0..3], destination[0..3])) {
        return 1;
    }

    if (!path_count.contains(position)) {
        const mapping = mappings.get(position) orelse return 0;
        var count: usize = 0;
        for (mapping.to[0..mapping.toCount]) |nextPos| {
            count += try traverse(allocator, mappings, &nextPos, destination, path_count);
        }
        try path_count.put(try allocator.dupe(u8, position), count);
    }
    return path_count.get(position) orelse unreachable;
}

fn solveWithFile(runBenchmark: bool, allocator: std.mem.Allocator, path: []const u8, part: usize) !struct { usize, usize } {
    var lines = try aoc2025zig.readFileLines(allocator, path, true);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    var part1: usize = 0;
    var part2: usize = 0;

    const iterations: usize = if (runBenchmark) 100 else 1;
    var totalDuration: u64 = 0;

    for (0..iterations) |_| {
        const t0 = try std.time.Instant.now();

        part1 += 0;
        part2 += 0;

        var mappings = std.StringHashMap(Mapping).init(allocator);
        defer {
            var keyIter = mappings.keyIterator();
            while (keyIter.next()) |key| {
                allocator.free(key.*);
            }
            mappings.deinit();
        }
        for (lines.items) |line| {
            var iter = std.mem.tokenizeScalar(u8, line, ' ');
            var to: [32][3]u8 = undefined;
            var count: usize = 0;
            var first = true;
            var from: [3]u8 = undefined;
            while (iter.next()) |token| {
                if (first) {
                    std.mem.copyForwards(u8, &from, token[0..3]);
                    first = false;
                } else {
                    std.mem.copyForwards(u8, &to[count], token[0..3]);
                    count += 1;
                }
            }
            try mappings.put(try allocator.dupe(u8, &from), Mapping{ .from = from, .to = to, .toCount = count });
        }

        if (part == 0 or part == 1) {
            part1 = try findDistance(allocator, &mappings, "you", "out");
        }

        if (part == 0 or part == 2) {
            const dacToFft = try findDistance(allocator, &mappings, "dac", "fft");
            const fftToDac = try findDistance(allocator, &mappings, "fft", "dac");
            if (dacToFft == 0 and fftToDac != 0) {
                const svrToFft = try findDistance(allocator, &mappings, "svr", "fft");
                const dacToOut = try findDistance(allocator, &mappings, "dac", "out");
                part2 = svrToFft * fftToDac * dacToOut;
            } else if (dacToFft != 0 and fftToDac == 0) {
                const svrToDac = try findDistance(allocator, &mappings, "svr", "dac");
                const fftToOut = try findDistance(allocator, &mappings, "fft", "out");
                part2 = svrToDac * dacToFft * fftToOut;
            } else {
                unreachable;
            }
        }
        const t1 = try std.time.Instant.now();
        const diff = std.time.Instant.since(t1, t0);
        totalDuration += diff;
    }
    std.debug.print("Day 11 solved in {d} ns\n", .{totalDuration / iterations});

    std.debug.print("Day 11, Part 1: {d}\n", .{part1});
    std.debug.print("Day 11, Part 2: {d}\n", .{part2});

    return .{ part1, part2 };
}

test "day11 solve test" {
    const result1 = try solveWithFile(false, std.testing.allocator, "input_test_11_01.txt", 1);
    try std.testing.expectEqual(5, result1[0]);
    const result2 = try solveWithFile(false, std.testing.allocator, "input_test_11_02.txt", 2);
    try std.testing.expectEqual(2, result2[1]);
}
