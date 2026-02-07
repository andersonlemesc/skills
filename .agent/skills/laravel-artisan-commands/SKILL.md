---
name: laravel-artisan-commands
description: "Comprehensive Laravel 12.x Artisan commands reference for creating models, controllers, migrations, managing cache, queues, routes, and deployment optimization. Expert agent for executing correct Laravel CLI commands."
---

# Laravel 12.x Artisan Commands Mastery

## Overview

This skill provides a comprehensive reference for all Laravel 12.x Artisan commands with correct syntax, flags, and naming conventions. Use this skill when you need to create files, manage databases, optimize applications, handle queues, or perform any Laravel CLI operations. This is your expert agent for executing Laravel commands correctly.

---

## When to Use This Skill

Use this skill whenever you need to:
- Create Laravel files (models, controllers, migrations, etc.)
- Run database migrations or seeders
- Manage application cache and optimization
- Work with queues and scheduled tasks
- List or cache routes
- Deploy or optimize Laravel applications
- Execute any Artisan command with correct syntax

---

## Command Categories

### 1. File Generation Commands (make:*)

These commands create new files following Laravel conventions.

#### **make:model** - Create Eloquent Model

```bash
# Basic model
php artisan make:model Post

# Model with migration
php artisan make:model Post -m
php artisan make:model Post --migration

# Model with multiple related files
php artisan make:model Post -mfsc
# -m = migration
# -f = factory
# -s = seeder
# -c = controller

# Model with resource controller and form requests
php artisan make:model Post -crR
# -c = controller
# -r = resource controller
# -R = form requests

# Model with API resource controller
php artisan make:model Post --api

# Model with policy
php artisan make:model Post --policy

# Generate EVERYTHING (migration, factory, seeder, policy, controller, requests)
php artisan make:model Post --all
php artisan make:model Post -a

# Pivot model (for many-to-many relationships)
php artisan make:model ProjectUser --pivot
php artisan make:model ProjectUser -p

# Polymorphic pivot model
php artisan make:model Taggable --morph-pivot
```

**Naming Convention for Models:**
- Singular, PascalCase: `User`, `Post`, `BlogPost`
- Table name will be plural snake_case: `users`, `posts`, `blog_posts`

#### **make:controller** - Create Controller

```bash
# Basic controller
php artisan make:controller PostController

# Resource controller (CRUD methods)
php artisan make:controller PostController --resource
php artisan make:controller PostController -r

# API resource controller (no create/edit views)
php artisan make:controller PostController --api

# Controller for existing model
php artisan make:controller PostController --model=Post

# Resource controller with model and form requests
php artisan make:controller PostController --model=Post --requests
php artisan make:controller PostController -m Post -R

# Invokable controller (single action)
php artisan make:controller ShowProfileController --invokable
```

**Naming Convention for Controllers:**
- PascalCase with "Controller" suffix: `PostController`, `UserProfileController`
- Resource controllers: plural nouns (PostsController) or singular with Controller (PostController)

#### **make:migration** - Create Database Migration

```bash
# Create table migration
php artisan make:migration create_posts_table
php artisan make:migration create_posts_table --create=posts

# Modify table migration
php artisan make:migration add_status_to_posts_table
php artisan make:migration add_status_to_posts_table --table=posts

# Migration with custom path
php artisan make:migration create_posts_table --path=database/migrations/posts
```

**Naming Convention for Migrations:**
- snake_case with descriptive action
- Create: `create_[table]_table`
- Modify: `add_[field]_to_[table]_table`, `remove_[field]_from_[table]_table`
- Examples: `create_users_table`, `add_email_verified_at_to_users_table`

#### **make:seeder** - Create Database Seeder

```bash
# Create seeder
php artisan make:seeder UserSeeder
php artisan make:seeder DepartmentSeeder
```

**Naming Convention for Seeders:**
- PascalCase with "Seeder" suffix: `UserSeeder`, `PostSeeder`

#### **make:factory** - Create Model Factory

```bash
# Create factory
php artisan make:factory PostFactory

# Factory for specific model
php artisan make:factory PostFactory --model=Post
```

**Naming Convention for Factories:**
- PascalCase with "Factory" suffix: `UserFactory`, `PostFactory`

