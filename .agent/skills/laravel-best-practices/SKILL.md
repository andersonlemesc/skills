---
name: laravel-best-practices
description: "Comprehensive Laravel 12.x best practices covering security, validation, performance optimization, caching, queues, error handling, and testing for full-stack Blade applications"
---

# Laravel 12.x Best Practices

## Overview
TThis skill file provides comprehensive guidance for building secure, performant, and maintainable Laravel 12.x applications. Laravel's elegant syntax pairs with robust security defaults and optimization tools, making it ideal for government and corporate full-stack Blade applications.

---

## Project structure and organization

Laravel 12.x enforces a conventional directory structure that promotes separation of concerns. The **`app/`** directory contains application logic organized by type: Controllers handle HTTP requests, Models represent database entities, and Services encapsulate business logic. Configuration lives in **`config/`**, while database migrations, factories, and seeders reside in **`database/`**.

For government or corporate applications requiring complex business logic, adopt the **Actions pattern**: single-purpose classes in `app/Actions/` that perform one task. Combine this with **Form Requests** for validation encapsulation and **Services** for reusable business operations:

```php
app/
├── Actions/
│   └── CreateUserAction.php      // Single-purpose business operations
├── Http/
│   ├── Controllers/
│   ├── Requests/                  // Form Request validation classes
│   └── Middleware/
├── Models/
├── Services/                      // Reusable business logic
│   └── DocumentProcessingService.php
└── DTOs/                          // Data Transfer Objects
    └── UserData.php
```

**Data Transfer Objects (DTOs)** provide type-safe data containers for passing structured data between layers. In PHP 8.2+, use readonly classes with constructor promotion:

```php
readonly class UserData
{
    public function __construct(
        public string $name,
        public string $email,
        public ?string $department = null,
    ) {}
    
    public static function fromRequest(StoreUserRequest $request): self
    {
        return new self(
            name: $request->validated('name'),
            email: $request->validated('email'),
            department: $request->validated('department'),
        );
    }
}
```

---

## Security best practices

### Authentication architecture

Laravel's authentication uses **Guards** (how users authenticate) and **Providers** (how users are retrieved). Session-based authentication suits Blade applications; always regenerate sessions after login to prevent session fixation attacks:

```php
if (Auth::attempt(['email' => $email, 'password' => $password])) {
    $request->session()->regenerate();
    return redirect()->intended('dashboard');
}

// Logout properly invalidates session and CSRF token
Auth::logout();
$request->session()->invalidate();
$request->session()->regenerateToken();
```

For government applications requiring "remember me" functionality, ensure the `remember_token` column exists (nullable, 100 characters) and passwords are stored in columns ≥60 characters.

### Authorization with Gates and Policies

**Gates** handle simple, closure-based authorization not tied to models. **Policies** organize model-specific authorization logic. Laravel auto-discovers policies in `app/Policies/` matching model names with a `Policy` suffix:

```php
// Gate definition in AppServiceProvider
Gate::define('access-admin-dashboard', function (User $user) {
    return $user->role === 'administrator';
});

// Policy for document access (government example)
class DocumentPolicy
{
    public function view(User $user, Document $document): bool
    {
        return $user->department_id === $document->department_id 
            || $user->clearance_level >= $document->classification_level;
    }
    
    public function update(User $user, Document $document): Response
    {
        if ($document->is_locked) {
            return Response::deny('Document is locked for editing.');
        }
        return $user->id === $document->author_id
            ? Response::allow()
            : Response::deny('You are not the document author.');
    }
}
```

Apply authorization in Blade templates with `@can` directives and in routes via middleware:

```php
Route::put('/documents/{document}', [DocumentController::class, 'update'])
    ->middleware('can:update,document');
```

### CSRF, XSS, and SQL injection prevention

Laravel includes **automatic CSRF protection** for all POST, PUT, PATCH, and DELETE requests. Include the token in every form:

```blade
<form method="POST" action="/documents">
    @csrf
    <!-- form fields -->
</form>
```

For AJAX requests, set the `X-CSRF-TOKEN` header from a meta tag or use the `XSRF-TOKEN` cookie (automatically handled by Axios).

**XSS prevention** relies on Blade's automatic escaping. The `{{ }}` syntax runs `htmlspecialchars()` on all output. **Never use `{!! !!}` on user-supplied content**—reserve it exclusively for trusted HTML:

```blade
<!-- SAFE: Auto-escaped -->
{{ $userComment }}

<!-- DANGEROUS: Only for trusted content like rendered Markdown -->
{!! $trustedHtml !!}

<!-- Safe JSON in JavaScript -->
<script>var config = {{ Js::from($settings) }};</script>
```

**SQL injection protection** is automatic when using Eloquent or Query Builder—PDO parameter binding protects all queries. The vulnerable pattern is string concatenation:

