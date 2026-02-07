---
name: laravel-database-design-patterns
description: "Database design patterns and schema conventions for Laravel 12.x with PostgreSQL. Covers table structures, naming conventions, relationships, indexes, and complete module examples for government and corporate applications."
---

# Laravel 12.x Database Design Patterns

## Overview

This skill provides comprehensive database design patterns for Laravel 12.x applications using PostgreSQL. It covers table structures, naming conventions, relationships, indexing strategies, and complete real-world examples for government and corporate systems.

---

## When to Use This Skill

Use this skill when:
- Designing new database tables and relationships
- Creating migrations for complex modules
- Defining foreign keys and indexes
- Structuring audit trails and soft deletes
- Planning database architecture
- Implementing many-to-many or polymorphic relationships

---

## Table Naming Conventions

### Basic Rules

| Entity Type | Convention | Example |
|-------------|-----------|---------|
| **Regular Tables** | Plural, snake_case | `users`, `blog_posts`, `order_items` |
| **Pivot Tables** | Alphabetical singular | `post_tag`, `employee_project`, `role_user` |
| **Polymorphic Pivot** | Alphabetical + -able | `commentable`, `taggable`, `fileable` |
| **Junction Tables** | Descriptive name | `user_permissions`, `project_assignments` |

### Examples

```php
// ✅ CORRECT - Standard table names
users
employees
departments
documents
audit_logs
blog_posts

// ✅ CORRECT - Pivot table names (alphabetical)
employee_project  // NOT project_employee
post_tag          // NOT tag_post
role_user         // NOT user_role

// ✅ CORRECT - Polymorphic tables
taggable          // polymorphic pivot for tags
commentable       // polymorphic for comments
attachments       // polymorphic for files

// ❌ WRONG - Inconsistent naming
user              // Should be 'users'
BlogPost          // Should be 'blog_posts'
project_employees // Should be 'employee_project'
```

---

## Column Naming Conventions

### Standard Columns

| Column Type | Convention | Example |
|-------------|-----------|---------|
| **Primary Key** | `id` (BigInt or UUID) | `id` |
| **Foreign Key** | `[table_singular]_id` | `user_id`, `department_id`, `blog_post_id` |
| **Boolean** | `is_` or `has_` prefix | `is_active`, `has_approved`, `is_published` |
| **Dates** | `_at` suffix | `published_at`, `deleted_at`, `verified_at` |
| **Counts** | `_count` suffix | `views_count`, `likes_count` |
| **JSON/JSONB** | Descriptive name | `metadata`, `settings`, `preferences` |
| **Text** | No suffix | `title`, `content`, `description` |

### Examples

```php
// ✅ CORRECT - Column naming
id                    // Primary key
user_id              // Foreign key (singular!)
department_id        // Foreign key
is_active            // Boolean
has_permissions      // Boolean
published_at         // Timestamp
deleted_at           // Soft delete
views_count          // Counter
metadata             // JSONB
settings             // JSON

// ❌ WRONG - Incorrect naming
userId               // Should be user_id
users_id             // Should be user_id (singular)
active               // Should be is_active
publishDate          // Should be published_at
view_count           // Should be views_count
```

---

## Standard Table Structure

### Minimal Table

```php
Schema::create('posts', function (Blueprint $table) {
    $table->id();                           // Auto-increment BigInt primary key
    $table->string('title');
    $table->text('content');
    $table->timestamps();                   // created_at, updated_at
});
```

### Complete Table with All Common Fields

```php
Schema::create('documents', function (Blueprint $table) {
    // Primary Key
    $table->id();                           // or $table->uuid('id')->primary();
    
    // Foreign Keys
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('department_id')->constrained()->onDelete('restrict');
    
    // Basic Fields
    $table->string('title', 255);
    $table->text('content');
    $table->string('slug')->unique();
    
    // Status/State
    $table->enum('status', ['draft', 'published', 'archived'])->default('draft');
    $table->boolean('is_featured')->default(false);
    
    // Metadata
    $table->jsonb('metadata')->nullable();
    $table->integer('views_count')->default(0);
    
    // Dates
    $table->timestamp('published_at')->nullable();
    $table->timestamp('expires_at')->nullable();
    
    // Standard Timestamps
    $table->timestamps();                   // created_at, updated_at
    $table->softDeletes();                  // deleted_at
    
    // Indexes
    $table->index('status');
    $table->index(['department_id', 'status', 'published_at']);
    $table->fullText('content');            // PostgreSQL full-text search
});
```

