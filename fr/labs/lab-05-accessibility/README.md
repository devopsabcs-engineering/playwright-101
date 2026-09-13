---
layout: default
title: "Labo 05 : Tests d'accessibilité"
nav_order: 8
description: "Exécuter des analyses axe avec Playwright, examiner les constats WCAG et comparer les résultats CI"
permalink: /fr/labs/lab-05-accessibility/
---

| | |
| --- | --- |
| **Durée** | 20 minutes (complément à l'atelier d'une heure) |
| **Niveau** | Débutant |
| **Type** | Pratique et examen des rapports |

## Objectifs d'apprentissage

* Exécuter séparément les suites fonctionnelle et d'accessibilité
* Analyser les états de page avec les règles axe associées aux WCAG 2.1, niveaux A et AA
* Examiner les violations à partir des identifiants de règle, des éléments et des pièces jointes
* Comparer les tâches CI indépendantes et reconnaître les vérifications manuelles nécessaires

## Prérequis

* Terminez le labo 02 et le parcours [GitHub Actions](../lab-04-ci-pipeline/) ou
  [Azure DevOps](../lab-04-ci-pipeline-ado/) pour l'exercice CI.
* Installez Node.js 20 ou une version ultérieure et Chromium avec les commandes ci-dessous.
* Disposez d'un accès réseau à Ontario.ca. Aucun compte n'est requis pour les pages testées.

> [!IMPORTANT]
> Les analyses automatisées détectent certains problèmes, mais ne couvrent pas
> toutes les exigences WCAG. Une analyse réussie ne prouve ni la conformité WCAG
> ni la conformité juridique. Les vérifications au clavier, au lecteur d'écran,
> au zoom et les autres tests manuels restent nécessaires.

## Exercices

### Exercice 1 : Exécuter la suite d'accessibilité

Depuis la racine du dépôt :

```bash
cd playwright-tests
npm ci
npx playwright install --with-deps chromium
npm run test:accessibility
```

