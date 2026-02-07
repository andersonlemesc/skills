# AI Skills & Rules Collection

Colecao de **skills**, **rules** e **workflows** para potencializar o desenvolvimento com assistentes de IA.

Compativel com **Claude Code**, **Cursor** e **Antigravity**.

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

## Como Usar em Seus Projetos

Existem 3 formas de trazer estas skills para dentro dos seus projetos sem comprometer o codigo existente.

### Opcao 1: Git Submodule (Recomendado)

O submodule adiciona este repositorio como uma dependencia dentro do seu projeto. Ele fica isolado em sua propria pasta e nao mistura com seu codigo.

```bash
# Dentro do seu projeto, adicionar como submodule
git submodule add https://github.com/SEU_USUARIO/ai-skills.git .ai-skills

# Criar symlinks para as pastas que cada ferramenta espera
# Para Claude Code
ln -s .ai-skills/.claude/skills .claude/skills
ln -s .ai-skills/.claude/rules .claude/rules

# Para Cursor
ln -s .ai-skills/.cursor/skills .cursor/skills
ln -s .ai-skills/.cursor/rules .cursor/rules

# Para Antigravity/Agent
ln -s .ai-skills/.agent .agent
```

**Atualizar skills no futuro:**

```bash
cd .ai-skills
git pull origin main
cd ..
git add .ai-skills
git commit -m "chore: update ai-skills submodule"
```

**Quando alguem clonar seu projeto:**

```bash
git clone --recurse-submodules https://github.com/SEU_USUARIO/meu-projeto.git

# Ou se ja clonou sem submodules:
git submodule init
git submodule update
```

**Remover se nao quiser mais:**

```bash
git submodule deinit .ai-skills
git rm .ai-skills
rm -rf .git/modules/.ai-skills
```

---

### Opcao 2: Script de Instalacao

Um script que clona o repositorio e copia apenas o necessario para seu projeto.

Salve o script `install-skills.sh` na raiz do seu projeto:

```bash
#!/bin/bash
# install-skills.sh - Instala AI skills no projeto atual
# Uso: ./install-skills.sh [claude|cursor|agent|all]

set -e

REPO_URL="https://github.com/SEU_USUARIO/ai-skills.git"
TEMP_DIR=$(mktemp -d)
TARGET=${1:-all}

echo "Baixando skills..."
git clone --depth 1 "$REPO_URL" "$TEMP_DIR"

install_claude() {
    echo "Instalando Claude Code skills e rules..."
    mkdir -p .claude
    cp -r "$TEMP_DIR/.claude/skills" .claude/
    cp -r "$TEMP_DIR/.claude/rules" .claude/
    echo "  Claude Code: OK"
}

install_cursor() {
    echo "Instalando Cursor skills e rules..."
    mkdir -p .cursor
    cp -r "$TEMP_DIR/.cursor/skills" .cursor/
    cp -r "$TEMP_DIR/.cursor/rules" .cursor/
    echo "  Cursor: OK"
}

install_agent() {
    echo "Instalando Agent skills, workflows e agents..."
    cp -r "$TEMP_DIR/.agent" .
    echo "  Agent: OK"
}

case "$TARGET" in
    claude) install_claude ;;
    cursor) install_cursor ;;
    agent)  install_agent ;;
    all)
        install_claude
        install_cursor
        install_agent
        ;;
    *)
        echo "Uso: $0 [claude|cursor|agent|all]"
        exit 1
        ;;
esac

rm -rf "$TEMP_DIR"
echo "Instalacao concluida!"
```

```bash
# Dar permissao e executar
chmod +x install-skills.sh

# Instalar tudo
./install-skills.sh all

# Ou apenas para uma ferramenta
./install-skills.sh claude
./install-skills.sh cursor
./install-skills.sh agent
```

---

### Opcao 3: Git Sparse Checkout (Clonar apenas pastas especificas)

Util quando voce quer apenas uma parte do repositorio.

```bash
# Clonar sem baixar arquivos
git clone --no-checkout --filter=blob:none https://github.com/SEU_USUARIO/ai-skills.git .ai-skills
cd .ai-skills

# Configurar sparse checkout
git sparse-checkout init --cone

# Baixar apenas Claude Code skills
git sparse-checkout set .claude/skills .claude/rules

# Ou apenas Cursor
git sparse-checkout set .cursor/skills .cursor/rules

# Ou apenas Agent
git sparse-checkout set .agent

# Baixar os arquivos
git checkout main
```

---

## Comparacao dos Metodos

| | Submodule | Script | Sparse Checkout |
|---|---|---|---|
| **Atualizacao** | `git pull` no submodule | Rodar script novamente | `git pull` |
| **Rastreamento** | Versao fixada no commit | Sem rastreamento | Branch tracking |
| **Facilidade** | Media | Facil | Media |
| **Ideal para** | Projetos em equipe | Uso pessoal rapido | Baixar parcial |
| **Compromete projeto?** | Nao | Nao | Nao |

---

## Estrutura do Repositorio

```
.
├── .claude/                  # Claude Code
│   ├── skills/               # 52 skills
│   │   ├── laravel-best-practices/
│   │   ├── react-patterns/
│   │   ├── pest-testing/
│   │   └── ...
│   ├── rules/                # 6 rules
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
├── .cursor/                  # Cursor IDE
│   ├── skills/               # 52 skills
│   ├── rules/                # 6 rules
│   └── mcp.json
│
├── .agent/                   # Antigravity / Agent
│   ├── skills/               # 50 skills
│   ├── workflows/            # 11 workflows
│   ├── agents/               # 20 agent personas
│   ├── rules/                # Rules
│   ├── scripts/              # 4 utility scripts
│   └── ARCHITECTURE.md
│
└── README.md
```

---

## Adicionando ao .gitignore do Seu Projeto

Se usar o metodo de script (Opcao 2), adicione ao `.gitignore` do seu projeto para nao commitar as skills junto:

```gitignore
# AI Skills (baixados via script)
.claude/skills/
.claude/rules/
.cursor/skills/
.cursor/rules/
.agent/
```

Se quiser que as skills fiquem versionadas junto ao projeto (recomendado para equipes), **nao** adicione ao `.gitignore`.

---

## Dicas

- **Novo projeto?** Use o script (Opcao 2) para copiar rapido
- **Projeto em equipe?** Use submodule (Opcao 1) para todos terem a mesma versao
- **Quer personalizar?** Copie com o script e edite livremente no seu projeto
- **Nao usa todas as ferramentas?** Instale apenas o que precisa (`./install-skills.sh claude`)

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
