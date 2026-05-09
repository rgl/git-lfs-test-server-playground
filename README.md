# About

[![test](https://github.com/rgl/git-lfs-test-server-playground/actions/workflows/test.yml/badge.svg)](https://github.com/rgl/git-lfs-test-server-playground/actions/workflows/test.yml)

My [Git-LFS](https://git-lfs.com) Playground.

# Usage

This can be tested [in docker compose](#usage-docker-compose).

## Usage (docker compose)

Install docker and docker compose.

Create the environment:

```bash
docker compose up --build --detach
docker compose ps
docker compose logs
```

Access the git-lfs-test-server management page:

```bash
xdg-open http://localhost:8080/mgmt
```

Enter the playground:

```bash
docker compose exec git-lfs-test-server bash -l
```

Verify that we do not need to run `git lfs install`:

```bash
# NB here we can see that git lfs install --system was called at the
#    git-lfs package installation.
cat /var/lib/dpkg/info/git-lfs.postinst
```

Create a repository to represent the upstream repository:

```bash
git init --bare --initial-branch main test-upstream
```

Clone the upstream repository:

```bash
git clone test-upstream test
cd test
```

Configure the git credential helper and add the git lfs server credentials:

```bash
# NB the cache credential helper uses a background daemon. we can signal it to
#    exit with git credential-cache exit.
# NB the cache credential helper daemon is shared by all the git processes of
#    the same user that use the same socket (by default, its configured as
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
```

Configure the git repository to use the local git-lfs repository:

```bash
git config -f .lfsconfig lfs.url http://localhost:8080
git add .lfsconfig
git commit -m "configure the git-lfs repository"
```

Configure the git repository to track the `*.txt` files with git-lfs:

```bash
git lfs track "*.txt"
git add .gitattributes
git commit -m "git-lfs track txt files"
```

Add a file that is tracked by git-lfs:

```bash
# NB its content will be stored in the git-lfs repository; not in
#    the git repository.
echo test >test.txt
git add test.txt
git commit -m "add test txt file"
```

Push the commits to the upstream repository:

```bash
# NB this also triggers a git lfs push to push the files to the git-lfs
#    repository.
git push

# NB git lfs push is optional. this is here just to show how we can force
#    an interaction with the git lfs server.
git lfs push origin main --all
```

Delete the git-lfs tracked file from the current git branch:

```bash
# NB the file will not be deleted from the git-lfs repository.
git rm test.txt
git commit -m 'delete test.txt'
git push
```

Show information about the git and git-lfs configuration:

```bash
git config --show-origin --list
git lfs env
git lfs ls-files --debug
find .git/lfs -type f
```

Exit the playground:

```bash
exit
```

Destroy the environment:

```bash
docker compose down --volumes --remove-orphans --timeout=0
```
