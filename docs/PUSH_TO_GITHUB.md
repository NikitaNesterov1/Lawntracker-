# Push This Project to GitHub

Target repository:

`https://github.com/NikitaNesterov1/Lawntracker-.git`

## Easiest Windows Path

Use GitHub Desktop:

1. Install GitHub Desktop.
2. Sign in to GitHub.
3. Choose `File > Add local repository`.
4. Select this folder: `BushkillLawnTracker`.
5. If GitHub Desktop asks to initialize the repository, allow it.
6. Set the remote to `NikitaNesterov1/Lawntracker-`.
7. Commit all files.
8. Push to GitHub.

After pushing, open the repository's Actions tab and run `iOS Simulator Build`.

## Command Line Path

If Git is installed:

```bash
cd "BushkillLawnTracker"
git init
git branch -M main
git add .
git commit -m "Create Bushkill Lawn Tracker iOS app"
git remote add origin https://github.com/NikitaNesterov1/Lawntracker-.git
git push -u origin main
```

If the remote already has files, Git may ask you to pull or merge first.
