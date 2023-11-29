# Pre-process markdown to insert latex before generating the PDF.
BOOK_START=0
IS_BOOK_START=0
BOOK_END=0
SEC_ENTER=0
SEC_EXIT=0
SSEC_ENTER=0
SSEC_EXIT=0
IS_SSEC_BREAK=0
PARA_ENTER=0
PARA_EXIT=0
COMM_ENTER=0
COMM_EXIT=0

function set_verse_size() {
    if [[ "$line" =~ ^[[:upper:]] ]]; then
        echo "\\small $line  "
    elif [[ "$line" =~ ^[[:lower:]] ]]; then
        echo "\\small $line  "
    elif [[ "$line" =~ ^[[:punct:]] ]]; then
        echo "\\small $line  "
    else
        echo "\\Large $line  "
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
        if [[ $PARA_EXIT -eq 1 ]]; then
            # echo "%SEC-EXIT"
            echo "\\egroup"
            echo
        elif [[ $COMM_EXIT -eq 1 ]]; then
            echo "\\egroup"
            echo
        fi
        if [[ $BOOK_START -eq 1 ]]; then
            BOOK_END=1
            # echo "%BOOK-END"
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
            # echo "%BOOK-START"
        fi
        echo "$line"
        SEC_ENTER=1
        SEC_EXIT=0
        # echo "%SEC-ENTER"
        PARA_ENTER=0
        PARA_EXIT=0
        COMM_ENTER=0
        COMM_EXIT=0
        continue
    fi

    is_ssbreak
    IS_SSEC_BREAK=$?
    if [[ $IS_SSEC_BREAK -eq 1 ]]; then
        if [[ $SSEC_ENTER -eq 1 ]]; then
            if [[ $PARA_EXIT -eq 1 ]]; then
                echo "\\egroup"
                echo
            elif [[ $COMM_EXIT -eq 1 ]]; then
                echo "\\egroup"
                echo
            fi
            # echo "%SSEC-EXIT"
        elif [[ $PARA_EXIT -eq 1 ]]; then
            echo \\egroup
            echo
        fi
        SSEC_ENTER=1
        # echo "%SSEC-ENTER"
        SSEC_EXIT=0
        PARA_ENTER=0
        PARA_EXIT=0
        COMM_ENTER=0
        COMM_EXIT=0
        echo "$line"
        continue
    fi

    if [[ $BOOK_START -eq 0 ]]; then
        echo "$line"
        continue
    fi

    if [[ "$line" = "" ]]; then
        if [[ $COMM_ENTER -eq 1 ]]; then
            COMM_ENTER=0
            COMM_EXIT=1
            # echo "%COMM-EXIT"
        elif [[ $PARA_ENTER -eq 1 ]]; then
            PARA_ENTER=0
            PARA_EXIT=1
            # echo "%PARA-EXIT"
        fi
        echo "$line"
        continue
    fi

    # Not a section/subsection break or a blank line.

    if [[ "$line" = '<!-- commentary -->' ]]; then
        COMM_ENTER=1
        # echo "%COMM-ENTER"
        if [[ $PARA_EXIT -eq 1 ]]; then
            PARA_ENTER=0
            PARA_EXIT=0
            # echo "%PARA-EXIT-COMM"
            echo "\\egroup"
        fi
        echo "\\medskip\\bgroup"
        continue
    fi

    if [[ $COMM_ENTER -eq 1 ]]; then
        echo "$line"
        continue
    fi

    if [[ $PARA_ENTER -eq 0 ]]; then
        PARA_ENTER=1
        if [[ $PARA_EXIT -eq 1 ]]; then
            PARA_EXIT=0
            # echo "%PARA-EXIT-ENTER"
            echo "\\egroup"
            echo "\\bgroup\\centering\\filbreak"
            set_verse_size "$line"
            continue
        else
            # echo "%PARA-ENTER"
            echo "\\bgroup\\centering\\filbreak"
            set_verse_size "$line"
            continue
        fi
    fi

    # The line is in a verse.

    set_verse_size "$line"

done < "$1"
