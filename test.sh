#!/usr/bin/bash
set -euxo pipefail

exec 2>&1

rm -rf test-upstream test

# create a repository to represent the upstream repository.
git init --bare --initial-branch main test-upstream

# clone the upstream repository.
git clone test-upstream test

pushd test

# configure the git credential helper and add the git lfs server credentials.
# NB the cache credential helper uses a background daemon. we can signal it to
#    exit with git credential-cache exit.
# NB the cache credential helper daemon is shared by all the git processes of
#    the same user that use the same socket (default configured as
#    --socket=$XDG_CACHE_HOME/git/credential/socket).
# NB we can add multiple credential helpers with --add. they are all executed,
#    by the order they are defined, until one of them returns a credential.
git config --local credential.helper 'cache --timeout=3600'
git credential approve <<EOF
url=http://localhost:8080
username=admin
password=admin
EOF
git config --show-origin --get-all credential.helper
ls -laF ~/.cache/git/credential/socket

# configure the git repository to use the local git-lfs repository.
git config -f .lfsconfig lfs.url http://localhost:8080
git add .lfsconfig
git commit -m "configure the git-lfs repository"

# configure the git repository to track the `*.txt` files with git-lfs.
git lfs track "*.txt"
git add .gitattributes
git commit -m "git-lfs track txt files"

# add a file that is tracked by git-lfs.
# NB its content will be stored in the git-lfs repository; not in
#    the git repository.
echo test >test.txt
git add test.txt
git commit -m "add test txt file"

# push the commits to the upstream repository.
# NB this also triggers a git lfs push to push the files to the git-lfs
#    repository
git push

# show information about the git and git-lfs configuration.
git config --show-origin --list | cat
git lfs env
git lfs ls-files --debug
find .git/lfs -type f

popd

# show how the files ended up in the upstream repository.
pushd test-upstream
git ls-tree -r -l main
git show main:.lfsconfig
git show main:test.txt
popd