---

## Primary Keys: UUID vs BigInt

### When to Use Each

| Use Case | Recommendation | Why |
|----------|---------------|-----|
| **Public IDs** | UUID | Prevents enumeration attacks |
| **Distributed Systems** | UUID | Globally unique without coordination |
| **Simple Apps** | BigInt | Faster, smaller, simpler |
| **APIs** | UUID | Security and privacy |
| **Internal Only** | BigInt | Better performance |
| **Large Scale** | BigInt with partitioning | Better performance at scale |

### UUID Primary Key

```php
use Illuminate\Database\Eloquent\Concerns\HasUuids;

// Migration
Schema::create('documents', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('title');
    $table->timestamps();
});

// Model
class Document extends Model
{
    use HasUuids;
    
    protected $keyType = 'string';
    public $incrementing = false;
}
```

### BigInt Primary Key (Default)

```php
// Migration
Schema::create('posts', function (Blueprint $table) {
    $table->id();  // Shorthand for bigIncrements('id')
    $table->string('title');
    $table->timestamps();
});

// Model - no special configuration needed
class Post extends Model {}
```

---

## Foreign Keys and Relationships

### One-to-Many Relationship

```php
// Parent table: departments
Schema::create('departments', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->timestamps();
});

// Child table: employees
Schema::create('employees', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    
    // ✅ CORRECT - Foreign key with constraints
    $table->foreignId('department_id')
        ->constrained()                    // References departments.id
        ->onUpdate('cascade')              // Update employee when department changes
        ->onDelete('restrict');            // Prevent deleting department with employees
    
    $table->timestamps();
    
    // Index for faster queries
    $table->index('department_id');
});

// Models
class Department extends Model
{
    public function employees(): HasMany
    {
        return $this->hasMany(Employee::class);
    }
}

class Employee extends Model
{
    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }
}
```

### Many-to-Many Relationship

```php
// First table: employees
Schema::create('employees', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->timestamps();
});

// Second table: projects
Schema::create('projects', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->timestamps();
});

// ✅ CORRECT - Pivot table (alphabetical order: employee_project)
Schema::create('employee_project', function (Blueprint $table) {
    $table->id();
    
    // Foreign keys
    $table->foreignId('employee_id')->constrained()->onDelete('cascade');
    $table->foreignId('project_id')->constrained()->onDelete('cascade');
    
    // Pivot-specific data
    $table->string('role')->nullable();
    $table->integer('allocated_hours')->default(0);
    $table->date('assigned_at')->nullable();
    
    // Prevent duplicates
    $table->unique(['employee_id', 'project_id']);
    
    $table->timestamps();
});

// Models
class Employee extends Model
{
    public function projects(): BelongsToMany
    {
        return $this->belongsToMany(Project::class)
            ->withPivot('role', 'allocated_hours', 'assigned_at')
            ->withTimestamps();
    }
}

class Project extends Model
{
    public function employees(): BelongsToMany
    {
        return $this->belongsToMany(Employee::class)
            ->withPivot('role', 'allocated_hours', 'assigned_at')
            ->withTimestamps();
    }
}
```

### Polymorphic Relationships

```php
// Polymorphic table: comments (can belong to posts, videos, etc.)
Schema::create('comments', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained();
    
    // ✅ CORRECT - Polymorphic columns
    $table->morphs('commentable');  // Creates commentable_id and commentable_type
    
    $table->text('content');
    $table->timestamps();
    
    // Composite index for polymorphic queries
    $table->index(['commentable_id', 'commentable_type']);
});

// Models
class Comment extends Model
{
    public function commentable(): MorphTo
    {
        return $this->morphTo();
    }
}

class Post extends Model
{
    public function comments(): MorphMany
    {
        return $this->morphMany(Comment::class, 'commentable');
    }
}

class Video extends Model
{
    public function comments(): MorphMany
    {
        return $this->morphMany(Comment::class, 'commentable');
    }
}
```

