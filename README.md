<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/banner-dark.png">
  <img src="assets/banner-light.png" alt="Lab 01: First Commit. Write history worth reading." width="830">
</picture>

Lab 01 introduces foundational Git mechanics: configuration, examining existing history, keeping unwanted files out, and staging atomic commits with descriptive messages.

<div align="center">
  <p><strong>Download the guide</strong></p>
  <a href="https://github.com/reflog-labs/lab-01-first-commit/raw/main/guide/reflog-lab-01-guide-light.pdf"><img src="assets/download-light.png" width="400" alt="Download Lab 01 Guide (Light theme, PDF)"></a>
  <a href="https://github.com/reflog-labs/lab-01-first-commit/raw/main/guide/reflog-lab-01-guide-dark.pdf"><img src="assets/download-dark.png" width="400" alt="Download Lab 01 Guide (Dark theme, PDF)"></a>
  <p><em>Same guide, two themes. Searchable text, no sign-up.</em></p>
</div>

---

## At a glance

| Attribute | Details |
| :--- | :--- |
| **Track** | Foundations |
| **Level** | Basic |
| **Time** | About 60 minutes |
| **You need** | Git 2.28 or newer, a terminal, any text editor (Windows: Git Bash) |
| **Scope** | Local only: nothing is pushed anywhere in this lab |

---

## What you will learn

```diff
+ git init and core configuration defaults
+ inspecting repository history with git log and git show
+ finding historical changes with pickaxe search: git log -S
+ ignoring credentials and dependencies with .gitignore
+ staging partial file edits with git add -p
+ writing clear, structured commit messages using the 50/72 convention
- committing node_modules folders and credential files
- vague commit messages like "stuff", "fix", and "final_v2"
```

---

## Quick start

1. Click **Code** above and select **Download ZIP**. Unpack the archive on your computer.
2. Open your terminal in the unpacked folder. On Windows, right click inside the folder and select **Open Git Bash here**.
3. We cover cloning in Lab 03, so a downloaded ZIP works fine here.
4. Run the setup script to generate the practice project:
   ```bash
   bash setup.sh
   ```
5. Enter the newly created practice repository:
   ```bash
   cd practice
   ```
6. If you ever need a clean slate to restart the lab, run:
   ```bash
   bash setup.sh --reset
   ```

---

## Task 1: Introduce yourself to git

### Goal
Configure your name, email address, default initial branch name, and preferred editor across all Git repositories on your computer.

### Steps
1. Set your full name for commit author attribution:
   ```bash
   git config --global user.name "Jane Doe"
   ```
2. Set your commit author email address:
   ```bash
   git config --global user.email "jane@example.com"
   ```
   If you prefer not to expose your personal email address in Git history, GitHub provides a private noreply address. Accounts created after July 18, 2017 receive an ID-based address formatted as `<ID>+<username>@users.noreply.github.com`. Accounts created before that date use `<username>@users.noreply.github.com`. You can view your exact address in your GitHub account under Settings, Emails.
3. Configure Git to name initial branches `main`:
   ```bash
   git config --global init.defaultBranch main
   ```
4. Set your preferred command-line text editor. Choose one based on your setup:
   - Visual Studio Code:
     ```bash
     git config --global core.editor "code --wait"
     ```
   - Windows Notepad:
     ```bash
     git config --global core.editor "notepad"
     ```
   - macOS or Linux terminal editor (nano):
     ```bash
     git config --global core.editor "nano"
     ```
5. Review your global settings:
   ```bash
   git config --global --list
   ```

> [!NOTE]
> **The vim trap**
> If you make a commit without `-m` and your screen fills with lines starting with `~` characters, Git opened vim. To escape without saving, press `Esc`, type `:q!` and press `Enter`. This leaves the commit message empty and Git aborts the commit. To save your message and finish committing in vim, press `Esc`, type `:wq` and press `Enter`. Leaving a message completely empty always aborts the commit cleanly.

### You are done when
Running `git config --global --list` displays your configured `user.name`, `user.email`, `init.defaultBranch`, and `core.editor`.

---

## Task 2: Read the history

### Goal
Inspect an existing repository with multiple commits. Learn how to reconstruct what each commit accomplished and evaluate message clarity.

The setup script built a repository inside `practice/` for a fictional coffee shop named `tiny-cafe`. Its history contains 6 commits made by fictional team members, but the messages are unhelpful: "stuff", "final_v2", "fix", "wip", "asdf", "update".

Do not rewrite this history. History rewriting belongs in Labs 08 and 09. In this task, you are only auditing history.

### Steps
1. View the commit log in compact single-line format:
   ```bash
   git log --oneline
   ```
2. View changed file summaries and line counts for each commit:
   ```bash
   git log --stat
   ```
3. Inspect the full diff of a specific commit using its short hash:
   ```bash
   git show <hash>
   ```
