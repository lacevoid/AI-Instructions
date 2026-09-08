# GIT — Branching, Commits, Version Control

This file defines git branching and commit conventions. Rules are universal where they concern discipline; project-specific branch/commit formats are preserved.

---

## Branching

### Universal Rules
- Branch `main` (or `master`) is the stable branch containing verified & tested code.
- **DO NOT** make changes directly on the main branch.
- Each feature/fase requires a separate branch.
- Always create new branches from the correct base branch.
- Do NOT push or create a PR unless explicitly asked.

### Base Branch Decision Tree
```
What are you working on?
├── A new feature/fase → create branch from develop (or main, per project)
├── A bug fix → create branch from the relevant release/development branch
└── A hotfix → create branch from the affected stable branch
```

### Branch Workflow (Standard)
```
1. git checkout {base-branch}
2. git pull origin {base-branch}
3. git checkout -b {feature-branch}
4. ... work ...
5. git add . && git commit -m "{type}: {description}"
6. (do NOT push unless asked)
```

---

## Commits

### Required Discipline
- Inspect `git status`, `git diff`, and `git log` before committing.
- Stage only intended files; never commit secrets.
- Do not `git add .` blindly — review what is being staged.
- Write a concise commit message that matches repo style.
- **DO NOT** create empty commits.

### Prohibited Operations
- Committing directly to the main branch.
- Force-pushing.
- Pushing secrets or credentials.
- Committing generated/vendor files.
- Amending commits unless explicitly asked.

---

## Commit Message Format (Action-based projects)

**Format:**
```
<Type>: <Concise Description>
```

**Allowed types:**

| Type | Purpose | Example |
|------|---------|---------|
| `Create` / `Add` | New feature | `Add: validation for collage input` |
| `Update` / `Fix` | Update or fix | `Fix: calc logic in LoanService` |
| `Refactor` | Refactor without changing function | `Refactor: move logic to Service layer` |
| `Test` | Add/fix tests | `Test: add payment allocation cases` |
| `Docs` | Documentation | `Docs: update README` |
| `Chore` | Maintenance | `Chore: add index to loans` |

**Rules:**
1. Description concise and specific.
2. Capitalize the first letter of the type.
3. No period at the end.
4. Max ~72 characters for the subject line.
5. Use precise technical terms.

---

## Project-Specific Branch Naming

Some projects use phase-based or milestone-based branching. Check `12-project-specific/` for project-specific branch naming conventions.

### Phase-Based Branching (Example)
For projects using phase-based development:
```
fase/1-foundation
fase/2-feature-a
fase/3-feature-b
...
```

Commits on phase branches MUST be prefixed `Fase X:`:
```
Fase 3: tambah logic loan engine
```

---

## Conventional Commits (Alternative)

For projects using conventional commits:
```
feat: add article management feature
fix: correct payment allocation order
refactor: extract service layer
test: add collateral release cases
docs: update instruction system
chore: update dependencies
```

---

## Speculative Refactoring Policy

- **DO NOT refactor working code** — only fix what is broken for the current feature.
- **DO NOT fix issues** that are not directly related to the current task.
- **DO NOT "improve"** existing code during a feature implementation.
