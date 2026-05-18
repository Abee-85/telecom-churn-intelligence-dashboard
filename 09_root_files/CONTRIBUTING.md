# 🤝 Contributing Guide

## Branch Strategy

```
main          ← production-ready, protected
develop       ← integration branch
feature/*     ← individual features
bugfix/*      ← bug fixes
docs/*        ← documentation updates
```

## Commit Convention

```
feat:     new feature
fix:      bug fix
docs:     documentation only
style:    formatting, no logic change
refactor: code restructure
test:     adding/fixing tests
chore:    build/config changes

Examples:
  feat: add gradient boosting classifier
  fix: handle TotalCharges empty string edge case
  docs: update ETL workflow diagram
```

## GitHub Setup Commands

```bash
git init
git add .
git commit -m "feat: initial commit - Telecom Churn Intelligence Dashboard"
git branch -M main
git remote add origin https://github.com/<username>/telecom-churn-intelligence-dashboard.git
git push -u origin main
```
