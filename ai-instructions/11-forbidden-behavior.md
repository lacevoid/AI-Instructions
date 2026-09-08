# FORBIDDEN BEHAVIOR — Explicit Prohibitions

The following behaviors are explicitly forbidden. These are absolute rules unless the user explicitly overrides them for a specific task.

---

## Architecture Violations

- ❌ Putting business logic in Controllers.
- ❌ Accessing Eloquent directly from Actions or Controllers (must go through Repository).
- ❌ Creating Service classes (LingSID has no Service layer) or DTOs — pass arrays/Models.
- ❌ Creating unnecessary abstractions (only create contracts when multiple implementations or clear need exists).
- ❌ Creating files outside the feature's context.
- ❌ Modifying routes outside the contextual naming convention.
- ❌ Violating dependency direction rules:
  - Model → Repository
  - Repository → Action
  - Action → Controller
  - Controller → Repository directly (must go through an Action)
  - Leaves calling Eloquent directly (Controller/Model → Model::query)
  - Circular dependencies
- ❌ Introducing circular dependencies.
- ❌ Reproducing legacy duplicate class names when a canonical contextual class exists (e.g. creating `CreateResidentAction` alongside `CreateSidResidentAction`).

---

## Style Violations

- ❌ Using BDD test naming (`it_should_...`).
- ❌ Adding comments unless asked.
- ❌ Using `declare(strict_types=1)` (project convention).
- ❌ Using tabs for indentation (use 4 spaces).
- ❌ Using Options API in Vue (always Composition API).
- ❌ Skipping TypeScript types in frontend.
- ❌ Using generic/technical names for domain concepts (`TypeService`, `DataHandler`, `Manager`; `Helper.php`, `Utils.php`).

---

## Implementation Violations

- ❌ Modifying vendor code without confirmation.
- ❌ Adding dependencies without checking the existing codebase first.
- ❌ Refactoring working code (speculative refactoring).
- ❌ Fixing bugs not directly related to the current task.
- ❌ Doing work directly on `develop` or `main` (create a feature branch from `develop`).
- ❌ Creating empty commits.
- ❌ Pushing secrets or credentials.
- ❌ Using `dd()`, `dump()`, or `ray()` in committed code.
- ❌ Running the full test suite unless explicitly asked.
- ❌ Mocking in Feature tests.
- ❌ Calling an instance Action `handle()` statically (`XxxAction::handle(...)`) — resolve and call via the container on an instance.
- ❌ Referencing classes/methods that do not exist (broken imports, undefined variables, unknown repository methods). Always verify the target class/method exists in the codebase before using it.
- ❌ Passing payload keys to Actions that do not match the repository/model columns or the RuledAction validation rules.

---

## Security Violations

- ❌ Storing plaintext passwords.
- ❌ Exposing sensitive data in responses.
- ❌ Trusting user input without validation.
- ❌ Committing secrets or API keys.
- ❌ Logging passwords, tokens, or sensitive data.
- ❌ Returning raw database errors to users.

---

## Scope Violations

- ❌ Modifying unrelated files.
- ❌ Making speculative changes.
- ❌ Fixing unrelated issues while implementing a feature.
- ❌ Creating controllers or frontend components unless explicitly asked (feature stops at Action layer by default).

---

## Unknown Territory Handling

When you encounter a situation not covered by these instructions:
1. State the problem clearly.
2. Propose the minimal fix.
3. Get user confirmation before proceeding.
4. Do not invent new patterns without evidence from the codebase.
