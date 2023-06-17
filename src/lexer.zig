const std = @import("std");

const token = @import("token.zig");
const Token = token.Token;
const TokenType = token.TokenType;

const Lexer = struct {
    input: []const u8,
    current_position: usize, // current position in input (points to current char)
    next_position: usize, // next reading position in input (points after current char)
    ch: u8, // current char under examination

    pub fn init(input: []const u8) Lexer {
        var l = Lexer{
            .input = input,
            .current_position = 0,
            .next_position = 0,
            .ch = 0,
        };
        l.read_char();
        return l;
    }

    pub fn next_token(self: *Lexer) Token {
        var tok: Token = undefined;
        var sch = [_]u8{self.ch};
        switch (self.ch) {
            '=' => tok = Token.init(TokenType.assign, &sch),
            '+' => tok = Token.init(TokenType.plus, &sch),
            '(' => tok = Token.init(TokenType.lparen, &sch),
            ')' => tok = Token.init(TokenType.rparen, &sch),
            '{' => tok = Token.init(TokenType.lbrace, &sch),
            '}' => tok = Token.init(TokenType.rbrace, &sch),
            ',' => tok = Token.init(TokenType.comma, &sch),
            ';' => tok = Token.init(TokenType.semicolon, &sch),
            0 => tok = Token.init(TokenType.eof, ""),
            else => tok = Token.init(TokenType.illegal, &sch),
        }

        self.read_char();
        return tok;
    }

    fn read_char(self: *Lexer) void {
        if (self.next_position >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.next_position];
        }
        self.current_position = self.next_position;
        self.next_position += 1;
    }
};

test "NextToken" {
    const tests = [_]struct {
        input: []const u8,
        tokens: []const Token,
    }{
        .{
            .input = "=+(){},;",
            .tokens = &[_]Token{
                Token.init(TokenType.assign, "="),
                Token.init(TokenType.plus, "+"),
                Token.init(TokenType.lparen, "("),
                Token.init(TokenType.rparen, ")"),
                Token.init(TokenType.lbrace, "{"),
                Token.init(TokenType.rbrace, "}"),
                Token.init(TokenType.comma, ","),
                Token.init(TokenType.semicolon, ";"),
                Token.init(TokenType.eof, ""),
            },
        },
    };

    for (tests) |t| {
        var l = Lexer.init(t.input);
        for (t.tokens) |expected| {
            var got = l.next_token();
            //try std.testing.expectEqualDeep(expected, got);
            try std.testing.expectEqual(expected.token_type, got.token_type);
            try std.testing.expectEqualStrings(expected.literal, got.literal);
        }
    }
}
