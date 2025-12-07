//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try stdout.flush(); // Don't forget to flush!
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}

pub const Direction = enum {
    left,
    right,
};

pub const Code = struct {
    dir: Direction,
    steps: i32,
};

pub fn parseDay1(gpa: std.mem.Allocator, lines: std.ArrayList([]u8)) !std.ArrayList(Code) {
    var result: std.ArrayList(Code) = .empty;
    // for (lines.items) |line| {
    //     std.debug.print("ParseLine: {s}\n", .{line});
    // }
    for (lines.items) |line| {
        var dir: Direction = undefined;
        // std.debug.print("Parsing line: {s}\n", .{line});
        if (line[0] == 'L') {
            dir = .left;
        } else if (line[0] == 'R') {
            dir = .right;
        } else {
            return error.InvalidDirection;
        }
        // std.debug.print("Parsing line: {s}\n", .{line[1..]});
        const steps = try std.fmt.parseInt(i32, line[1..], 10);
        try result.append(gpa, Code{ .dir = dir, .steps = steps });
    }

    return result;
}

pub fn readFileLines(gpa: std.mem.Allocator, path: []const u8, ignoreBlankLines: bool) !std.ArrayList([]u8) {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var file_buffer: [4096]u8 = undefined;
    var reader = file.reader(&file_buffer);
    var line_no: usize = 0;
    var lines: std.ArrayList([]u8) = .empty;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        line_no += 1;
        if (ignoreBlankLines and line.len == 0) continue;
        // std.debug.print("{d}--{s}\n", .{ line_no, line });
        const l = try gpa.alloc(u8, line.len);
        std.mem.copyForwards(u8, l, line);
        try lines.append(gpa, l);
    }
    return lines;
}

test "parseDay1 works" {
    //    const allocator = std.testing.allocator;
    const allocator = std.heap.page_allocator;
    var input: std.ArrayList([]const u8) = .empty;
    try input.append(std.heap.page_allocator, "L2");
    try input.append(std.heap.page_allocator, "R3");
    try input.append(std.heap.page_allocator, "L10");
    const codes = try parseDay1(allocator, input);
    try std.testing.expect(codes.items.len == 3);
    try std.testing.expect(codes.items[0].dir == .left);
    try std.testing.expect(codes.items[0].steps == 2);
    try std.testing.expect(codes.items[1].dir == .right);
    try std.testing.expect(codes.items[1].steps == 3);
    try std.testing.expect(codes.items[2].dir == .left);
    try std.testing.expect(codes.items[2].steps == 10);
}
