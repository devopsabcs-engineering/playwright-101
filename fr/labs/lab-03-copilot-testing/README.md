---
layout: default
title: "Labo 03 : GitHub Copilot pour les tests"
nav_order: 5
description: "Accélérer la rédaction de tests Playwright avec GitHub Copilot"
permalink: /fr/labs/lab-03-copilot-testing/
---

| | |
| --- | --- |
| **Durée** | 15 minutes |
| **Niveau** | Intermédiaire |
| **Type** | Pratique |

## Objectifs d'apprentissage

À la fin de ce labo, vous pourrez :

* Utiliser les suggestions en ligne de GitHub Copilot pour écrire des tests
* Générer des scénarios complets avec Copilot Chat
* Appliquer la technique des deux requêtes : le contexte, puis la demande
* Vérifier et améliorer le code généré par l'IA

## Prérequis

* Avoir terminé le labo 02 avec un test modifié qui réussit
* Avoir installé et activé GitHub Copilot dans VS Code

> [!NOTE]
> Sans abonnement Copilot, utilisez les exemples de code manuels fournis.
> Vous pouvez réaliser tous les exercices sans génération assistée.

## Exercices

### Exercice 1 : Générer à partir d'un commentaire

Ouvrez `playwright-tests/tests/ontario-search.spec.ts`. À la fin du bloc `describe`,
commencez un nouveau test par un commentaire descriptif :

```typescript
// Vérifier qu'un clic sur un résultat ouvre la bonne page
```

Si Copilot est actif, une suggestion apparaît après le commentaire. Examinez-la
avant de l'accepter. Vérifiez les sélecteurs par rapport aux éléments réels, par
exemple `h4 a` pour les liens des résultats.

Sans Copilot, saisissez ce test après le commentaire :

```typescript
test('clicking a search result navigates to the correct page', async ({ page }) => {
  await page.goto('/search?query=driver+licence');
  await page.waitForSelector('h4 a');
  const firstResult = page.locator('h4 a').first();
  const resultText = await firstResult.textContent();
  await firstResult.click();
  await expect(page).not.toHaveURL(/\/search/);
  await expect(page.locator('h1, h2').first()).toBeVisible();
});
```

### Exercice 2 : Fournir le contexte à Copilot Chat

Ouvrez Copilot Chat (`Ctrl+Shift+I`) et envoyez ce contexte avant de demander du code :

```text
Ce fichier teste ontario.ca/search avec Playwright. La page est une application
React monopage avec un champ de recherche (#search-input-field), des cases à cocher
pour les sujets, des boutons radio pour le tri et une pagination (.rc-pagination).
Les tests ciblent la version anglaise du site : conserve les sélecteurs et les
textes attendus en anglais.
```

Copilot dispose maintenant du contexte pour la demande suivante. Sans Copilot,
utilisez cette description comme référence pour écrire le test.

### Exercice 3 : Demander la génération d'un test

Dans la même conversation, envoyez cette demande :

```text
Génère un test Playwright qui vérifie que le nombre de résultats diminue après
l'application d'un filtre par sujet.
```

Copilot propose un test à partir des sélecteurs du contexte. Ajoutez le code dans
le bloc `describe` de `ontario-search.spec.ts`.

Sans Copilot, ajoutez ce test manuellement :

```typescript
test('topic filter decreases result count', async ({ page }) => {
  await page.goto('/search?query=driver+licence');
  await page.waitForSelector('h4 a');

  const resultsHeader = page.locator('h3').filter({ hasText: /results/ });
  const beforeText = await resultsHeader.textContent();
  const beforeCount = parseInt(beforeText?.match(/\d+/)?.[0] ?? '0');

  await page.locator('label').filter({ hasText: /driving/i }).first().click();
  await page.locator('#filterSortApply').click();
  await page.waitForSelector('h4 a');

  const afterText = await resultsHeader.textContent();
  const afterCount = parseInt(afterText?.match(/\d+/)?.[0] ?? '0');

  expect(afterCount).toBeLessThan(beforeCount);
});
```

### Exercice 4 : Vérifier le résultat

Depuis la racine du dépôt, exécutez les tests :

```bash
cd playwright-tests
npx playwright test
```

Examinez en particulier le nouveau test. Les deux tests `@failure-demo` échouent
volontairement et ne constituent pas des défauts du code généré.

Les problèmes courants du code généré comprennent :

* Des sélecteurs qui ne correspondent pas au DOM réel
* Des attentes manquantes avant d'interagir avec le contenu dynamique
* Des assertions qui vérifient le mauvais élément ou la mauvaise propriété
* Des valeurs fixes qui ne résistent pas aux changements de contenu

### Exercice 5 : Améliorer le test

Si le nouveau test échoue, apportez des corrections ciblées :

1. Comparez les sélecteurs aux éléments réels avec les outils de développement
   du navigateur (`F12`) sur Ontario.ca/search.
2. Ajoutez les attentes nécessaires là où Copilot a supposé un rendu immédiat.
3. Ajustez les assertions pour vérifier le comportement réel de la page.

Relancez les tests après chaque correction :

```bash
npx playwright test
```

Continuez jusqu'à ce que le nouveau test réussisse. Distinguez toujours les échecs
du site en ligne et les démonstrations intentionnelles.

### Exercice 6 : Discussion

Discutez de ces questions en équipe :

* Dans quelles situations pouvez-vous utiliser le code de Copilot sans modification?
* Quelles parties exigent le plus d'attention? Les sélecteurs, les attentes et les
  assertions sont des sources fréquentes d'échec.
* Comment le contexte de l'exercice 2 améliore-t-il le code par rapport à une
  demande sans contexte?

## Point de vérification

Au moins un nouveau test généré par Copilot ou rédigé manuellement réussit aux
côtés des scénarios existants. Vous pouvez expliquer ses sélecteurs, ses attentes
et ses assertions, et distinguer les échecs `@failure-demo`.

## Résumé

GitHub Copilot accélère la rédaction en proposant du code et des scénarios complets.
La technique des deux requêtes, contexte puis demande, améliore la pertinence des
suggestions. Vérifiez toujours le DOM réel, le rendu dynamique et le comportement
couvert par chaque assertion.

## Étape suivante

Passez au [labo 04 : Pipeline CI/CD (GitHub Actions)](../lab-04-ci-pipeline/) ou au
[labo 04 : Pipeline CI/CD (Azure DevOps)](../lab-04-ci-pipeline-ado/), selon
l'emplacement de votre dépôt.
