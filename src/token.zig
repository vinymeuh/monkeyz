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
};

pub const Token = struct {
    token_type: TokenType = .illegal,
    literal: []const u8,

    pub fn init(token_type: TokenType, literal: []const u8) Token {
        return Token{
            .token_type = token_type,
            .literal = literal,
        };
    }
};
