---
layout: default
title: "Labo 00 : Prérequis"
nav_order: 2
description: "Préparer votre environnement de développement pour l'atelier Playwright 101"
permalink: /fr/labs/lab-00-prerequisites/
---

| | |
| --- | --- |
| **Durée** | 15 minutes (à votre rythme) |
| **Niveau** | Débutant |
| **Type** | Configuration |

## Objectifs d'apprentissage

À la fin de ce labo, votre environnement de développement sera configuré pour
rédiger et exécuter des tests Playwright tout au long de l'atelier.

## Prérequis

* Un système Windows, macOS ou Linux
* Un accès Internet
* Un compte GitHub (l'offre gratuite suffit)

## Exercices

### Exercice 1 : Installer Node.js 20 ou une version ultérieure

Téléchargez et installez Node.js 20 ou une version ultérieure à partir de
[nodejs.org](https://nodejs.org). La version LTS (prise en charge à long terme)
est recommandée. Vérifiez l'installation :

```bash
node --version
```

La sortie doit afficher `v20.x.x` ou une version ultérieure.

### Exercice 2 : Installer Visual Studio Code

Téléchargez et installez Visual Studio Code à partir de
[code.visualstudio.com](https://code.visualstudio.com). Vous utiliserez cet éditeur
pour rédiger vos tests et interagir avec GitHub Copilot.

### Exercice 3 : Installer les extensions VS Code

Ouvrez VS Code et installez les extensions suivantes à partir du catalogue :

1. **Playwright Test for VS Code** permet d'exécuter et de déboguer les tests,
   ainsi que de générer du code directement dans l'éditeur.
2. **GitHub Copilot** permet la rédaction de tests assistée par l'IA au labo 03.

> [!TIP]
> Recherchez chaque extension par son nom dans le volet Extensions
> (`Ctrl+Shift+X`), puis sélectionnez **Install** (Installer).

### Exercice 4 : Cloner le dépôt

Ouvrez un terminal et clonez le dépôt de l'atelier :

```bash
git clone https://github.com/devopsabcs-engineering/playwright-101.git
```

### Exercice 5 : Installer les dépendances

Accédez au répertoire du projet de tests et installez les dépendances Node.js :

```bash
cd playwright-101/playwright-tests
npm install
```

### Exercice 6 : Installer les navigateurs Playwright

Playwright a besoin des exécutables de navigateur pour lancer les tests. Installez
Chromium et ses dépendances système :

```bash
npx playwright install --with-deps chromium
```

### Exercice 7 : Vérifier la configuration

Exécutez la suite fonctionnelle pour confirmer que les tests démarrent :

```bash
npx playwright test
```

La suite comprend sept scénarios normaux et deux tests `@failure-demo` qui échouent
volontairement pour pratiquer le diagnostic. Pour vérifier uniquement les scénarios
normaux :

```bash
npx playwright test --grep-invert @failure-demo
```

Les tests ciblent la version anglaise d'Ontario.ca. Conservez les chaînes anglaises
dans le code. Le site en ligne peut évoluer; distinguez un problème de configuration
d'un échec d'assertion avant de modifier l'environnement.

## Point de vérification

Les sept scénarios normaux démarrent sans erreur de dépendance ni de navigateur.
Examinez tout échec lié au site en ligne et distinguez-le des deux démonstrations
intentionnelles. En cas d'erreur de configuration, reprenez l'étape concernée.

## Résumé

Votre environnement comprend Node.js, VS Code avec les extensions requises et
Chromium pour Playwright. Vous savez exécuter la suite et reconnaître les échecs
intentionnels.

## Étape suivante

Passez au [labo 01 : Des récits utilisateurs aux cas de test](../lab-01-test-planning/).