#### **make:request** - Create Form Request

```bash
# Create form request
php artisan make:request StorePostRequest
php artisan make:request UpdatePostRequest
```

**Naming Convention for Requests:**
- PascalCase describing action: `StorePostRequest`, `UpdateUserRequest`, `DeleteDocumentRequest`

#### **make:resource** - Create API Resource

```bash
# Single resource
php artisan make:resource UserResource

# Resource collection
php artisan make:resource UserCollection --collection
```

#### **make:policy** - Create Authorization Policy

```bash
# Create policy
php artisan make:policy PostPolicy

# Policy for specific model
php artisan make:policy PostPolicy --model=Post
```

#### **make:middleware** - Create Middleware

```bash
php artisan make:middleware CheckUserRole
php artisan make:middleware EnsureTokenIsValid
```

#### **make:command** - Create Custom Artisan Command

```bash
php artisan make:command SendWeeklyReport
php artisan make:command SendWeeklyReport --command=reports:send-weekly
```

#### **make:job** - Create Queueable Job

```bash
php artisan make:job ProcessPodcast
php artisan make:job SendEmailNotification
```

#### **make:observer** - Create Model Observer

```bash
php artisan make:observer UserObserver
php artisan make:observer UserObserver --model=User
```

#### **make:event** - Create Event

```bash
php artisan make:event UserRegistered
php artisan make:event OrderShipped
```

#### **make:listener** - Create Event Listener

```bash
php artisan make:listener SendWelcomeEmail
php artisan make:listener SendWelcomeEmail --event=UserRegistered
```

#### **make:notification** - Create Notification

```bash
php artisan make:notification InvoicePaid
php artisan make:notification InvoicePaid --markdown
```

#### **make:mail** - Create Mailable

```bash
php artisan make:mail OrderShipped
php artisan make:mail OrderShipped --markdown=emails.orders.shipped
```

#### **make:rule** - Create Validation Rule

```bash
php artisan make:rule ValidGovernmentId
php artisan make:rule Uppercase
```

#### **make:test** - Create Test

```bash
# Feature test (default)
php artisan make:test UserTest

# Unit test
php artisan make:test UserTest --unit

# Pest test
php artisan make:test UserTest --pest
```

#### **make:cast** - Create Custom Cast

```bash
php artisan make:cast Json
php artisan make:cast Money
```

#### **make:scope** - Create Query Scope

```bash
php artisan make:scope ActiveScope
php artisan make:scope DepartmentScope
```

---

### 2. Database Commands

#### **migrate** - Run Migrations

```bash
# Run all pending migrations
php artisan migrate

# Run migrations for specific connection
php artisan migrate --database=pgsql

# Force migrations in production (skips confirmation)
php artisan migrate --force

# Run migrations with seed
php artisan migrate --seed

# Pretend mode (show SQL without executing)
php artisan migrate --pretend

# Run specific migration path
php artisan migrate --path=database/migrations/2024_01_01_create_posts_table.php
```

#### **migrate:rollback** - Rollback Migrations

```bash
# Rollback last batch
php artisan migrate:rollback

# Rollback specific number of batches
php artisan migrate:rollback --step=3

# Rollback specific batch number
php artisan migrate:rollback --batch=2

# Pretend mode
php artisan migrate:rollback --pretend
```

#### **migrate:reset** - Rollback All Migrations

```bash
php artisan migrate:reset
```

#### **migrate:refresh** - Rollback and Re-run Migrations

```bash
# Reset and re-run all migrations
php artisan migrate:refresh

# Refresh with seed
php artisan migrate:refresh --seed

# Refresh specific number of steps
php artisan migrate:refresh --step=5
```

#### **migrate:fresh** - Drop All Tables and Re-run Migrations

```bash
# Drop all tables and re-run migrations
php artisan migrate:fresh

# Fresh with seed
php artisan migrate:fresh --seed

# Specify seeder class
php artisan migrate:fresh --seeder=DatabaseSeeder
```

#### **migrate:status** - Show Migration Status

```bash
php artisan migrate:status
```

#### **db:seed** - Run Database Seeders

