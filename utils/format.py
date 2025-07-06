#!/usr/bin/env python

from enum import Enum
import os
import subprocess
import types

PACKAGES_FILE_PATH = "./include/packages.sh"

LEXER_CHARS = types.SimpleNamespace()

LEXER_CHARS.EQUALS = "="
LEXER_CHARS.LEFT_PARENTHESIS = "("
LEXER_CHARS.RIGHT_PARENTHESIS = ")"
LEXER_CHARS.COMMENT = "#"
LEXER_CHARS.QUOTATION_MARK = '"'
LEXER_CHARS.NEW_LINE = "\n"
LEXER_CHARS.SPACE = " "


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
    def __init__(self, name: TokenName, value: str | None):
        self.name = name
        self.value = value

    def __str__(self):
        if self.value != None:
            value_string = f", value: '{self.value}'"
        else:
            value_string = ""

        return "{" + f"name: '{self.name}'{value_string}" + "}"

    def __repr__(self):
        return self.__str__()

    def to_char(self) -> str:
        match self.name:
            case TokenName.EQUALS:
                return LEXER_CHARS.EQUALS
            case TokenName.LEFT_PARENTHESIS:
                return LEXER_CHARS.LEFT_PARENTHESIS
            case TokenName.RIGHT_PARENTHESIS:
                return LEXER_CHARS.RIGHT_PARENTHESIS
            case TokenName.COMMENT:
                return LEXER_CHARS.COMMENT
            case TokenName.INLINE_COMMENT:
                return LEXER_CHARS.COMMENT
            case TokenName.QUOTATION_MARK:
                return LEXER_CHARS.QUOTATION_MARK
            case TokenName.NEW_LINE:
                return LEXER_CHARS.NEW_LINE
            case _:
                return "Unreachable"


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


class Lexer:
    def __init__(self, text: str):
        self.state = LexerState(text)
        self.tokens: list[Token] = []

    def __collect_string_until(self, end_char: str) -> str:
        temp_string = ""

        while not self.state.is_text_end():
            char = self.state.char()

            if self.state.peek() == end_char:
                temp_string += (
                    char  # Breaks before collecting the last char in the string
                )
                break

            temp_string += char

            self.state.advance()

        return temp_string

    def __is_last_token_name(self, name: TokenName) -> bool:
        return len(self.tokens) > 0 and self.tokens[-1].name == name

    def lex(self):
        while not self.state.is_text_end():
            match self.state.char():
                case "\t":
                    pass
                case LEXER_CHARS.NEW_LINE:
                    self.tokens.append(Token(TokenName.NEW_LINE, value=None))
                case LEXER_CHARS.SPACE:
                    pass
                case LEXER_CHARS.EQUALS:
                    self.tokens.append(Token(TokenName.EQUALS, value=None))
                case LEXER_CHARS.LEFT_PARENTHESIS:
                    self.tokens.append(Token(TokenName.LEFT_PARENTHESIS, value=None))
                case LEXER_CHARS.RIGHT_PARENTHESIS:
                    self.tokens.append(Token(TokenName.RIGHT_PARENTHESIS, value=None))
                case LEXER_CHARS.QUOTATION_MARK:
                    self.tokens.append(Token(TokenName.QUOTATION_MARK, value=None))
                case LEXER_CHARS.COMMENT:
                    if self.state.peek() == "\n":
                        self.tokens.append(Token(TokenName.COMMENT, ""))
                    else:
                        self.state.advance()  # skip #
                        if self.state.char() == " ":
                            self.state.advance()

                        if self.__is_last_token_name(TokenName.QUOTATION_MARK):
                            # inline-comment
                            comment_string = self.__collect_string_until("\n")
                            self.tokens.append(
                                Token(TokenName.INLINE_COMMENT, comment_string)
                            )
                        else:
                            # normal comment
                            comment_string = self.__collect_string_until("\n")
                            self.tokens.append(Token(TokenName.COMMENT, comment_string))
                case _:
                    if self.__is_last_token_name(TokenName.KEYWORD):
                        package_list_name = self.__collect_string_until("=")
                        self.tokens.append(
                            Token(TokenName.PACKAGE_LIST_NAME, package_list_name)
                        )
                    elif self.__is_last_token_name(TokenName.QUOTATION_MARK):
                        package_name = self.__collect_string_until('"')
                        self.tokens.append(Token(TokenName.PACKAGE, package_name))
                    else:
                        keyword_string = self.__collect_string_until(" ")
                        self.tokens.append(Token(TokenName.KEYWORD, keyword_string))

            self.state.advance()


