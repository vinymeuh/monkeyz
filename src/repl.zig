const std = @import("std");

const Prompt = ">> ";

pub fn start(in: std.fs.File.Reader, out: std.fs.File.Writer) !void {
    var msg_buf: [4096]u8 = undefined;

    while (true) {
        _ = try out.write(Prompt);

        var msg = try in.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg == null) {
            break;
        }
        var line = msg.?;
        std.debug.print("msg: {s}\n", .{line});
    }
}
