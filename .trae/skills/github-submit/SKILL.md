---
name: github-submit
description: Commit and push the current project to GitHub. Use when the user asks to 提交项目, push to GitHub, 上传代码, or commit and push changes to a GitHub remote.
---

# GitHub Submit

Safely commit and push the current workspace to a GitHub repository over SSH.

## When to trigger

User says things like "提交项目"、"push 到 GitHub"、"上传代码"、"commit 并 push"、"推送到 github.com/xxx/yyy"。

## Preconditions to check first

1. Current directory is a git repo; if not, run `git init` and configure `user.name` / `user.email`.
2. A GitHub remote URL was provided — use SSH form `git@github.com:owner/repo.git` even if user pasted HTTPS.
3. SSH public key is already added to the GitHub account. If the user says "已设置公钥", trust that and skip keygen.
4. No uncommitted secrets or huge binaries. Offer to create a `.gitignore` if none exists.

## Steps

1. Run `git remote -v`. If no remote exists, add the SSH URL:
   ```
   git remote add origin git@github.com:OWNER/REPO.git
   ```
2. If remote points to a different repo than the user asked, update it:
   ```
   git remote set-url origin git@github.com:OWNER/REPO.git
   ```
3. Optional — test SSH auth before pushing:
   ```
   ssh -T git@github.com
   ```
   "Hi OWNER! You've successfully authenticated" → continue.
   "Permission denied (publickey)" → stop and tell user to add the public key.
4. Stage files — prefer explicit add, never blind `git add -A` without checking `git status` first:
   ```
   git status -s
   git add .
   ```
5. Commit:
   ```
   git commit -m "feat: initial commit"   # or a message matching the change
   ```
6. Push. On first push use `-u` to set upstream:
   ```
   git push -u origin main
   ```
   Older repos may default to `master`; check with `git branch`.

## Failure handling

- `Permission denied (publickey)` → ask user to confirm SSH key is added to GitHub settings.
- `Repository not found` → the SSH URL owner/repo may be wrong; re-check.
- `src refspec main does not match any` → nothing to commit; confirm changes exist.
- Push rejected → remote has commits the local doesn't; run `git pull --rebase origin main` then push again.

## Output contract

Report:
- Remote URL (SSH form)
- Branch pushed
- Commit hash (short)
- "View at: https://github.com/OWNER/REPO"
