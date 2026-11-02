#!/bin/bash
# =============================================================================
# setup.sh — Script de déploiement rapide pour le TP Phishing
# BTS SIO B2 — Module 3.2 — Identité Numérique
#
# Ce script déploie la page de phishing et le harvester sur le conteneur Kali
# Usage : bash setup.sh
# =============================================================================

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd -- "$ROOT_DIR"

KALI_CONTAINER="kali-lab1"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[*] Déploiement du TP Phishing sur ${KALI_CONTAINER}${NC}"

# Vérifier que le conteneur existe et tourne
if ! docker ps --format '{{.Names}}' | grep -q "^${KALI_CONTAINER}$"; then
    echo -e "${RED}[!] Le conteneur ${KALI_CONTAINER} n'est pas en cours d'exécution.${NC}"
    echo "    Lancez d'abord le lab : bash gestion_lab1.sh -l"
    exit 1
fi

echo -e "${GREEN}[+] Conteneur ${KALI_CONTAINER} trouvé${NC}"

# Préparer les répertoires de destination
docker exec "$KALI_CONTAINER" mkdir -p /var/www/html /opt

# Copier la page de phishing
echo "[*] Copie de la page de phishing..."
docker cp phishing-page/index.html ${KALI_CONTAINER}:/var/www/html/index.html

# Copier le harvester
echo "[*] Copie du credential harvester..."
docker cp harvester/harvester.py ${KALI_CONTAINER}:/opt/harvester.py

# Copier la config DNS ettercap
echo "[*] Copie de la configuration DNS spoofing..."
docker exec -i "$KALI_CONTAINER" bash -c '
    set -e
    test -f /etc/ettercap/etter.dns
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" == \#* ]] && continue
        grep -Fqx -- "$line" /etc/ettercap/etter.dns || printf "%s\n" "$line" >> /etc/ettercap/etter.dns
    done
' < ettercap/etter.dns.snippet

# Installer Apache si pas déjà fait
echo "[*] Vérification d'Apache2..."
docker exec ${KALI_CONTAINER} bash -c 'which apache2 > /dev/null 2>&1 || apt install -y apache2'

echo ""
echo -e "${GREEN}[OK] Déploiement terminé !${NC}"
echo ""
echo "Commandes utiles :"
echo "  # Démarrer Apache (page de phishing statique)"
echo "  docker exec ${KALI_CONTAINER} service apache2 start"
echo ""
echo "  # OU démarrer le harvester Python (capture les identifiants)"
echo "  docker exec ${KALI_CONTAINER} bash -c 'service apache2 stop; python3 /opt/harvester.py'"
echo ""
echo "  # Vérifier les identifiants capturés"
echo "  docker exec ${KALI_CONTAINER} cat /opt/creds.txt"
