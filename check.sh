#!/usr/bin/env bash
# Reflog Labs: Lab 01 (First Commit)
# Checker script: verifies tasks using Git plumbing only.

set -u

# Configure terminal colors honoring NO_COLOR
use_color=0
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  use_color=1
fi

col_pass() {
  if [ "$use_color" -eq 1 ]; then printf "\033[32m[pass]\033[0m %s\n" "$1"; else printf "[pass] %s\n" "$1"; fi
}

col_warn() {
  if [ "$use_color" -eq 1 ]; then printf "\033[33m[warn]\033[0m %s\n" "$1"; else printf "[warn] %s\n" "$1"; fi
}

col_fail() {
  if [ "$use_color" -eq 1 ]; then printf "\033[31m[fail]\033[0m %s\n" "$1"; else printf "[fail] %s\n" "$1"; fi
}

target_dir="${1:-./practice}"

if [ ! -d "$target_dir" ] || [ ! -d "$target_dir/.git" ]; then
  col_fail "Target directory '$target_dir' is not a Git repository. Run setup.sh first (see Quick Start)."
  exit 1
fi

# Switch to target directory
cd "$target_dir"

pass_count=0
warn_count=0
fail_count=0

record_pass() {
  pass_count=$((pass_count + 1))
  col_pass "$1"
}

record_warn() {
  warn_count=$((warn_count + 1))
  col_warn "$1"
}

record_fail() {
  fail_count=$((fail_count + 1))
  col_fail "$1"
}

# Helper: check commit message rules
# Usage: check_message_format "<subject>" "<context_label>"
check_message_format() {
  subj="$1"
  label="$2"
  subj_len=${#subj}

  # Rule 1: Subject length
  if [ "$subj_len" -gt 72 ]; then
    record_fail "$label: subject exceeds 72 characters ($subj_len chars): '$subj' (see Task 4)"
  elif [ "$subj_len" -gt 50 ]; then
    record_warn "$label: subject is $subj_len characters (prefer 50 or fewer): '$subj' (see Task 4)"
  else
    record_pass "$label: subject length is $subj_len characters"
  fi

  # Rule 2: No trailing period
  case "$subj" in
    *.)
      record_fail "$label: subject has a trailing period: '$subj' (see Task 4)"
      ;;
    *)
      record_pass "$label: no trailing period"
      ;;
  esac

  # Rule 3: Banned placeholder messages
  subj_lower=$(echo "$subj" | tr '[:upper:]' '[:lower:]' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  is_banned=0
  case "$subj_lower" in
    wip|fix|stuff|update|asdf|final|final_v2|misc|changes|test|tmp)
      is_banned=1
      ;;
  esac
  if [ "$is_banned" -eq 1 ]; then
    record_fail "$label: subject uses banned placeholder '$subj' (see Task 4)"
  else
    record_pass "$label: subject is not a banned placeholder"
  fi

  # Rule 4: First word imperative mood check (warn only)
  first_word=$(echo "$subj" | awk '{print $1}' | sed -e 's/[^a-zA-Z]//g')
  first_lower=$(echo "$first_word" | tr '[:upper:]' '[:lower:]')
  is_past_or_ing=0
  case "$first_lower" in
    added|adding|fixed|fixing|updated|updating|changed|changing|created|creating|removed|removing|deleted|deleting|modified|modifying)
      is_past_or_ing=1
      ;;
  esac
  if [ "$is_past_or_ing" -eq 1 ]; then
    record_warn "$label: first word '$first_word' looks like past tense or -ing; use imperative mood like 'Add' or 'Fix' (see Task 4)"
  fi

  # Rule 5: Capitalization
  # Accept normal sentence case or Conventional Commits prefix (feat:, fix:, docs:, chore:, refactor:, test:)
  has_cc_prefix=0
  case "$subj" in
    feat:*|fix:*|docs:*|chore:*|refactor:*|test:*|style:*|perf:*|build:*|ci:*)
      has_cc_prefix=1
      ;;
  esac

  if [ "$has_cc_prefix" -eq 0 ]; then
    first_char=$(printf "%.1s" "$subj")
    case "$first_char" in
      [A-Z])
        # Starts with capital letter
        ;;
      *)
        record_warn "$label: subject should start with a capital letter or Conventional Commits prefix (see Task 4)"
        ;;
    esac
  fi
}