```bash
# Run DatabaseSeeder
php artisan db:seed

# Run specific seeder
php artisan db:seed --class=UserSeeder

# Force in production
php artisan db:seed --force
```

#### **db:wipe** - Drop All Tables

```bash
php artisan db:wipe
php artisan db:wipe --database=pgsql
```

---

### 3. Cache and Optimization Commands

#### **Cache Management**

```bash
# Clear application cache
php artisan cache:clear

# Clear specific cache store
php artisan cache:clear --store=redis

# Clear cache tags (Redis/Memcached only)
php artisan cache:forget cache-key
```

#### **Configuration Cache**

```bash
# Cache configuration files (production optimization)
php artisan config:cache

# Clear configuration cache
php artisan config:clear
```

**IMPORTANT:** After running `config:cache`, the `env()` function will only return system environment variables. Always use `env()` exclusively in config files, then access via `config()` in application code.

#### **Route Cache**

```bash
# Cache routes (production optimization - 10-50% faster)
php artisan route:cache

# Clear route cache
php artisan route:clear
```

**Note:** Route caching doesn't work with closure-based routes. All routes must use controller references.

#### **View Cache**

```bash
# Precompile all Blade views
php artisan view:cache

# Clear compiled views
php artisan view:clear
```

#### **Event Cache**

```bash
# Cache auto-discovered events
php artisan event:cache

# Clear event cache
php artisan event:clear
```

#### **Optimize** - All-in-One Optimization

```bash
# Cache config, routes, events, and views in one command
php artisan optimize

# Clear all optimization caches
php artisan optimize:clear
```

**Deployment Best Practice:** Run `php artisan optimize` during deployment for maximum performance.

**Difference Between Commands:**
- `php artisan optimize`: Caches config, routes, events, views (files in /storage/framework)
- `php artisan cache:clear`: Clears application cache driver (Redis, DB, etc.)
- `php artisan optimize:clear`: Removes optimize files AND clears cache driver

---

### 4. Route Commands

```bash
# List all registered routes
php artisan route:list

# Show route middleware
php artisan route:list -v
php artisan route:list --verbose

# Filter by method
php artisan route:list --method=GET

# Filter by URI
php artisan route:list --path=api

# Filter by name
php artisan route:list --name=post

# Hide vendor routes
php artisan route:list --except-vendor

# Show only vendor routes
php artisan route:list --only-vendor

# Reverse sort order
php artisan route:list --reverse
php artisan route:list -r

# Compact output
php artisan route:list --compact
```

---

### 5. Queue Commands

#### **queue:work** - Process Queue Jobs

```bash
# Start queue worker (daemon mode by default)
php artisan queue:work

# Specify connection
php artisan queue:work redis

# Specify queue(s) with priority
php artisan queue:work --queue=high,default,low

# Set maximum memory limit (MB)
php artisan queue:work --memory=512

# Set timeout (seconds)
php artisan queue:work --timeout=60

# Set maximum attempts
php artisan queue:work --tries=3

# Process jobs then exit (for cron or testing)
php artisan queue:work --once

# Stop after N seconds
php artisan queue:work --max-time=3600

# Stop after N jobs
php artisan queue:work --max-jobs=1000

# Sleep duration when no jobs (seconds)
php artisan queue:work --sleep=5

# Delay between jobs (seconds)
php artisan queue:work --delay=5

# Complete command for production
php artisan queue:work redis --queue=high,default --tries=3 --timeout=60 --memory=512
```

#### **queue:listen** - Listen for Queue Jobs

```bash
# Listen mode (restarts Laravel for each job - slower)
php artisan queue:listen

# With options
php artisan queue:listen --queue=high,default --timeout=60 --tries=3
```

**Note:** `queue:work` (daemon mode) is preferred for production as it's much faster than `queue:listen`.

#### **queue:restart** - Restart Queue Workers

```bash
# Signal workers to restart after current job
php artisan queue:restart
```

**CRITICAL for Deployment:** Always run `queue:restart` after deploying new code so workers pick up changes.

#### **queue:retry** - Retry Failed Jobs

```bash
# Retry all failed jobs
php artisan queue:retry all

# Retry specific job by ID
php artisan queue:retry 5

# Retry multiple jobs
php artisan queue:retry 5 10 15
```

