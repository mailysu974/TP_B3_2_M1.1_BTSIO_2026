#!/usr/bin/env bash
# Contrôles sans déploiement. Prérequis : Bash, Python 3 et Node.js.
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$ROOT_DIR"
bash -n setup.sh gestion_lab1.sh scripts/check-project.sh
python3 - <<'PY'
import ast
from pathlib import Path
ast.parse(Path('harvester/harvester.py').read_text())
for name in ('README.md', 'phishing-page/index.html', 'ettercap/etter.dns.snippet',
             'docs/TP-3.2-identite-numerique-kali.md', 'docs/workflow-maintenance.md'):
    assert Path(name).is_file(), f'Fichier absent : {name}'
print('Syntaxe Bash/Python et fichiers requis : OK')
PY
node scripts/check-emoji.cjs
