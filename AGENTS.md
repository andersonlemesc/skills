# AGENTS.md

## Stack

- **Backend:** Laravel 12.x, PHP 8.4, Fortify v1
- **Frontend:** React 19, Inertia.js v2, Tailwind CSS v4
- **Database:** PostgreSQL
- **Testing:** Pest 4, PHPUnit 12
- **Tools:** Wayfinder, Pint, Sail, Vite

## Commands

- `php artisan test --compact` — run tests
- `php artisan test --compact --filter=TestName` — run specific test
- `vendor/bin/pint --dirty` — format PHP code
- `npm run dev` — start frontend dev server
- `npm run build` — build frontend
- `composer run dev` — start full dev environment

## Project Structure

```
app/Http/Controllers/     — Controllers (return Inertia responses)
app/Http/Requests/        — Form Request validation classes
app/Models/               — Eloquent models
app/Services/             — Business logic services
resources/js/Pages/       — React page components
resources/js/Components/  — Reusable React components
resources/js/types/       — TypeScript type definitions
routes/web.php            — Web routes
bootstrap/app.php         — Middleware, exceptions, routing config
```

## Code Conventions

### PHP
- PSR-12 style, always use curly braces
- PHP 8 constructor property promotion
- Explicit return type declarations on all methods
- Use `config()` not `env()` outside config files
- Use `php artisan make:*` commands to create files, always with `--no-interaction`

### Database
- Use `DB::transaction()` for multi-table operations
- Prefer Eloquent over raw queries, avoid `DB::` facade
- Eager load relationships to prevent N+1
- Always use `Carbon::now('America/Sao_Paulo')` — never without timezone

### Frontend
- TypeScript strict mode, type all props with interfaces
- Use Inertia's `useForm`, `router`, `<Link>` — never raw axios/fetch
- Import routes from `@/actions/` or `@/routes/` (Wayfinder)
- Tailwind CSS v4 for styling

### Error Handling
- Try-catch on all write operations in controllers, services, jobs
- Log with full context: error message, file, line, trace, relevant IDs
- User-friendly error messages — never expose technical details

### Testing
- Every change must have tests
- Use Pest, create with `php artisan make:test --pest`
- Use model factories, check existing states before manual setup
- Run `vendor/bin/pint --dirty --format agent` before finalizing

## Git Workflow

- **Never** commit directly to `main` or `develop`
- Work on `feature/*`, `bugfix/*`, or `hotfix/*` branches from `develop`
- Test before committing — all tests must pass
- Conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`
- One feature = one clean commit, not one commit per AI response
- Merge via Pull Request

## Boundaries

- Do not create files unless necessary — prefer editing existing ones
- Do not change dependencies without approval
- Do not create documentation files unless explicitly requested
- Do not commit without user confirmation
- Do not delete tests without approval
- Stick to existing directory structure
- Check sibling files for conventions before creating new ones