#### **queue:failed** - List Failed Jobs

```bash
php artisan queue:failed
```

#### **queue:flush** - Delete All Failed Jobs

```bash
php artisan queue:flush
```

#### **queue:forget** - Delete Specific Failed Job

```bash
php artisan queue:forget 5
```

#### **queue:prune-failed** - Prune Old Failed Jobs

```bash
# Prune failed jobs older than 48 hours
php artisan queue:prune-failed --hours=48
```

#### **queue:monitor** - Monitor Queue Metrics

```bash
php artisan queue:monitor redis:default,redis:high --max=100
```

---

### 6. Schedule Commands

```bash
# Run scheduled tasks (called by cron every minute)
php artisan schedule:run

# Run schedule in verbose mode
php artisan schedule:run --verbose
php artisan schedule:run -v

# List all scheduled tasks
php artisan schedule:list

# Test scheduled task
php artisan schedule:test

# Clear schedule cache/locks
php artisan schedule:clear-cache

# Run scheduler locally for testing
php artisan schedule:work
```

**Cron Entry for Production:**
```bash
* * * * * cd /path-to-your-project && php artisan schedule:run >> /dev/null 2>&1
```

---

### 7. Maintenance and Deployment Commands

```bash
# Put application in maintenance mode
php artisan down

# Maintenance mode with custom message and secret bypass
php artisan down --message="Upgrading Database" --secret="1630542a-246b-4b66-afa1-dd72a4c43515"

# Take application out of maintenance mode
php artisan up

# Show application info
php artisan about

# Show installed packages
php artisan package:discover

# Publish vendor assets/config
php artisan vendor:publish

# Publish specific provider
php artisan vendor:publish --provider="Vendor\Package\ServiceProvider"

# Publish specific tag
php artisan vendor:publish --tag=config
php artisan vendor:publish --tag=migrations
```

---

### 8. Development and Debug Commands

```bash
# Enter Tinker REPL
php artisan tinker

# Serve application locally
php artisan serve
php artisan serve --host=0.0.0.0 --port=8080

# Generate application key
php artisan key:generate

# Create storage symlink
php artisan storage:link

# Publish stubs for customization
php artisan stub:publish
```

---

### 9. Model Pruning

```bash
# Prune prunable models
php artisan model:prune

# Prune specific models
php artisan model:prune --model=LogEntry

# Prune except specific models
php artisan model:prune --except=User,Post

# Pretend mode
php artisan model:prune --pretend
```

---

## Common Command Patterns

### Creating Complete Resource in One Command

```bash
# Create model with everything
php artisan make:model Post -a

# This creates:
# - app/Models/Post.php (model)
# - database/migrations/xxxx_create_posts_table.php (migration)
# - database/factories/PostFactory.php (factory)
# - database/seeders/PostSeeder.php (seeder)
# - app/Http/Controllers/PostController.php (resource controller)
# - app/Policies/PostPolicy.php (policy)
# - app/Http/Requests/StorePostRequest.php (store request)
# - app/Http/Requests/UpdatePostRequest.php (update request)
```

### Create Resource with Common Files

```bash
# Model + Migration + Controller + Resource + Requests
php artisan make:model Post -mcrR

# Model + Migration + Factory + Seeder + Controller
php artisan make:model Post -mfsc
```

---

## Docker Integration

When using Docker/Sail, prefix commands with `sail`:

```bash
# Instead of:
php artisan migrate

# Use:
sail artisan migrate

# Or with docker-compose:
docker-compose exec app php artisan migrate
```

---

## Naming Convention Best Practices

### File and Class Naming

