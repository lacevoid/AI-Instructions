# LINGUSID — Project-Specific Invariants

This module applies ONLY when the repository is the **LingSID** project (Sistem Informasi Desa — Laravel 12 / Inertia / Vue 3 / TypeScript / Tailwind CSS v4 stack).

---

## Stack (binding)

- **PHP ^8.2, Laravel ^12.0** (no `declare(strict_types=1)`).
- **Inertia.js v2 + Vue 3** (`<script setup lang="ts">`, Composition API only) + **TypeScript**.
- **Tailwind CSS v4** + **shadcn-vue** primitives (`resources/js/components/ui/`) + `lucide-vue-next` icons.
- **Vite 6** (build + SSR) and **ziggy-js** for route resolution in the frontend.
- **bun** is the preferred JS package manager; `npm` is the fallback (never mix within a project).
- No Blade pages for application UI (Inertia/Vue only).

---

## Architecture Invariants

1. **No Service layer. No DTOs.** Business logic lives in Actions; data is passed as arrays/Models.
2. **Repository-only Eloquent access.** Controllers/Actions must not query Eloquent directly.
3. **Validation in RuledActions** (`rules(array $payload): array`). FormRequests are used ONLY for `Auth/` and `Settings/` flows.
4. **Thin Controllers.** Controllers resolve Actions via constructor injection and delegate.
5. **Domain contexts on disk:** `app/Models/Sid/`, `app/Models/Web/`, `app/Actions/Sid/`, `app/Actions/Web/`, `app/Repositories/Sid/`, `app/Repositories/Web/`, controllers under `app/Http/Controllers/{Sid,Web,Dashboard,Settings,Auth}/`.
6. **Canonical entity naming carries the context prefix** for domain entities: `SidResident`, `WebArticle`, `WebPage` (models), `CreateSidResidentAction`, `UpdateWebArticleAction` (actions), `SidResidentRepository`, `WebArticleRepository` (repositories). Do not reproduce legacy unprefixed duplicates (`CreateResidentAction`, `UpdateResidentAction`).
7. **Base classes:** extend `App\Abstractions\Actions\Action` (or `IndexAction`) and `App\Abstractions\Repository\ModelRepository`. Use shared model traits `App\Abstractions\Traits\Model\HasGroups` and `App\Abstractions\Traits\Model\HasMetadata` instead of re-implementing poly-morphic behavior.
8. **System constants via `App\Enums\System\GroupEnum`** (string-backed, SCREAMING_SNAKE_CASE cases). Do not hardcode group slugs/classes outside the enum; do not mutate or delete system groups (throw `SystemGroupImmutableException` / guard circular membership via `CircularMembershipException`).
9. **Feature stops at the Action layer** unless the user explicitly asks for Controllers, routes, or frontend pages.

---

## Routes / Pages

- Authenticated routes grouped under `dashboard.{context}.{subcontext}.{entity}.{action}`:
  - `dashboard.sid.population.residents.*` ↔ `resources/js/pages/Sid/Population/Residents/*`
  - `dashboard.web.articles.*` ↔ `resources/js/pages/Web/Articles/*`
  - `dashboard.web.articles.categories.*` ↔ `resources/js/pages/Web/ArticleCategories/*`
- `routes/web.php`, `routes/auth.php`, `routes/settings.php` are the only route files.
- Protected app routes run under `['auth', 'verified', ShareDashboardData::class]`.

---

## Packages in Use

- **spatie/laravel-permission** — roles & permissions (`HasRoles`, `HasPermissions`).
- **spatie/laravel-medialibrary** — file/media attachments for models.
- **spatie/laravel-activitylog** — audit trails on important mutations.
- **spatie/laravel-backup**, **spatie/laravel-responsecache** — backup + response caching.
- **laravel/scout** — search over Eloquent models.
- **cviebrock/eloquent-sluggable** — URL slugs on publishable entities.
- **staudenmeir/eloquent-has-many-deep** — deep relationship queries.
- **barryvdh/laravel-dompdf**, **maatwebsite/excel** — document/export generation (SID letters, reports).

Use these packages where applicable. Do NOT add new dependencies without checking the codebase first (analogue-first).

---

## Quality Gates (LingSID-specific)

- [ ] Static analysis passes: `./vendor/bin/phpstan analyse` (level 5, paths `app/ config/ database/ routes/`).
- [ ] Code formatted with `laravel/pint`.
- [ ] Frontend passes `bun run lint` (ESLint) and `bun run format:check` (Prettier).
- [ ] `#[Test]` attribute + snake_case method names on new tests; `RefreshDatabase` on database tests.
- [ ] Works on a feature branch off `develop`; never commit to `develop`/`main` directly.
- [ ] No `dd()`, `dump()`, `ray()` in committed code.
- [ ] No static call to instance methods (`XxxAction::handle()` must never appear).