#!/usr/bin/env python

from enum import Enum
import os
import subprocess

PACKAGES_FILE_PATH = "./include/packages.bash"

CHAR_EQUALS = "="
CHAR_LEFT_PARENTHESIS = "("
CHAR_RIGHT_PARENTHESIS = ")"
CHAR_COMMENT = "#"
CHAR_QUOTATION_MARK = '"'
CHAR_NEW_LINE = "\n"
CHAR_SPACE = " "


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

    def token_name_into_char(self) -> str | None:
        match self.name:
            case TokenName.EQUALS:
                return CHAR_EQUALS
            case TokenName.LEFT_PARENTHESIS:
                return CHAR_LEFT_PARENTHESIS
            case TokenName.RIGHT_PARENTHESIS:
                return CHAR_RIGHT_PARENTHESIS
            case TokenName.COMMENT:
                return CHAR_COMMENT
            case TokenName.INLINE_COMMENT:
                return CHAR_COMMENT
            case TokenName.QUOTATION_MARK:
                return CHAR_QUOTATION_MARK
            case TokenName.NEW_LINE:
                return CHAR_NEW_LINE


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
                tokens.append(Token(TokenName.NEW_LINE, value=None))
            case " ":
                pass
            case "=":
                tokens.append(Token(TokenName.EQUALS, value=None))
            case "(":
                tokens.append(Token(TokenName.LEFT_PARENTHESIS, value=None))
            case ")":
                tokens.append(Token(TokenName.RIGHT_PARENTHESIS, value=None))
            case '"':
                tokens.append(Token(TokenName.QUOTATION_MARK, value=None))
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
            if token.value != None:
                l.append(token.value)

    return l


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
        check=True,
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

    # TODO: get the longest package name and + empty space for balanced inline-comments
    # TODO: in Package check if there is a inline-comment, if not insert package description
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
                text += CHAR_EQUALS

            case TokenName.LEFT_PARENTHESIS:
                is_inside_list = True
                text += CHAR_LEFT_PARENTHESIS

            case TokenName.RIGHT_PARENTHESIS:
                is_inside_list = False
                text += CHAR_RIGHT_PARENTHESIS

            case TokenName.PACKAGE:
                if token.value:
                    text += token.value

            case TokenName.COMMENT:
                if is_inside_list:
                    text += indent
                text += CHAR_COMMENT
                text += " "
                if token.value:
                    text += token.value

            case TokenName.INLINE_COMMENT:
                text += " "
                package_name = tokens[index - 2].value
                if package_name != None:
                    for _ in range(0, max_package_length - len(package_name)):
                        text += " "
                text += CHAR_COMMENT
                text += " "
                if token.value:
                    text += token.value

            case TokenName.QUOTATION_MARK:
                if tokens[index - 1].name == TokenName.NEW_LINE:
                    if is_inside_list:
                        text += indent

                text += CHAR_QUOTATION_MARK

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
                        text += CHAR_COMMENT
                        text += " "
                        text += description

            case TokenName.NEW_LINE:
                text += CHAR_NEW_LINE

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

    lexer_state = LexerState(text)
    tokens = lexer(lexer_state)

    new_text = tokens_to_text(tokens)
    print(new_text)


if __name__ == "__main__":
    main()
