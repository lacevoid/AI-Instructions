# CODING STANDARDS — Style, Formatting, Conventions

This file defines coding style, formatting rules, and code conventions. Some rules are universal; others are project-specific.

---

## PHP Style

### General
- **Standard:** PSR-12
- **Indentation:** 4 spaces (no tabs)
- **Line endings:** LF
- **Final newline:** Yes
- **Strict types:** NOT used (no `declare(strict_types=1)` — project convention)
- **PHP version:** 8.x

### Class Structure
- One class per file.
- Namespace matches directory path.
- `<?php` opening tag, no closing tag.
- Single blank line after namespace declaration.
- One blank line between use groups.
- Use statements ordered: classes, then functions, then constants.

### Method Style
- Return types declared on all methods.
- Nullable types use `?Type` syntax.
- No `readonly` properties (project does not use this widely).
- Constructor property promotion used in some cases but not universally.
- Method ordering: `__construct` → public methods → protected/private methods.

### Property Visibility
- Properties use `protected` by default in Actions/Controllers (constructor promotion).
- `private` used in base classes for internal state.
- `$fillable` arrays in Models are always `protected`.

### Conditional Style
```php
// Preferred: negated condition with early return
if (! $condition) {
    return $fallback;
}

// Guard clauses
if (! is_string($groupKey)) {
    throw new InvalidArgumentException('...');
}
```

### Array Syntax
```php
// Associative arrays: short syntax with spaced brackets
$validatedPayload = [
    'name' => $validatedPayload['name'],
    'description' => $validatedPayload['description'],
];

// Empty arrays
return [];
```

### String Style
- Single quotes for simple strings.
- Double quotes for strings with variables.
- `sprintf()` for formatted strings.
- `Str::of()` fluent interface for string manipulation.

### Import Ordering
```php
// 1. PHP built-in classes
use InvalidArgumentException;

// 2. Laravel framework classes
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

// 3. Application classes (alphabetical by namespace)
use App\Abstractions\Actions\Action;
use App\Contracts\Action\RuledActionContract;
use App\Models\Group;
use App\Repositories\GroupRepository;
```

---

## TypeScript/Vue Style

### General
- **Indentation:** 4 spaces
- **Semicolons:** Yes (enforced by Prettier)
- **Quotes:** Single quotes (enforced by Prettier)
- **Print width:** 150
- **Trailing commas:** Yes

### Vue Component Structure
```vue
<script setup lang="ts">
// Imports (ordered by prettier-plugin-organize-imports)
import AppLayout from '@/layouts/AppLayout.vue';
import { type BreadcrumbItem } from '@/types';
import { Head, Link, useForm } from '@inertiajs/vue3';

// Props interface
interface Props {
    data: SomeType;
    sidebarMenus: Array<any>;
}

const props = defineProps<Props>();

// Breadcrumbs
const breadcrumbs: BreadcrumbItem[] = [
    { title: 'Dashboard', href: '/dashboard' },
];

// Form (if applicable)
const form = useForm({
    field: '',
});

// Methods
const submit = () => {
    form.post(route('route.name'));
};
</script>

<template>
    <Head title="Page Title" />
    <AppLayout :breadcrumbs="breadcrumbs">
        <!-- content -->
    </AppLayout>
</template>
```

### TypeScript Types
- Use `interface` for object shapes.
- Use `type` for unions/intersections.
- Props always typed with interfaces.
- Model type references follow project convention (e.g., `App.Models.{Context}.{Model}`).

### CSS Classes
- Tailwind CSS utility classes.
- Use `cn()` helper for conditional classes (from `@/lib/utils`).
- Use project UI component library (e.g., shadcn-vue) for UI primitives.
- Dark mode via `.dark` class on `<html>`.

---

## Comment Style

**DO NOT add comments** unless explicitly asked. The codebase is largely comment-free. The few existing comments are:
- PHPDoc on model properties (`@var`).
- Type annotations (`@return`, `@param`).
- Occasional `@see` references.

---

## Code Documentation

Do not add explanatory comments or documentation blocks unless explicitly asked. The code should be self-documenting through clear naming and structure.

---

## Formatting Rules (Enforced by Tools)

### PHP
- PHP-CS-Fixer or PHP_CodeSniffer (PSR-12).
- PHPStan level as configured in the project (typically level 5).

### TypeScript/Vue
- Prettier with:
  - `prettier-plugin-organize-imports` (auto-sorts imports).
  - `prettier-plugin-tailwindcss` (sorts Tailwind classes).
- ESLint with Vue and TypeScript configs.
- Run via project scripts (e.g., `bun run lint` / `bun run format`).

---

## File Organization Summary

```
app/
├── Abstractions/
│   ├── Actions/
│   │   ├── Action.php          (base Action class)
│   │   └── IndexAction.php     (base for index/list actions)
│   ├── Repository/
│   │   └── ModelRepository.php (base Repository class)
│   └── Traits/
│       └── Model/
│           ├── HasGroups.php
│           └── HasMetadata.php
├── Actions/
│   └── {Context}/
│       └── {Verb}{Entity}Action.php
├── Contracts/
│   ├── Action/
│   │   ├── InvokeableActionContract.php
│   │   └── RuledActionContract.php
│   ├── Model/
│   │   └── Has{Name}Contract.php
│   └── Repository/
│       ├── RepositoryContract.php
│       └── ModelRepositoryContract.php
├── Enums/
│   └── {Context}/
│       └── {Name}Enum.php
├── Exceptions/
│   └── {Context}/
│       └── {Description}Exception.php
├── Http/
│   ├── Controllers/
│   │   ├── {Context}/
│   │   │   └── {Entity}Controller.php
│   │   ├── Auth/
│   │   └── Settings/
│   ├── Middleware/
│   └── Requests/
├── Models/
│   ├── {Context}/
│   │   └── {Context}{Entity}.php
│   └── {RootEntity}.php
├── Policies/
├── Providers/
└── Repositories/
    └── {Context}/
        └── {Entity}Repository.php
```
