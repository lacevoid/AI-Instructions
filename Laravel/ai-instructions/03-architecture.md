# ARCHITECTURE — Patterns, Layers, Boundaries

This file defines the architectural patterns, layer responsibilities, and dependency rules. Some rules are universal; others are project-specific (marked with their project).

---

## Layer Architecture (Universal)

```
HTTP Request
    ↓
Controller (thin — HTTP handling only)
    ↓
Action (business logic orchestration)
    ↓
Repository (data access — Eloquent ORM)
    ↓
Model (Eloquent relationships, casts, fillable)
```

### Controller Layer

- **Responsibility:** Handle HTTP requests, delegate to Actions, return responses.
- **Rules:**
  - Controllers MUST be thin — no business logic.
  - Controllers CAN handle authentication and authorization.
  - Controllers CAN validate simple request data directly.
  - Controllers MUST NOT access Eloquent directly.
  - Controllers MUST NOT access Services directly (only Actions).
  - Use method injection to receive Actions.

### Action Layer

- **Responsibility:** Orchestrate business logic, validation, coordinate between Repositories.
- **Rules:**
  - Actions orchestrate — they call Repositories and other Actions.
  - Actions MUST NOT handle authentication/authorization.
  - RuledActions validate via `rules()` method.
  - Actions return Models, collections, or primitives — never responses.
  - Actions inject Repositories via constructor.

### Repository Layer

- **Responsibility:** Data access only — query Eloquent, return models/collections.
- **Rules:**
  - Repositories are the ONLY layer that talks to Eloquent.
  - Extend `ModelRepository` for standard CRUD.
  - Add custom query methods when needed.
  - Auto-resolve model from class name (convention).

### Model Layer

- **Responsibility:** Define relationships, casts, fillable attributes.
- **Rules:**
  - Models define data structure and relationships.
  - Models use Traits for cross-cutting concerns.
  - Models do NOT contain business logic.

---

## Service Layer

**Universal rule:** Services are designated for integrating with third-party APIs or encapsulating complex, domain-specific business logic that does not fit elsewhere. They are NOT the default location for business logic.

**Project-specific:** Check `12-project-specific/` for rules about Service Layer usage in specific projects.

---

## Dependency Direction Rules

```
Controller → Action → Repository → Model
Controller → Action → Action (orchestration)
Action → Action (composition)
```

**FORBIDDEN:**
- Model → Repository
- Repository → Action
- Action → Controller
- Repository → Service
- Any circular dependencies

---

## Context-Based Organization

Code is organized by domain context, NOT by technical layer.

```
app/
├── Actions/
│   └── {Context}/
│       └── {Verb}{Entity}Action.php
├── Repositories/
│   └── {Context}/
│       └── {Entity}Repository.php
├── Models/
│   └── {Context}/
│       └── {Context}{Entity}.php
├── Http/
│   └── Controllers/
│       └── {Context}/
│           └── {Entity}Controller.php
```

**Rule:** When creating or modifying any file, ensure it aligns with the established contextual structure of the project.

---

## Routing Organization

Routes are organized by domain context with nested prefixes:

```php
Route::prefix('dashboard/{context}')->name('dashboard.{context}.')->group(function () {
    Route::prefix('{feature}')->name('{feature}.')->group(function () {
        Route::resource('{entities}', {Context}{Entity}Controller::class);
    });
});
```

**Naming convention:** `dashboard.{context}.{feature}.{action}`

**Rule:** New routes MUST be placed within the correct group (prefix and name) that matches their domain context.

---

## Frontend Organization

Vue/frontend pages mirror the URI structure:

```
resources/js/pages/
├── Dashboard/
├── {Context}/
│   └── {Feature}/
│       ├── Index.vue
│       ├── Create.vue
│       ├── Edit.vue
│       └── Show.vue
├── Settings/
├── Auth/
└── Public/
```

**Rule:** Pages MUST mirror the URI path. Components MUST be in the correct contextual directory.

---

## Middleware

- Share common data (sidebar menus, auth state) via middleware using `Inertia::share()` or equivalent.
- Apply middleware at the group level in route definitions.
- Authentication and authorization logic is handled at the Controller layer.

---

## Abstraction Philosophy

**DO:**
- Use the existing base Action class for business logic.
- Use the existing base Repository class for data access.
- Use RuledAction + RuledActionContract when validation is needed.
- Use Traits for reusable model behaviors.
- Use Enums for system constants and type-safe values.
- Use Contracts for interface definitions.
- Prefer auto-resolution over manual container bindings.

**DON'T:**
- Create Service classes unless integrating external APIs (project-specific exceptions apply).
- Create DTOs — pass arrays or Models.
- Create Helper classes unless they are truly reusable utilities.
- Add unnecessary layers of abstraction.
- Create abstractions for one-off operations.
- Use manual container bindings unless required (prefer auto-resolution).

---

## Architectural Decisions

Key decisions that are binding:

1. **Action Pattern as Primary Business Logic Layer** — All business logic lives in Actions, not Controllers or Services (unless project-specific rules override).
2. **Repository for All Eloquent Access** — Only the Repository layer interacts with Eloquent ORM.
3. **No Service Layer by Default** — Services are reserved for third-party integrations.
4. **Validation in Actions** — RuledActions validate their own input via `rules()` method.
5. **Context-Based Directory Organization** — Code organized by domain context, not technical type.
6. **Feature Stops at Action Layer** — Unless explicitly asked, do not create Controllers or Frontend components.
7. **Integer IDs** — Use auto-incrementing integer IDs (project-specific exceptions may apply).
8. **Auto-Resolution Over Manual Binding** — Prefer Laravel's auto-resolution.
