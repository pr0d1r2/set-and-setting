# shellcheck shell=bash
# Lefthook-compatible narrow-language-add wrapper.
# Inverse of compact: appends unknown repo words to the dictionary.
# NOTE: sourced by writeShellApplication — no shebang or set needed.

DICT="${NARROW_LANGUAGE_DICT:-.narrow-language.dic}"
if [ ! -f "$DICT" ]; then
    exit 0
fi

dict_basename=$(basename "$DICT")

repo_words=$(
    {
        git ls-files --cached
        git diff --cached --name-only
    } |
        sort -u |
        grep -v "^${dict_basename}$" |
        grep -v '^flake\.lock$' |
        if [ -n "${NARROW_LANGUAGE_GLOB_INCLUDE:-}" ]; then
            if [ -n "${NARROW_LANGUAGE_GLOB_INCLUDE_EXTRA:-}" ]; then
                grep -E "${NARROW_LANGUAGE_GLOB_INCLUDE}|${NARROW_LANGUAGE_GLOB_INCLUDE_EXTRA}"
            else
                grep -E "$NARROW_LANGUAGE_GLOB_INCLUDE"
            fi
        else
            cat
        fi |
        while IFS= read -r f; do [ -f "$f" ] && printf '%s\n' "$f"; done |
        xargs sed -E 's/[0-9a-f]{40,64}//g' 2>/dev/null |
        grep -oE '[A-Za-z]+' |
        sed 's/\([a-z0-9]\)\([A-Z]\)/\1\n\2/g' |
        tr '[:upper:]' '[:lower:]' |
        awk 'length >= 3 && (/a/ || /e/ || /i/ || /o/ || /u/)' |
        sort -u
)

unknown=$(comm -23 <(echo "$repo_words") <(LC_ALL=C sort -u "$DICT"))

if [ -z "$unknown" ]; then
    exit 0
fi

count=$(echo "$unknown" | wc -l | tr -d ' ')
echo "narrow-language-add: adding $count new word(s) to $DICT:"
while IFS= read -r w; do printf '  %s\n' "$w"; done <<<"$unknown"

{
    cat "$DICT"
    echo "$unknown"
} | LC_ALL=C sort -u >"${DICT}.tmp"
mv "${DICT}.tmp" "$DICT"
git add "$DICT"
