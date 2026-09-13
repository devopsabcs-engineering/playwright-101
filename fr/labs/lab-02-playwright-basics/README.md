---
layout: default
title: "Labo 02 : Votre premier test Playwright"
nav_order: 4
description: "Exécuter, explorer et modifier des tests Playwright en pratique"
permalink: /fr/labs/lab-02-playwright-basics/
---

| | |
| --- | --- |
| **Durée** | 20 minutes |
| **Niveau** | Débutant |
| **Type** | Pratique |

## Objectifs d'apprentissage

À la fin de ce labo, vous pourrez :

* Exécuter des tests Playwright existants en ligne de commande
* Comprendre la structure des tests : `describe`, `test`, `expect`
* Modifier le comportement des tests et ajouter des assertions
* Enregistrer des interactions avec Playwright Codegen
* Déboguer les échecs avec Trace Viewer

## Prérequis

* Avoir terminé le [labo 00 : Prérequis](../lab-00-prerequisites/)
* Avoir consulté le [labo 01 : Des récits utilisateurs aux cas de test](../lab-01-test-planning/)

## Exercices

### Exercice 1 : Exécuter les tests fournis

Depuis la racine du dépôt, ouvrez un terminal et accédez au projet de tests :

```bash
cd playwright-tests
npx playwright test
```

La suite contient sept scénarios normaux et deux tests `@failure-demo` qui échouent
volontairement. Pour vérifier les scénarios normaux sans ces démonstrations :

```bash
npx playwright test --grep-invert @failure-demo
```

La sortie indique les noms des tests et leur durée. En cas d'erreur de dépendance
ou de navigateur, reprenez le labo 00. Examinez séparément les échecs liés au site
en ligne, dont le contenu peut changer.

### Exercice 2 : Explorer la structure des tests

Ouvrez `tests/ontario-search.spec.ts` dans VS Code. Ce fichier contient les
scénarios associés aux critères du labo 01.

#### Importations et regroupement

Chaque fichier importe les outils de test et peut utiliser `test.describe()`
pour regrouper les scénarios liés :

```typescript
import { test, expect } from '@playwright/test';

test.describe('Ontario.ca Search', () => {
});
```

#### Configuration commune avec beforeEach

Le hook `test.beforeEach()` s'exécute avant chaque test du groupe. Ici, il ajoute
un témoin de langue pour éviter la page de sélection de langue :

```typescript
test.beforeEach(async ({ context }) => {
  await context.addCookies([{
    name: 'lang',
    value: 'en',
    domain: '.ontario.ca',
    path: '/'
  }]);
});
```

Les tests ciblent la version anglaise. Ne traduisez pas la valeur du témoin,
les sélecteurs ni le texte attendu dans les assertions.

#### Cas de test individuels

Chaque bloc `test()` cible un scénario. Remarquez la fonction `async` et la fixture
`{ page }` obtenue par déstructuration :

```typescript
test('search for driver licence returns results', async ({ page }) => {
  await page.goto('/search?query=driver+licence');
  await page.waitForSelector('h4 a');
  await expect(page.locator('h3').filter({ hasText: /results/ })).toBeVisible();
  await expect(page.locator('h4 a').first()).toBeVisible();
});
```

#### Stratégies de localisation

Playwright propose plusieurs façons de trouver les éléments :

| Stratégie | Exemple | Utilisation |
| --- | --- | --- |
| Sélecteur CSS | `page.locator('h4 a')` | Cibler une balise, une classe ou un identifiant |
| Filtre avec expression régulière | `page.locator('h3').filter({ hasText: /results/ })` | Réduire les correspondances selon le texte |
| Texte du libellé | `page.getByLabel('Updated date (new to old)')` | Trouver des champs accessibles |
| Localisateur chaîné | `page.locator('label').filter({ hasText: /driving/i }).first()` | Combiner les stratégies pour plus de précision |

#### Assertions

Les assertions Playwright attendent automatiquement que la condition soit remplie :

| Assertion | Objectif |
| --- | --- |
| `toHaveTitle(/ontario/i)` | Le titre correspond au motif |
| `toBeVisible()` | L'élément est présent et visible |
| `toContainText('2')` | L'élément contient le texte attendu |

### Exercice 3 : Modifier un test

Dans `tests/ontario-search.spec.ts`, remplacez la requête du test
`search for driver licence returns results` par une recherche de carte Santé :

