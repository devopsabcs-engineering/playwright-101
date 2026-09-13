---
layout: default
title: "Labo 04 : Pipeline CI/CD (Azure DevOps)"
nav_order: 7
description: "Exécuter en parallèle les tests Playwright fonctionnels et d'accessibilité avec Azure Pipelines"
permalink: /fr/labs/lab-04-ci-pipeline-ado/
---

| | |
| --- | --- |
| **Durée** | 15 minutes |
| **Niveau** | Débutant |
| **Type** | Démonstration et configuration |

## Objectifs d'apprentissage

À la fin de ce labo, vous pourrez :

* Comprendre les concepts CI/CD appliqués aux tests automatisés
* Lire et modifier un pipeline YAML Azure DevOps
* Exécuter les suites fonctionnelle et d'accessibilité dans des tâches matricielles indépendantes
* Créer un pipeline Azure DevOps à partir d'un fichier YAML existant
* Consulter les résultats et les artefacts dans Azure DevOps
* Choisir les déclencheurs : push, demande de tirage ou planification

## Prérequis

* Avoir terminé le labo 03
* Disposer d'une organisation et d'un projet Azure DevOps
* Avoir le droit de pousser dans le dépôt Azure DevOps ou GitHub utilisé

> [!NOTE]
> Choisissez [GitHub Actions](../lab-04-ci-pipeline/) pour l'autre parcours CI.
> Azure Pipelines peut aussi utiliser un dépôt GitHub.

## Exercices

### Exercice 1 : Examiner le pipeline