printf "\n--- Task 1: Introduce yourself to git ---\n"

# Check user.name
cfg_name=$(git config --get user.name 2>/dev/null || true)
if [ -z "$cfg_name" ]; then
  record_fail "user.name is not set. Run: git config --global user.name 'Your Name' (see Task 1)"
else
  is_sample_author=0
  case "$cfg_name" in
    "Morgan Smith"|"Taylor Jones"|"Alex Rivera"|"Jordan Lee"|"Sam Patel")
      is_sample_author=1
      ;;
  esac
  if [ "$is_sample_author" -eq 1 ]; then
    record_fail "user.name is set to sample author '$cfg_name'. Use your own name (see Task 1)"
  else
    record_pass "user.name is set: $cfg_name"
  fi
fi

# Check user.email
cfg_email=$(git config --get user.email 2>/dev/null || true)
if [ -z "$cfg_email" ]; then
  record_fail "user.email is not set. Run: git config --global user.email 'you@example.com' (see Task 1)"
else
  case "$cfg_email" in
    *@example.invalid)
      record_fail "user.email uses example.invalid. Use your personal email or GitHub noreply address (see Task 1)"
      ;;
    *)
      record_pass "user.email is set: $cfg_email"
      ;;
  esac
fi

# Check core.editor (warn only if missing)
cfg_editor=$(git config --get core.editor 2>/dev/null || true)
if [ -z "$cfg_editor" ]; then
  record_warn "core.editor is not set. Configure your editor to avoid the vim trap (see Task 1)"
else
  record_pass "core.editor is set: $cfg_editor"
fi

printf "\n--- Task 2: Read the history ---\n"

# Seeded commit list
seed_commits=$(git rev-list --reverse HEAD 2>/dev/null | head -n 6 || true)
seed_count=$(echo "$seed_commits" | grep -v '^$' | wc -l | tr -d ' ')

if [ "$seed_count" -lt 6 ]; then
  record_fail "Practice repository has fewer than 6 base commits. Run setup.sh --reset (see Quick Start)"
fi

if [ ! -f "AUDIT.md" ]; then
  record_fail "AUDIT.md does not exist in practice directory (see Task 2)"
