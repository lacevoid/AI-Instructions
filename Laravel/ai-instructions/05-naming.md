# NAMING — Conventions for All Artifacts

This file defines naming conventions for context/action-based, Repository-driven projects. Apply them where the technology matches.

---

## PHP Classes

### Naming Pattern: `{Context}{Type}.php`

Every PHP class follows:
```
App\{Layer}\{Context}\{ClassName}
```

### Layer Naming

| Layer | Namespace | Pattern | Example |
|-------|-----------|---------|---------|
| Actions | `App\Actions\{Context}\` | `{Verb}{Entity}Action` | `CreateArticleAction` |
| Repositories | `App\Repositories\{Context}\` | `{Entity}Repository` | `ResidentRepository` |
| Models | `App\Models\{Context}\` | `{Entity}` or `{Context}{Entity}` | `Resident`, `WebArticle` |
| Controllers | `App\Http\Controllers\{Context}\` | `{Entity}Controller` | `ArticleController` |
| Enums | `App\Enums\{Context}\` | `{Name}Enum` | `GroupEnum` |
| Exceptions | `App\Exceptions\{Context}\` | `{Description}Exception` | `CircularMembershipException` |
| Contracts | `App\Contracts\{Layer}\` | `{Name}Contract` | `RuledActionContract` |
| Traits | `App\Abstractions\Traits\{Context}\` | `Has{Name}` | `HasGroups`, `HasMetadata` |

---

## Action Naming Semantics

| Prefix | Purpose | Example |
|--------|---------|---------|
| `Create` | Create new entity | `CreateGroupAction` |
| `Update` | Modify existing entity | `UpdateMenuAction` |
| `Delete` | Remove entity | `DeleteGroupAction` |
| `Get` | Retrieve single entity | `GetResidentAction` |
| `GetAll` / `Get` + plural | Retrieve collection | `GetResidentsAction`, `GetMenusAction` |
| `Ensure` | Guarantee existence (create if needed) | `EnsureSystemGroupExistsAction` |
| `Add` | Attach/relate entities | `AddGroupChildAction` |
| `Reset` | Reset to default state | `ResetPasswordAction` |

---

## Method Naming

| Method | Purpose | Location |
|--------|---------|----------|
| `handle()` | Public entry point — triggers the Action | `Action` base class |
| `handler()` | Protected — contains actual business logic | Action subclasses |
| `execute()` | Instance-based invocation (alternative to `handle()`) | `InvokeableActionContract` |
| `rules()` | Returns validation rules array | `RuledActionContract` |
| `query()` | Build Eloquent query builder | `ModelRepository` |
| `store()` | Create and persist entity | `ModelRepository` |
| `findOrFail()` | Find or throw exception | `ModelRepository` |
| `findBySlug()` | Find by slug field | `ModelRepository` |

**Never directly call `handler()`** — it is protected and intended for internal use.

---

## Calling Actions

- `ActionClass::handle($payload)` — Static call, resolves from container (use in service providers, simple scripts).
- `$action->handle($payload)` — Instance call via constructor injection.
- `$action->execute($payload)` — Instance call (InvokeableActionContract).

**Prefer `execute()`** when you have an instance (e.g., via dependency injection in a Controller).

---

## Database Naming

### Tables
- Plural, snake_case: `residents`, `articles`, `model_has_groups`.
- Prefix with domain context where applicable: `population_`, `content_`.
- Pivot tables: `model_has_{relation}` (e.g., `model_has_groups`).

### Columns
- snake_case: `birth_date`, `author_id`, `parent_id`.
- Foreign keys: `{related_table_singular}_id` (e.g., `author_id`, `group_id`, `parent_id`).
- Timestamps: `created_at`, `updated_at` (standard Laravel).
- Slugs: `slug` (used by Eloquent Sluggable).
- Enums stored as strings: `varchar`/`string` type, not native PHP enums in DB.

### Primary Keys
- Integer auto-increment (`id`).

---

## Route Naming

Pattern: `dashboard.{context}.{feature}.{action}`

```php
// Population context routes
'dashboard.population.residents.index'
'dashboard.population.residents.create'
'dashboard.population.residents.store'

// Content context routes
'dashboard.content.articles.index'
'dashboard.content.article-categories.index'

// Settings routes
'profile.edit'
'password.edit'
```

**Rule:** Routes MUST follow the domain context prefix. Do NOT create routes outside the contextual prefix.

---

## Frontend Naming

### Vue Files
- PascalCase for components: `AppLayout.vue`, `AppSidebar.vue`.
- Pages match URI path: `resources/js/pages/Population/Residents/Index.vue`.
- Each CRUD resource has: `Index.vue`, `Create.vue`, `Edit.vue`, `Show.vue`.

### Vue Props
- Interface named `Props`.
- Typed explicitly.

```typescript
interface Props {
    residents: Array<Resident>;
    sidebarMenus: Array<any>;
}
```

### Inertia Page Names
- Match the file path from `resources/js/pages/`: `Population/Residents/Index`.

---

## Enum Naming

- PHP 8.1 backed enums with `string` type.
- Suffix: `Enum`.
- Cases: UPPER_SNAKE_CASE.
- Values: descriptive strings (often matching database/group slugs).

```php
enum GroupEnum: string
{
    case DASHBOARD_SIDEBAR_MENU = 'dashboard sidebar menu';
    case CONTENT_ARTICLE_CATEGORY = 'content article category';
}
```

---

## Prohibited Naming

Do NOT use:
- Technical names for domain concepts: `TypeService`, `DataHandler`, `Manager`.
- Generic names: `Helper.php`, `Utils.php`, `Service.php`.
- Correct: `CreateArticleAction`, `GetResidentsAction`, `MenuRepository`, `HasGroups.php`.
