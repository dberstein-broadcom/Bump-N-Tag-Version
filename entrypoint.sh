#!/bin/sh
set -e

# git config
git config --global user.email "Bump-N-Tag@github-action.com"
git config --global user.name "Bump-N-Tag App"

# git checkout ...
[ "x${GITHUB_EVENT_NAME}x" = "xpushx" ] || { GITHUB_REF=${GITHUB_HEAD_REF} && git checkout ${GITHUB_REF}; }

# bump version ...
N=3 && FILE="${1:-VERSION}" && BUMP_A=$(cat "${FILE}") && TMPFILE="$(mktemp --tmpdir version.XXXXXX)" \
&& ( tr . \\n | sed -r $N' s/^(.*)([0-9]+)(.*)/echo \1$(echo 1+\2 | bc)\3/ge' && seq 1 $N ) \
< "${FILE}" | head -n3 | tr \\n . | sed 's/\.*$/\n/g' \
> "$TMPFILE" && mv "$TMPFILE" "${FILE}" && BUMP_B=$(cat "${FILE}") && echo -e "Bumped: ${BUMP_A} -> ${BUMP_B}"

# git commit ...
git add "${FILE}" && git commit -m "Incremented to ${BUMP_B}"  -m "[skip ci]"

( [ -n "$2" ] && [ "$2" = "true" ] ) && ( git tag -a "${BUMP_B}" -m "[skip ci]" ) || echo "No tag created"

# git push ...
git push --follow-tags "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" HEAD:${GITHUB_REF}

exit 0