| Type | Convention | Example |
|------|-----------|---------|
| Model | Singular, PascalCase | `User`, `BlogPost`, `OrderItem` |
| Controller | PascalCase + "Controller" | `UserController`, `BlogPostController` |
| Migration (create) | `create_[table]_table` | `create_users_table` |
| Migration (modify) | `add_[field]_to_[table]_table` | `add_status_to_posts_table` |
| Seeder | PascalCase + "Seeder" | `UserSeeder`, `DatabaseSeeder` |
| Factory | PascalCase + "Factory" | `UserFactory`, `PostFactory` |
| Request | Action + Model + "Request" | `StorePostRequest`, `UpdateUserRequest` |
| Resource | Model + "Resource" | `UserResource`, `PostResource` |
| Collection | Model + "Collection" | `UserCollection`, `PostCollection` |
| Policy | Model + "Policy" | `UserPolicy`, `PostPolicy` |
| Job | Descriptive action | `ProcessPodcast`, `SendEmail` |
| Event | Past tense | `UserRegistered`, `OrderShipped` |
| Listener | Descriptive action | `SendWelcomeEmail`, `LogOrderShipment` |
| Middleware | Descriptive | `Authenticate`, `CheckRole` |
| Rule | Descriptive | `Uppercase`, `ValidPhone` |

### Table Naming

- Plural, snake_case: `users`, `blog_posts`, `order_items`
- Pivot tables: alphabetical singular: `post_tag`, `project_user`

---

## Command Flags Reference

### Common Flags Across Commands

| Flag | Short | Description |
|------|-------|-------------|
| `--help` | `-h` | Display help for command |
| `--quiet` | `-q` | Do not output any message |
| `--verbose` | `-v`, `-vv`, `-vvv` | Increase verbosity |
| `--version` | `-V` | Display application version |
| `--no-interaction` | `-n` | Do not ask any interactive question |
| `--env` | | Environment the command should run under |
| `--force` | | Force operation (skip confirmations) |

### make:model Specific Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--all` | `-a` | Generate migration, seeder, factory, policy, controller, and requests |
| `--controller` | `-c` | Create controller |
| `--resource` | `-r` | Resource controller |
| `--api` | | API resource controller |
| `--requests` | `-R` | Create form request classes |
| `--migration` | `-m` | Create migration |
| `--factory` | `-f` | Create factory |
| `--seed` | `-s` | Create seeder |
| `--policy` | | Create policy |
| `--pivot` | `-p` | Pivot model |
| `--morph-pivot` | | Polymorphic pivot model |

---

## Deployment Checklist Commands

```bash
# 1. Clear all development caches
php artisan optimize:clear

# 2. Run migrations
php artisan migrate --force

# 3. Optimize for production
php artisan optimize

# Or individually:
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# 4. Restart queue workers
php artisan queue:restart

# 5. Link storage
php artisan storage:link

# 6. Generate key if needed
php artisan key:generate --force
```

---

## Common Pitfalls and Solutions

| Pitfall | Symptom | Solution |
|---------|---------|----------|
| Routes not working after cache | 404 on valid routes | Run `php artisan route:clear` then `php artisan route:cache` |
| Config changes not reflecting | Old config values persist | Run `php artisan config:clear` |
| Views not updating | Old view content displays | Run `php artisan view:clear` |
| Queue workers using old code | New code doesn't execute | Run `php artisan queue:restart` after deployment |
| env() returns null | After `config:cache` | Never use `env()` outside config files; use `config()` |
| Migration already ran | "Table already exists" error | Check `migrations` table or run `migrate:status` |
| Seeder not found | Class not found error | Run `composer dump-autoload` |
| Route cache with closures | Routes not working | Remove closure routes or don't cache |

---

## Help and Discovery

```bash
# List all available commands
php artisan list
php artisan

# Get help for specific command
php artisan help migrate
php artisan migrate --help
php artisan migrate -h

# Search for commands
php artisan list make
php artisan list queue
php artisan list cache
```

---

## Examples for Government/Corporate Applications

### Creating Complete CRUD Resource

```bash
# Create Document model with everything
php artisan make:model Document -a

# This automatically creates:
# - Model: app/Models/Document.php
# - Migration: database/migrations/xxxx_create_documents_table.php
# - Factory: database/factories/DocumentFactory.php
# - Seeder: database/seeders/DocumentSeeder.php
# - Controller: app/Http/Controllers/DocumentController.php (with CRUD methods)
# - Policy: app/Policies/DocumentPolicy.php
# - Requests: app/Http/Requests/StoreDocumentRequest.php, UpdateDocumentRequest.php
```

### Creating Employee Management System