```typescript
test('search for health card returns results', async ({ page }) => {
  await page.goto('/search?query=health+card');
  await page.waitForSelector('h4 a');
  await expect(page.locator('h3').filter({ hasText: /results/ })).toBeVisible();
  await expect(page.locator('h4 a').first()).toBeVisible();
});
```

Relancez les tests pour vérifier le scénario modifié :

```bash
npx playwright test
```

> [!TIP]
> Seuls la requête et le nom du test changent. Les localisateurs et les assertions
> restent identiques, car la structure de la page ne dépend pas des mots recherchés.

### Exercice 4 : Ajouter une assertion

Renforcez le test en vérifiant que le premier lien contient un texte pertinent.
Ajoutez cette ligne avant le `});` final :

```typescript
await expect(page.locator('h4 a').first()).toContainText('health');
```

Le test vérifie maintenant l'affichage des résultats, la visibilité du premier lien
et la pertinence de son texte. Relancez-le pour vérifier la nouvelle assertion.

La précision constitue un compromis. Une assertion générale comme `toBeVisible`
est stable, mais détecte moins de défauts. Une assertion ciblée comme
`toContainText('health')` détecte plus de problèmes, mais peut échouer si le contenu
change. Adaptez la précision à votre connaissance du contenu de la page.

### Exercice 5 : Utiliser Codegen

Playwright Codegen enregistre vos interactions et génère le code correspondant :

```bash
npm run codegen
```

Une fenêtre Chromium s'ouvre sur la recherche Ontario.ca. Effectuez ces actions :

1. Cliquez dans le champ de recherche.
2. Effacez le texte et saisissez « birth certificate ».
3. Appuyez sur Entrée.
4. Cliquez sur le premier résultat.

Codegen écrit le code Playwright dans une autre fenêtre. Copiez-le dans un nouveau
bloc de test pour voir comment les interactions deviennent des appels de
localisateur et des assertions.

> [!NOTE]
> Le code généré est un point de départ. Examinez les localisateurs et améliorez
> leur stabilité. Préférez `getByLabel()` ou `filter({ hasText })` aux sélecteurs
> CSS fragiles lorsque cela convient.

### Exercice 6 : Déboguer avec Trace Viewer

Trace Viewer présente la chronologie des actions, les captures d'écran, les
instantanés du DOM et les requêtes réseau. Provoquez un échec pour l'explorer.

#### Provoquer un échec

Dans le test `search for health card returns results`, ajoutez une assertion
de titre qui ne peut pas correspondre :

  ```typescript
  await expect(page).toHaveTitle(/nonexistent title/i);
  ```

#### Enregistrer la trace

Exécutez les tests avec les traces activées :

  ```bash
  npx playwright test --trace on
  ```

  Le test échoue et Playwright enregistre une trace.

#### Examiner la trace

Ouvrez Trace Viewer avec le chemin de la trace du test concerné :

  ```bash
  npx playwright show-trace test-results/*/trace.zip
  ```

  Si plusieurs traces existent ou si votre terminal ne développe pas `*`, remplacez
  le motif par le chemin exact d'un fichier `trace.zip`.

  Explorez la chronologie :

* Chaque action présente une capture avant et après son exécution.
* Sélectionnez une étape pour examiner l'instantané du DOM.
* L'onglet Network affiche les appels API effectués pendant le test.
* L'onglet Console affiche les messages du navigateur.

#### Rétablir l'assertion

Remplacez l'assertion incorrecte par celle du titre attendu :

  ```typescript
  await expect(page).toHaveTitle(/ontario/i);
  ```

Relancez `npx playwright test` et vérifiez que votre test modifié réussit.
Les tests `@failure-demo` restent volontairement en échec.

## Point de vérification

Votre test modifié réussit avec la recherche « health card » et l'assertion
`toContainText('health')`. Vous avez enregistré une interaction avec Codegen et
examiné un échec avec Trace Viewer.

## Résumé

Playwright propose des assertions avec attente automatique, plusieurs stratégies
de localisation et un outil visuel de diagnostic. Ces fonctions facilitent la
rédaction, la maintenance et le débogage des tests sans pauses arbitraires.

## Étape suivante

Passez au [labo 03 : GitHub Copilot pour les tests](../lab-03-copilot-testing/).
