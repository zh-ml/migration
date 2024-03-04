#!/bin/sh
set -e

check_params() {
    if [ -z "$SOURCE_TOKEN" ] || [ -z "$REMOTE_TOKEN" ]; then
        echo "[SOURCE_TOKEN | REMOTE_TOKEN] needed."
        exit 1
    fi
    if [ -z "$SOURCE_REPO" ] || [ -z "$REMOTE_REPO" ]; then
        echo "[SOURCE_REPO | REMOTE_REPO] needed."
        exit 1
    fi
    if [ -z "$BASE_BRANCH" ] || [ -z "$HEAD_BRANCH" ]; then
        echo "[BASE_BRANCH | HEAD_BRANCH] needed."
        exit 1
    fi
}

auth() {
    echo $SOURCE_TOKEN > gh.txt
    echo $REMOTE_TOKEN > ghe.txt
    gh auth login --with-token < gh.txt
    gh auth login --hostname github.jp.klab.com  --with-token < ghe.txt
}

check_remote_pr() {
    pr_remote=$(gh pr ls -R $REMOTE_REPO -B $BASE_BRANCH -H $HEAD_BRANCH --json title,body)
    pr_length=$(echo "$pr_remote"|jq length)
    if [ "$pr_length" -eq 1 ]; then
        echo "remote PR already exist...!"
        exit 1
    fi
}

sync_pr() {
    check_remote_pr
    echo "PR from $HEAD_BRANCH to $BASE_BRANCH."
    pr_info=$(gh pr ls -R $SOURCE_REPO -B $BASE_BRANCH -H $HEAD_BRANCH --json title,body)

    echo -e "PR: \n$pr_info"
    pr_title=$(echo "$pr_info"|jq -r '.[0].title')
    pr_body=$(echo "$pr_info"|jq -r '.[0].body')

    echo "sync PR from $SOURCE_REPO to $REMOTE_REPO."
    gh pr create -R $REMOTE_REPO -B $BASE_BRANCH -H $HEAD_BRANCH --title "$pr_title" --body "$pr_body"

    echo "sync PR to enterprise..."
}

check_params
auth
sync_pr 