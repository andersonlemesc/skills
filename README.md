# AI Skills & Rules Collection

Colecao de **skills**, **rules** e **workflows** para potencializar o desenvolvimento com assistentes de IA.

Compativel com **Claude Code**, **Cursor** e **Antigravity**.

---

## Instalacao Rapida

Um comando para instalar no seu projeto:

```bash
# Instalar tudo (Claude Code + Cursor + Agent)
curl -fsSL https://raw.githubusercontent.com/andersonlemesc/skills/main/bin/install.sh | bash

# Apenas Claude Code
curl -fsSL https://raw.githubusercontent.com/andersonlemesc/skills/main/bin/install.sh | bash -s -- --claude

# Apenas Cursor
curl -fsSL https://raw.githubusercontent.com/andersonlemesc/skills/main/bin/install.sh | bash -s -- --cursor

# Apenas Agent/Antigravity
curl -fsSL https://raw.githubusercontent.com/andersonlemesc/skills/main/bin/install.sh | bash -s -- --agent
```

### Instalar em projeto especifico

```bash
# Apontar para o diretorio do projeto
curl -fsSL https://raw.githubusercontent.com/andersonlemesc/skills/main/bin/install.sh | bash -s -- --all --path /caminho/do/projeto

# Instalar globalmente no HOME (~/.claude, ~/.cursor, ~/.agent)
curl -fsSL https://raw.githubusercontent.com/andersonlemesc/skills/main/bin/install.sh | bash -s -- --all --global
```

### Atualizar

Basta rodar o mesmo comando novamente. O script substitui as skills existentes pela versao mais recente.

---

## Conteudo

| Categoria | Quantidade | Diretorio |
|---|---|---|
| Claude Code Skills | 52 | `.claude/skills/` |
| Claude Code Rules | 6 | `.claude/rules/` |
| Cursor Skills | 52 | `.cursor/skills/` |
| Cursor Rules | 6 | `.cursor/rules/` |
| Agent Skills | 50 | `.agent/skills/` |
| Agent Workflows | 11 | `.agent/workflows/` |
| Agent Agents | 20 | `.agent/agents/` |
| Agent Scripts | 4 | `.agent/scripts/` |

**Total: 643 arquivos**

---

## Skills Disponiveis

### Desenvolvimento Web
- `laravel-best-practices` - Laravel 12.x boas praticas
- `laravel-artisan-commands` - Comandos Artisan
- `laravel-eloquent-database` - Eloquent ORM e otimizacao
- `laravel-database-design-patterns` - Padroes de schema PostgreSQL
- `developing-with-fortify` - Autenticacao com Fortify
- `inertia-react-development` - Inertia.js v2 + React
- `wayfinder-development` - Rotas Laravel no frontend
- `nextjs-react-expert` - React/Next.js performance
- `react-patterns` - Padroes modernos React
- `nodejs-best-practices` - Node.js patterns

### Frontend
- `frontend-design` - Design de interfaces
- `frontend-dev-guidelines` - Standards React + TypeScript
- `tailwind-patterns` - Tailwind CSS v4
- `tailwindcss-development` - Estilos com Tailwind
- `web-design-guidelines` - Auditoria de UI/UX
- `mobile-design` - Design mobile-first

### Backend & API
- `api-patterns` - REST, GraphQL, tRPC
- `api-security-best-practices` - Seguranca de API
- `backend-dev-guidelines` - Node.js + Express + TypeScript
- `database-design` - Schema, indexing, ORM
- `server-management` - Gerenciamento de servidores

### Qualidade & Testes
- `pest-testing` - Pest 4 PHP testing
- `testing-patterns` - Unit, integration, mocking
- `tdd-workflow` - Test-Driven Development
- `test-driven-development` - TDD antes de implementar
- `webapp-testing` - E2E com Playwright
- `systematic-debugging` - Debugging estruturado

### Seguranca
- `vulnerability-scanner` - OWASP 2025, supply chain
- `red-team-tactics` - MITRE ATT&CK
- `code-review-checklist` - Review de seguranca

### DevOps & Tooling
- `deployment-procedures` - Deploy e rollback
- `bash-linux` - Terminal Linux/macOS
- `powershell-windows` - PowerShell Windows
- `mcp-builder` - Model Context Protocol servers

### Linguagens
- `typescript-expert` - TypeScript avancado
- `rust-pro` - Rust 1.75+ producao
- `python-patterns` - Python patterns
- `clean-code` - Standards pragmaticos

