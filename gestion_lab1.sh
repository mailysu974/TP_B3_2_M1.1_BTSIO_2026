#!/usr/bin/env bash
# Lance le script CERTA depuis son propre répertoire.
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="${CERTA_LAB_DIR:-$ROOT_DIR/lab1}"
usage() {
    printf '%s\n' 'Usage : bash gestion_lab1.sh {-c|-l|-s|-d|--help}' \
        'Prérequis : dépôt CERTA lab1 présent dans ./lab1 ou CERTA_LAB_DIR.' \
        '-c : créer ; -l : lancer ; -s : arrêter ; -d : supprimer le laboratoire.'
}
if [[ $# -eq 1 && $1 == --help ]]; then usage; exit 0; fi
if [[ $# -ne 1 ]]; then usage >&2; exit 2; fi
case "$1" in -c|-l|-s|-d) ;; *) usage >&2; exit 2 ;; esac
if [[ ! -f "$LAB_DIR/gestion_lab1.sh" ]]; then
    printf '%s\n' "Script CERTA absent : $LAB_DIR/gestion_lab1.sh" \
        'Récupérer le dépôt officiel depuis la racine de ce projet :' \
        'git clone https://forge.apps.education.fr/reseau-certa/bts-sio/labos-kali-docker/lab1.git lab1' \
        'Ou définir CERTA_LAB_DIR vers une copie existante du lab1.' >&2
    exit 1
fi
if [[ "$LAB_DIR/gestion_lab1.sh" -ef "${BASH_SOURCE[0]}" ]]; then
    printf '%s\n' 'CERTA_LAB_DIR doit désigner le laboratoire officiel, pas ce projet.' >&2
    exit 1
fi
cd -- "$LAB_DIR"
exec bash ./gestion_lab1.sh "$1"
