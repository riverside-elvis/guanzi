# Build the ebook. Check build.md to prep build environment.

# Check arg.
case $1 in
    epub) echo "Building $1" ;;
    pdf) echo "Building $1" ;;
    *) echo "Usage: $0 [epub|pdf]" > /dev/stderr && exit 1
esac

# Pre-process foreward template version.
if [[ -n $(git status -s) ]]; then
    COMMIT="#######"
    EPOCH=$(date +%s)
else
    COMMIT=$(git log -1 --format=%h)
    EPOCH=$(git log -1 --format=%ct)
    TAG=$(git describe --tags --candidates=0 $COMMIT 2>/dev/null)
    if [[ -n $TAG ]]; then
        COMMIT=$TAG
    fi
fi
DATE="@$EPOCH"
VERSION="Commit $COMMIT, $(date -d $DATE +'%B %d, %Y')."
sed "s/{{ version }}/$VERSION/g" foreward.tpl.md > foreward.md
echo "${VERSION}"

# Pre-process input files.
MD="GuanziXinShu-$COMMIT.md"
sed -s '$G' -s \
    foreward.md \
    01-nei-ye/01-I.md \
    01-nei-ye/02-II.md \
    01-nei-ye/03-III.md \
    01-nei-ye/04-IV.md \
    01-nei-ye/05-V.md \
    01-nei-ye/06-VI.md \
    01-nei-ye/07-VII.md \
    01-nei-ye/08-VIII.md \
    01-nei-ye/09-IX.md \
    01-nei-ye/10-X.md \
    01-nei-ye/11-XI.md \
    01-nei-ye/12-XII.md \
    01-nei-ye/13-XIII.md \
    01-nei-ye/14-XIV.md \
    01-nei-ye/15-XV.md \
    02-xin-shu-xia/01.md \
    03-xin-shu-shang/01-statements.md \
    03-xin-shu-shang/02-explanations.md \
    04-bai-xin/01-I.md \
    04-bai-xin/02-II.md \
    04-bai-xin/03-III.md \
    04-bai-xin/04-IV.md \
    04-bai-xin/05-V.md \
    04-bai-xin/06-VI.md \
    04-bai-xin/07-VII.md \
    04-bai-xin/08-VIII.md \
    04-bai-xin/09-IX.md \
    04-bai-xin/10-X.md \
    04-bai-xin/11-XI.md \
    04-bai-xin/12-XII.md \
    01-nei-ye/intro.md \
    02-xin-shu-xia/intro.md \
    03-xin-shu-shang/intro.md \
    04-bai-xin/intro.md \
    README.md \
    01-nei-ye/notes.md \
    02-xin-shu-xia/notes.md \
    03-xin-shu-shang/notes.md \
    04-bai-xin/notes.md > "$MD"

# Build epub.
if [ $1 = "epub" ]; then
    EPUB="GuanziXinShu-$COMMIT.epub"
    HTML="GuanziXinShu-$COMMIT.html.md"
    CJK_FONT="/usr/share/fonts/opentype/noto/NotoSerifCJK-Light.ttc"
    CJK_OUT="epub-fonts/CJK.ttf"
    python epub_fonts.py "$MD" "$CJK_FONT" "$CJK_OUT" cjk
    bash epub-html.bash "$MD" > "$HTML"
    pandoc "$HTML" \
        --defaults epub-defaults.yaml \
        --output "${EPUB}"
    echo Built "${EPUB}"
fi

## Or build pdf.
if [ $1 = "pdf" ]; then
    PDF="GuanziXinShu-$COMMIT.pdf"
    TEX="GuanziXinShu-$COMMIT.tex.md"
    bash pdf-latex.bash "$MD" > "$TEX"
    pandoc "$TEX" \
        --defaults pdf-defaults.yaml \
        --output "${PDF}"
    echo Built "${PDF}"
fi
