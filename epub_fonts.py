""" Write a subset of a font file. """
import os
import string
import sys
from fontTools.subset import main as ftsubset


def is_cjk(char):
    """ Return True if the character is in a Unihan block. """
    try:
        codepoint = ord(char)
    except TypeError:
        return False

    # A cheap test up front.
    if char in string.printable:
        return False

    # https://www.unicode.org/reports/tr38/#BlockListing
    # https://www.unicode.org/reports/tr38/#SortingAlgorithm

    switch = False
    match codepoint:
        # CJK Unified Ideographs
        case codepoint if 0x4E00 <= codepoint <= 0x9FFF:
            switch = True
        # CJK Unified Ideographs Extension A
        case codepoint if 0x3400 <= codepoint <= 0x4DBF:
            switch = True
        # CJK Unified Ideographs Extension B
        case codepoint if 0x20000 <= codepoint <= 0x2A6DF:
            switch = True
        # CJK Unified Ideographs Extension C
        case codepoint if 0x2A700 <= codepoint <= 0x2B739:
            switch = True
        # CJK Unified Ideographs Extension D
        case codepoint if 0x2B740 <= codepoint <= 0x2B81D:
            switch = True
        # CJK Unified Ideographs Extension E
        case codepoint if 0x2B820 <= codepoint <= 0x2CEA1:
            switch = True
        # CJK Unified Ideographs Extension F
        case codepoint if 0x2CEB0 <= codepoint <= 0x2EBE0:
            switch = True
        # CJK Unified Ideographs Extension G
        case codepoint if 0x30000 <= codepoint <= 0x3134A:
            switch = True
        # CJK Unified Ideographs Extension H
        case codepoint if 0x31350 <= codepoint <= 0x323AF:
            switch = True
        # CJK Compatibility Ideographs
        case codepoint if 0xF900 <= codepoint <= 0xFAD9:
            switch = True
        # CJK Compatibility Supplement
        case codepoint if 0x2F800 <= codepoint <= 0x2FA1D:
            switch = True
        # CJK Symbols and Punctuation
        case codepoint if 0x3000 <= codepoint <= 0x303F:
            switch = True
    return switch


def write_font(infile, infont, outfont, subset):
    """ Write font subset. """

    # Get character sets from .md files.
    cjk_chars = set()
    regular_chars = set()
    with open(infile, "r", encoding="utf-8") as infiled:
        for line in infiled.read().splitlines():
            for char in line:
                if char != " ":
                    if is_cjk(char):
                        if subset == "cjk":
                            cjk_chars.add(char)
                    else:
                        regular_chars.add(char)

    # Prep text.
    if subset == "cjk":
        text = ''.join(cjk_chars)
    else:
        text = ''.join(regular_chars)
    print(text)

    # Run the subset command.
    # Adapted from the options example.
    # https://fonttools.readthedocs.io/en/latest/subset/index.html#application-options
    sys.argv = [
        None,
        infont,
        "--font-number=0",
        f"--text={text}",
        "--no-ignore-missing-unicodes",
        "--layout-features=*",
        "--glyph-names",
        "--symbol-cmap",
        "--legacy-cmap",
        "--notdef-glyph",
        "--notdef-outline",
        "--recommended-glyphs",
        "--name-IDs=*",
        "--name-legacy",
        "--name-languages=*",
        f"--output-file={outfont}"
    ]
    ftsubset()


def main():
    """ Parse args and run reduce. """
    usage = f"Usage: {sys.argv[0]} <infont> <outfont> [cjk]\n"
    arg1 = None
    arg2 = None
    arg3 = None
    arg4 = None
    try:
        arg1 = sys.argv[1]
        arg2 = sys.argv[2]
        arg3 = sys.argv[3]
    except IndexError:
        sys.stderr.write(usage)
        sys.exit(1)
    if len(sys.argv) == 5:
        arg4 = sys.argv[4]
    if arg2 and arg3 and arg2 == arg3:
        err = True
    elif not os.path.isfile(arg1):
        err = True
    elif not os.path.isfile(arg2):
        err = True
    else:
        err = False
    if err:
        sys.stderr.write(usage)
        sys.exit(1)
    print(f"{arg1} {arg2} {arg3} {arg4}")
    write_font(arg1, arg2, arg3, arg4)


if __name__ == "__main__":
    main()
