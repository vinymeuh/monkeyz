const std = @import("std");
const repl = @import("repl.zig");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const username = "vinymeuh"; // TODO

    try stdout.print("Hello {s}! This is the Monkey programming language!\n", .{username});
    try stdout.print("Feel free to type in commands\n", .{});
    try repl.start(stdin, stdout);
}
