#!/usr/bin/env python

# TODO: parse include/packages and format the packages to this format
# "PACKAGE" # DESCRIPTION

from enum import Enum
import os

PACKAGES_FILE_PATH = "./include/packages.bash"


class TokenName(Enum):
    KEYWORD = "keyword"  # export
    PACKAGE_LIST_NAME = "package_list_name"  # PACMAN_PACKAGES
    EQUALS = "equals"  # =
    LEFT_PARENTHESIS = "left_parenthesis"  # (
    RIGHT_PARENTHESIS = "right_parenthesis"  # )
    PACKAGE = "package"  # ghostty
    COMMENT = "comment"  # # test
    INLINE_COMMENT = "inline_comment"  # "ghostty" # terminal
    QUOTATION_MARK = "quotation_mark"  # "
    NEW_LINE = "new_line"  # \n


class Token:
    def __init__(self, name: TokenName, value: str):
        self.name = name
        self.value = value

    def __str__(self):
        return f"\n<name: '{self.name}' | value: '{self.value}'>"

    def __repr__(self):
        return self.__str__()


class State:
    def __init__(self):
        self.inside_comment = False
        self.inside_string = False

    def __str__(self):
        return f"inside_comment: {self.inside_comment}, inside_string: {self.inside_string}"

    def __repr__(self):
        return self.__str__()


class LexerState:
    def __init__(self, text):
        self.text = text
        self.cursor = 0

    def peek(self):
        return self.text[self.cursor + 1]

    def char(self):
        return self.text[self.cursor]

    def advance(self):
        self.cursor += 1

    def is_text_end(self):
        return self.cursor == len(self.text) - 1


def collect_string_until(lexer_state: LexerState, end_char: str) -> str:
    temp_string = ""

    while not lexer_state.is_text_end():
        char = lexer_state.char()

        if lexer_state.peek() == end_char:
            temp_string += char  # Breaks before collecting the last char in the string
            break

        temp_string += char

        lexer_state.advance()

    return temp_string


def is_last_token_name(tokens: list[Token], name: TokenName) -> bool:
    return len(tokens) > 0 and tokens[-1].name == name


def lexer(lexer_state: LexerState) -> list[Token]:
    tokens: list[Token] = []

    while not lexer_state.is_text_end():
        match lexer_state.char():
            case "\t":
                pass
            case "\n":
                tokens.append(Token(TokenName.NEW_LINE, lexer_state.char()))
            case " ":
                pass
            case "=":
                tokens.append(Token(TokenName.EQUALS, lexer_state.char()))
            case "(":
                tokens.append(Token(TokenName.LEFT_PARENTHESIS, lexer_state.char()))
            case ")":
                tokens.append(Token(TokenName.RIGHT_PARENTHESIS, lexer_state.char()))
            case '"':
                tokens.append(Token(TokenName.QUOTATION_MARK, lexer_state.char()))
            case "#":
                if lexer_state.peek() == "\n":
                    tokens.append(Token(TokenName.COMMENT, ""))
                else:
                    lexer_state.advance()  # skip #
                    if lexer_state.char() == " ":
                        lexer_state.advance()

                    if is_last_token_name(tokens, TokenName.QUOTATION_MARK):
                        # inline-comment
                        comment_string = collect_string_until(lexer_state, "\n")
                        tokens.append(Token(TokenName.INLINE_COMMENT, comment_string))
                    else:
                        # normal comment
                        comment_string = collect_string_until(lexer_state, "\n")
                        tokens.append(Token(TokenName.COMMENT, comment_string))
            case _:
                if is_last_token_name(tokens, TokenName.KEYWORD):
                    package_list_name = collect_string_until(lexer_state, "=")
                    tokens.append(Token(TokenName.PACKAGE_LIST_NAME, package_list_name))
                elif is_last_token_name(tokens, TokenName.QUOTATION_MARK):
                    package_name = collect_string_until(lexer_state, '"')
                    tokens.append(Token(TokenName.PACKAGE, package_name))
                else:
                    keyword_string = collect_string_until(lexer_state, " ")
                    tokens.append(Token(TokenName.KEYWORD, keyword_string))

        lexer_state.advance()

    return tokens


def collect_pacman_packages(tokens: list[Token]) -> list[str]:
    l = []

    for token in tokens:
        if token.name == TokenName.RIGHT_PARENTHESIS:
            break

        if token.name == TokenName.PACKAGE:
            l.append(token.value)

    return l


# TODO: Serialize back into file
def to_file(tokens: list[Token]) -> list[str]:
    lines = []

    return lines


# TODO: get descriptions for pacman packages
def main():
    if not os.path.exists(PACKAGES_FILE_PATH):
        print("Could not find packages file at: " + PACKAGES_FILE_PATH)
        return

    with open(PACKAGES_FILE_PATH, "r") as f:
        text = f.read()
        lexer_state = LexerState(text)
        tokens = lexer(lexer_state)
        print(tokens)


if __name__ == "__main__":
    main()
