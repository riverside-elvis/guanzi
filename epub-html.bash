# Pre-process markdown to insert HTML before generating EPUB.
BOOK_START=0
BOOK_END=0
SEC_ENTER=0
SEC_EXIT=0
SSEC_ENTER=0
SSEC_EXIT=0
PARA_ENTER=0
PARA_EXIT=0
IN_COMMENTARY=0
DEBUG=0

function set_verse_size() {
    if [[ "$line" =~ ^[[:upper:]] ]]; then
        echo "<span class=\"text\">$line</span>  "
    elif [[ "$line" =~ ^[[:lower:]] ]]; then
        echo "<span class=\"text\">$line</span>  "
    elif [[ "$line" =~ ^[[:punct:]] ]]; then
        echo "<span class=\"text\">$line</span>  "
    else
        echo "<span class=\"cjk\">$line</span>  "
    fi
}

function is_ssbreak() {
    if [[ "$line" =~ ^##[[:space:]] ]]; then
        return 1
    elif [[ "$line" =~ ^###[[:space:]] ]]; then
        return 1
    elif [[ "$line" =~ ^---$ ]]; then
        return 1
    else
        return 0
    fi
}

function is_book_start() {
    if [[ "$line" =~ 內業 ]]; then
        return 1
    elif [[ "$line" =~ 心術下 ]]; then
        return 1
    elif [[ "$line" =~ 心術上 ]]; then
        return 1
    elif [[ "$line" =~ 白心 ]]; then
        return 1
    else
        return 0
    fi
}

while IFS= read -r line; do

    if [[ $BOOK_END -eq 1 ]]; then
        echo "$line"
        continue
    fi

    if [[ "$line" =~ ^#[[:space:]] ]]; then
        if [[ $SEC_ENTER -eq 1 ]]; then
            SEC_EXIT=1
            if [[ $DEBUG -eq 1 ]]; then echo "<!--SEC-EXIT-->"; fi
        fi
        if [[ $PARA_EXIT -eq 1 ]]; then
            if [[ $DEBUG -eq 1 ]]; then echo "<!--SEC-PARA-EXIT-->"; fi
        fi
        if [[ $BOOK_START -eq 1 ]]; then
            BOOK_END=1
            if [[ $DEBUG -eq 1 ]]; then echo "<!--BOOK-END-->"; fi
        fi
        if [[ "$line" =~ Appendix ]]; then
            BOOK_END=1
            echo "$line"
            continue
        fi
        is_book_start
        IS_BOOK_START=$?
        if [[ IS_BOOK_START -eq 1 ]]; then
            BOOK_START=1
            BOOK_END=0
            if [[ $DEBUG -eq 1 ]]; then echo "<!--BOOK-START-->"; fi
        fi
        echo "$line {.book}"
        SEC_ENTER=1
        SEC_EXIT=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--SEC-ENTER-->"; fi
        PARA_ENTER=0
        PARA_EXIT=0
        continue
    fi

    is_ssbreak
    SSEC_BREAK=$?
    if [[ $SSEC_BREAK -eq 1 ]]; then
        if [[ $SSEC_ENTER -eq 1 ]]; then
            SSEC_ENTER=0
            if [[ $PARA_EXIT -eq 1 ]]; then
                if [[ $DEBUG -eq 1 ]]; then echo "<!--SSEC-PARA-EXIT-->"; fi
            else
                SSEC_EXIT=1
                if [[ $DEBUG -eq 1 ]]; then echo "<!--SSEC-EXIT-->"; fi
            fi
        fi
        echo "$line"
        SSEC_ENTER=1
        SSEC_EXIT=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--SSEC-ENTER-->"; fi
        PARA_ENTER=0
        PARA_EXIT=0
        continue
    fi

    if [[ $BOOK_START -eq 0 ]]; then
        echo "$line"
        continue
    fi

    if [[ "$line" = "" ]]; then
        if [[ $IN_COMMENTARY -eq 1 ]]; then
            IN_COMMENTARY=0
            echo "</p>"
            if [[ $DEBUG -eq 1 ]]; then echo "<!--COMMENTARY-EXIT-->"; fi
        elif [[ $PARA_ENTER -eq 1 ]]; then
            PARA_ENTER=0
            PARA_EXIT=1
            if [[ $DEBUG -eq 1 ]]; then echo "<!--PARA-EXIT-->"; fi
        fi
        echo "$line"
        continue
    fi

    # Not a header and not a blank line.

    if [[ "$line" = '<!-- commentary -->' ]]; then
        IN_COMMENTARY=1
        echo "<p class="commentary">"
        if [[ $DEBUG -eq 1 ]]; then echo "<!--PARA-EXIT-COMMENTARY-->"; fi
        if [[ $PARA_EXIT -eq 1 ]]; then
            PARA_ENTER=0
            PARA_EXIT=0
            if [[ $DEBUG -eq 1 ]]; then echo "<!--PARA-EXIT-COMMENTARY-->"; fi
        fi
        continue
    fi

    if [[ $IN_COMMENTARY -eq 1 ]]; then
        echo "$line"
        continue
    fi

    if [[ $PARA_ENTER -eq 0 ]]; then
        PARA_ENTER=1
        if [[ $PARA_EXIT -eq 1 ]]; then
            PARA_EXIT=0
            if [[ $DEBUG -eq 1 ]]; then echo "<!--%PARA-EXIT-ENTER-->"; fi
            set_verse_size "$line"
            continue
        else
            if [[ $DEBUG -eq 1 ]]; then echo "<!--%PARA-ENTER-->"; fi
            set_verse_size "$line"
            continue
        fi
    fi

    set_verse_size "$line"

done < "$1"
