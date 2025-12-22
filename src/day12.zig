const std = @import("std");
const aoc2025zig = @import("root.zig");

const ParseState = enum {
    Initial,
    Instructions,
    Tile,
};

pub fn solve(runBenchmark: bool) !void {
    _ = try solveWithFile(runBenchmark, std.heap.page_allocator, "input_12.txt", 0);
}

fn solveWithFile(runBenchmark: bool, allocator: std.mem.Allocator, path: []const u8, part: usize) !struct { usize, usize } {
    var lines = try aoc2025zig.readFileLines(allocator, path, false);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    _ = part;
    var part1: usize = 0;
    var part2: usize = 0;

    const iterations: usize = if (runBenchmark) 100 else 1;
    var totalDuration: u64 = 0;

    for (0..iterations) |_| {
        const t0 = try std.time.Instant.now();

        part1 += 0;
        part2 += 0;

        var parseState = ParseState.Initial;
        for (lines.items) |line| {
            while (true) {
                switch (parseState) {
                    .Initial => {
                        if (std.mem.containsAtLeastScalar(u8, line, 1, 'x')) {
                            parseState = .Instructions;
                        } else if (std.mem.containsAtLeastScalar(u8, line, 1, ':')) {
                            parseState = .Tile;
                            break;
                        }
                    },
                    .Tile => {
                        if (line.len == 0) {
                            parseState = .Initial;
                            break;
                        } else {
                            break;
                        }
                    },
                    .Instructions => {
                        if (line.len == 0) {
                            break;
                        } else {
                            var outerIter = std.mem.splitScalar(u8, line, ':');
                            const sizePart = outerIter.next() orelse unreachable;
                            var sizeIter = std.mem.splitScalar(u8, sizePart, 'x');
                            const widthString = sizeIter.next() orelse unreachable;
                            const heightString = sizeIter.next() orelse unreachable;
                            const width = try std.fmt.parseInt(usize, widthString, 10);
                            const height = try std.fmt.parseInt(usize, heightString, 10);
                            var counts: usize = 0;
                            const countPart = outerIter.next() orelse unreachable;
                            var countIter = std.mem.tokenizeScalar(u8, countPart, ' ');
                            while (countIter.next()) |countString| {
                                const count = try std.fmt.parseInt(usize, countString, 10);
                                counts += count;
                            }
                            part1 += if (width * height >= counts * 9) 1 else 0;
                            break;
                        }
                    },
                }
            }
        }

        const t1 = try std.time.Instant.now();
        const diff = std.time.Instant.since(t1, t0);
        totalDuration += diff;
    }
    std.debug.print("Day 12 solved in {d} ns\n", .{totalDuration / iterations});

    std.debug.print("Day 12, Part 1: {d}\n", .{part1});
    std.debug.print("Day 12, Part 2: {d}\n", .{part2});

    return .{ part1, part2 };
}

test "day12 solve test" {
    const result = try solveWithFile(false, std.testing.allocator, "input_test_12_01.txt", 0);
    try std.testing.expectEqual(1, result[0]);
    try std.testing.expectEqual(0, result[1]);
}
