#!/usr/bin/env bash
# Script enxuto: repete `terraform apply -auto-approve` até sucesso.
# Ctrl+C interrompe.
# Variáveis de ambiente opcionais:
#   DELAY_SECONDS (default 30)
#   EXTRA_ARGS    (ex.: -var-file=terraform.tfvars)
# Reexecução automática se não estiver em bash.
[ -z "$BASH_VERSION" ] && { echo "Este script requer bash. Reexecutando..."; exec bash "$0" "$@"; }

# Ativa pipefail apenas se suportado.
if set -o | grep -q pipefail 2>/dev/null; then
  set -o pipefail
fi

DELAY_SECONDS="${DELAY_SECONDS:-30}"
EXTRA_ARGS="${EXTRA_ARGS:-}" # string livre

command -v terraform >/dev/null 2>&1 || { echo 'terraform não encontrado no PATH' >&2; exit 127; }

attempt=0

# Marca início para medir tempo total
START_TIME=$(date +%s)

# Função simples para formatar segundos em HH:MM:SS
format_elapsed() {
  local s=$1
  local h=$(( s / 3600 ))
  local m=$(( (s % 3600) / 60 ))
  local sec=$(( s % 60 ))
  printf '%02dh:%02dm:%02ds' "$h" "$m" "$sec"
}

trap 'END_TIME=$(date +%s); ELAPSED=$(( END_TIME - START_TIME )); echo "Interrompido pelo usuário. Tempo decorrido: $(format_elapsed $ELAPSED) (~${ELAPSED}s)."; exit 130' INT

while true; do
  attempt=$(( attempt + 1 ))
  echo "[Attempt $attempt] terraform apply -auto-approve $EXTRA_ARGS"
  # shellcheck disable=SC2086
  if terraform apply -auto-approve $EXTRA_ARGS; then
    END_TIME=$(date +%s)
    ELAPSED=$(( END_TIME - START_TIME ))
    echo "Sucesso na tentativa $attempt. Tempo total: $(format_elapsed $ELAPSED) (~${ELAPSED}s)."
    exit 0
  else
    code=$?
    END_TIME=$(date +%s)
    ELAPSED=$(( END_TIME - START_TIME ))
    echo "Falhou (exit code=$code). Tentativa $attempt levou até agora $(format_elapsed $ELAPSED). Nova tentativa em ${DELAY_SECONDS}s..."
    sleep "$DELAY_SECONDS"
  fi
done