Le projet inclut déjà `@axe-core/playwright`. La commande utilise
[playwright.accessibility.config.ts](https://github.com/devopsabcs-engineering/playwright-101/blob/main/playwright-tests/playwright.accessibility.config.ts),
qui reprend l'URL de base, le projet Chromium, les paramètres de capture et les
traces de nouvelle tentative de la configuration fonctionnelle. Elle change le
répertoire de tests, le délai maximal et les chemins de rapports.

Comparez les deux suites :

| Suite | Commande | Répertoire de tests | Rapport HTML | XML JUnit |
| --- | --- | --- | --- | --- |
| Fonctionnelle | `npm run test:functional` | `tests` | `playwright-report` | `test-results/junit.xml` |
| Accessibilité | `npm run test:accessibility` | `accessibility-tests` | `playwright-report/accessibility` | `test-results/accessibility/junit.xml` |

`npm test` et `npx playwright test` choisissent la configuration fonctionnelle par
défaut; ils n'exécutent pas les deux suites. En local, lancez d'abord les tests
fonctionnels, puis ceux d'accessibilité. Les sorties d'accessibilité se trouvent
dans les répertoires de sortie fonctionnels; une exécution fonctionnelle ultérieure
peut donc effacer les résultats d'accessibilité précédents. La CI évite ces
collisions avec des agents distincts.

### Exercice 2 : Lire l'analyse

Ouvrez [ontario-accessibility.spec.ts](https://github.com/devopsabcs-engineering/playwright-101/blob/main/playwright-tests/accessibility-tests/ontario-accessibility.spec.ts).
Repérez les trois scénarios :

| État de page | Vérification avant l'analyse |
| --- | --- |
| Accueil anglais | Le titre de niveau 1 est visible |
| Résultats de recherche présents | Le premier lien de résultat est visible |
| Aucun résultat | Le titre contenant `0 results` est visible |

Le témoin de langue anglaise évite la page de sélection de langue. Chaque assertion
vérifie que l'état attendu est affiché avant l'analyse axe. Conservez ces valeurs
anglaises dans les tests. L'analyse utilise la chaîne suivante :

```typescript
const results = await new AxeBuilder({ page })
  .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
  .analyze();
```

Ces étiquettes sélectionnent les règles pertinentes des WCAG 2.0 et 2.1, niveaux
A et AA. Elles n'activent pas toutes les règles axe ni tous les critères WCAG.
Le test joint le résultat JSON complet sous le nom `axe-results` avant de vérifier
que la liste des violations est vide.

### Exercice 3 : Examiner et classer les résultats

Depuis `playwright-tests`, ouvrez le rapport HTML d'accessibilité :

```bash
npx playwright show-report playwright-report/accessibility
```

1. Choisissez un test et examinez son statut, sa capture et la pièce jointe
   `axe-results`. Par défaut, les captures locales concernent les échecs; la CI
   capture chaque test.
2. Pour une violation, relevez l'identifiant de règle, l'incidence, le lien d'aide,
   les sélecteurs `target` et le `failureSummary` dans l'assertion ou le JSON.
3. Inspectez l'élément de la page. Distinguez un problème du site d'un échec de
   navigation ou de préparation ayant empêché l'analyse.
4. Examinez les résultats `incomplete` qui exigent un jugement humain. L'assertion
   actuelle échoue sur `violations`, et non sur `incomplete`.
5. Relancez un scénario pour vérifier le constat :

```bash
npm run test:accessibility -- --grep "populated search results"
```

Si l'analyse réussit, examinez `passes` et `incomplete`, puis décrivez une règle
vérifiée. Ne provoquez pas artificiellement une erreur sur le site en ligne.

Ontario.ca est un site public hors du contrôle de ce dépôt. Signalez les constats
avec des étapes reproductibles et des preuves. Ne désactivez pas les règles et
n'excluez pas les éléments concernés uniquement pour obtenir une réussite.
Pour une application qui vous appartient, corrigez le balisage ou l'interaction
à la source, puis répétez l'analyse.

### Exercice 4 : Comparer les résultats CI en parallèle

Ouvrez une exécution du labo 04 :

* Dans GitHub Actions, examinez **Playwright functional**, **Playwright accessibility**
  et leurs résumés. `fail-fast: false` empêche l'échec d'une tâche d'annuler l'autre.
* Dans Azure DevOps, examinez **Functional**, **Accessibility** et l'onglet **Tests**
  avec les exécutions distinctes `Playwright functional` et `Playwright accessibility`.
  La capacité disponible détermine si les tâches démarrent simultanément.

Les deux plateformes publient les mêmes noms d'artefacts :

| Suite | Rapport HTML | Résultats bruts |
| --- | --- | --- |
| Fonctionnelle | `playwright-report-functional` | `test-results-functional` |
| Accessibilité | `playwright-report-accessibility` | `test-results-accessibility` |

Téléchargez et extrayez le rapport HTML d'accessibilité, puis exécutez
`npx playwright show-report <extracted-report-directory>` avec le chemin extrait.
Vérifiez la pièce jointe axe. Les résultats bruts comprennent le XML JUnit, les
captures et les traces lorsqu'ils ont été générés. Les traces sont enregistrées
à la première nouvelle tentative; une réussite dès le premier essai n'en produit pas.

Une réussite fonctionnelle et un échec d'accessibilité sont des constats indépendants.
Les deux suites doivent réussir pour que la CI soit verte. Configurez séparément
la protection de branche ou la stratégie de validation ADO pour bloquer les fusions.

La suite fonctionnelle comprend des tests `@failure-demo` intentionnels.
Distinguez-les des échecs réels; ils n'annulent pas la tâche d'accessibilité.

### Exercice 5 : Ajouter une couverture manuelle

Sur la page de recherche, notez le comportement attendu et observé pour ces contrôles :

* Naviguez avec Tab et Maj+Tab. Vérifiez la visibilité du focus, l'ordre logique
  et l'absence de pièges au clavier.
* Lancez une recherche au clavier et vérifiez que vous pouvez atteindre les résultats.
* Avec un lecteur d'écran, vérifiez le nom accessible du champ, les titres, les
  régions et les annonces lors du changement des résultats.
* Vérifiez le texte à 200 % de zoom et la redistribution sur une largeur de
  320 pixels CSS, souvent obtenue à 400 % sur une fenêtre de 1280 pixels.
  Recherchez les pertes de contenu ou de commandes.

Pour la traçabilité ADO, associez chaque critère d'acceptation à au moins un cas de
test dans une suite statique sous un plan de test. Référencez l'identifiant AC,
reliez le cas au récit utilisateur avec `Tests`, puis vérifiez le lien inverse
`Tested By`. Appliquez l'étiquette `Agentic AI` au plan, à la suite et aux cas.
Une exécution JUnit en CI ne crée pas à elle seule cette couverture des critères.

## Point de vérification

* Les trois scénarios s'exécutent, ou vous identifiez précisément le blocage
  d'environnement ou de préparation de page.
* Vous retrouvez le rapport HTML d'accessibilité, le XML JUnit et la pièce jointe axe.
* Vous expliquez un résultat d'analyse et un contrôle exigeant une vérification manuelle.
* Les deux suites CI publient des résultats indépendants, y compris les preuves d'échec.

## Ressources

* [Tests d'accessibilité Playwright](https://playwright.dev/docs/accessibility-testing)
* [Intégration axe-core pour Playwright](https://www.npmjs.com/package/@axe-core/playwright)
* [WCAG 2.1](https://www.w3.org/TR/WCAG21/)
* [Vérifications rapides WAI](https://www.w3.org/WAI/test-evaluate/easy-checks/)