4. Search for the commit that added the oat milk substitute using Git's pickaxe flag:
   ```bash
   git log -S "Oat milk" -p
   ```
5. In your text editor, create a new file named `AUDIT.md` inside `practice/`.
6. Write one line for at least 3 of the 6 seeded commits. Use this exact format:
   ```
   <short hash>: <better subject line>
   ```
   For example:
   ```
   a1b2c3d: Add hot drinks and pastry pricing to menu
   b2c3d4e: Correct price of almond croissant
   c3d4e5f: Add weekday opening hours to README
   ```
7. Save `AUDIT.md`. Do not commit this file yet.

### You are done when
`practice/AUDIT.md` contains at least 3 lines referencing valid seeded commit hashes, each paired with an imperative subject line that accurately describes the changes in that commit.

---

## Task 3: Keep the junk out

### Goal
Prevent sensitive configuration files and transient build dependencies from entering version control.

Inspect your working directory with `git status`. You will see two untracked items created during setup: `.env` (containing a fake API key `CAFE_API_KEY=not-a-real-key-lab-01-practice`) and a `node_modules/` folder.

Never use `git add .` blindly. Staging entire directories without reviewing untracked files is the number one reason credentials and dependency bundles leak into Git history.

### Steps
1. Inspect the untracked items:
   ```bash
   git status
   ```
2. Create a file named `.gitignore` inside `practice/`:
   ```
   .env
   node_modules/
   ```
3. Verify that Git honors both ignore rules:
   ```bash
   git check-ignore -v .env node_modules/tiny-pkg/package.json
   ```
   Git will print the line of `.gitignore` that matched each file.
4. Stage only `.gitignore` explicitly:
   ```bash
   git add .gitignore
   ```
5. Verify what is staged before committing:
   ```bash
   git diff --staged
   ```
6. Make your first commit using your configured editor:
   ```bash
   git commit
   ```
   Your editor will open. Type a clean subject line, such as `Ignore local environment files and dependencies`, save the file, and close the editor.

### You are done when
`git status` reports `.gitignore` committed, `.env` and `node_modules/` remain untracked without appearing in Git status, and `git log -1` displays your new commit.

---

## Task 4: Two changes, two commits

### Goal
Use patch staging (`git add -p`) to split separate edits within the same file into two distinct, well-described commits.

In `practice/menu.md`, you need to make two changes:
1. Fix the typo `Expresso` near the top of the file so it reads `Espresso`.
2. Add a new drink item at the very bottom of the file:
   ```markdown
   - Cortado: $3.75
   ```

Because these changes sit 15 lines apart, Git isolates them into separate hunks.

> [!NOTE]
> **The 50/72 message convention**
> Strive for a subject line of 50 characters or fewer, and wrap body lines near 72 characters.
> Why?
> 1. `git log --oneline` truncates or wraps long subjects, making logs hard to scan.
> 2. Terminal windows, code review tools, and Git email commands wrap text with left indentation. Long lines become jagged.
> 3. Short subjects force you to name the core change.
>
> This convention is standard practice across open source projects, not a rigid rule enforced by the Git binary. Write in the imperative mood: "Fix typo in menu", not "Fixed typo in menu". Use the test: "If applied, this commit will [your subject line]". Omit trailing periods. Explain why a change exists in the commit body, not just how. Save informal work-in-progress notes for private scratch work, not shared history.

### Steps
1. Open `practice/menu.md` in your text editor.
2. Correct `Expresso` to `Espresso` on line 4.
3. At the end of `menu.md`, add `- Cortado: $3.75`.
4. Save `menu.md`.
5. Run patch staging:
   ```bash
   git add -p menu.md
   ```
   Git displays the first hunk (the typo fix). Type `y` to stage this hunk.
   Git then displays the second hunk (the Cortado addition). Type `n` to leave it unstaged for now.
   *(If both edits ever appear grouped into a single hunk, type `s` to split the hunk into smaller pieces).*
6. Verify staged changes contain only the typo fix:
   ```bash
   git diff --staged
   ```
7. Commit the typo fix:
   ```bash
   git commit -m "Fix espresso spelling in drinks menu"
   ```
8. Stage the remaining change in `menu.md`:
   ```bash
   git add menu.md
   ```
9. Commit the Cortado addition with an explanatory body wrapped near 72 characters:
   ```bash
   git commit
   ```
   In your editor, write a subject line, leave the second line blank, and add an explanatory body:
   ```
   Add cortado to menu

   Customers frequently ask for an espresso drink with equal parts
   steamed milk. Adding cortado fills the gap between espresso and latte.
   ```
   Save and close your editor.
10. Stage and commit your `AUDIT.md` file from Task 2:
    ```bash
    git add AUDIT.md
    git commit -m "Add history audit for initial seeded commits"
    ```
11. View your complete commit log:
    ```bash
    git log --oneline
    ```

