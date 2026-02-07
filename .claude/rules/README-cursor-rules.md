# Cursor Rules - Laravel 12 + React + Inertia.js

Coleção completa de **5 Cursor Rules** para o projeto.

---

## 📁 Estrutura

```
.cursor/rules/
├── database-transactions.mdc      ← Transações de banco de dados
├── error-handling.mdc             ← Tratamento de erros e logs
├── carbon-timezone.mdc            ← Timezone América/São Paulo
├── laravel-inertia-patterns.mdc   ← Padrões Laravel + Inertia
└── git-workflow.mdc               ← Git Workflow e commits ✨ NOVO
```

---

## 🎯 Rules Disponíveis

### 1. **database-transactions.mdc**
**Descrição:** Garante uso de transações de banco de dados em operações que envolvem múltiplas tabelas ou são dependentes entre si.

**Quando se aplica:**
- Controllers
- Services
- Actions
- Repositories
- Jobs

**Exemplo:**
```php
// ✅ CORRETO
DB::transaction(function () {
    $user = User::create($data);
    $user->profile()->create($profileData);
});

// ❌ ERRADO
$user = User::create($data);
$user->profile()->create($profileData);  // Sem transaction!
```

---

### 2. **error-handling.mdc**
**Descrição:** Padrões de tratamento de erros e logging detalhado para facilitar debugging.

**Quando se aplica:**
- Controllers
- Services
- Jobs
- Actions

**Exemplo:**
```php
// ✅ CORRETO
try {
    $result = $service->process($data);
} catch (\Exception $e) {
    Log::error('Failed to process data', [
        'error' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
        'trace' => $e->getTraceAsString(),
        'data' => $data,
    ]);
    
    return back()->with('error', 'Erro ao processar dados.');
}
```

---

### 3. **carbon-timezone.mdc**
**Descrição:** Sempre usa timezone 'America/Sao_Paulo' ao trabalhar com datas.

**Quando se aplica:**
- Qualquer arquivo PHP
- Factories
- Seeders

**Exemplo:**
```php
// ✅ CORRETO
Carbon::now('America/Sao_Paulo');
Carbon::parse($date, 'America/Sao_Paulo');

// ❌ ERRADO
Carbon::now();  // Usa timezone padrão (pode estar errado)
```

---

### 4. **laravel-inertia-patterns.mdc**
**Descrição:** Padrões para Laravel 12 com React e Inertia.js.

**Quando se aplica:**
- Controllers
- Pages (React)
- Components (React)

**Exemplo:**
```php
// ✅ Controller
public function index()
{
    return Inertia::render('Users/Index', [
        'users' => UserResource::collection(User::paginate()),
    ]);
}
```

```tsx
// ✅ React Component
export default function Index({ users }: PageProps<{ users: PaginatedData<User> }>) {
    const { data, delete: destroy } = useForm();
    
    return (
        <AuthenticatedLayout>
            {/* Component content */}
        </AuthenticatedLayout>
    );
}
```

---

### 5. **git-workflow.mdc** ✨ NOVO
**Descrição:** Workflow Git (Gitflow), padrões de commit, e boas práticas para evitar commits prematuros.

**Quando se aplica:**
- Ao trabalhar com Git
- Ao criar branches
- Ao commitar código
- Ao fazer merge

**Principais Regras:**
```bash
# ❌ NUNCA
- Commit direto na main
- Commit direto na develop
- Commit sem testar
- Commit após cada resposta da IA

# ✅ SEMPRE
- Trabalhar em feature/* branches
- Testar antes de commitar
- Usar mensagens claras de commit
- Merge via Pull Request
- Um feature = Um commit limpo
```