```bash
# Create Employee model with common files
php artisan make:model Employee -mfsc

# Create Department model
php artisan make:model Department -mc

# Create pivot for many-to-many
php artisan make:model EmployeeProject --pivot -m
```

### Database Management

```bash
# Fresh start in development
php artisan migrate:fresh --seed

# Production deployment
php artisan migrate --force

# Check migration status
php artisan migrate:status

# Rollback if needed
php artisan migrate:rollback --step=1
```

### Queue Management for Reports

```bash
# Create job for report generation
php artisan make:job GenerateAuditReport

# Start queue worker
php artisan queue:work --queue=reports,default --tries=3 --timeout=300

# Monitor failed jobs
php artisan queue:failed

# Retry all failed
php artisan queue:retry all
```

---

## Best Practices

### 1. Always Use Correct Flags

```bash
# ✅ GOOD: Use short flags for common operations
php artisan make:model Post -mfsc

# ❌ BAD: Creating files separately (inefficient)
php artisan make:model Post
php artisan make:migration create_posts_table
php artisan make:factory PostFactory
php artisan make:seeder PostSeeder
```

### 2. Follow Naming Conventions

```bash
# ✅ GOOD: Laravel understands these conventions
php artisan make:model BlogPost           # Creates BlogPost model
php artisan make:migration create_blog_posts_table  # Laravel auto-fills table

# ❌ BAD: Fighting conventions
php artisan make:model blog_post          # Wrong case
php artisan make:migration blog_posts     # Unclear intent
```

### 3. Optimize for Production

```bash
# ✅ GOOD: One-command optimization
php artisan optimize

# ❌ BAD: Forgetting to optimize
# (Slower application performance)
```

### 4. Clear Caches During Development

```bash
# ✅ GOOD: Clear when making config changes
php artisan optimize:clear

# ❌ BAD: Debugging with stale cache
# (Wasted time debugging cached values)
```

### 5. Restart Queue Workers After Deployment

```bash
# ✅ GOOD: Workers pick up new code
php artisan queue:restart

# ❌ BAD: Forgetting to restart
# (Workers continue using old code)
```

---

## Quick Reference Card

### Most Used Commands

```bash
# File Generation
php artisan make:model Post -a          # Everything
php artisan make:controller PostController -r  # Resource controller
php artisan make:migration create_posts_table  # Migration

# Database
php artisan migrate                     # Run migrations
php artisan migrate:fresh --seed        # Fresh start with data
php artisan db:seed                     # Run seeders

# Cache & Optimization
php artisan optimize                    # Cache everything
php artisan optimize:clear              # Clear everything
php artisan route:list                  # List routes

# Queue
php artisan queue:work                  # Start worker
php artisan queue:restart               # Restart workers

# Development
php artisan serve                       # Local server
php artisan tinker                      # REPL
php artisan make:test PostTest          # Create test
```

---

## Pro Tips

1. **Interactive Prompts**: Running `php artisan make:model` without a name shows interactive prompts in Laravel 12.x

2. **Force Flag**: Use `--force` in production scripts to skip confirmations:
   ```bash
   php artisan migrate --force
   php artisan key:generate --force
   ```

3. **Pretend Mode**: Test commands without executing:
   ```bash
   php artisan migrate --pretend
   php artisan migrate:rollback --pretend
   ```

4. **Composer Autoload**: After creating seeders or any classes, run:
   ```bash
   composer dump-autoload
   ```

5. **Environment-Specific Commands**: Specify environment:
   ```bash
   php artisan migrate --env=staging
   ```

---

## Integration with Supervisor (Production)

Example Supervisor configuration for queue workers:

```ini
[program:laravel-queue]
process_name=%(program_name)s_%(process_num)02d
command=php /path/to/artisan queue:work redis --queue=high,default --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=4
redirect_stderr=true
stdout_logfile=/path/to/storage/logs/queue.log
stopwaitsecs=3600
```

---

## Conclusion

Master these Artisan commands to work efficiently with Laravel 12.x. Always:
- Follow naming conventions
- Use appropriate flags
- Optimize for production
- Clear caches when needed
- Restart queue workers after deployment
- Test migrations with `--pretend` first

Refer to this skill whenever executing Laravel CLI operations to ensure correct syntax and approach.