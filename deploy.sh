#!/usr/bin/env bash
# Despliega la página en el VPS (EasyPanel, servicio isilnetflix/demo).
# Uso (desde Git Bash, en la carpeta del proyecto):
#   ./deploy.sh "mensaje del commit"
#
# La URL del Deploy Webhook de EasyPanel se lee de:
#   1) la variable de entorno EASYPANEL_WEBHOOK, o
#   2) el archivo .deploy-webhook (no se sube a GitHub, está en .gitignore)
set -euo pipefail

BRANCH="main"
MSG="${1:-Actualizo página}"

WEBHOOK="${EASYPANEL_WEBHOOK:-}"
if [ -z "$WEBHOOK" ] && [ -f .deploy-webhook ]; then
  WEBHOOK="$(tr -d '[:space:]' < .deploy-webhook)"
fi
if [ -z "$WEBHOOK" ]; then
  echo "ERROR: falta la URL del Deploy Webhook."
  echo "Cópiala de EasyPanel > isilnetflix > demo > Deployments y guárdala en .deploy-webhook"
  exit 1
fi

echo "==> 1/2 Subiendo cambios a GitHub"
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "$MSG"
else
  echo "    No hay cambios locales nuevos."
fi
git pull --rebase origin "$BRANCH"
git push origin "$BRANCH"

echo "==> 2/2 Pidiendo a EasyPanel que despliegue"
curl -fsS "$WEBHOOK" && echo
echo "==> Listo. Sigue el progreso en EasyPanel > Deployments."