### You are done when
Your repository contains at least 4 learner commits, the typo fix and Cortado addition exist in separate commits, at least one commit includes a wrapped body, `AUDIT.md` is committed, and running `bash check.sh` from the repository root passes all tests.

---

## Check your work

Return to the lab root folder and execute the verification script:
```bash
bash check.sh
```

You can also pass a custom directory path:
```bash
bash check.sh ./practice
```

### Reading results
- `[pass]`: Requirement satisfied.
- `[warn]`: An advisory observation (for example, subject line length between 51 and 72 characters, missing editor configuration, or non-imperative verb form). Warnings do not cause a non-zero exit code.
- `[fail]`: Requirement unmet. The output provides a one-line explanation pointing directly to the relevant task.

The script exits with code `0` when there are zero failures.

---

## Level up (optional)

<details>
<summary>Click to view advanced commit techniques</summary>

### Commit trailers
Trailers are key-value pairs placed at the bottom of a commit message body, separated by a colon. Common trailers include:
- `Fixes: #104` or `Closes: #104`: Link and automatically close issues on hosting platforms.
- `Co-authored-by: Name <email>`: Attributes work to multiple collaborators.

### Developer Certificate of Origin (DCO)
Projects following the Linux kernel contribution model require sign-off trailers to confirm you have the right to submit code:
```bash
git commit -s
```
This automatically appends `Signed-off-by: Jane Doe <jane@example.com>` to your message body.

### Commit templates
You can configure Git to load a boilerplate reminder template whenever you run `git commit` without `-m`:
```bash
git config --global commit.template ~/.gitmessage.txt
```

### Conventional Commits
Many projects automate changelog generation using structured prefix tags:
- `feat: add oat milk option to menu`
- `fix: correct espresso spelling in menu`
- `docs: document counter ordering policy`

Different teams adopt different standards. Always inspect existing project history with `git log` before choosing a style.

</details>

---

## Troubleshooting

<details>
<summary>Stuck in vim with tilde (~) characters</summary>

Press `Esc` to ensure normal mode is active.
- To abort without committing: type `:q!` and press `Enter`.
- To save your message and commit: type `:wq` and press `Enter`.
Git aborts the commit if the commit message remains empty.

</details>

<details>
<summary>Error: Author identity unknown</summary>

Git requires an identity before recording any commit. Configure your global details:
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

</details>

<details>
<summary>bash: command not found (Windows)</summary>

On Windows, use the Git Bash terminal bundled with Git for Windows. Open File Explorer, right click inside the repository directory, and select **Open Git Bash here**.

</details>

<details>
<summary>setup.sh says practice already exists</summary>

To wipe the practice folder and recreate the initial state, run:
```bash
bash setup.sh --reset
```
The reset flag checks for the Lab 01 marker file to ensure it never touches unrelated projects.

</details>

<details>
<summary>Line ending warnings on Windows (LF will be replaced by CRLF)</summary>

Git warns about Windows carriage return conversions. The repository includes `.gitattributes` to keep shell scripts and markdown files normalized to LF line endings. You can safely ignore informational conversion notices.

</details>

<details>
<summary>I added .gitignore but files still show as tracked</summary>

`.gitignore` only ignores untracked files. If a file was already tracked in Git before adding the ignore rule, Git continues tracking it. To untrack without deleting your local copy, run:
```bash
git rm --cached <filename>
```

</details>

<details>
<summary>I committed .env by mistake</summary>

Do not panic. Reset the practice repository and start fresh:
```bash
bash setup.sh --reset
```
Lab 09 covers how to remove committed credentials and rewrite historical commits.

</details>

<details>
<summary>git add -p shows only one hunk</summary>

If your edits were placed too close together, Git combines them into one hunk. When prompted, type `s` to split the hunk into smaller segments.

</details>

---

## What is in the guide

The accompanying guide provides visual architectural explanations of Git's data model, an annotated message anatomy breakdown, real-world commit rewrite case studies, a pre-commit review checklist, a command reference card, and an annotated reading list.

---

## Sources and further reading

- [How to Write a Git Commit Message by Chris Beams](https://cbea.ms/git-commit/)
  A thorough guide explaining the seven rules of great commit messages and why team velocity depends on clear commit logs.
- [Conventional Commits Specification](https://www.conventionalcommits.org/en/v1.0.0/)
  A structured specification for adding machine-readable meaning to commit messages.
- [Pro Git Book by Scott Chacon and Ben Straub](https://git-scm.com/book/en/v2)
  The comprehensive open source reference covering Git configuration and daily workflows.
- [Official Git Documentation](https://git-scm.com/doc)
  The definitive reference manuals for git-config, git-log, git-add, and Git porcelain commands.

---

## What is next

In Lab 02, you will learn how branches work and how Git isolates parallel streams of work.

---

## License

This lab is released under the [MIT License](LICENSE). Copyright (c) 2026 Reflog Labs.