### Polymorphic Many-to-Many

```php
// Tables: posts, videos
// Polymorphic: tags can be attached to multiple models

Schema::create('tags', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('slug')->unique();
    $table->timestamps();
});

// ✅ CORRECT - Polymorphic pivot table
Schema::create('taggables', function (Blueprint $table) {
    $table->foreignId('tag_id')->constrained()->onDelete('cascade');
    $table->morphs('taggable');  // taggable_id, taggable_type
    
    $table->unique(['tag_id', 'taggable_id', 'taggable_type']);
    $table->timestamps();
});

// Models
class Tag extends Model
{
    public function posts(): MorphToMany
    {
        return $this->morphedByMany(Post::class, 'taggable');
    }
    
    public function videos(): MorphToMany
    {
        return $this->morphedByMany(Video::class, 'taggable');
    }
}

class Post extends Model
{
    public function tags(): MorphToMany
    {
        return $this->morphToMany(Tag::class, 'taggable');
    }
}
```

---

## Soft Deletes Pattern

### When to Use Soft Deletes

✅ **Use soft deletes when:**
- Need audit trails
- Regulatory compliance requires data retention
- Users might need to restore data
- Related data depends on the record
- Government/corporate applications

❌ **Don't use soft deletes when:**
- Privacy/GDPR requires permanent deletion
- Truly temporary data (sessions, cache)
- High-volume tables (performance impact)

### Implementation

```php
// Migration
Schema::create('documents', function (Blueprint $table) {
    $table->id();
    $table->string('title');
    $table->timestamps();
    $table->softDeletes();  // Adds deleted_at column
    
    // Index for queries excluding soft-deleted
    $table->index('deleted_at');
});

// Model
use Illuminate\Database\Eloquent\SoftDeletes;

class Document extends Model
{
    use SoftDeletes;
    
    // Optional: Custom deleted_at column name
    // const DELETED_AT = 'removed_at';
}

// Usage
$document->delete();           // Soft delete (sets deleted_at)
$document->forceDelete();      // Permanent delete
$document->restore();          // Restore soft-deleted

// Queries
Document::all();                    // Excludes soft-deleted
Document::withTrashed()->get();     // Includes soft-deleted
Document::onlyTrashed()->get();     // Only soft-deleted
```

---

## Audit Trail Pattern

### Complete Audit Log Table

```php
Schema::create('audit_logs', function (Blueprint $table) {
    $table->id();
    
    // Who did it
    $table->foreignId('user_id')->nullable()->constrained();
    $table->string('user_name')->nullable();  // Snapshot in case user deleted
    
    // What was affected
    $table->morphs('auditable');  // auditable_id, auditable_type
    
    // What happened
    $table->string('action', 50);  // created, updated, deleted, restored
    $table->jsonb('old_values')->nullable();
    $table->jsonb('new_values')->nullable();
    
    // When and where
    $table->ipAddress('ip_address')->nullable();
    $table->string('user_agent')->nullable();
    $table->timestamp('created_at');  // No updated_at needed for logs
    
    // Indexes for common queries
    $table->index(['auditable_id', 'auditable_type']);
    $table->index('user_id');
    $table->index('action');
    $table->index('created_at');
});

// Model
class AuditLog extends Model
{
    const UPDATED_AT = null;  // No updated_at for logs
    
    protected $casts = [
        'old_values' => 'array',
        'new_values' => 'array',
    ];
    
    public function auditable(): MorphTo
    {
        return $this->morphTo();
    }
    
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
```

---

## Indexing Strategies

### When to Add Indexes

✅ **Always index:**
- Foreign keys
- Columns used in WHERE clauses frequently
- Columns used in ORDER BY
- Columns used in JOIN conditions
- Unique columns (email, slug)

### Index Types

