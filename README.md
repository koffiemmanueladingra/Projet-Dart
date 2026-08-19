# Projet-Dart — Gestionnaire de tâches

Application CLI de gestion de tâches développée en **Dart pur**.

## Prérequis

* **Dart SDK ≥ 3.0.0**
* Flutter n'est pas nécessaire.

Vérifier l'installation de Dart :

```bash
dart --version
```

## Installation

Cloner le projet puis installer les dépendances :

```bash
git clone https://github.com/koffiemmanueladingra/Projet-Dart.git avec https
git clone git@github.com:koffiemmanueladingra/Projet-Dart.git avec ssh
cd  Projet-Dart
cd task_cli
dart pub get
```

## Lancer l'application

Lancer l'application avec :

```bash
dart run bin/main.dart
```

### Exemples de commandes

Ajouter une tâche :

```bash
dart run bin/main.dart add --title "Payer la facture EDT" --priority high --deadline 2026-08-25
```

Ajouter une tâche urgente :

```bash
dart run bin/main.dart add --title "Serveur de prod en panne" --urgent
```

Lister les tâches :

```bash
dart run bin/main.dart list
```

Trier les tâches par date limite :

```bash
dart run bin/main.dart list --sort deadline
```

Marquer une tâche comme terminée :

```bash
dart run bin/main.dart complete --id <id>
```

Supprimer une tâche :

```bash
dart run bin/main.dart delete --id <id>
```

Afficher l'aide :

```bash
dart run bin/main.dart help
```

Les données sont automatiquement enregistrées dans le fichier local `tasks.json`.

## Tests

Exécuter l'ensemble des tests :

```bash
dart test
```

Pour obtenir un rapport détaillé :

```bash
dart test --reporter expanded
```

Projet réalisé dans le cadre d'un exercice de validation des compétences
Dart.
