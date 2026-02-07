---
name: laravel-eloquent-database
description: "Laravel 12.x Eloquent ORM and database optimization guide covering relationships, query performance, PostgreSQL-specific features, migrations, and large dataset processing"
---

# Laravel 12.x Eloquent & Database Mastery

## Overview
This skill file covers Laravel 12.x Eloquent ORM and database operations with emphasis on PostgreSQL optimization. Eloquent provides an expressive, object-relational mapping layer while the Query Builder offers fine-grained control for complex queries.

---

## Eloquent fundamentals

### Model conventions

Eloquent models follow naming conventions that eliminate boilerplate. A `User` model maps to the `users` table, expects an `id` primary key, and auto-manages `created_at`/`updated_at` timestamps:

```php
class User extends Model
{
    // Override only when deviating from conventions
    protected $table = 'employees';           // Custom table name
    protected $primaryKey = 'employee_id';    // Custom primary key
    protected $keyType = 'string';            // For UUID/ULID keys
    public $incrementing = false;             // Disable auto-increment
    public $timestamps = false;               // Disable timestamps
    
    protected $connection = 'pgsql_replica';  // Non-default connection
    
    // Default attribute values
    protected $attributes = [
        'status' => 'pending',
        'options' => '{}',
    ];
}
```

For UUID or ULID primary keys (recommended for distributed systems):

```php
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Document extends Model
{
    use HasUuids;
    
    // Generates UUID for 'id' automatically on create
}
```

### Strictness in development

Enable strict mode to catch N+1 queries and mass assignment issues early:

```php
// In AppServiceProvider::boot()
Model::preventLazyLoading(!app()->isProduction());
Model::preventSilentlyDiscardingAttributes(!app()->isProduction());
```

---

## Relationships and optimization

### Defining relationships

Laravel supports all standard relationship types with expressive method definitions:

```php
class Department extends Model
{
    // One-to-Many: Department has many employees
    public function employees(): HasMany
    {
        return $this->hasMany(Employee::class);
    }
    
    // One-to-One: Department has one director
    public function director(): HasOne
    {
        return $this->hasOne(Employee::class)->where('is_director', true);
    }
    
    // Has One of Many: Latest budget request
    public function latestBudgetRequest(): HasOne
    {
        return $this->hasOne(BudgetRequest::class)->latestOfMany();
    }
    
    // Has Many Through: All documents via employees
    public function documents(): HasManyThrough
    {
        return $this->hasManyThrough(Document::class, Employee::class);
    }
}

class Employee extends Model
{
    // Belongs-To inverse
    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }
    
    // Many-to-Many with pivot data
    public function projects(): BelongsToMany
    {
        return $this->belongsToMany(Project::class)
            ->withPivot('role', 'allocated_hours')
            ->withTimestamps();
    }
}
```

### Eager loading and N+1 prevention

**Eager loading** retrieves related models in a single query, preventing the N+1 problem where each iteration triggers a new query:

```php
// BAD: N+1 problem (1 query for employees + N queries for departments)
$employees = Employee::all();
foreach ($employees as $employee) {
    echo $employee->department->name; // Triggers query per employee
}

// GOOD: Eager loading (2 queries total)
$employees = Employee::with('department')->get();
foreach ($employees as $employee) {
    echo $employee->department->name; // Already loaded
}

// Nested eager loading
$departments = Department::with(['employees.documents', 'director'])->get();

// Constrained eager loading
$employees = Employee::with(['documents' => function ($query) {
    $query->where('classification', 'public')
          ->orderBy('created_at', 'desc');
}])->get();
```

Enable **automatic eager loading** (Laravel 12.x) for collections:

```php
Model::automaticallyEagerLoadRelationships();
```

The **`chaperone()` method** prevents N+1 when iterating over children and accessing their parent:

```php
$employees = Employee::with(['documents' => fn($q) => $q->chaperone()])->get();

foreach ($employees as $employee) {
    foreach ($employee->documents as $document) {
        echo $document->employee->name; // No additional query
    }
}
```

---

## Query scopes

### Local scopes with attributes (Laravel 12.x)

Scopes encapsulate reusable query constraints. Laravel 12.x uses the `#[Scope]` attribute:

```php
use Illuminate\Database\Eloquent\Attributes\Scope;

class Document extends Model
{
    #[Scope]
    protected function published(Builder $query): void
    {
        $query->whereNotNull('published_at');
    }
    
    #[Scope]
    protected function classification(Builder $query, string $level): void
    {
        $query->where('classification', $level);
    }
    
    #[Scope]
    protected function draft(Builder $query): void
    {
        $query->withAttributes(['status' => 'draft']);
    }
}

// Usage
$publicDocs = Document::published()->classification('public')->get();
$newDraft = Document::draft()->create(['title' => 'New Policy']); // status='draft' auto-set
```

