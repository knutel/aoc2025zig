const std = @import("std");
const aoc2025zig = @import("root.zig");

pub fn solve() !void {
    _ = try solveWithFile(std.heap.page_allocator, "input_10.txt");
}

const Instr = struct { lights: u16, lightCount: u8, buttons: [20]u16, buttonCount: u8, joltages: [20]u16 };

const Path = struct { lights: u16, buttonPresses: [10000]u8, pressCount: u16 };

const Rational = struct {
    nom: i64,
    denom: i64,
};

fn findShortest(shortestSoFar: *[65536]u16, state: Path, instr: Instr) void {
    if (shortestSoFar[state.lights] <= state.pressCount) {
        return;
    }
    shortestSoFar[state.lights] = state.pressCount;
    if (state.lights == instr.lights) {
        return;
    }
    for (0..instr.buttonCount) |i| {
        var newState = state;
        newState.lights ^= instr.buttons[i];
        const mask = (@as(u16, 1) << @as(u4, @intCast(instr.lightCount))) - 1;
        newState.lights &= mask;
        newState.buttonPresses[newState.pressCount] = @intCast(i);
        newState.pressCount += 1;
        findShortest(shortestSoFar, newState, instr);
    }
}

fn divide(a: Rational, b: Rational) Rational {
    const nom = a.nom * b.denom * (if (b.nom < 0) @as(i64, -1) else 1);
    const denom = a.denom * @as(i64, @intCast(@abs(b.nom)));
    return simplify(Rational{ .nom = nom, .denom = denom });
}

fn multiply(a: Rational, b: Rational) Rational {
    const nom = a.nom * b.nom;
    const denom = a.denom * b.denom;
    return simplify(Rational{ .nom = nom, .denom = denom });
}

fn subtract(a: Rational, b: Rational) Rational {
    if (a.denom != b.denom) {
        const nom = a.nom * b.denom - b.nom * a.denom;
        const denom = a.denom * b.denom;
        return simplify(Rational{ .nom = nom, .denom = denom });
    }
    const nom = a.nom - b.nom;
    const denom = a.denom;
    return simplify(Rational{ .nom = nom, .denom = denom });
}

fn simplify(a: Rational) Rational {
    const primes = [_]i64{ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29 };
    var nom = a.nom;
    var denom = a.denom;

    if (@mod(nom, denom) == 0) {
        nom = @divExact(nom, denom);
        denom = 1;
    } else {
        for (primes) |p| {
            while (@mod(nom, p) == 0 and @mod(denom, p) == 0) {
                nom = @divExact(nom, p);
                denom = @divExact(denom, p);
            }
        }
    }
    return Rational{ .nom = nom, .denom = denom };
}

fn findSolution(solution: *[16]Rational, a: *[16][16]Rational, cols: usize, rows: usize) void {
    var iterations: usize = 0;
    var missing: usize = 0;
    for (solution[0 .. cols - 1]) |s| {
        if (s.denom == 0) {
            missing += 1;
        }
    }

    while (missing > 0) {
        iterations += 1;
        var h: usize = rows - 1;
        while (true) {
            var variable: usize = 1000;
            var value = a[h][cols - 1];
            var foundUnknown = false;
            for (a[h][0 .. cols - 1], 0..) |v, i| {
                if (variable == 1000 and v.denom != 0 and v.nom != 0) {
                    variable = i;
                } else if (variable != 1000 and v.denom != 0 and v.nom != 0) {
                    if (solution[i].denom == 0) {
                        foundUnknown = true;
                        break;
                    }
                    value = subtract(value, multiply(v, solution[i]));
                }
            }
            if (variable != 1000 and !foundUnknown) {
                solution[variable] = divide(value, a[h][variable]);
                missing -= 1;
            }
            if (h == 0) {
                break;
            }
            h -= 1;
        }
        if (iterations > 20) {
            break;
        }
    }
}

fn findFreeVars(a: *[16][16]Rational, freeVars: *[16]usize, cols: usize, rows: usize) usize {
    var count: usize = 0;
    var free: [16]bool = .{true} ** 16;
    for (0..rows) |row| {
        for (0..cols) |col| {
            if (a[row][col].nom != 0) {
                free[col] = false;
                break;
            }
        }
    }
    for (0..cols) |col| {
        if (free[col]) {
            freeVars[count] = col;
            count += 1;
        }
    }
    return count;
}

fn gaussEliminate(a: *[16][16]Rational, cols: usize, rows: usize) void {
    // Straight from Wikipedia: https://en.wikipedia.org/wiki/Gaussian_elimination#Pseudocode
    var h: usize = 0;
    var k: usize = 0;
    const m = rows;
    const n = cols;

    while (h < m and k < n) {
        var i_max: usize = h;
        var max: f64 = @abs(@as(f64, @floatFromInt(a[h][k].nom)) / @as(f64, @floatFromInt(a[h][k].denom)));
        for (h + 1..m) |i| {
            const maybe_max: f64 = @abs(@as(f64, @floatFromInt(a[i][k].nom)) / @as(f64, @floatFromInt(a[i][k].denom)));
            if (maybe_max >= max) {
                max = maybe_max;
                i_max = i;
            }
        }
        if (a[i_max][k].nom == 0) {
            k += 1;
        } else {
            for (0..n) |c| {
                const temp = a[i_max][c];
                a[i_max][c] = a[h][c];
                a[h][c] = temp;
            }

            for (h + 1..m) |i| {
                const f = divide(a[i][k], a[h][k]);
                a[i][k].nom = 0;
                a[i][k].denom = 1;

                for (k + 1..n) |j| {
                    const fm = multiply(a[h][j], f);
                    a[i][j] = subtract(a[i][j], fm);
                }
            }
            h += 1;
            k += 1;
        }
    }
}