```php
Schema::create('documents', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained();
    $table->foreignId('department_id')->constrained();
    $table->string('title');
    $table->string('slug')->unique();
    $table->text('content');
    $table->string('status', 20);
    $table->timestamp('published_at')->nullable();
    $table->timestamps();
    
    // ✅ Single column indexes
    $table->index('user_id');           // Foreign key
    $table->index('status');            // Frequently filtered
    $table->index('published_at');      // Date queries
    
    // ✅ Composite index (order matters!)
    // For queries like: WHERE department_id = ? AND status = ? ORDER BY created_at
    $table->index(['department_id', 'status', 'created_at']);
    
    // ✅ Unique index
    $table->unique('slug');
    $table->unique(['user_id', 'slug']);  // Unique per user
    
    // ✅ Full-text search (PostgreSQL)
    $table->fullText('content');
    $table->fullText(['title', 'content']);  // Multiple columns
});
```

### Composite Index Guidelines

```php
// ✅ GOOD - Most selective column first
$table->index(['department_id', 'status', 'published_at']);

// Query that uses this index efficiently:
// WHERE department_id = 5 AND status = 'published' ORDER BY published_at

// ❌ BAD - Wrong order for your queries
$table->index(['status', 'department_id', 'published_at']);

// This doesn't help if you filter by department_id first
```

---

## PostgreSQL-Specific Features

### JSONB Columns

```php
Schema::create('documents', function (Blueprint $table) {
    $table->id();
    $table->string('title');
    
    // ✅ JSONB for queryable JSON data
    $table->jsonb('metadata')->nullable();
    $table->jsonb('settings')->default('{}');
    
    // JSON indexes for better performance
    $table->index('metadata'); // GIN index automatically
});

// Usage in queries
Document::where('metadata->language', 'pt-BR')->get();
Document::whereJsonContains('metadata->tags', 'urgent')->get();
```

### Array Columns

```php
Schema::create('posts', function (Blueprint $table) {
    $table->id();
    $table->string('title');
    
    // PostgreSQL array column
    $table->json('tags')->default('[]');  // Store as JSON array
});

// Model casting
class Post extends Model
{
    protected $casts = [
        'tags' => 'array',
    ];
}
```

### Full-Text Search

```php
Schema::create('articles', function (Blueprint $table) {
    $table->id();
    $table->string('title');
    $table->text('content');
    
    // Full-text search index
    $table->fullText('content');
    $table->fullText(['title', 'content']);
});

// Usage
Article::whereFullText('content', 'laravel database')->get();
Article::whereFullText(['title', 'content'], 'laravel database')->get();
```

---

## Complete Module Examples

### Example 1: Blog System

```php
// Table: categories
Schema::create('categories', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('slug')->unique();
    $table->text('description')->nullable();
    $table->timestamps();
});

// Table: tags
Schema::create('tags', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('slug')->unique();
    $table->timestamps();
});

// Table: posts
Schema::create('posts', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('category_id')->constrained()->onDelete('restrict');
    
    $table->string('title');
    $table->string('slug')->unique();
    $table->text('excerpt')->nullable();
    $table->text('content');
    
    $table->enum('status', ['draft', 'published', 'archived'])->default('draft');
    $table->boolean('is_featured')->default(false);
    
    $table->integer('views_count')->default(0);
    $table->jsonb('metadata')->nullable();
    
    $table->timestamp('published_at')->nullable();
    $table->timestamps();
    $table->softDeletes();
    
    // Indexes
    $table->index(['category_id', 'status', 'published_at']);
    $table->index('user_id');
    $table->fullText(['title', 'content']);
});

// Table: post_tag (many-to-many)
Schema::create('post_tag', function (Blueprint $table) {
    $table->foreignId('post_id')->constrained()->onDelete('cascade');
    $table->foreignId('tag_id')->constrained()->onDelete('cascade');
    $table->unique(['post_id', 'tag_id']);
    $table->timestamps();
});

// Table: comments (polymorphic)
Schema::create('comments', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained();
    $table->morphs('commentable');
    $table->text('content');
    $table->boolean('is_approved')->default(false);
    $table->timestamps();
    $table->softDeletes();
    
    $table->index(['commentable_id', 'commentable_type']);
    $table->index('is_approved');
});
```

### Example 2: Government Document Management

