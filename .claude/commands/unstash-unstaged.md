---

description: "Restore previously stashed unstaged changes"
allowed-tools:

- Bash(git \*)

---

# Unstash Unstaged Changes

This command brings back the changes made by the "stash-unstaged" command.

Ensure that the current workspace is clean (no staged or unstaged files) and if there are any — ask if the user still wants to proceed.
If the user confirms, run `git stash apply` command to bring back previously stashed changes.