Ouvrez [.azuredevops/pipelines/playwright-tests.yml](https://github.com/devopsabcs-engineering/playwright-101/blob/main/.azuredevops/pipelines/playwright-tests.yml)
dans VS Code. Examinez cette matrice extraite du pipeline complet :

```yaml
jobs:
  - job: Playwright
    displayName: 'Playwright tests'
    strategy:
      maxParallel: 2
      matrix:
        Functional:
          suite: 'functional'
          junitPath: 'test-results/junit.xml'
          reportPath: 'playwright-report'
          resultsPath: 'test-results'
        Accessibility:
          suite: 'accessibility'
          junitPath: 'test-results/accessibility/junit.xml'
          reportPath: 'playwright-report/accessibility'
          resultsPath: 'test-results/accessibility'
```

Chaque entrée s'exécute indépendamment sur un agent Ubuntu. `maxParallel: 2`
autorise deux exécutions simultanées selon la capacité de votre organisation.
Avec un seul emplacement disponible, les tâches se mettent en file d'attente.

Lisez les étapes qui suivent la matrice dans le pipeline complet :

* `UseNode@1` installe Node.js 20 et `npm install` installe les dépendances de test.
* Playwright installe Chromium et ses dépendances système.
* `npm run test:$(suite)` choisit la configuration fonctionnelle ou d'accessibilité.
* `PLAYWRIGHT_SCREENSHOT: 'on'` capture chaque test; la configuration commune
  enregistre les traces lors de la première nouvelle tentative.
* `PublishTestResults@2` publie `$(junitPath)` sous le titre `Playwright $(suite)`.
  Des tests en échec ou un rapport JUnit absent font échouer cette étape.
* `PublishPipelineArtifact@1` publie les rapports et résultats propres à chaque
  suite avec `condition: succeededOrFailed()`, afin de préserver les preuves
  générées même après un échec.

> [!IMPORTANT]
> Le déclencheur YAML `pr` s'applique aux dépôts GitHub. Pour Azure Repos Git,
> configurez une stratégie de validation de build sur `main` pour les PR.
> La section `trigger` lance les builds lors des push vers `main` dans les deux cas.

### Exercice 2 : Créer le pipeline dans Azure DevOps

Si le pipeline n'existe pas encore dans votre projet :

1. Ouvrez le projet et sélectionnez **Pipelines > New pipeline**.
2. Choisissez l'emplacement du code, Azure Repos Git ou GitHub.
3. Sélectionnez votre dépôt.
4. Choisissez **Existing Azure Pipelines YAML file**.
5. Sélectionnez la branche `main` et le chemin
   `/.azuredevops/pipelines/playwright-tests.yml`.
6. Examinez le YAML, puis sélectionnez **Run** pour enregistrer et lancer le pipeline.

### Exercice 3 : Pousser une modification

Ajoutez une instruction `console.log` à un test pour vérifier le déclenchement :

```typescript
test('navigate to Ontario.ca search page', async ({ page }) => {
  console.log('CI pipeline verification');
  await page.goto('/search?query=driver+licence');
  await expect(page).toHaveTitle(/ontario/i);
});
```

Créez un commit et poussez depuis la branche de votre élément de travail.
Remplacez `1234` par l'identifiant du récit utilisateur ou du bogue, rattaché à
une fonctionnalité (Feature) et à une épopée (Epic), puis ouvrez une PR vers `main` :

```bash
git add playwright-tests/tests/ontario-search.spec.ts
git commit -m "test: verify parallel CI suites AB#1234"
git push -u origin HEAD
```

### Exercice 4 : Suivre le pipeline

1. Ouvrez votre projet Azure DevOps et sélectionnez **Pipelines**.
2. Trouvez l'exécution déclenchée par votre PR, avec le déclencheur ou la stratégie
   de branche appropriée.
3. Consultez les tâches **Functional** et **Accessibility** ainsi que leurs journaux.

Le pipeline installe Node.js, exécute les tests, publie leurs résultats et charge
les artefacts. Chaque étape possède son propre journal.

### Exercice 5 : Consulter les résultats

Après l'exécution :

1. Vérifiez le statut global : réussite en vert ou échec en rouge.
2. Ouvrez **Tests** pour consulter les nombres, les durées et les détails des
   échecs issus du rapport JUnit.
3. Dans **Artifacts**, retrouvez les sorties des deux suites :

| Suite | Rapport HTML | JUnit, captures et traces |
| --- | --- | --- |
| Fonctionnelle | `playwright-report-functional` | `test-results-functional` |
| Accessibilité | `playwright-report-accessibility` | `test-results-accessibility` |

### Exercice 6 : Ouvrir le rapport HTML

1. Téléchargez et extrayez un artefact de rapport HTML.
2. Depuis `playwright-tests`, exécutez `npx playwright show-report <extracted-report-directory>`
   en remplaçant le paramètre par le répertoire extrait.
3. Explorez les noms, les durées, les statuts et les captures de chaque test,
   activées par `PLAYWRIGHT_SCREENSHOT=on` dans le pipeline.

Ces rapports correspondent aux commandes locales `npm run test:functional` et
`npm run test:accessibility`. Chaque rapport ne contient que sa propre suite.

### Exercice 7 : Discussion

Discutez de ces stratégies :

* Ajouter une stratégie de validation de build sur `main` qui exige la réussite du
  pipeline avant la fusion d'une PR pour limiter les régressions.
* Ajouter un déclencheur `schedules` (`cron: '0 2 * * *'`) pour détecter la nuit
  les changements du site ou des dépendances externes.
* Étendre la matrice à Chromium, Firefox et WebKit pour vérifier la compatibilité,
  en ajoutant les projets et les installations de navigateurs correspondants.

## Point de vérification

Les deux tâches terminent, l'onglet **Tests** contient des exécutions distinctes
et les quatre artefacts sont disponibles lorsque les tests s'exécutent. Utilisez
les preuves de la suite concernée pour diagnostiquer les échecs du site en ligne.

Les tests fonctionnels `@failure-demo` échouent volontairement pour pratiquer le
diagnostic. Ils peuvent rendre la tâche rouge même si les scénarios normaux
réussissent. La tâche d'accessibilité doit terminer indépendamment.

## Résumé

Les pipelines CI/CD exécutent les tests à chaque modification sans intervention
manuelle. Ils automatisent l'installation du navigateur, l'exécution et les
rapports dans un environnement propre pour détecter les régressions.

## Étape suivante

Continuez avec le [labo 05 : Tests d'accessibilité](../lab-05-accessibility/) pour
explorer axe, diagnostiquer les violations et pratiquer les vérifications manuelles.
Ce complément facultatif de 20 minutes suit le parcours principal d'une heure.

### Pour approfondir

* [Documentation Playwright](https://playwright.dev)
* [Microsoft Learn : tests de bout en bout avec Playwright](https://learn.microsoft.com/fr-fr/training/modules/build-with-playwright/)
* [Documentation Azure Pipelines](https://learn.microsoft.com/fr-fr/azure/devops/pipelines/)
* [Azure Test Plans](https://learn.microsoft.com/fr-fr/azure/devops/test/overview)
