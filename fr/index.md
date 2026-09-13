---
layout: default
title: Accueil
nav_order: 1
description: "Playwright 101 : des récits utilisateurs aux tests automatisés"
permalink: /fr/
---

## Atelier Playwright 101

Des récits utilisateurs aux tests automatisés avec Playwright, GitHub Copilot et Azure DevOps
{: .fs-6 .fw-300 }

## Présentation de l'atelier

Cet atelier pratique accompagne les spécialistes de l'assurance qualité dans le
passage des tests manuels à l'automatisation du navigateur avec Playwright. Vous
partirez de récits utilisateurs, les transformerez en cas de test structurés, puis
implémenterez ces tests avec le cadre de tests de bout en bout libre de Microsoft.

Vous utiliserez GitHub Copilot pour accélérer la rédaction des tests et découvrirez
comment le développement assisté par l'IA s'intègre au travail de test. Au labo 04,
choisissez GitHub Actions ou Azure DevOps pour exécuter en parallèle les suites
fonctionnelle et d'accessibilité. Le labo 05 prolonge l'atelier avec des analyses
d'accessibilité axe, l'examen des échecs et des vérifications manuelles.

Aucune expérience préalable en automatisation n'est requise. Le parcours principal
dure environ une heure avec l'un des deux labos CI. Prévoyez 20 minutes de plus
pour le volet accessibilité.

## Modules de l'atelier

| Module | Titre | Durée | Description |
| --- | --- | --- | --- |
| Labo 00 | [Prérequis](labs/lab-00-prerequisites/) | Avant l'atelier | Préparer l'environnement |
| Labo 01 | [Des récits utilisateurs aux cas de test](labs/lab-01-test-planning/) | 10 min | Relier les exigences aux tests |
| Labo 02 | [Votre premier test Playwright](labs/lab-02-playwright-basics/) | 20 min | Rédiger des tests en pratique |
| Labo 03 | [GitHub Copilot pour les tests](labs/lab-03-copilot-testing/) | 15 min | Générer des tests avec l'IA |
| Labo 04 | [Pipeline CI/CD (GitHub Actions)](labs/lab-04-ci-pipeline/) | 15 min | Automatiser l'exécution des tests |
| Labo 04 | [Pipeline CI/CD (Azure DevOps)](labs/lab-04-ci-pipeline-ado/) | 15 min | Automatiser l'exécution des tests |
| Labo 05 | [Tests d'accessibilité](labs/lab-05-accessibility/) | 20 min (complément) | Analyses axe, résultats CI et vérifications manuelles |

## Application cible

Tous les labos utilisent la page de recherche Ontario.ca
(`https://www.ontario.ca/search`) comme système à tester. Cette application React
monopage publique propose un champ de recherche, des filtres, une pagination et des
résultats dynamiques sans authentification ni accès particulier. Les participants
utilisent le même environnement en ligne pour limiter la configuration nécessaire.

Les tests ciblent la version anglaise du site. Gardez les valeurs de recherche,
les libellés d'interface et les sélecteurs anglais dans le code, même lorsque vous
suivez les consignes en français.

## Démarrage rapide

Clonez le dépôt, installez les dépendances et vérifiez votre environnement :

```bash
git clone https://github.com/devopsabcs-engineering/playwright-101.git
cd playwright-101/playwright-tests
npm install
npx playwright install --with-deps chromium
npx playwright test
```

La commande par défaut exécute uniquement les tests fonctionnels, y compris deux
tests `@failure-demo` qui échouent volontairement. Exécutez
`npm run test:accessibility` pour les analyses axe, puis
`npx playwright show-report playwright-report/accessibility` pour consulter leur
rapport. Le site en ligne peut changer ou présenter des problèmes d'accessibilité.
Pour les problèmes de configuration, consultez les
[prérequis](labs/lab-00-prerequisites/); pour les constats d'analyse, consultez le
[labo 05](labs/lab-05-accessibility/).