fn solveWithFile(allocator: std.mem.Allocator, path: []const u8) !struct { u16, u16 } {
    var lines = try aoc2025zig.readFileLines(allocator, path, true);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit(allocator);
    }

    var instructions: std.ArrayList(Instr) = .empty;
    defer {
        instructions.deinit(allocator);
    }

    for (lines.items) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        var instr: Instr = .{ .lights = 0, .lightCount = 0, .buttons = .{0} ** 20, .buttonCount = 0, .joltages = .{0} ** 20 };
        while (it.next()) |p| {
            if (p[0] == '[') {
                for (p[1 .. p.len - 1], 0..) |l, i| {
                    if (l == '#') {
                        instr.lights |= @as(u16, 1) << @intCast(i);
                    }
                }
                instr.lightCount = @intCast(p.len - 2);
            } else if (p[0] == '(') {
                var bIt = std.mem.tokenizeScalar(u8, p[1 .. p.len - 1], ',');
                var button: u16 = 0;
                while (bIt.next()) |b| {
                    const buttonIndex = try std.fmt.parseInt(u16, b, 10);
                    button |= @as(u16, 1) << @intCast(buttonIndex);
                }
                instr.buttons[instr.buttonCount] = button;
                instr.buttonCount += 1;
            } else if (p[0] == '{') {
                var jIt = std.mem.tokenizeScalar(u8, p[1 .. p.len - 1], ',');
                var joltageCount: u8 = 0;
                while (jIt.next()) |b| {
                    instr.joltages[joltageCount] = try std.fmt.parseInt(u16, b, 10);
                    joltageCount += 1;
                }
                if (joltageCount != instr.lightCount) {
                    unreachable;
                }
            }
        }
        try instructions.append(allocator, instr);
    }

    var part1: u16 = 0;
    var part2: u16 = 0;

    const iterations = 1;
    var totalDuration: u64 = 0;

    for (0..iterations) |_| {
        const t0 = try std.time.Instant.now();

        part1 = 0;
        part2 = 0;

        for (instructions.items) |instr| {
            var shortestSoFar: [65536]u16 = .{0xffff} ** 65536;
            const state: Path = .{ .lights = 0, .buttonPresses = .{0} ** 10000, .pressCount = 0 };
            findShortest(&shortestSoFar, state, instr);
            part1 += shortestSoFar[instr.lights];
        }

        for (instructions.items) |instr| {
            var matrix: [16][16]Rational = .{.{Rational{ .nom = 0, .denom = 1 }} ** 16} ** 16;
            const c = instr.lightCount;
            const b = instr.buttonCount;
            for (instr.joltages[0..c], 0..) |joltage, row| {
                matrix[row][b].nom = joltage;
            }
            for (instr.buttons[0..b], 0..) |button, col| {
                for (0..c) |row| {
                    if (button & (@as(u16, 1) << @intCast(row)) != 0) {
                        matrix[row][col].nom = 1;
                    }
                }
            }
            gaussEliminate(&matrix, b + 1, c);

            var freeVars: [16]usize = .{0} ** 16;
            const freeVarCount = findFreeVars(&matrix, &freeVars, b, c);

            var initialSolution: [16]Rational = .{Rational{ .nom = 0, .denom = 0 }} ** 16;
            for (freeVars[0..freeVarCount]) |i| {
                initialSolution[i].denom = 1;
            }
            var bestSolution: [16]Rational = undefined;
            var bestCount: i64 = 1000000;
            var maxIterations: i64 = 0;
            for (instr.joltages) |joltage| {
                maxIterations = @max(maxIterations, joltage);
            }
            while (true) {
                var solution: [16]Rational = undefined;
                std.mem.copyForwards(Rational, &solution, &initialSolution);
                findSolution(&solution, &matrix, b + 1, c);
                var unusable = false;
                var sum: i64 = 0;
                for (solution[0..b]) |s| {
                    if (s.denom != 1 or s.nom < 0) {
                        unusable = true;
                        break;
                    }
                    sum += s.nom;
                }
                if (!unusable and sum < bestCount) {
                    bestCount = sum;
                    std.mem.copyForwards(Rational, &bestSolution, &solution);
                }
                if (freeVarCount == 0) {
                    break;
                }
                for (0..freeVarCount) |i| {
                    initialSolution[freeVars[i]].nom += 1;
                    if (initialSolution[freeVars[i]].nom == maxIterations) {
                        if (i + 1 == freeVarCount) {
                            break;
                        }
                        initialSolution[freeVars[i]].nom = 0;
                    } else {
                        break;
                    }
                }
                if (initialSolution[freeVars[freeVarCount - 1]].nom == maxIterations) {
                    break;
                }
            }
            part2 += @intCast(bestCount);
        }

        const t1 = try std.time.Instant.now();
        const diff = std.time.Instant.since(t1, t0);
        totalDuration += diff;
    }
    std.debug.print("Day 10 solved in {d} ns\n", .{totalDuration / iterations});

    std.debug.print("Day 10, Part 1: {d}\n", .{part1});
    std.debug.print("Day 10, Part 2: {d}\n", .{part2});

    return .{ part1, part2 };
}

test "day10 solve test" {
    const result = try solveWithFile(std.testing.allocator, "input_test_10_01.txt");
    try std.testing.expectEqual(7, result[0]);
    try std.testing.expectEqual(33, result[1]);
}
