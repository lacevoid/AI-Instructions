# ARCHITECTURE — Patterns, Layers, Boundaries

This file defines the architectural patterns, layer responsibilities, and dependency rules of the LingSID project. The stack is Laravel 12 + PHP 8.2 with Inertia.js v2, Vue 3, TypeScript, and Tailwind CSS v4.

---

## Layer Architecture

```
HTTP Request
    ↓
Controller (thin — HTTP handling only)
    ↓
Action (business logic orchestration + validation)
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
  - Controllers MUST NOT validate business data inline — validation lives in RuledActions (FormRequests only for `Auth/` and `Settings/` flows).
  - Controllers MUST NOT access Eloquent directly.
  - Controllers MUST NOT call Repositories directly (only via Actions).
  - Use constructor injection for the Actions a controller needs (canonical for controllers using several actions); method injection is acceptable for one-off actions. Match the style of the controller file being edited.
  - Controllers pass the whole user input to Actions as a **single array payload**: `$action->handle($request->all())` (or `'key' => $model + $request->all()` for model-aware updates). Never pass a second argument.
  - Example `app/Http/Controllers/Sid/SidResidentController.php` (constructor injection), `app/Http/Controllers/Web/WebArticleController.php` (method injection).

### Action Layer

- **Responsibility:** Orchestrate business logic, validate input, coordinate between Repositories.
- **Rules:**
  - Actions orchestrate — they call Repositories and other Actions.
  - Actions MUST NOT handle authentication/authorization.
  - Actions with validation implement `RuledActionContract` and define `rules(array $payload): array`.
  - Actions return Models, collections, or primitives — never responses.
  - Actions inject Repositories via constructor.
  - Actions live under `app/Actions/{Context}/…` and extend `App\Abstractions\Actions\Action` (or `IndexAction` for list actions).
  - Ruled actions receive validated data as the second `handler($payload, $validatedPayload)` argument; plain actions receive only `$payload`.
  - Canonical examples: `App\Actions\Web\Article\CreateWebArticleAction`, `App\Actions\Sid\Resident\UpdateSidResidentAction`, `App\Actions\Group\EnsureSystemGroupExistsAction`, `App\Actions\Web\Dashboard\Sidebar\GetAllSidebarMenuAction`.

### Repository Layer

- **Responsibility:** Data access only — query Eloquent, return models/collections.
- **Rules:**
  - Repositories are the ONLY layer that talks to Eloquent.
  - Extend `App\Abstractions\Repository\ModelRepository` for standard CRUD.
  - Add custom query methods on the concrete repository when needed.
  - Canonical examples: `App\Repositories\GroupRepository`, `App\Repositories\Web\WebArticleRepository`, `App\Repositories\Sid\SidResidentRepository`.

### Model Layer

- **Responsibility:** Define relationships, casts, fillable attributes.
- **Rules:**
  - Models define data structure and relationships.
  - Models use reusable traits for cross-cutting concerns.
  - Models do NOT contain business logic.
  - Canonical examples: `App\Models\Group`, `App\Models\Menu`, `App\Models\Term`, `App\Models\Metadata`, `App\Models\User`, `App\Models\Sid\SidResident`, `App\Models\Web\WebArticle`, `App\Models\Web\WebPage`.

---

## No Service Layer

**This project has NO Service layer and no DTOs.** Do not create them.

- Business logic belongs in Actions.
- Data access belongs in Repositories.
- Data is passed as plain arrays or Models.
- This is an invariant of the project (`12-project-specific/lingusid.md`).

---

## Supporting Layers

| Layer | Location | Purpose |
|-------|----------|---------|
| Abstractions | `app/Abstractions/` | Base `Action`, `IndexAction`, `ModelRepository`, reusable model traits (`HasGroups`, `HasMetadata`) |
| Contracts | `app/Contracts/` | `Action/RuledActionContract` (`rules(array $payload): array`), `Action/InvokeableActionContract` (`__invoke(array $payload)` — unused), `Repository/RepositoryContract`, `Repository/ModelRepositoryContract`, `Model/Has*Contract` interfaces |
| Enums | `app/Enums/System/` | String-backed PHP enums for system constants (`GroupEnum`) |
| Exceptions | `app/Exceptions/Model/Group/` | Domain exceptions (`CircularMembershipException`, `SystemGroupImmutableException`) |
| Middleware | `app/Http/Middleware/` | `HandleAppearance`, `HandleInertiaRequests`, `ShareDashboardData`, `ShareWebData` |
| Policies | `app/Policies/` | Model-level authorization (`ContentArticlePolicy`) |

---

## Dependency Direction Rules

```
Controller → Action → Repository → Model
Controller → Action → Action (orchestration)
Action → Repository
```

**FORBIDDEN:**
- Model → Repository
- Repository → Action
- Action → Controller
- Controller → Repository (must go through an Action)
- Controller/Model → Eloquent directly
- Any circular dependencies

---

## Context-Based Organization

Code is organized by domain context, NOT by technical layer. Real contexts:

| Context | Purpose | Canonical artifacts |
|---------|---------|---------------------|
| `Sid` | Population / village data (Sistem Informasi Desa) | `app/Models/Sid/SidResident.php`, `app/Repositories/Sid/SidResidentRepository.php`, `app/Actions/Sid/Resident/*`, `app/Http/Controllers/Sid/SidResidentController.php` |
| `Web` | Public content (articles, pages, categories) | `app/Models/Web/WebArticle.php`, `app/Repositories/Web/WebArticleRepository.php`, `app/Actions/Web/Article/*`, `app/Http/Controllers/Web/WebArticleController.php` |
| `Dashboard` | Authenticated app shell / sidebar menus | `app/Actions/Web/Dashboard/Sidebar/*`, `resources/js/pages/Dashboard/*` |
| `Settings` | Profile, password, appearance | `routes/settings.php`, `app/Http/Controllers/Settings/*`, `app/Http/Requests/Settings/*` |
| `Auth` | Registration, login, verification | `routes/auth.php`, `app/Http/Controllers/Auth/*`, `app/Http/Requests/Auth/*` |
| `System` | Cross-cutting taxonomy | `app/Enums/System/GroupEnum.php`, `app/Models/{Group,Term,Metadata,Menu}.php` |

Generic cross-domain entities (`Group`, `Term`, `Metadata`, `Menu`, `User`) live at the `app/Models` root; domain-owned entities carry their context prefix (`SidResident`, `WebArticle`).

**Rule:** When creating or modifying any file, place it in the contextual directory that matches its domain. Do not invent new context folders that have no analogue.

---

## Routing Organization

Routes are organized by authenticated domain context (`routes/web.php` + `routes/auth.php` + `routes/settings.php`):

```php
Route::prefix('dashboard/sid')->name('dashboard.sid.')->group(function () {
    Route::prefix('population')->name('population.')->group(function () {
        Route::resource('residents', SidResidentController::class)->except(['show']);
    });
});

Route::prefix('dashboard/web')->name('dashboard.web.')->group(function () {
    Route::resource('articles', WebArticleController::class);
    Route::resource('categories', ArticleCategoryController::class);
});
```

**Naming convention:** `dashboard.{context}.{subcontext}.{entity}.{action}`

Real names:
- `dashboard.sid.population.residents.index` / `.create` / `.store` / `.edit` / `.update` / `.destroy`
- `dashboard.web.articles.index` / `.create` / …
- `dashboard.web.articles.categories.index` / …

**Rule:** New routes MUST be placed in the correct group (prefix and name) matching their domain context. Do NOT create routes outside the contextual prefix.

---

## Frontend Organization

Pages mirror the Inertia component path from `resources/js/pages/`:

```
resources/js/pages/
├── Public/Welcome.vue
├── Auth/               (Login, Register, VerifyEmail, …)
├── Dashboard/Index.vue
├── Sid/
│   └── Population/
│       └── Residents/  (Index, Create, Edit)
├── Web/
│   ├── Articles/       (Index, Create, Edit, Show)
│   └── ArticleCategories/
├── Settings/           (Profile, Password, Appearance)
```

**Rule:** Pages MUST mirror the URI path. Components MUST be in the correct contextual directory.

Frontend conventions:
- Composition API only `<script setup lang="ts">`.
- Shared layout/components in `resources/js/components/` (`AppShell.vue`, `AppContent.vue`, `AppHeader.vue`, `AppLogo.vue`, …) and shadcn-vue primitives in `resources/js/components/ui/`.
- Typed shared values via `@types`/`types/index.d.ts` (`App.Models.*`, `App.Data.*` dotted references).
- Routes resolved client-side with **ziggy-js** `route('route.name')`.
- Tailwind CSS v4 (`resources/css/app.css`) + `cn()`/`clsx` helper for conditional classes.

---

## Middleware

- Share common data (sidebar menus, auth state, appearance) via `ShareDashboardData`, `ShareWebData`, `HandleAppearance`, `HandleInertiaRequests`.
- Apply middleware at group level in route definitions.
- Protected application routes run under `['auth', 'verified', ShareDashboardData::class]`.

---

## Reusable Taxonomy (Group / Term / Metadata)

The project uses a polymorphic taxonomy system:

- **Groups** — categorized systems constants defined by `App\Enums\System\GroupEnum` (e.g. `CONTENT_ARTICLE_CATEGORY`, `RESIDENT_RELIGION`). Models opt in via `App\Abstractions\Traits\Model\HasGroups`.
- **Terms** — user-managed taxonomy values (e.g. an article category, a resident religion) attachable to models.
- **Metadata** — key/value metadata attachable via `App\Abstractions\Traits\Model\HasMetadata`.
- Pivot tables: `model_has_groups`, `model_has_terms`, `model_has_metadata`.
- Companion contracts in `App\Contracts\Model\` (`HasGroupsContract`, `HasMetadataContract`, …).

Do not hardcode group behavior in controllers/actions; use `GroupEnum` cases and the group/term/metadata traits.

---

## Canonical Snippets & Invocation Protocol

**`12-project-specific/canonical-snippets.md` is the authoritative verbatim snippet bank** (Action base, ruled/plain actions, controllers, repositories, models, traits, enums, exceptions, tests, frontend pages). Snippets are copied unchanged from the LingSID codebase and carry source anchors (`lingusid app/…:line`).

**Invocation protocol (MUST):**
- `$action->handle($request->all())` — ruled action: single array payload, validated inside the action.
- `$action->handle(['id' => $id])` — delete/update by id inside the payload array.
- `$action->handle(['resident' => $resident] + $request->all())` — model-aware rules (e.g. `Rule::unique(...)->ignore($payload['resident']->id)`).
- `$action->handle()` — non-ruled list/dashboard actions.
- `$action->handle($model)` — only a **non-ruled** action may receive a Model payload.
- **Never** pass a second argument to `handle()` (it is ignored) and **never** call `execute()` (no such method exists).

Follow the bank's `// BAD` vs canonical replacement table rather than inventing invocation styles.

---

## Abstraction Philosophy

**DO:**
- Use the existing base `Action` / `IndexAction` classes for business logic.
- Copy canonical snippets verbatim from `12-project-specific/canonical-snippets.md`, changing only identifiers/values.
- Use the existing `ModelRepository` base for data access.
- Use `RuledActionContract` when the action needs to validate input.
- Use existing reusable traits (`HasGroups`, `HasMetadata`) for model behaviors.
- Use string-backed Enums for system constants and type-safe values.
- Use Contracts for interface definitions.
- Prefer auto-resolution over manual container bindings.

**DON'T:**
- Create Service classes or DTOs (invariant).
- Create `Helper` / `Utils` catch-all classes.
- Add unnecessary layers of abstraction.
- Create abstractions for one-off operations.
- Use manual container bindings unless required.

---

## Architectural Decisions

Key binding decisions for LingSID:

1. **Action Pattern as Primary Business Logic Layer** — All business logic lives in Actions, not Controllers or Services.
2. **Repository for All Eloquent Access** — Only the Repository layer interacts with Eloquent ORM.
3. **No Service Layer, No DTOs** — Data passes as arrays/Models; business logic in Actions.
4. **Validation in Actions** — RuledActions validate via `rules(array $payload)`; FormRequests only for Auth/Settings.
5. **Context-Based Directory Organization** — Code organized by domain context (`Sid`, `Web`, `Dashboard`, `Settings`, `Auth`, `System`).
6. **Feature Stops at Action Layer** — Unless explicitly asked, do not create Controllers or Frontend components.
7. **Integer IDs** — Auto-incrementing integer primary keys.
8. **Auto-Resolution Over Manual Binding** — Prefer Laravel container auto-resolution.
9. **Polymorphic Taxonomy** — Groups/Terms/Metadata via traits + `GroupEnum`; never hardcode domain classifications.
10. **Frontend Mirrors Backend** — Inertia pages mirror URI; Ziggy for routes; shadcn-vue `ui/` components for primitives.