```php
// SAFE: Automatic parameter binding
$users = User::where('email', $email)->get();
$users = DB::table('users')->where('email', $email)->get();

// SAFE: Explicit binding for raw queries
$users = DB::select('SELECT * FROM users WHERE email = ?', [$email]);

// VULNERABLE: Never concatenate user input
$users = DB::select("SELECT * FROM users WHERE email = '$email'"); // DON'T DO THIS
```

### Mass assignment protection

Always define **`$fillable`** (whitelist approach) on models and use `validated()` or `only()` when creating records:

```php
class User extends Model
{
    protected $fillable = ['name', 'email', 'department_id'];
}

// SAFE: Only validated fields are mass-assigned
User::create($request->validated());

// SAFE: Explicit field selection
User::create($request->only(['name', 'email']));

// UNSAFE: Potential mass assignment vulnerability
User::create($request->all()); // Attacker could inject 'is_admin' => true
```

Enable strict mode in development to catch silent discarding:

```php
Model::preventSilentlyDiscardingAttributes(!app()->isProduction());
```

### Rate limiting

Protect login endpoints and sensitive actions with rate limiters:

```php
// In AppServiceProvider
RateLimiter::for('login', function (Request $request) {
    return Limit::perMinute(5)
        ->by($request->ip())
        ->response(fn() => response()->json(['message' => 'Too many login attempts.'], 429));
});

// Apply to route
Route::post('/login', [AuthController::class, 'login'])
    ->middleware('throttle:login');
```

---

## Validation patterns

### Form Requests for clean controllers

Form Requests encapsulate validation and authorization, keeping controllers focused on handling requests:

```php
// Generate: php artisan make:request StoreDocumentRequest

class StoreDocumentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', Document::class);
    }

    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'classification' => 'required|in:public,internal,confidential,secret',
            'department_id' => 'required|exists:departments,id',
            'content' => 'required|string|min:10',
            'attachments.*' => 'file|mimes:pdf,docx|max:10240',
        ];
    }

    public function messages(): array
    {
        return [
            'classification.in' => 'Classification must be: public, internal, confidential, or secret.',
        ];
    }

    // Sanitize input before validation
    protected function prepareForValidation(): void
    {
        $this->merge([
            'title' => strip_tags($this->title),
        ]);
    }
}
```

Use the request in controllers—validation runs automatically before the method executes:

```php
public function store(StoreDocumentRequest $request): RedirectResponse
{
    $document = Document::create($request->validated());
    return redirect()->route('documents.show', $document);
}
```

### Custom validation rules

Create reusable rules for domain-specific validation:

```php
// Generate: php artisan make:rule ValidGovernmentId

class ValidGovernmentId implements ValidationRule
{
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (!preg_match('/^[A-Z]{2}\d{8}$/', $value)) {
            $fail('The :attribute must be a valid government ID (e.g., AB12345678).');
        }
    }
}

// Usage
$request->validate([
    'employee_id' => ['required', new ValidGovernmentId],
]);
```

### Displaying validation errors in Blade

```blade
@if ($errors->any())
    <div class="alert alert-danger">
        <ul>
            @foreach ($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif

<!-- Per-field error display -->
<input type="text" name="title" value="{{ old('title') }}" 
       class="@error('title') is-invalid @enderror">
@error('title')
    <span class="invalid-feedback">{{ $message }}</span>
@enderror
```

---

## Performance optimization

### Caching strategies

Laravel supports Redis, Memcached, database, and file caching. Use `Cache::remember()` to retrieve or compute values atomically:

```php
// Cache expensive queries for 1 hour
$departments = Cache::remember('departments:active', 3600, function () {
    return Department::where('active', true)
        ->with('manager')
        ->get();
});

// Stale-while-revalidate pattern (serves stale data while refreshing)
$reports = Cache::flexible('monthly_reports', [300, 600], function () {
    return Report::generateMonthlyStatistics();
});
```

**Cache tags** (Redis/Memcached only) enable targeted invalidation:

```php
Cache::tags(['users', 'department:5'])->put('user:42', $user, 3600);
Cache::tags(['department:5'])->flush(); // Clears all department:5 caches
```

### Queue-driven architecture

Offload time-consuming tasks like PDF generation, email sending, or API calls to queues:

```php
// Job class
class GenerateAuditReport implements ShouldQueue
{
    use Queueable;
    
    public $tries = 3;
    public $timeout = 300;
    
    public function __construct(public AuditRequest $auditRequest) {}
    
    public function handle(ReportGenerator $generator): void
    {
        $report = $generator->generate($this->auditRequest);
        $this->auditRequest->user->notify(new AuditReportReady($report));
    }
    
    public function failed(Throwable $exception): void
    {
        Log::error('Audit report generation failed', [
            'audit_request_id' => $this->auditRequest->id,
            'error' => $exception->getMessage(),
        ]);
    }
}

// Dispatch with delay
GenerateAuditReport::dispatch($auditRequest)->delay(now()->addMinutes(5));
```

For Docker deployments, run queue workers via Supervisor or use `php artisan queue:work --max-time=3600` with container orchestration.