**Exemplo de Workflow:**
```bash
# 1. Criar feature branch
git checkout develop
git checkout -b feature/user-permissions

# 2. Desenvolver e testar com IA
# (múltiplas iterações, sem commits)

# 3. Testar tudo
php artisan test
# Testar no browser
# Verificar edge cases

# 4. Commitar apenas quando tudo funciona
git add .
git commit -m "feat: implement user permission system"
git push origin feature/user-permissions

# 5. Criar Pull Request
```

---

## 🚀 Como Usar

### Instalação

1. **Criar estrutura:**
```bash
mkdir -p .cursor/rules
```

2. **Copiar arquivos:**
```bash
# Copiar as 5 rules .mdc para .cursor/rules/
cp database-transactions.mdc .cursor/rules/
cp error-handling.mdc .cursor/rules/
cp carbon-timezone.mdc .cursor/rules/
cp laravel-inertia-patterns.mdc .cursor/rules/
cp git-workflow.mdc .cursor/rules/
```

3. **Reiniciar Cursor** (se necessário)

---

## 💡 Como as Rules Funcionam

### Aplicação Inteligente

Todas as rules usam **"Apply Intelligently"** mode:

```yaml
description: "Detailed description with keywords..."
alwaysApply: false
globs:
  - "path/patterns/**"
```

**O que isso significa:**
- ✅ Agent decide quando aplicar baseado no contexto
- ✅ Mais flexível que aplicação por globs apenas
- ✅ Funciona em diferentes situações
- ✅ Não é invasivo

---

## 📊 Prioridade de Aplicação

As rules são aplicadas quando relevantes ao contexto:

| Rule | Quando se Aplica | Exemplo de Trigger |
|------|------------------|-------------------|
| **database-transactions** | Operações de BD | "create user with profile" |
| **error-handling** | Try-catch necessário | "handle API errors" |
| **carbon-timezone** | Trabalho com datas | "filter by date", "schedule task" |
| **laravel-inertia-patterns** | Controller/React | "create Inertia page" |
| **git-workflow** | Git operations | "commit this", "create branch" |

---

## 🎯 Exemplos de Uso

### Exemplo 1: Criando Feature Completa

```bash
# User pergunta:
"Create a document approval system with:
- Controllers
- Validation
- Tests
- React components"

# Rules aplicadas automaticamente:
✅ database-transactions → Para criar documento + approval
✅ error-handling → Try-catch nos controllers
✅ carbon-timezone → Datas de aprovação
✅ laravel-inertia-patterns → Controllers e React
✅ git-workflow → Não commitar ainda, testar primeiro
```

---

### Exemplo 2: Debugging Issues

```bash
# User: "Fix this timezone issue in document publishing"

# Rules aplicadas:
✅ carbon-timezone → Usa America/Sao_Paulo
✅ error-handling → Logs detalhados
✅ git-workflow → Commit após fix testado
```

---

### Exemplo 3: Commit Workflow

```bash
# User: "I finished implementing user permissions, commit this"

# git-workflow rule se aplica:
Agent: "Before committing, let's verify:
1. Have you tested the feature?
2. Do all tests pass?
3. Did you check manually?

Let's run: php artisan test --filter PermissionTest

After confirming everything works, I'll help with:
git add .
git commit -m 'feat: implement user permission system'
"
```

---

## ⚙️ Customização

### Ajustar Globs

Se quiser que uma rule se aplique em arquivos específicos:

```yaml
globs:
  - "app/Http/Controllers/**/*.php"
  - "app/Services/**/*.php"
  - "resources/js/Pages/**/*.tsx"
```

### Ajustar Descrição

Para melhorar quando a rule é ativada:

```yaml
description: "Add more keywords here to trigger rule in specific contexts"
```

---

## 🔍 Debugging Rules

### Ver quais rules estão ativas

1. Olhar no chat do Cursor
2. Agent menciona rules aplicadas
3. Rules aparecem em contexto

### Forçar uma rule

```bash
# Mencionar explicitamente
"Apply the git-workflow rule to help me commit this"
"Use database-transactions rule for this operation"
```

---

## 📚 Documentação de Cada Rule

