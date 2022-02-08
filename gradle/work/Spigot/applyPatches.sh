#!/bin/sh

PS1="$"
basedir=`pwd`
echo "Rebuilding Forked projects.... "

applyPatch() {
    what=$1
    target=$2
    branch=$3

    cd "$basedir"
    if [ ! -d  "$target" ]; then
        git clone ../$what $target
    fi
    cd "$basedir/$target"
    echo "Resetting $target to $what..."
    git config commit.gpgSign false
    git remote rm origin >/dev/null 2>&1
    git remote add origin ../../$what >/dev/null 2>&1
    git checkout master >/dev/null 2>&1
    git fetch origin >/dev/null 2>&1
    git reset --hard $branch

    echo "  Applying patches to $target..."
    git am --abort >/dev/null 2>&1
    git am --3way "../${what}-Patches/"*.patch
    if [ "$?" != "0" ]; then
        echo "  Something did not apply cleanly to $target."
        echo "  Please review above details and finish the apply then"
        echo "  save the changes with rebuildPatches.sh"
        exit 1
    else
        echo "  Patches applied cleanly to $target"
    fi
}

cd ../Bukkit
hash=$(git rev-parse HEAD)
git branch -f spigot "$hash"

applyPatch Bukkit Spigot-API origin/spigot && applyPatch CraftBukkit Spigot-Server origin/patched
