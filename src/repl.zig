const std = @import("std");

const lexer = @import("lexer.zig");
const Lexer = lexer.Lexer;

const token = @import("token.zig");
const Token = token.Token;
const TokenType = token.TokenType;

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

        var l = Lexer.init(line);
        var tok: Token = l.next_token();
        while (tok.token_type != TokenType.eof) : (tok = l.next_token()) {
            std.debug.print("{}\n", .{tok});
        }
    }
}
