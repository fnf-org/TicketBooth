---

description: "Create a pull request from current branch or staged changes"
allowed-tools:

- Bash(./.claude/branch-name.sh)
- Bash(just check-all:\*)
- Bash(git \*)
- Bash(gh \*)

---

# Create One or More Pull Request from the Currently Modified or Staged Files

IMPORTANT: NON-INTERACTIVITY. This command should complete nearly always without human interaction. Only if you are really confused or lacking a major permission should you pause and ask question. Assume that the human is away from the keyboard while you are submitting their changes as PRs.

## Command's Purpose

The purpose of this command is to take all locally modified files (staged or not), split them into unrelated, or related but stackable commits and PRs, and do it non-interactively, and do it in such a away that both locally and on Github CI (if there is one) each PR passes, does not have merge conflicts, and should be ready to be reviewed and merged.

## Steps to Accomplish

1. First, feel free to `git add . ` so that all the modified files are staged. This command is deliberately mean to commit ALL modified files for simplicity, otherwise it's difficult to identify what should or should not be committed.
2. Second, if the repo supports command `just format` or `make format` or `rubocop -a` (or other safe linter fix commandss) — go ahead and run them now. If there are locally modified files, `git add` them.
3. If we are NOT on the main branch, then do a diff between the current branch and the main (excluding the staged files) to understand what the context of the current branch is. 
4. Next you are going to review all the staged files and break them up by "context": i.e. that means they need to be committed and pushed to a PR together.  This will also help you identify which files should be committed into the current branch (i.e. they all relate to the changes on this branch, or the branch name). If there are several unrelated changes in this set of staged files, OR multiple related changes, but there are a lot of changes (the diff is > 500 lines) you will need to break up this PR into multiple PRs.

Multiple PRs can either be on branches that are created off main (those changes should have nothing to do with the current branch), OR they can be committed and pushed as multiple PRs that are stacked on each other.

For every commit and branch that you push you must ensure that local tests are passing and if not either fix them (if that's easy) or refuse to push a PR until you pairing with the developer resolve all test issues. 

Tests are typically invoked as:

```
just test # if there is a justfile at the root
make test # if there is a Makefile at the root
bundle exec rspec --format documentation # if this is a ruby repo, meaning there is a Gemfile and Gemfile.lock at the root level and spec folder
npm run test # if there is package.json and a test command
# for other types of repos identify the most common ways to run tests, and do run them before committing any code.
```

## Branch Names

We provided a convenient shell script in the .claude directory, called `./.claude/branch-name.sh`

To generate a new branch name, identify from three to six key words describing this change and  then run from the project root:

```bash
$ .claude/branch-name.sh add copilot LLM bubble for admins # this script will output the following
kig/add-copilot-llm-bubble-for-admins
```

If you run this script, capture it's STDOUT and you'll get the branch name.

It prefixes the current user `$USER` and a slash, and then dash-joins all the words you specified.

If you need information on how to split one large PR into smaller ones, the following URLs might be helpful:

- https://www.davepacheco.net/blog/2025/stacked-prs-on-github/
- https://itsnotbugitsfeature.com/2019/10/22/splitting-a-big-pull-request-into-smaller-review-able-ones
- https://newsletter.pragmaticengineer.com/p/stacked-diffs

## Committing Changes and Creating the PR

Once we are on the appropriate branch, and either there are only changes staged for commit or NO changes at all (so we'll be creating the PR from the branch).

## Rebase from main?

Compare the local main with remote main, and if they diverged, you'll want to stash all the changes, switch to main, do git pull, then restore the branch, and before you pop the stash, run `git rebase main`. Resolve any conflicts that you are able to do on your own, otherwise this is one case where you can engage interactively and ask the developer for help. Once the current branch is rebased, you `git stash pop`. This may also result in conflicts. The same thing: attempt to resolve them and commit the rebase, or engage with the developer.

### Committing Currently Staged Changes

At this point, you should either a clean branch with all changes committed, or some changes staged for commit.

If there are changes staged for commit, you must perform `git diff --cached`, and summarize those changes in the markdown format in a temporary file we'll call <tempfile> (preferably under /tmp folder), and create a short title for the commit.

Then we commit with `git commit -m "<title>" -F "<tempfile>"`, and push the changes `git push -u origin`.

### Creating the PR

This is the final step. You are to use command `gh` (which stands for `github`).

In order to create a PR we must NOT be on the `main` branch, we must have all changes pushed to the origin and we must have no locally untracked or modified files.

The next step is describing the PR.

You are going to perform the diff of the current branch with the remote `main` branch using `git diff origin/main...HEAD`, and analyze it. You will create a markdown file that we'll refer to <pr-description> preferably in the `/tmp` folder, that describes the changes of this PR precisely, professionally, without any emojis. It should have the top header title that we'll refer to <pr-title>, (with a single '#' in markdown) that will also be the name of the PR. It should have the sections such as Summary (a short abstract-type description, no more than a few paragraphs) Description (if necessary, a more detailed description), Motivation, Testing, Backwards Compatibility, Scalability & Performance Impact, and Code Quality Analysis.

Once completed analysis and summarizing of this change, you will invoke the command `gh pr create -a @me -B main -F "<pr-description>" -t "<pr-title>"`.

If the command responds with an error such as Github Token authorization is insufficient, you are to save the PR description in the file at the root of the project called `PR.md` and report this to the user. Also print the URL required to create the PR on the web by clicking on the URL.

If you were able to create the PR with the `gh pr create` command, then open the web page to it anyway. Get the PR ID with `gh pr list | grep "<pr-title>" | awk '{print $1}'`