else
  record_pass "AUDIT.md exists"
  
  audit_lines=$(grep -v '^[[:space:]]*$' AUDIT.md 2>/dev/null | grep -v '^#' || true)
  audit_count=$(echo "$audit_lines" | grep -v '^$' | wc -l | tr -d ' ')
  
  if [ "$audit_count" -lt 3 ]; then
    record_fail "AUDIT.md has $audit_count reviewed commits; at least 3 required (see Task 2)"
  else
    record_pass "AUDIT.md contains $audit_count reviewed commit lines"
  fi

  # Validate each line in AUDIT.md
  while IFS= read -r aline; do
    [ -z "$aline" ] && continue
    
    # Format must be "<short hash>: <better subject line>"
    case "$aline" in
      *:*)
        ahash=$(echo "$aline" | cut -d: -f1 | tr -d '[:space:]')
        asubj=$(echo "$aline" | cut -d: -f2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        # Verify hash resolves to a commit
        if ! full_hash=$(git rev-parse --verify --quiet "$ahash^{commit}" 2>/dev/null); then
          record_fail "AUDIT.md hash '$ahash' does not resolve to a valid commit (see Task 2)"
          continue
        fi
        
        # Verify hash is one of the 6 seeded commits
        is_seed=0
        for sh in $seed_commits; do
          if [ "$full_hash" = "$sh" ]; then
            is_seed=1
            break
          fi
        done
        
        if [ "$is_seed" -eq 1 ]; then
          record_pass "AUDIT.md hash '$ahash' matches seeded commit"
        else
          record_fail "AUDIT.md hash '$ahash' is not one of the 6 seeded commits (see Task 2)"
        fi
        
        # Check proposed subject formatting
        check_message_format "$asubj" "AUDIT.md [$ahash]"
        
        # Advisory heuristic: check if proposed subject shares any word with commit diff
        diff_text=$(git diff-tree -p "$full_hash" 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)
        found_word=0
        for w in $asubj; do
          clean_w=$(echo "$w" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z]//g')
          w_len=${#clean_w}
          if [ "$w_len" -ge 4 ]; then
            case "$diff_text" in
              *"$clean_w"*)
                found_word=1
                break
                ;;
            esac
          fi
        done
        if [ "$found_word" -eq 0 ]; then
          record_warn "AUDIT.md [$ahash]: proposed subject shares no significant words with commit diff (advisory heuristic)"
        fi
        ;;
      *)
        record_fail "AUDIT.md line '$aline' does not follow '<hash>: <subject>' format (see Task 2)"
        ;;
    esac
  done << EOF
$audit_lines
EOF
fi

printf "\n--- Task 3: Keep the junk out ---\n"

# Verify .gitignore is committed
if git ls-tree -r --name-only HEAD 2>/dev/null | grep -q '^\.gitignore$'; then
  record_pass ".gitignore is committed to HEAD"
else
  record_fail ".gitignore is not committed to HEAD (see Task 3)"
fi

# Verify .gitignore content in HEAD
gi_content=$(git show HEAD:.gitignore 2>/dev/null || true)
case "$gi_content" in
  *.env*)
    record_pass ".gitignore ignores .env"
    ;;
  *)
    record_fail ".gitignore does not contain .env rule (see Task 3)"
    ;;
esac

case "$gi_content" in
  *node_modules*)
    record_pass ".gitignore ignores node_modules/"
    ;;
  *)
    record_fail ".gitignore does not contain node_modules/ rule (see Task 3)"
    ;;
esac

# Verify neither .env nor node_modules is tracked in any commit
env_tracked=$(git log --all --name-only --format= -- .env 2>/dev/null | tr -d '[:space:]' || true)
if [ -n "$env_tracked" ]; then
  record_fail ".env was committed to history (see Task 3 and Troubleshooting)"
else
  record_pass ".env is not tracked in any commit"
fi

nm_tracked=$(git log --all --name-only --format= -- node_modules 2>/dev/null | tr -d '[:space:]' || true)
if [ -n "$nm_tracked" ]; then
  record_fail "node_modules was committed to history (see Task 3)"
else
  record_pass "node_modules is not tracked in any commit"
fi

# Verify fake key text does not appear in any commit
key_commits=$(git log -S "not-a-real-key-lab-01-practice" --format=%H 2>/dev/null | tr -d '[:space:]' || true)
if [ -n "$key_commits" ]; then
  record_fail "Fake API key was found in commit history (see Task 3 and Troubleshooting)"
else
  record_pass "Fake API key is not present in any commit"
fi

printf "\n--- Task 4: Two changes, two commits ---\n"

seed_head=$(echo "$seed_commits" | sed -n '6p')
learner_commits=""
if [ -n "$seed_head" ]; then
  learner_commits=$(git rev-list "$seed_head..HEAD" 2>/dev/null || true)
fi

learner_count=$(echo "$learner_commits" | grep -v '^$' | wc -l | tr -d ' ')

if [ "$learner_count" -lt 4 ]; then
  record_fail "Found $learner_count learner commits; at least 4 required (see Task 4)"
else
  record_pass "Found $learner_count learner commits"
