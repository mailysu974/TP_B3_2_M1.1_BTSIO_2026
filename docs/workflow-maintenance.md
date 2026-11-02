# Workflow de maintenance du TP

## Demande et critères

Révision du 25 septembre 2026 : retirer les emojis des fichiers texte du projet, réécrire le README pour le TP de cybersécurité et identifier les scripts shell cités mais absents.

Les ressources BYAN locales sont incluses dans le nettoyage. L’historique Git, les fichiers binaires, les dépendances externes et les liens symboliques sont exclus. Les politiques rédactionnelles chargées sont `_byan/agent/byan/tao.md` et `_byan/_config/communication-policy.json`, version `fr-1`. Les profils retenus sont pédagogique et procédure.

## Exécution

1. Inventorier les fichiers, les changements existants et les références aux scripts shell.
2. Lire le README, l’énoncé et les fichiers exécutables pour documenter leur comportement réel.
3. Retirer les pictogrammes Unicode et leurs caractères de composition dans les fichiers texte locaux.
4. Réécrire le README : objectifs, topologie, prérequis, installation, observations, interprétation, compte rendu et dépannage.
5. Ajouter `gestion_lab1.sh`, lanceur du script CERTA externe, avec vérification du chemin, des options et de l’absence de récursion.
6. Corriger `setup.sh` : répertoire de travail indépendant du terminal, préparation des destinations, transmission de l’entrée standard à Docker et ajout des lignes DNS sans doublons identiques.
7. Exécuter les vérifications locales et consigner leurs limites.

## Revue rédactionnelle

Revue du README pour un lectorat étudiant, selon les règles Tao et les étapes de `_byan/command/editorial-review-prose.xml`. Les commandes sont examinées séparément de la prose.

| Texte initial | Formulation retenue | Motif |
|---|---|---|
| « La victime ne se doute de RIEN » | Décrire l’enregistrement puis la redirection HTTP 302. | Le comportement du programme ne permet pas de connaître la perception de l’utilisateur. |
| « Doit retourner » | Présenter le résultat visé et les conditions de l’expérience. | Distinguer résultat attendu et résultat observé. |
| « C’est normal. Ignorez l’erreur. » | Conserver l’erreur et vérifier la configuration. | Une erreur ne peut pas être déclarée bénigne sans diagnostic. |

Les corrections techniques du README sont distinctes de cette revue : le résultat DNS initial et l’usage de DoH ne sont plus présentés comme universels. L’énoncé détaillé conserve son contenu pédagogique existant ; son retrait d’emojis ne constitue pas une validation technique complète.

## Contrôles reproductibles

Exécuter `bash scripts/check-project.sh` depuis la racine du dépôt. Le contrôle analyse la syntaxe Bash et Python, les fichiers requis et les pictogrammes Unicode des fichiers texte UTF-8. Il ignore `.git`, `node_modules`, `__pycache__`, la copie externe `lab1` et les liens symboliques.

La gestion CERTA se teste avec un laboratoire factice : transmission des quatre options, répertoire de travail correct, rejet d’une option inconnue, d’un script absent et d’un chemin récursif. Le déploiement se teste avec une commande Docker simulée : copie des deux fichiers et transmission de la configuration sur l’entrée standard.

Aucun laboratoire ni attaque réseau n’est lancé par ce workflow. La récupération de la forge CERTA par l’outil web a renvoyé HTTP 403. Les conteneurs, images, accès RDP et échanges ARP/DNS réels ne sont pas validés ici.

## Résultats de cette exécution

- Nettoyage : 476 fichiers modifiés, 8 050 points de code retirés.
- Contrôle Unicode : aucun emoji détecté dans les 1 045 fichiers texte examinés.
- Syntaxe Bash et Python : valide.
- Lanceur CERTA : quatre options transmises, chemins avec espaces pris en charge, erreurs attendues vérifiées.
- Docker simulé : deux fichiers copiés et configuration DNS transmise sur l’entrée standard.
- Boucle DNS réelle sur fichier temporaire : contenu existant préservé et aucune ligne ajoutée en double après deux passages.
- `git diff --check` : aucune erreur.

Ces contrôles locaux ne remplacent pas une séance de validation dans le laboratoire CERTA.