### Produtividade
- `architecture` - Decisoes arquiteturais
- `plan-writing` - Planejamento de tarefas
- `brainstorming` - Ideacao estruturada
- `behavioral-modes` - Modos operacionais da IA
- `parallel-agents` - Orquestracao multi-agente
- `intelligent-routing` - Roteamento automatico de agentes
- `app-builder` - Orquestrador de aplicacoes

### SEO & Marketing
- `seo-fundamentals` - SEO e Core Web Vitals
- `geo-fundamentals` - GEO para buscas com IA

### Outros
- `documentation-templates` - Templates de documentacao
- `i18n-localization` - Internacionalizacao
- `performance-profiling` - Profiling e otimizacao
- `game-development` - Desenvolvimento de jogos
- `lint-and-validate` - Linting e validacao

---

## Rules Disponiveis

| Rule | Descricao |
|---|---|
| `database-transactions` | Transacoes em operacoes multi-tabela |
| `error-handling` | Try-catch com logs detalhados |
| `carbon-timezone` | Timezone America/Sao_Paulo |
| `laravel-inertia-patterns` | Padroes Laravel 12 + Inertia + React |
| `git-workflow` | Gitflow, commits limpos |
| `laravel-boost` | Otimizacoes gerais Laravel |

---

## Metodos Alternativos de Instalacao

### Git Submodule

Adiciona como sub-repositorio. Bom para projetos em equipe.

```bash
# Adicionar submodule
git submodule add https://github.com/andersonlemesc/skills.git .ai-skills

# Criar diretorios e symlinks
mkdir -p .claude .cursor
ln -s ../.ai-skills/.claude/skills .claude/skills
ln -s ../.ai-skills/.claude/rules .claude/rules
ln -s ../.ai-skills/.cursor/skills .cursor/skills
ln -s ../.ai-skills/.cursor/rules .cursor/rules
ln -s .ai-skills/.agent .agent
```

**Atualizar:**
```bash
cd .ai-skills && git pull origin main && cd ..
git add .ai-skills && git commit -m "chore: update ai-skills"
```

**Clonar projeto com submodule:**
```bash
git clone --recurse-submodules https://github.com/SEU_USUARIO/meu-projeto.git
```

### Git Clone Direto

Para uso rapido sem vincular ao projeto:

```bash
# Clonar e copiar manualmente
git clone --depth 1 https://github.com/andersonlemesc/skills.git /tmp/skills

# Copiar o que precisa
mkdir -p .claude && cp -r /tmp/skills/.claude/skills .claude/
mkdir -p .cursor && cp -r /tmp/skills/.cursor/skills .cursor/

rm -rf /tmp/skills
```

---

## Comparacao dos Metodos

| | Script (curl) | Submodule | Clone direto |
|---|---|---|---|
| **Facilidade** | Um comando | Media | Manual |
| **Atualizacao** | Rodar novamente | `git pull` | Rodar novamente |
| **Ideal para** | Uso pessoal | Equipes | Uso pontual |
| **Compromete projeto?** | Nao | Nao | Nao |

---

## Estrutura do Repositorio

```
.
├── bin/
│   └── install.sh               # Script de instalacao
│
├── .claude/                      # Claude Code
│   ├── skills/                   # 52 skills
│   ├── rules/                    # 6 rules
│   │   ├── core/
│   │   │   ├── database-transactions.mdc
│   │   │   ├── error-handling.mdc
│   │   │   └── carbon-timezone.mdc
│   │   ├── framework/
│   │   │   └── laravel-inertia-patterns.mdc
│   │   └── workflow/
│   │       └── git-workflow.mdc
│   └── mcp.json
│
├── .cursor/                      # Cursor IDE
│   ├── skills/                   # 52 skills
│   ├── rules/                    # 6 rules
│   └── mcp.json
│
├── .agent/                       # Antigravity / Agent
│   ├── skills/                   # 50 skills
│   ├── workflows/                # 11 workflows
│   ├── agents/                   # 20 agent personas
│   ├── rules/
│   ├── scripts/                  # 4 utility scripts
│   └── ARCHITECTURE.md
│
└── README.md
```

---

## .gitignore do Seu Projeto

Se nao quiser versionar as skills no projeto alvo:

```gitignore
# AI Skills (instalados via script)
.claude/skills/
.claude/rules/
.cursor/skills/
.cursor/rules/
.agent/
```

---

## Contribuindo

1. Fork este repositorio
2. Crie uma branch (`git checkout -b feature/nova-skill`)
3. Adicione sua skill na pasta correta (`.claude/skills/`, `.cursor/skills/`, `.agent/skills/`)
4. Commit (`git commit -m "feat: add nova-skill"`)
5. Push e abra um Pull Request

---

## Licenca

MIT