fi

# Check typo fix commit and cortado commit
typo_commit=$(git log "$seed_head..HEAD" -S "Expresso" --format=%H 2>/dev/null | tail -n 1 || true)
cortado_commit=$(git log "$seed_head..HEAD" -S "Cortado" --format=%H 2>/dev/null | tail -n 1 || true)

if [ -z "$typo_commit" ]; then
  # Alternative: check if Espresso was added
  typo_commit=$(git log "$seed_head..HEAD" -S "Espresso" --format=%H 2>/dev/null | tail -n 1 || true)
fi

if [ -z "$typo_commit" ]; then
  record_fail "Typo fix (Expresso -> Espresso) was not found in learner commits (see Task 4)"
else
  record_pass "Found commit fixing Expresso typo (${typo_commit:0:7})"
fi

if [ -z "$cortado_commit" ]; then
  record_fail "Cortado addition was not found in learner commits (see Task 4)"
else
  record_pass "Found commit adding Cortado (${cortado_commit:0:7})"
fi

if [ -n "$typo_commit" ] && [ -n "$cortado_commit" ]; then
  if [ "$typo_commit" = "$cortado_commit" ]; then
    record_fail "Typo fix and Cortado addition were combined in the same commit. Use git add -p to separate them (see Task 4)"
  else
    record_pass "Typo fix and Cortado addition are in separate commits"
  fi
fi

# Check AUDIT.md is committed to HEAD
if git ls-tree -r --name-only HEAD 2>/dev/null | grep -q '^AUDIT\.md$'; then
  record_pass "AUDIT.md is committed to HEAD"
else
  record_fail "AUDIT.md is not committed to HEAD (see Task 4)"
fi

# Check at least one learner commit has a body with blank line after subject and body <= 72 chars
has_valid_body_commit=0
for lc in $learner_commits; do
  # Extract raw commit message
  raw_msg=$(git log -1 --format=%B "$lc" 2>/dev/null || true)
  
  # Read message lines
  line_idx=0
  has_blank_second=0
  body_lines_ok=1
  has_body_content=0

  while IFS= read -r mline || [ -n "$mline" ]; do
    line_idx=$((line_idx + 1))
    if [ "$line_idx" -eq 1 ]; then
      continue
    elif [ "$line_idx" -eq 2 ]; then
      if [ -z "$mline" ]; then
        has_blank_second=1
      else
        break
      fi
    else
      # Body lines
      has_body_content=1
      mline_len=${#mline}
      if [ "$mline_len" -gt 72 ]; then
        body_lines_ok=0
        break
      fi
    fi
  done << EOF
$raw_msg
EOF

  if [ "$has_blank_second" -eq 1 ] && [ "$has_body_content" -eq 1 ] && [ "$body_lines_ok" -eq 1 ]; then
    has_valid_body_commit=1
    break
  fi
done

if [ "$has_valid_body_commit" -eq 1 ]; then
  record_pass "Found learner commit with blank separator line and body lines wrapped to 72 characters"
else
  record_fail "No learner commit has an explanatory body with a blank line after subject and lines <= 72 chars (see Task 4)"
fi

# Check message rules for each learner commit
printf "\n--- Checking Learner Commit Messages ---\n"
for lc in $learner_commits; do
  sh_hash=$(git log -1 --format=%h "$lc" 2>/dev/null || true)
  sh_subj=$(git log -1 --format=%s "$lc" 2>/dev/null || true)
  check_message_format "$sh_subj" "Commit $sh_hash"
done

printf "\n========================================\n"
printf "Summary: %d passed, %d warnings, %d failed.\n" "$pass_count" "$warn_count" "$fail_count"
printf "This checks the form of your messages. Only a person can judge whether they are relevant.\n"
printf "========================================\n\n"

if [ "$fail_count" -eq 0 ]; then
  exit 0
else
  exit 1
fi
