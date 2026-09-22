#!/usr/bin/env bash
set -e

echo "=== VRCX Fork Sync & Rebase Utility ==="

# Ensure upstream remote exists
if ! git remote get-url upstream >/dev/null 2>&1; then
    echo "Adding upstream remote: https://github.com/vrcx-team/VRCX.git"
    git remote add upstream https://github.com/vrcx-team/VRCX.git
fi

echo "Fetching latest changes and tags from upstream..."
git fetch upstream master --tags

OLD_VERSION=$(cat Version 2>/dev/null || echo "unknown")

if git merge-base --is-ancestor upstream/master HEAD; then
    echo "Fork is already up-to-date with upstream/master."
else
    echo "New commits detected in upstream. Rebasing..."
    if ! git rebase upstream/master; then
        echo "Rebase encountered conflicts. Resolve conflicts and run: git rebase --continue"
        exit 1
    fi
    NEW_VERSION=$(cat Version 2>/dev/null || echo "unknown")
    echo "Rebase completed successfully!"
    if [ "$OLD_VERSION" != "$NEW_VERSION" ]; then
        echo "Version changed from $OLD_VERSION to $NEW_VERSION"
    fi
    echo "To push rebased master to your fork, run:"
    echo "  git push origin master --force-with-lease --tags"
fi