```php
// Table: departments
Schema::create('departments', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('code', 10)->unique();
    $table->text('description')->nullable();
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});

// Table: employees
Schema::create('employees', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->foreignId('department_id')->constrained()->onDelete('restrict');
    
    $table->string('employee_id', 20)->unique();  // Government ID
    $table->string('name');
    $table->string('position');
    $table->integer('clearance_level')->default(1);
    
    $table->boolean('is_active')->default(true);
    $table->date('hired_at');
    $table->date('terminated_at')->nullable();
    
    $table->timestamps();
    $table->softDeletes();
    
    $table->index('department_id');
    $table->index('clearance_level');
});

// Table: documents
Schema::create('documents', function (Blueprint $table) {
    $table->uuid('id')->primary();  // UUID for security
    $table->foreignId('author_id')->constrained('employees');
    $table->foreignId('department_id')->constrained();
    
    $table->string('document_number', 50)->unique();
    $table->string('title');
    $table->text('description')->nullable();
    $table->string('file_path');
    
    $table->enum('classification', ['public', 'internal', 'confidential', 'secret']);
    $table->enum('status', ['draft', 'review', 'approved', 'archived'])->default('draft');
    
    $table->boolean('is_locked')->default(false);
    $table->integer('version')->default(1);
    
    $table->jsonb('metadata')->nullable();
    
    $table->timestamp('approved_at')->nullable();
    $table->foreignId('approved_by')->nullable()->constrained('employees');
    
    $table->timestamps();
    $table->softDeletes();
    
    $table->index(['department_id', 'classification', 'status']);
    $table->index('document_number');
    $table->fullText('title');
});

// Table: document_approvals (audit trail)
Schema::create('document_approvals', function (Blueprint $table) {
    $table->id();
    $table->foreignUuid('document_id')->constrained();
    $table->foreignId('employee_id')->constrained();
    
    $table->enum('action', ['submitted', 'approved', 'rejected', 'revised']);
    $table->text('comments')->nullable();
    $table->jsonb('changes')->nullable();
    
    $table->timestamp('created_at');
    
    $table->index('document_id');
    $table->index('employee_id');
});
```

### Example 3: E-commerce System

```php
// Table: products
Schema::create('products', function (Blueprint $table) {
    $table->id();
    $table->string('sku', 50)->unique();
    $table->string('name');
    $table->string('slug')->unique();
    $table->text('description')->nullable();
    
    $table->decimal('price', 10, 2);
    $table->decimal('sale_price', 10, 2)->nullable();
    
    $table->integer('stock_quantity')->default(0);
    $table->boolean('is_available')->default(true);
    
    $table->jsonb('specifications')->nullable();
    
    $table->timestamps();
    $table->softDeletes();
    
    $table->index('sku');
    $table->index('is_available');
    $table->fullText(['name', 'description']);
});

// Table: orders
Schema::create('orders', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained();
    
    $table->string('order_number', 20)->unique();
    $table->enum('status', ['pending', 'processing', 'shipped', 'delivered', 'cancelled']);
    
    $table->decimal('subtotal', 10, 2);
    $table->decimal('tax', 10, 2)->default(0);
    $table->decimal('shipping', 10, 2)->default(0);
    $table->decimal('total', 10, 2);
    
    $table->jsonb('shipping_address');
    $table->jsonb('billing_address');
    
    $table->timestamp('paid_at')->nullable();
    $table->timestamp('shipped_at')->nullable();
    $table->timestamp('delivered_at')->nullable();
    
    $table->timestamps();
    
    $table->index('user_id');
    $table->index('order_number');
    $table->index(['status', 'created_at']);
});

// Table: order_items
Schema::create('order_items', function (Blueprint $table) {
    $table->id();
    $table->foreignId('order_id')->constrained()->onDelete('cascade');
    $table->foreignId('product_id')->constrained();
    
    $table->integer('quantity');
    $table->decimal('price', 10, 2);  // Snapshot price at time of order
    $table->decimal('total', 10, 2);
    
    $table->jsonb('product_snapshot')->nullable();  // Product details at time of order
    
    $table->timestamps();
    
    $table->index('order_id');
    $table->index('product_id');
});
```

---

## Migration Best Practices

### Naming Conventions

