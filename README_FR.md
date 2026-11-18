# Idle-Mouse‑Move
## À propos
Script PowerShell Windows de déplacement automatique de la souris, destiné à empêcher le système de détecter une inactivité prolongée.
- ✅ Mouvement alterné de la souris : décalage vers la gauche d’un nombre défini de pixels, attente puis retour à la position initiale, exécution en boucle
- ✅ API native anti‑veille système, empêche la mise en veille du système et l’arrêt automatique de l’écran
- ✅ Fonctionne entièrement en local, aucune connexion réseau nécessaire, utilise les API Windows pour contrôler le curseur et la gestion de l’alimentation
- ✅ Deux versions : version stable (sans journal sur disque), version débogage (enregistre les coordonnées pour le dépannage)

> ⚠️ Avertissement important
> Les deux scripts utilisent un déplacement relatif et **ne verrouillent pas la position de référence de la souris capturée au lancement du script**.
> Si vous déplacez manuellement la souris pendant l’exécution ou si de minuscules tremblements du curseur surviennent, la position de la souris dérivera progressivement.

> ⚠️ Limites d’environnement
> Les machines virtuelles et certaines sessions de bureau à distance interceptent l’API `SetCursorPos`, la souris ne bougera pas ; les logiciels de sécurité peuvent bloquer les appels du script aux interfaces système Windows.
> Sur certains appareils, seul le mouvement de la souris fonctionne et l’arrêt de l’écran ne peut pas être empêché,Cela peut aussi être lié à la stratégie d’alimentation du système.

## Liste des fichiers
### `mouse_move.ps1` - **【Script principal｜Version stable】**
- Objectif : utilisation quotidienne, affichage uniquement dans la console, **aucun fichier journal n’est écrit sur le disque**
- Fonctionnalités : mouvement alterné de la souris + activation de la prévention de la mise en veille système (`SetThreadExecutionState`)
- Lanceur associé : `run_mouse_move.bat`

### `run_test.ps1` - **【Script de débogage｜Pour le dépannage】**
- Objectif : diagnostiquer les problèmes, génère le fichier `mouse_log.txt` dans le dossier du script pour enregistrer les coordonnées de la souris à chaque boucle
- Fonctionnalités : mouvement alterné de la souris + activation de la prévention de la mise en veille + enregistrement des journaux sur disque
- Attention : écrit continuellement des journaux sur le disque, **ne convient pas pour une exécution longue durée**
- Lanceur associé : `run_test.bat`

### `run_mouse_move.bat`
Lanceur batch stable, double‑cliquez pour exécuter le script principal `mouse_move.ps1`.
> Le message `Keep screen awake` dans le batch correspond au comportement réel : la prévention de la mise en veille est activée dans le script PowerShell.
Méthode d’arrêt : appuyez sur `Ctrl+C` dans la fenêtre de console ou fermez‑la directement.

### `run_test.bat`
Lanceur batch de débogage, exécute le script de test, génère le fichier journal et active la prévention de la mise en veille.

### `mouse_log.txt`
> **Généré uniquement lors de l’exécution de `run_test.ps1`. Le script principal stable ne produit jamais ce fichier.**
> Contient l’horodatage, le numéro de boucle et les coordonnées de la souris avant et après déplacement ; le fichier fonctionne en mode ajout, les anciens journaux ne sont pas écrasés automatiquement.

## Utilisation
### Méthode 1 : double‑clic (recommandée)
1. Utilisation quotidienne : double‑cliquez sur `run_mouse_move.bat`
2. Besoin de journaux pour le dépannage : double‑cliquez sur `run_test.bat`
3. Arrêter le script : appuyez sur `Ctrl+C` ou fermez la fenêtre de console

### Méthode 2 : exécution manuelle en ligne de commande
```cmd
:: Lancer le script principal stable
cd dossier‑du‑script
run_mouse_move.bat

:: Lancer le script de débogage
run_test.bat
```

### Méthode 3 : exécuter directement le script PowerShell
```powershell
# Version stable
powershell -NoProfile -ExecutionPolicy Bypass -File mouse_move.ps1

# Version débogage
powershell -NoProfile -ExecutionPolicy Bypass -File run_test.ps1
```

## Configuration des paramètres
Modifiez le fichier ps1 correspondant pour changer les paramètres :

**mouse_move.ps1 (Version stable)**
```powershell
$moveAmount = 50        # Nombre de pixels de déplacement unitaire
$leftMoveTime = 5000    # Délai en millisecondes après le décalage vers la gauche
$rightMoveTime = 5000   # Délai en millisecondes après le retour à la position de base
```

**run_test.ps1 (Version débogage)**
```powershell
$moveAmount = 50        # Nombre de pixels de déplacement unitaire
$leftTime = 5000        # Délai en millisecondes après le décalage vers la gauche
$rightTime = 5000       # Délai en millisecondes après le retour à la position de base
```

## Foire aux questions
### Q1 : La souris ne bouge pas du tout ?
Réponse : Vérifiez point par point :
1. Vérifiez si vous utilisez une machine virtuelle / une session de bureau à distance qui intercepte `SetCursorPos` ;
2. Un logiciel de sécurité bloque les appels du script à l’API souris de Windows ;
3. Utilisez le script de débogage `run_test.bat` et consultez `mouse_log.txt` pour vérifier si le script s’exécute normalement.

### Q2 : L’écran s’éteint malgré l’exécution du script ?
Réponse : `SetThreadExecutionState` n’agit que sur le processus du script en cours ; les paramètres d’alimentation système sont restaurés à la fermeture du script. Certains logiciels tiers de gestion de l’alimentation peuvent annuler l’effet de cette API.

### Q3 : Impossible de trouver `mouse_log.txt` ?
Réponse : Le fichier journal **n’est généré que par le script de débogage run_test.ps1**, le script stable ne produit aucun journal.

### Q4 : La position de la souris dérive progressivement au fil du temps ?
Réponse : Le script utilise un déplacement relatif sans verrouiller la position initiale. Évitez de déplacer la souris manuellement pendant son exécution.

## Détails techniques
1. Contrôle du curseur : API `SetCursorPos`, `GetCursorPos` provenant de user32.dll
2. Implémentation anti‑veille : `SetThreadExecutionState` provenant de kernel32.dll
    - Drapeaux : `ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED`
    - Effet : empêche la mise en veille du système et l’arrêt automatique de l’écran ; devient inactif automatiquement à la fin du processus.

## Avertissement de non‑responsabilité
Ce script est exclusivement destiné à l’apprentissage et aux tests. Vous assumez l’ensemble des risques liés à son utilisation, y compris sans s’y limiter les anomalies système ou les comportements anormaux de la souris. Ne pas utiliser pour l’inactivité automatique dans les jeux, certains jeux détectent les entrées simulées.

## Avis sur les auteurs et la génération par IA
- Brouillon de code initial généré par **GLM‑4.7‑Flash** ;
- Traitement du README.md, des descriptions, du fichier .gitignore et d’une partie de la revue de code réalisé par **Doubao** ;
- Revue de code complémentaire et tests réalisés par **dot‑idk‑dot** et **LLLyyy‑star**
- Version : 1.0
- Dernière modification : 2026‑11‑18