def max_pacman_package_length(tokens: list[Token]) -> int:
    length = 0

    for token in tokens:
        if token.name == TokenName.RIGHT_PARENTHESIS:
            break

        if token.name == TokenName.PACKAGE:
            if token.value != None:
                if length < len(token.value):
                    length = len(token.value)

    return length


def get_pacman_package_description(package: str) -> str | None:
    cmd = subprocess.run(
        args=["pacman", "-Qi", package],
        shell=False,
        capture_output=True,
        text=True,
    )

    if cmd.returncode != 0:
        return None

    for line in cmd.stdout.split("\n"):
        if line.startswith("Description"):
            desc = line.split(":")[1]
            desc = desc.lstrip()
            return desc

    return None


def tokens_to_text(tokens: list[Token]) -> str:
    text = ""
    indent = "    "
    is_inside_pacman_list = False
    is_inside_list = False
    max_package_length = max_pacman_package_length(tokens)

    for index, token in enumerate(tokens):
        match token.name:
            case TokenName.KEYWORD:
                if token.value:
                    text += token.value
                    text += " "

            case TokenName.PACKAGE_LIST_NAME:
                if token.value:
                    if token.value == "PACMAN_PACKAGES":
                        is_inside_pacman_list = True
                    else:
                        is_inside_pacman_list = False
                    text += token.value

            case TokenName.EQUALS:
                text += token.to_char()

            case TokenName.LEFT_PARENTHESIS:
                is_inside_list = True
                text += token.to_char()

            case TokenName.RIGHT_PARENTHESIS:
                is_inside_list = False
                text += token.to_char()

            case TokenName.PACKAGE:
                if token.value:
                    text += token.value

            case TokenName.COMMENT:
                if is_inside_list:
                    text += indent
                text += token.to_char()
                if token.value:
                    text += " "
                    text += token.value

            case TokenName.INLINE_COMMENT:
                text += " "
                package_name = tokens[index - 2].value
                if package_name != None:
                    for _ in range(0, max_package_length - len(package_name)):
                        text += " "
                text += token.to_char()
                text += " "
                if token.value:
                    text += token.value

            case TokenName.QUOTATION_MARK:
                if tokens[index - 1].name == TokenName.NEW_LINE:
                    if is_inside_list:
                        text += indent

                text += token.to_char()

                if (
                    is_inside_pacman_list
                    and tokens[index - 1].name == TokenName.PACKAGE
                    and tokens[index + 1].name != TokenName.INLINE_COMMENT
                ):
                    package_name = tokens[index - 1].value
                    assert package_name != None

                    description = get_pacman_package_description(package_name)
                    if description != None:
                        text += " "
                        for _ in range(0, max_package_length - len(package_name)):
                            text += " "
                        text += "#"
                        text += " "
                        text += description

            case TokenName.NEW_LINE:
                text += token.to_char()

    return text


def main():
    if not os.path.exists(PACKAGES_FILE_PATH):
        print("Could not find packages file at: " + PACKAGES_FILE_PATH)
        return

    text = ""

    with open(PACKAGES_FILE_PATH, "r") as f:
        text = f.read()

    if len(text) == 0:
        return

    lexer = Lexer(text)
    lexer.lex()

    new_text = tokens_to_text(lexer.tokens)

    print(new_text)

    with open(PACKAGES_FILE_PATH, "w") as f:
        f.write(new_text)


if __name__ == "__main__":
    main()
