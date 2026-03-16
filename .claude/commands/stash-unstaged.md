---

description: "Stash unstaged/untracked files while preserving staged changes"
allowed-tools:

- Bash(git \*)

---

# Stash Unstaged Changes

This command stashes unstaged and untracked files while preserving any files already staged for commit.

Check if there are any files staged for commit (i.e. git added) with `git diff --cached`

- If there are none, simply run `git stash push --include-untracked`
- If there are unstaged changes in the workspace in addition to staged, you are to perform the following series of commands:
  1. `git commit -m 'WIP: staged changes' --no-verify` — commit the staged changes temporarily
  1. `git stash push --include-untracked` — to stash the remaining unstaged changes
  1. `git reset --soft HEAD^` — to undo the temporary commit
  1. `git add .` — to stage the previously staged for commit files