### Deployment optimization commands

Run these commands during deployment for significant performance gains:

```bash
# Single command to cache config, routes, events, and views
php artisan optimize

# Or individually:
php artisan config:cache    # Combines all config into single file
php artisan route:cache     # Compiles routes (10-50% faster routing)
php artisan view:cache      # Precompiles Blade templates

# Optimize Composer autoloader
composer install --optimize-autoloader --no-dev
```

**Critical**: After caching configuration, the `env()` function only returns system environment variables. Always use `env()` exclusively in config files, then access values via `config()` in application code.

---

## Error handling and logging

### Exception handling configuration

Configure exception handling in `bootstrap/app.php`:

```php
->withExceptions(function (Exceptions $exceptions) {
    // Custom reporting for specific exceptions
    $exceptions->report(function (PaymentFailedException $e) {
        Log::channel('payments')->error('Payment failed', [
            'user_id' => auth()->id(),
            'amount' => $e->amount,
        ]);
    })->stop();
    
    // Ignore noisy exceptions
    $exceptions->dontReport([
        TemporaryMaintenanceException::class,
    ]);
    
    // Custom rendering for API responses
    $exceptions->render(function (ResourceNotFoundException $e, Request $request) {
        if ($request->expectsJson()) {
            return response()->json(['error' => $e->getMessage()], 404);
        }
    });
    
    // Throttle exception reporting to prevent log flooding
    $exceptions->throttle(function (Throwable $e) {
        if ($e instanceof ExternalServiceException) {
            return Limit::perMinute(10);
        }
    });
})
```

### Structured logging

Use contextual logging with request identifiers for traceability:

```php
Log::shareContext(['request_id' => request()->header('X-Request-ID')]);

Log::info('Document created', [
    'document_id' => $document->id,
    'user_id' => auth()->id(),
    'classification' => $document->classification,
]);
```

Configure daily rotating logs in production to prevent disk exhaustion:

```php
// config/logging.php
'daily' => [
    'driver' => 'daily',
    'path' => storage_path('logs/laravel.log'),
    'level' => env('LOG_LEVEL', 'error'),
    'days' => 14,
],
```

---

## Testing foundations

### Feature and unit tests

**Feature tests** verify complete request/response cycles; **unit tests** isolate individual components:

```php
// Feature test for document creation
class DocumentCreationTest extends TestCase
{
    use RefreshDatabase;
    
    public function test_authorized_user_can_create_document(): void
    {
        $user = User::factory()->create(['role' => 'editor']);
        $department = Department::factory()->create();
        
        $response = $this->actingAs($user)
            ->post('/documents', [
                'title' => 'Quarterly Report',
                'classification' => 'internal',
                'department_id' => $department->id,
                'content' => 'Report content here...',
            ]);
        
        $response->assertRedirect();
        $this->assertDatabaseHas('documents', [
            'title' => 'Quarterly Report',
            'author_id' => $user->id,
        ]);
    }
    
    public function test_guest_cannot_create_document(): void
    {
        $response = $this->post('/documents', []);
        $response->assertRedirect('/login');
    }
}
```

### Database testing with factories

Use `RefreshDatabase` trait and factories for isolated, repeatable tests:

```php
// Run tests in parallel with separate databases
php artisan test --parallel

// Profile slow tests
php artisan test --profile
```

---

## Configuration management

### Environment handling

Store secrets in `.env` (never committed) and document structure in `.env.example`:

```env
APP_NAME="Government Portal"
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:xxx

DB_CONNECTION=pgsql
DB_HOST=db.internal.gov
DB_PORT=5432
DB_DATABASE=portal_production
```

For CI/CD, encrypt the environment file:

```bash
php artisan env:encrypt --env=production
# Creates .env.production.encrypted with LARAVEL_ENV_ENCRYPTION_KEY
```

Access configuration values throughout the application:

```php
// CORRECT: Use config() helper
$appName = config('app.name');
$timeout = config('services.external.timeout', 30);

// INCORRECT: Don't use env() outside config files
$appName = env('APP_NAME'); // Returns null when config is cached
```

---

## Common pitfalls and solutions

| Pitfall | Impact | Solution |
|---------|--------|----------|
| Using `env()` in application code | Returns null when config cached | Always use `config()` helper |
| Missing `@csrf` in forms | 419 Page Expired errors | Add `@csrf` directive to all forms |
| `APP_DEBUG=true` in production | Exposes sensitive data | Always set to `false` in production |
| Using `{!! !!}` on user input | XSS vulnerability | Use `{{ }}` for auto-escaping |
| `User::create($request->all())` | Mass assignment vulnerability | Use `$request->validated()` |
| Synchronous heavy operations | Slow page loads, timeouts | Dispatch to queues |
| Single log file in production | Disk exhaustion | Use `daily` driver with rotation |
| Not throttling authentication | Brute force attacks | Apply `throttle` middleware |

---