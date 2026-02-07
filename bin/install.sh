#!/bin/bash
# install.sh - Instala AI skills no projeto atual ou globalmente
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/andersonlemesc/skills/main/bin/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/andersonlemesc/skills/main/bin/install.sh | bash -s -- --claude
#   curl -fsSL https://raw.githubusercontent.com/andersonlemesc/skills/main/bin/install.sh | bash -s -- --cursor
#   curl -fsSL https://raw.githubusercontent.com/andersonlemesc/skills/main/bin/install.sh | bash -s -- --agent
#   curl -fsSL https://raw.githubusercontent.com/andersonlemesc/skills/main/bin/install.sh | bash -s -- --all
#   curl -fsSL https://raw.githubusercontent.com/andersonlemesc/skills/main/bin/install.sh | bash -s -- --path /caminho/do/projeto

set -e

REPO="https://github.com/andersonlemesc/skills.git"
TEMP_DIR=$(mktemp -d)
TARGET=""
MODE=""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

print_help() {
    echo ""
    echo "andersonlemesc/skills - Instalador de AI Skills"
    echo ""
    echo "Uso:"
    echo "  install.sh [opcao]"
    echo ""
    echo "Opcoes:"
    echo "  --claude     Instala skills e rules para Claude Code"
    echo "  --cursor     Instala skills e rules para Cursor"
    echo "  --agent      Instala skills, workflows e agents para Antigravity"
    echo "  --all        Instala tudo (claude + cursor + agent)"
    echo "  --path <dir> Diretorio do projeto alvo (padrao: diretorio atual)"
    echo "  --global     Instala no HOME do usuario (~/.claude, ~/.cursor, ~/.agent)"
    echo "  --help       Mostra esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  # Instalar tudo no projeto atual"
    echo "  ./install.sh --all"
    echo ""
    echo "  # Instalar apenas Claude Code no projeto"
    echo "  ./install.sh --claude"
    echo ""
    echo "  # Instalar globalmente"
    echo "  ./install.sh --all --global"
    echo ""
    echo "  # Instalar em projeto especifico"
    echo "  ./install.sh --all --path /home/user/meu-projeto"
    echo ""
}

parse_args() {
    local install_claude=false
    local install_cursor=false
    local install_agent=false
    local global=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                print_help
                exit 0
                ;;
            --claude)
                install_claude=true
                shift
                ;;
            --cursor)
                install_cursor=true
                shift
                ;;
            --agent)
                install_agent=true
                shift
                ;;
            --all)
                install_claude=true
                install_cursor=true
                install_agent=true
                shift
                ;;
            --path)
                TARGET="$2"
                shift 2
                ;;
            --global)
                global=true
                shift
                ;;
            *)
                echo -e "${RED}Opcao desconhecida: $1${NC}"
                print_help
                exit 1
                ;;
        esac
    done

    # Padrao: instalar tudo se nenhum foi especificado
    if ! $install_claude && ! $install_cursor && ! $install_agent; then
        install_claude=true
        install_cursor=true
        install_agent=true
    fi

    # Definir diretorio alvo
    if $global; then
        TARGET="$HOME"
    elif [ -z "$TARGET" ]; then
        TARGET="$(pwd)"
    fi

    # Construir MODE
    MODE=""
    $install_claude && MODE="${MODE}claude "
    $install_cursor && MODE="${MODE}cursor "
    $install_agent && MODE="${MODE}agent "
}

install_skills() {
    echo -e "${BLUE}Baixando skills...${NC}"
    git clone --depth 1 --quiet "$REPO" "$TEMP_DIR/repo"

    # Copiar AGENTS.md (universal, funciona em todas as ferramentas)
    if [ -f "$TEMP_DIR/repo/AGENTS.md" ]; then
        cp "$TEMP_DIR/repo/AGENTS.md" "$TARGET/AGENTS.md"
        echo -e "  ${GREEN}AGENTS.md copiado para raiz${NC}"
    fi

    for tool in $MODE; do
        case "$tool" in
            claude)
                echo -e "${YELLOW}Instalando Claude Code...${NC}"
                mkdir -p "$TARGET/.claude"

                # Remover existentes para atualizar
                [ -d "$TARGET/.claude/skills" ] && rm -rf "$TARGET/.claude/skills"
                [ -d "$TARGET/.claude/rules" ] && rm -rf "$TARGET/.claude/rules"

                cp -r "$TEMP_DIR/repo/.claude/skills" "$TARGET/.claude/skills"
                cp -r "$TEMP_DIR/repo/.claude/rules" "$TARGET/.claude/rules"

                local count=$(find "$TARGET/.claude/skills" -maxdepth 1 -type d | tail -n +2 | wc -l)
                echo -e "  ${GREEN}Claude Code: ${count} skills instalados${NC}"
                ;;
            cursor)
                echo -e "${YELLOW}Instalando Cursor...${NC}"
                mkdir -p "$TARGET/.cursor"

                [ -d "$TARGET/.cursor/skills" ] && rm -rf "$TARGET/.cursor/skills"
                [ -d "$TARGET/.cursor/rules" ] && rm -rf "$TARGET/.cursor/rules"

                cp -r "$TEMP_DIR/repo/.cursor/skills" "$TARGET/.cursor/skills"
                cp -r "$TEMP_DIR/repo/.cursor/rules" "$TARGET/.cursor/rules"

                local count=$(find "$TARGET/.cursor/skills" -maxdepth 1 -type d | tail -n +2 | wc -l)
                echo -e "  ${GREEN}Cursor: ${count} skills instalados${NC}"
                ;;
            agent)
                echo -e "${YELLOW}Instalando Agent/Antigravity...${NC}"

                [ -d "$TARGET/.agent" ] && rm -rf "$TARGET/.agent"

                cp -r "$TEMP_DIR/repo/.agent" "$TARGET/.agent"

                local skills=$(find "$TARGET/.agent/skills" -maxdepth 1 -type d | tail -n +2 | wc -l)
                local workflows=$(find "$TARGET/.agent/workflows" -type f 2>/dev/null | wc -l)
                echo -e "  ${GREEN}Agent: ${skills} skills, ${workflows} workflows instalados${NC}"
                ;;
        esac
    done

    echo ""
    echo -e "${GREEN}Instalacao concluida em: ${TARGET}${NC}"
}

# Main
parse_args "$@"
install_skills
