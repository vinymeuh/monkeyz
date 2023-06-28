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

        self.skip_whitespaces();

        var buf: [2]u8 = undefined;
        const sch = std.fmt.bufPrint(&buf, "{u}", .{self.ch}) catch {
            unreachable;
        };

        switch (self.ch) {
            '=' => tok = Token.init(TokenType.assign, sch),
            '+' => tok = Token.init(TokenType.plus, sch),
            '(' => tok = Token.init(TokenType.lparen, sch),
            ')' => tok = Token.init(TokenType.rparen, sch),
            '{' => tok = Token.init(TokenType.lbrace, sch),
            '}' => tok = Token.init(TokenType.rbrace, sch),
            ',' => tok = Token.init(TokenType.comma, sch),
            ';' => tok = Token.init(TokenType.semicolon, sch),
            0 => tok = Token.init(TokenType.eof, ""),
            else => {
                if (is_letter(self.ch)) {
                    var literal = self.read_identifer();
                    var token_type = token.lookup_ident(literal);
                    tok = Token.init(token_type, literal);
                    return tok;
                } else if (is_digit(self.ch)) {
                    var literal = self.read_number();
                    tok = Token.init(TokenType.int, literal);
                    return tok;
                } else {
                    tok = Token.init(TokenType.illegal, sch);
                }
            },
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

    fn read_identifer(self: *Lexer) []const u8 {
        var begin = self.current_position;
        while (is_letter(self.ch)) {
            self.read_char();
        }
        return self.input[begin..self.current_position];
    }

    fn read_number(self: *Lexer) []const u8 {
        var begin = self.current_position;
        while (is_digit(self.ch)) {
            self.read_char();
        }
        return self.input[begin..self.current_position];
    }

    fn skip_whitespaces(self: *Lexer) void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
            self.read_char();
        }
    }
};

fn is_letter(ch: u8) bool {
    return ('a' <= ch and ch <= 'z') or ('A' <= ch and ch <= 'Z') or ch == '_';
}

fn is_digit(ch: u8) bool {
    return '0' <= ch and ch <= '9';
}

test "NextToken" {
    const tests = [_]struct {
        input: []const u8,
        tokens: []const Token,
    }{
        .{
            .input =
            \\let five = 5;
            \\let ten = 10;
            \\
            \\let add = fn(x, y) {
            \\ x + y;
            \\};
            \\
            \\let result = add(five, ten);
            ,
            .tokens = &[_]Token{
                Token.init(TokenType.let, "let"),
                Token.init(TokenType.ident, "five"),
                Token.init(TokenType.assign, "="),
                Token.init(TokenType.int, "5"),
                Token.init(TokenType.semicolon, ";"),
                Token.init(TokenType.let, "let"),
                Token.init(TokenType.ident, "ten"),
                Token.init(TokenType.assign, "="),
                Token.init(TokenType.int, "10"),
                Token.init(TokenType.semicolon, ";"),
                Token.init(TokenType.let, "let"),
                Token.init(TokenType.ident, "add"),
                Token.init(TokenType.assign, "="),
                Token.init(TokenType.function, "fn"),
                Token.init(TokenType.lparen, "("),
                Token.init(TokenType.ident, "x"),
                Token.init(TokenType.comma, ","),
                Token.init(TokenType.ident, "y"),
                Token.init(TokenType.rparen, ")"),
                Token.init(TokenType.lbrace, "{"),
                Token.init(TokenType.ident, "x"),
                Token.init(TokenType.plus, "+"),
                Token.init(TokenType.ident, "y"),
                Token.init(TokenType.semicolon, ";"),
                Token.init(TokenType.rbrace, "}"),
                Token.init(TokenType.semicolon, ";"),
                Token.init(TokenType.let, "let"),
                Token.init(TokenType.ident, "result"),
                Token.init(TokenType.assign, "="),
                Token.init(TokenType.ident, "add"),
                Token.init(TokenType.lparen, "("),
                Token.init(TokenType.ident, "five"),
                Token.init(TokenType.comma, ","),
                Token.init(TokenType.ident, "ten"),
                Token.init(TokenType.rparen, ")"),
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
