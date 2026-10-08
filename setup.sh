#!/usr/bin/env bash
# Reflog Labs: Lab 01 (First Commit)
# Setup script: creates the tiny-cafe practice repository with seeded history.

set -eu

# Print with color when stdout is a terminal and NO_COLOR is not set
use_color=0
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  use_color=1
fi

msg_info() {
  if [ "$use_color" -eq 1 ]; then
    printf "\033[1;34m==>\033[0m %s\n" "$1"
  else
    printf "==> %s\n" "$1"
  fi
}

msg_ok() {
  if [ "$use_color" -eq 1 ]; then
    printf "\033[1;32m==>\033[0m %s\n" "$1"
  else
    printf "==> %s\n" "$1"
  fi
}

msg_err() {
  if [ "$use_color" -eq 1 ]; then
    printf "\033[1;31mError:\033[0m %s\n" "$1" >&2
  else
    printf "Error: %s\n" "$1" >&2
  fi
}

# 1. Verify Git installation and version
if ! command -v git >/dev/null 2>&1; then
  msg_err "git is required but was not found on your PATH."
  printf "Please install Git (2.28 or newer): https://git-scm.com/downloads/\n" >&2
  exit 1
fi

raw_ver=$(git --version 2>/dev/null | sed -e 's/[^0-9]*\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/')
major=$(echo "$raw_ver" | cut -d. -f1)
minor=$(echo "$raw_ver" | cut -d. -f2)

if [ "${major:-0}" -lt 2 ] || { [ "${major:-0}" -eq 2 ] && [ "${minor:-0}" -lt 28 ]; }; then
  msg_err "Git 2.28 or newer is required. Found version: $(git --version)"
  printf "Please upgrade Git: https://git-scm.com/downloads/\n" >&2
  exit 1
fi

# 2. Check invocation arguments
do_reset=0
if [ $# -gt 0 ]; then
  if [ "$1" = "--reset" ]; then
    do_reset=1
  else
    msg_err "Unknown argument: $1"
    printf "Usage: bash setup.sh [--reset]\n" >&2
    exit 1
  fi
fi

# 3. Handle existing practice directory
marker_rel=".git/reflog-lab-01-practice"
if [ -d "practice" ]; then
  if [ "$do_reset" -eq 1 ]; then
    if [ -f "practice/$marker_rel" ]; then
      msg_info "Resetting existing practice directory..."
      rm -rf practice
    else
      msg_err "Directory ./practice exists but does not contain the Lab 01 marker."
      printf "Refusing to delete practice/ to avoid destroying unrelated work.\n" >&2
      printf "Please inspect or remove ./practice manually.\n" >&2
      exit 1
    fi
  else
    msg_err "Directory ./practice already exists."
    printf "To start over, run: bash setup.sh --reset\n" >&2
    exit 1
  fi
fi

msg_info "Building practice repository for tiny-cafe..."
mkdir -p practice
cd practice

# 4. Initialize repository on branch main without touching global config
git init -b main >/dev/null 2>&1 || {
  git init >/dev/null 2>&1
  git checkout -b main >/dev/null 2>&1
}

# Helper to make seeded commits with deterministic timestamps and authors
make_seeded_commit() {
  author_name="$1"
  author_email="$2"
  commit_date="$3"
  commit_msg="$4"

  GIT_AUTHOR_NAME="$author_name" \
  GIT_AUTHOR_EMAIL="$author_email" \
  GIT_AUTHOR_DATE="$commit_date" \
  GIT_COMMITTER_NAME="$author_name" \
  GIT_COMMITTER_EMAIL="$author_email" \
  GIT_COMMITTER_DATE="$commit_date" \
  git commit -m "$commit_msg" >/dev/null
}

# 5. Seed messy history (6 commits)
# Commit 1: Initial files with typo Expresso
cat << 'EOF' > README.md
# Tiny Cafe

Neighborhood coffee and pastries.

## Welcome
Orders are taken at the counter.
EOF

cat << 'EOF' > menu.md
# Tiny Cafe Menu

## Hot Drinks
- Expresso: $3.00
- Americano: $3.50
- Cappuccino: $4.00
- Latte: $4.50

## Pastries
- Plain Croissant: $3.00
- Almond Croissant: $3.75
EOF

git add README.md menu.md
make_seeded_commit "Morgan Smith" "morgan@example.invalid" "2026-02-01T09:00:00Z" "stuff"

# Commit 2: Almond Croissant price fix
cat << 'EOF' > menu.md
# Tiny Cafe Menu

## Hot Drinks
- Expresso: $3.00
- Americano: $3.50
- Cappuccino: $4.00
- Latte: $4.50

## Pastries
- Plain Croissant: $3.00
- Almond Croissant: $4.00
EOF

git add menu.md
make_seeded_commit "Taylor Jones" "taylor@example.invalid" "2026-02-02T10:15:00Z" "fix"

# Commit 3: Add opening hours in README
cat << 'EOF' > README.md
# Tiny Cafe

Neighborhood coffee and pastries.

## Welcome
Orders are taken at the counter.

## Hours
Tuesday to Sunday: 7am to 4pm.
EOF

git add README.md
make_seeded_commit "Alex Rivera" "alex@example.invalid" "2026-02-03T11:30:00Z" "asdf"

# Commit 4: Add oat milk option (findable with git log -S "Oat milk")
cat << 'EOF' > menu.md
# Tiny Cafe Menu

## Hot Drinks
- Expresso: $3.00
- Americano: $3.50
- Cappuccino: $4.00
- Latte: $4.50

## Milk Options
- Whole milk: default
- Oat milk substitute: +$0.75

## Pastries
- Plain Croissant: $3.00
- Almond Croissant: $4.00
EOF

git add menu.md
make_seeded_commit "Jordan Lee" "jordan@example.invalid" "2026-02-04T14:00:00Z" "update"

# Commit 5: Draft seasonal special
cat << 'EOF' > menu.md
# Tiny Cafe Menu

## Hot Drinks
- Expresso: $3.00
- Americano: $3.50
- Cappuccino: $4.00
- Latte: $4.50

## Milk Options
- Whole milk: default
- Oat milk substitute: +$0.75

## Pastries
- Plain Croissant: $3.00
- Almond Croissant: $4.00

## Seasonal Specials
- Cardamom Rose Latte: $5.25
EOF

git add menu.md
make_seeded_commit "Sam Patel" "sam@example.invalid" "2026-02-05T16:20:00Z" "wip"

# Commit 6: Extend closing hour to 5pm
cat << 'EOF' > README.md
# Tiny Cafe

Neighborhood coffee and pastries.

## Welcome
Orders are taken at the counter.

## Hours
Tuesday to Sunday: 7am to 5pm.
EOF

git add README.md
make_seeded_commit "Morgan Smith" "morgan@example.invalid" "2026-02-06T17:45:00Z" "final_v2"

# 6. Add untracked junk files
cat << 'EOF' > .env
CAFE_API_KEY=not-a-real-key-lab-01-practice
PORT=3000
EOF

mkdir -p node_modules/tiny-pkg
cat << 'EOF' > node_modules/tiny-pkg/package.json
{
  "name": "tiny-pkg",
  "version": "1.0.0"
}
EOF

cat << 'EOF' > node_modules/tiny-pkg/index.js
// Invented package stub for practice
module.exports = { name: "tiny-pkg" };
EOF

# 7. Write marker file
printf "reflog-lab-01-practice-v1\n" > "$marker_rel"

cd ..

msg_ok "Setup complete. Created ./practice with 6 seeded commits."
printf "\nNext steps:\n"
printf "  cd practice\n"
printf "  git log --oneline\n"
