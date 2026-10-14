#!/usr/bin/env bash
# Instala as skills deste repositório no diretório de skills de um agente.
#
# Uso:
#   ./install.sh [--link] [--integration <agente>[,<agente>...]]
#
#   --link                  cria symlinks em vez de copiar (alterações no repo valem na hora)
#   --integration <agente>  instala no diretório conhecido do agente (padrão: agents)
#
# Agentes conhecidos:
#   agents    ~/.agents/skills
#   claude    ~/.claude/skills
#   codex     ~/.codex/skills
#   gemini    ~/.gemini/skills
#   opencode  ~/.config/opencode/skills
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="copy"
INTEGRATIONS="agents"

usage() {
  sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

skills_dir_for() {
  case "$1" in
    agents)   echo "${HOME}/.agents/skills" ;;
    claude)   echo "${HOME}/.claude/skills" ;;
    codex)    echo "${HOME}/.codex/skills" ;;
    gemini)   echo "${HOME}/.gemini/skills" ;;
    opencode) echo "${HOME}/.config/opencode/skills" ;;
    *) return 1 ;;
  esac
}

while [ $# -gt 0 ]; do
  case "$1" in
    --link) MODE="link" ;;
    --integration)
      [ $# -ge 2 ] || { echo "Erro: --integration precisa de um valor." >&2; exit 1; }
      INTEGRATIONS="$2"
      shift
      ;;
    --integration=*) INTEGRATIONS="${1#*=}" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Erro: parâmetro desconhecido: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

# Valida todos os agentes antes de instalar qualquer coisa
IFS=',' read -ra AGENTS <<< "$INTEGRATIONS"
for agent in "${AGENTS[@]}"; do
  if ! skills_dir_for "$agent" > /dev/null; then
    echo "Erro: agente desconhecido: ${agent}" >&2
    echo "Agentes conhecidos: agents, claude, codex, gemini, opencode" >&2
    exit 1
  fi
done

for agent in "${AGENTS[@]}"; do
  dest_dir="$(skills_dir_for "$agent")"
  mkdir -p "$dest_dir"
  echo "[${agent}] ${dest_dir}"

  count=0
  for skill_dir in "$SRC_DIR"/*/; do
    [ -f "${skill_dir}SKILL.md" ] || continue
    name="$(basename "$skill_dir")"
    target="${dest_dir}/${name}"

    rm -rf "$target"
    if [ "$MODE" = "link" ]; then
      ln -s "${skill_dir%/}" "$target"
    else
      cp -r "${skill_dir%/}" "$target"
      # Remove metadados do Windows (WSL) copiados junto
      find "$target" -name '*:Zone.Identifier' -delete
    fi

    echo "  ✓ ${name}"
    count=$((count + 1))
  done

  echo "  ${count} skills instaladas (${MODE})."
done