```php
// ✅ CORRECT - Descriptive migration names
2024_01_15_100000_create_users_table.php
2024_01_15_100001_create_departments_table.php
2024_01_15_100002_create_employees_table.php
2024_01_15_110000_add_clearance_level_to_employees_table.php
2024_01_15_120000_create_employee_project_pivot_table.php

// ❌ WRONG - Vague names
2024_01_15_100000_users.php
2024_01_15_100001_update_employees.php
```

### Always Define Down Method

```php
public function up(): void
{
    Schema::create('documents', function (Blueprint $table) {
        // Table definition
    });
}

// ✅ CORRECT - Rollback capability
public function down(): void
{
    Schema::dropIfExists('documents');
}
```

### Foreign Keys in Correct Order

```php
// ✅ CORRECT - Parent tables first
// 1. Create departments table (parent)
Schema::create('departments', function (Blueprint $table) {
    $table->id();
});

// 2. Create employees table (child)
Schema::create('employees', function (Blueprint $table) {
    $table->id();
    $table->foreignId('department_id')->constrained();  // References departments
});

// ❌ WRONG - Child before parent causes error
// Trying to reference departments table that doesn't exist yet
```

---

## Common Pitfalls and Solutions

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Using users_id | Incorrect foreign key name | Use `user_id` (singular) |
| No indexes on foreign keys | Slow JOIN queries | Add `$table->index('user_id')` |
| Wrong pivot table name | Inconsistent naming | Use alphabetical order: `employee_project` |
| Missing onDelete constraint | Orphaned records | Always specify `->onDelete('cascade')` or `restrict` |
| No soft deletes for audit | Permanent data loss | Add `$table->softDeletes()` for important tables |
| Missing composite indexes | Slow multi-column queries | Add composite index for common WHERE combinations |
| Using JSON instead of JSONB | Slower PostgreSQL queries | Use `$table->jsonb()` for PostgreSQL |
| Forgetting unique constraints | Duplicate data | Add `->unique()` for unique columns |
| No default values | NULL handling issues | Specify `->default()` when appropriate |
| Migrations in wrong order | Foreign key errors | Create parent tables before child tables |

---

## Quick Reference Cheatsheet

### Common Column Types

```php
$table->id();                           // Auto-increment BigInt
$table->uuid('id')->primary();          // UUID primary key
$table->string('name', 255);            // VARCHAR
$table->text('content');                // TEXT
$table->boolean('is_active');           // BOOLEAN
$table->integer('count');               // INTEGER
$table->decimal('price', 10, 2);        // DECIMAL
$table->date('hired_at');               // DATE
$table->timestamp('published_at');      // TIMESTAMP
$table->jsonb('metadata');              // JSONB (PostgreSQL)
$table->enum('status', ['a', 'b']);     // ENUM
```

### Common Modifiers

```php
->nullable()                            // Allow NULL
->default('value')                      // Default value
->unique()                              // Unique constraint
->unsigned()                            // Unsigned number
->comment('Description')                // Column comment
->after('column')                       // Position after column
```

### Common Indexes

```php
$table->index('column');                // Regular index
$table->unique('column');               // Unique index
$table->fullText('column');             // Full-text index
$table->index(['col1', 'col2']);        // Composite index
```

### Foreign Keys

```php
$table->foreignId('user_id')
    ->constrained()                     // References users.id
    ->onUpdate('cascade')               // Update on parent change
    ->onDelete('cascade');              // Delete on parent delete
    
// Specify table explicitly
$table->foreignId('author_id')
    ->constrained('users')
    ->onDelete('restrict');
```

---

## Conclusion

Following these database design patterns ensures:
- ✅ Consistent naming across projects
- ✅ Proper indexing for performance
- ✅ Data integrity with foreign keys
- ✅ Audit trails and compliance
- ✅ Scalable architecture
- ✅ Easy maintenance and refactoring

Always prioritize:
1. **Data Integrity** - Use foreign keys and constraints
2. **Performance** - Add strategic indexes
3. **Audit Trails** - Track important changes
4. **Consistency** - Follow naming conventions
5. **Documentation** - Comment complex structures

Refer to this skill when designing new database schemas to ensure best practices are followed from the start.