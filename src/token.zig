const std = @import("std");

pub const TokenType = enum {
    illegal,
    eof,

    // Identifiers + literals
    ident,
    int,

    // Operators
    assign,
    plus,
    minus,
    bang,
    asterisk,
    slash,

    lt,
    gt,

    eq,
    neq,

    // Delimiters
    comma,
    semicolon,

    lparen,
    rparen,
    lbrace,
    rbrace,

    // Keywords
    function,
    let,
    true,
    false,
    _if,
    _else,
    _return,
};

pub const Token = struct {
    token_type: TokenType,
    literal: []const u8,

    pub fn init(token_type: TokenType, literal: []const u8) Token {
        return Token{
            .token_type = token_type,
            .literal = literal,
        };
    }
};

const keywords = std.ComptimeStringMap(TokenType, .{
    .{ "fn", .function },
    .{ "let", .let },
    .{ "true", .true },
    .{ "false", .false },
    .{ "if", ._if },
    .{ "else", ._else },
    .{ "return", ._return },
});

pub fn lookup_ident(ident: []const u8) TokenType {
    if (keywords.has(ident)) {
        return keywords.get(ident).?;
    }
    return .ident;
}
