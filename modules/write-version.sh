#!/usr/bin/env bash

VERSION_FILE=$(__get_version_file)
T3_VERSION_FILE=$(__get_t3_version_file)
VERSION_PREFIX=$(git config --get gitflow.prefix.versiontag)

if [ ! -z "$VERSION_PREFIX" ]; then
    VERSION=${VERSION#$VERSION_PREFIX}
fi

if [ -z "$VERSION_BUMP_MESSAGE" ]; then
    VERSION_BUMP_MESSAGE="Bump version to %version%"
fi

echo -n "$VERSION" > $VERSION_FILE && \
    git add $VERSION_FILE

if [ -f "$T3_VERSION_FILE" ] ; then
    VERSION=$VERSION awk '/'"'"'version/ { print "\t'"'"'version'"'"' => '"'"''"$VERSION"''"'"', // updated by git-flow-hooks";next } { print $0 }' "$T3_VERSION_FILE" > "$T3_VERSION_FILE.tmp" &&
    mv "$T3_VERSION_FILE.tmp" "$T3_VERSION_FILE"
    git add "$T3_VERSION_FILE"
fi

git commit -m "$(echo "$VERSION_BUMP_MESSAGE" | sed s/%version%/$VERSION/g)"

if [ $? -ne 0 ]; then
    __print_fail "Unable to write version to $VERSION_FILE."
    return 1
else
    return 0
fi