### Global scopes

Apply constraints to all queries on a model—useful for multi-tenancy or soft deletes:

```php
use Illuminate\Database\Eloquent\Attributes\ScopedBy;

#[ScopedBy([DepartmentScope::class])]
class Document extends Model {}

class DepartmentScope implements Scope
{
    public function apply(Builder $builder, Model $model): void
    {
        if (auth()->check()) {
            $builder->where('department_id', auth()->user()->department_id);
        }
    }
}

// Bypass global scope when needed
Document::withoutGlobalScope(DepartmentScope::class)->get();
```

---

## Accessors, mutators, and casting

### Attribute accessors and mutators

Transform attribute values when reading (accessor) or writing (mutator):

```php
use Illuminate\Database\Eloquent\Casts\Attribute;

class Employee extends Model
{
    // Combined accessor/mutator
    protected function fullName(): Attribute
    {
        return Attribute::make(
            get: fn () => "{$this->first_name} {$this->last_name}",
        );
    }
    
    protected function socialSecurityNumber(): Attribute
    {
        return Attribute::make(
            get: fn ($value) => decrypt($value),
            set: fn ($value) => encrypt($value),
        );
    }
    
    // Cache expensive computations
    protected function clearanceLevel(): Attribute
    {
        return Attribute::make(
            get: fn () => $this->calculateClearanceLevel(),
        )->shouldCache();
    }
}
```

### Attribute casting

The `casts()` method handles automatic type conversion:

```php
protected function casts(): array
{
    return [
        'is_active' => 'boolean',
        'salary' => 'decimal:2',
        'hired_at' => 'datetime:Y-m-d',
        'metadata' => 'array',
        'options' => AsArrayObject::class,        // Mutable without reassignment
        'preferences' => AsCollection::class,      // Collection methods available
        'status' => EmployeeStatus::class,         // PHP enum
        'secret_notes' => 'encrypted',             // Automatic encryption
        'password' => 'hashed',                    // Auto-hash on set
    ];
}
```

For PostgreSQL `jsonb` columns, use `AsCollection` or `AsArrayObject` to enable direct mutations:

```php
$employee->options['notification_email'] = true; // Works with AsArrayObject
$employee->save();
```

---

## Soft deletes and model events

### Soft delete implementation

Soft deletes mark records as deleted without removing them, essential for audit trails:

```php
use Illuminate\Database\Eloquent\SoftDeletes;

class Document extends Model
{
    use SoftDeletes;
}

// Migration
Schema::table('documents', function (Blueprint $table) {
    $table->softDeletes(); // Adds deleted_at column
});

// Queries
$activeDocuments = Document::all();                    // Excludes soft-deleted
$allDocuments = Document::withTrashed()->get();        // Includes soft-deleted
$trashedOnly = Document::onlyTrashed()->get();         // Only soft-deleted

// Restore and force delete
$document->restore();
$document->forceDelete();
```

### Model events and observers

Hook into model lifecycle events for audit logging, cache invalidation, or side effects:

```php
use Illuminate\Database\Eloquent\Attributes\ObservedBy;

#[ObservedBy([DocumentObserver::class])]
class Document extends Model {}

class DocumentObserver
{
    public function created(Document $document): void
    {
        AuditLog::create([
            'action' => 'created',
            'model_type' => Document::class,
            'model_id' => $document->id,
            'user_id' => auth()->id(),
            'changes' => $document->getAttributes(),
        ]);
    }
    
    public function updated(Document $document): void
    {
        if ($document->wasChanged('classification')) {
            SecurityTeam::notifyClassificationChange($document);
        }
    }
}

// Skip events when needed
$document->saveQuietly();
```

---

## Query Builder optimization

### Raw queries vs Query Builder vs Eloquent

Choose the right abstraction based on needs:

| Approach | Use Case | Trade-offs |
|----------|----------|------------|
| **Eloquent** | CRUD, relationships, model features | Highest abstraction, slight overhead |
| **Query Builder** | Complex queries, aggregations, joins | Balance of control and safety |
| **Raw SQL** | Database-specific features, extreme optimization | Maximum control, manual binding required |

