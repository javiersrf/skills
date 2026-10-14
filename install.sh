#!/usr/bin/env bash
# Instala as skills deste repositório em ~/.agents/skills/.
#
# Uso:
#   ./install.sh          copia as skills (sobrescreve versões anteriores)
#   ./install.sh --link   cria symlinks, para que alterações no repo reflitam na hora
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${HOME}/.agents/skills"
MODE="copy"

case "${1:-}" in
  --link) MODE="link" ;;
  "") ;;
  *) echo "Uso: $0 [--link]" >&2; exit 1 ;;
esac

mkdir -p "$DEST_DIR"

count=0
for skill_dir in "$SRC_DIR"/*/; do
  [ -f "${skill_dir}SKILL.md" ] || continue
  name="$(basename "$skill_dir")"
  target="${DEST_DIR}/${name}"

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

echo "${count} skills instaladas em ${DEST_DIR} (${MODE})."