### database-transactions.mdc
- **Objetivo:** Prevenir inconsistências de dados
- **Escopo:** Operações multi-tabela
- **Benefício:** Rollback automático em erros

### error-handling.mdc
- **Objetivo:** Logs detalhados para debugging
- **Escopo:** Operações que podem falhar
- **Benefício:** Rastreamento de bugs

### carbon-timezone.mdc
- **Objetivo:** Consistência de datas
- **Escopo:** Qualquer operação com datas
- **Benefício:** Evita bugs de timezone

### laravel-inertia-patterns.mdc
- **Objetivo:** Padrões modernos Laravel + Inertia
- **Escopo:** Controllers e React components
- **Benefício:** Código consistente e performático

### git-workflow.mdc ✨
- **Objetivo:** Git workflow profissional
- **Escopo:** Commits, branches, merges
- **Benefício:** Histórico limpo, menos "fix" commits

---

## 🎓 Best Practices

### 1. **Deixe as Rules Trabalharem**
- Não force aplicação manual
- Agent decide quando aplicar
- Confie no sistema inteligente

### 2. **Combine com Skills**
```bash
# Rules + Skills = Poder máximo
@laravel-best-practices [rules aplicam automaticamente]
@frontend-dev-guidelines [rules aplicam automaticamente]
```

### 3. **Revise Outputs**
- Rules ajudam, mas revise o código
- Teste sempre antes de commitar
- Use as rules como guidelines

---

## 🚨 Troubleshooting

### Rule não está aplicando?

**Possíveis causas:**
1. Descrição não tem keywords certas
2. Contexto não é relevante
3. Globs muito específicos

**Soluções:**
1. Mencione explicitamente a rule
2. Adicione mais keywords na descrição
3. Ajuste os globs

### Conflito entre rules?

- Rules não conflitam
- São aplicadas em conjunto
- Cada uma cuida de seu escopo

---

## ✅ Checklist de Instalação

- [ ] Criar pasta `.cursor/rules/`
- [ ] Copiar 5 arquivos .mdc
- [ ] Reiniciar Cursor (se necessário)
- [ ] Testar com comando Git
- [ ] Testar criando controller
- [ ] Verificar que rules aplicam automaticamente

---

## 📈 Próximos Passos

### Adicionar mais rules?

Considere criar rules para:
- **testing-patterns** - Padrões de teste
- **api-security** - Segurança de API
- **performance** - Otimização de queries
- **docker-workflow** - Docker/Sail patterns

### Estrutura sugerida:
```
.cursor/rules/
├── core/
│   ├── database-transactions.mdc
│   ├── error-handling.mdc
│   └── carbon-timezone.mdc
├── framework/
│   └── laravel-inertia-patterns.mdc
└── workflow/
    └── git-workflow.mdc
```

---

## 🎉 Resumo

**Você agora tem 5 Cursor Rules:**

1. ✅ **database-transactions** - BD seguro
2. ✅ **error-handling** - Logs detalhados
3. ✅ **carbon-timezone** - Datas consistentes
4. ✅ **laravel-inertia-patterns** - Padrões modernos
5. ✅ **git-workflow** - Commits profissionais ✨

**Combinadas com:**
- 4 Skills Laravel customizadas
- 600+ Skills da comunidade
- Cursor AI
- = **Desenvolvimento profissional automatizado** 🚀

---

## 📞 Suporte

**Problemas?**
1. Verifique estrutura de pastas
2. Confira sintaxe YAML no frontmatter
3. Reinicie o Cursor
4. Teste com exemplo específico

**Dúvidas sobre Git Workflow?**
- Veja exemplos no `git-workflow.mdc`
- Rule explica cada cenário
- Previne commits prematuros
- Mantém histórico limpo

---

**Happy Coding! 🎨**

Com estas rules, seu workflow Laravel + React + Inertia.js está no próximo nível! 🚀