```php
// Eloquent: Best for standard CRUD with relationships
$employees = Employee::with('department')
    ->where('status', 'active')
    ->get();

// Query Builder: Best for complex aggregations
$departmentStats = DB::table('employees')
    ->select('department_id', DB::raw('COUNT(*) as employee_count'))
    ->selectRaw('AVG(salary) as avg_salary')
    ->groupBy('department_id')
    ->having('employee_count', '>', 10)
    ->get();

// Raw SQL: For database-specific features
$results = DB::select('
    SELECT * FROM employees 
    WHERE department_id = ? 
    AND created_at > NOW() - INTERVAL ? DAY
', [$deptId, 30]);
```

### Conditional query building

The `when()` method enables clean conditional clauses:

```php
$employees = Employee::query()
    ->when($request->department_id, fn($q, $dept) => $q->where('department_id', $dept))
    ->when($request->status, fn($q, $status) => $q->where('status', $status))
    ->when($request->search, fn($q, $search) => $q->where('name', 'ilike', "%{$search}%"))
    ->orderBy($request->sort_by ?? 'name')
    ->paginate(25);
```

---

## PostgreSQL-specific optimizations

### Configuration and column types

Configure PostgreSQL with schema support and SSL:

```php
// config/database.php
'pgsql' => [
    'driver' => 'pgsql',
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '5432'),
    'database' => env('DB_DATABASE'),
    'username' => env('DB_USERNAME'),
    'password' => env('DB_PASSWORD'),
    'charset' => 'utf8',
    'schema' => 'public',
    'sslmode' => env('DB_SSLMODE', 'prefer'),
],
```

PostgreSQL-specific column types in migrations:

```php
Schema::create('documents', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('title');
    $table->jsonb('metadata')->nullable();           // JSONB for efficient JSON queries
    $table->text('content');
    $table->timestamps();
    
    // Full-text search index
    $table->fullText('content');
});
```

### JSONB queries

PostgreSQL's `jsonb` type enables powerful JSON queries:

```php
// Query nested JSON values
$employees = Employee::where('preferences->notifications->email', true)->get();

// Check JSON contains values
$employees = Employee::whereJsonContains('skills', 'php')->get();
$employees = Employee::whereJsonContains('skills', ['php', 'laravel'])->get();

// Query JSON array length
$employees = Employee::whereJsonLength('certifications', '>=', 3)->get();
```

### Lateral joins for correlated subqueries

PostgreSQL lateral joins enable efficient "top N per group" queries:

```php
$latestDocs = DB::table('documents')
    ->select('id', 'title', 'created_at')
    ->whereColumn('department_id', 'departments.id')
    ->orderByDesc('created_at')
    ->limit(3);

$departmentsWithDocs = DB::table('departments')
    ->joinLateral($latestDocs, 'latest_documents')
    ->get();
```

---

## Index strategies and query performance

### Index creation in migrations

Strategic indexing dramatically improves query performance:

```php
Schema::create('documents', function (Blueprint $table) {
    $table->id();
    $table->foreignId('department_id')->constrained();
    $table->foreignId('author_id')->constrained('employees');
    $table->string('classification');
    $table->timestamp('published_at')->nullable();
    $table->timestamps();
    $table->softDeletes();
    
    // Single-column indexes for frequent filters
    $table->index('classification');
    $table->index('published_at');
    
    // Composite index for common query patterns
    $table->index(['department_id', 'classification', 'created_at']);
    
    // Unique constraint as index
    $table->unique(['department_id', 'title']);
});
```

**Index guidelines for PostgreSQL:**
- Index columns used in `WHERE`, `ORDER BY`, and `JOIN` clauses
- Place most selective columns first in composite indexes
- Consider partial indexes for filtered queries
- Use `EXPLAIN ANALYZE` to verify index usage

### Cursor pagination for large datasets

Cursor pagination outperforms offset pagination on large tables:

```php
// Offset pagination: Scans all previous rows (slow on page 1000)
$documents = Document::paginate(25);

// Cursor pagination: Uses WHERE clause (consistent performance)
$documents = Document::orderBy('id')->cursorPaginate(25);
```

---

## Transaction handling

### Automatic transactions

Wrap related operations in transactions for data integrity:

```php
use Illuminate\Support\Facades\DB;

DB::transaction(function () use ($request) {
    $employee = Employee::create($request->validated());
    
    $employee->documents()->create([
        'title' => 'Onboarding Checklist',
        'classification' => 'internal',
    ]);
    
    AuditLog::create([
        'action' => 'employee_created',
        'model_id' => $employee->id,
    ]);
}, attempts: 5); // Retry on deadlock
```

### Pessimistic locking

Use locks for critical sections like financial transfers:

```php
DB::transaction(function () use ($fromAccount, $toAccount, $amount) {
    // Lock rows for update
    $sender = Account::lockForUpdate()->find($fromAccount);
    $receiver = Account::lockForUpdate()->find($toAccount);
    
    if ($sender->balance < $amount) {
        throw new InsufficientFundsException();
    }
    
    $sender->decrement('balance', $amount);
    $receiver->increment('balance', $amount);
    
    Transfer::create([
        'from_account_id' => $sender->id,
        'to_account_id' => $receiver->id,
        'amount' => $amount,
    ]);
});
```

---

## Migration best practices

### Reversible migrations

Always implement `down()` methods for rollback capability:

```php
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->string('action');
            $table->morphs('auditable');
            $table->foreignId('user_id')->nullable()->constrained();
            $table->jsonb('old_values')->nullable();
            $table->jsonb('new_values')->nullable();
            $table->ipAddress('ip_address')->nullable();
            $table->timestamps();
            
            $table->index(['auditable_type', 'auditable_id']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
```

### Foreign key constraints

Define constraints with clear cascade behavior:

```php
$table->foreignId('department_id')
    ->constrained()
    ->onUpdate('cascade')
    ->onDelete('restrict'); // Prevent deletion of referenced department

// Nullable foreign key
$table->foreignId('supervisor_id')
    ->nullable()
    ->constrained('employees')
    ->nullOnDelete(); // Set to null when supervisor deleted
```

---

## Seeding and factories for testing

### Factory definitions

Create realistic test data with factories:

```php
class EmployeeFactory extends Factory
{
    public function definition(): array
    {
        return [
            'first_name' => fake()->firstName(),
            'last_name' => fake()->lastName(),
            'email' => fake()->unique()->safeEmail(),
            'department_id' => Department::factory(),
            'hired_at' => fake()->dateTimeBetween('-10 years', 'now'),
            'salary' => fake()->numberBetween(40000, 150000),
            'status' => 'active',
        ];
    }
    
    public function director(): static
    {
        return $this->state(['is_director' => true, 'salary' => 200000]);
    }
    
    public function inactive(): static
    {
        return $this->state(['status' => 'inactive']);
    }
}

// Usage in tests
$director = Employee::factory()->director()->create();
$team = Employee::factory()->count(5)->for($department)->create();
```

### Relationship factories

```php
// Create employee with related documents
$employee = Employee::factory()
    ->has(Document::factory()->count(3)->state(['classification' => 'internal']))
    ->create();

// Magic method syntax
$employee = Employee::factory()
    ->hasDocuments(3, ['classification' => 'public'])
    ->create();

// Many-to-many with pivot data
$employee = Employee::factory()
    ->hasAttached(
        Project::factory()->count(2),
        ['role' => 'contributor', 'allocated_hours' => 40]
    )
    ->create();
```

---

## Processing large datasets

### Chunking to prevent memory exhaustion

Process large tables without loading everything into memory:

```php
// Process in batches of 1000
Employee::where('needs_review', true)
    ->chunkById(1000, function ($employees) {
        foreach ($employees as $employee) {
            $employee->update(['reviewed_at' => now()]);
        }
    });

// Lazy collections for streaming
Employee::where('status', 'active')
    ->lazy()
    ->each(function ($employee) {
        dispatch(new SendAnnualReviewEmail($employee));
    });
```

---

## Docker integration considerations

For Docker deployments with PostgreSQL:

```yaml
# docker-compose.yml
services:
  app:
    environment:
      DB_CONNECTION: pgsql
      DB_HOST: postgres
      DB_PORT: 5432
      
  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: laravel
      POSTGRES_USER: laravel
      POSTGRES_PASSWORD: secret
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

Run migrations in entrypoint scripts:

```bash
#!/bin/bash
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php-fpm
```

---

## Common database pitfalls and solutions

| Pitfall | Symptom | Solution |
|---------|---------|----------|
| N+1 queries | Slow page loads, many queries | Use `with()` eager loading |
| Missing indexes | Slow queries on large tables | Add indexes to filtered/sorted columns |
| Offset pagination on large datasets | Progressively slower pages | Use cursor pagination |
| Large result sets in memory | Out of memory errors | Use `chunk()` or `lazy()` |
| Unguarded mass assignment | Unexpected data modification | Define `$fillable` on all models |
| Missing transactions | Inconsistent data on errors | Wrap related operations in `DB::transaction()` |
| Raw queries without bindings | SQL injection vulnerability | Always use parameter binding |
| N+1 in nested loops | Exponential query count | Use `chaperone()` or nested eager loading |