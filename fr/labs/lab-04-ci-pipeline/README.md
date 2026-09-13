---
layout: default
title: "Labo 04 : Pipeline CI/CD (GitHub Actions)"
nav_order: 6
description: "Exécuter en parallèle les tests Playwright fonctionnels et d'accessibilité avec GitHub Actions"
permalink: /fr/labs/lab-04-ci-pipeline/
---

| | |
| --- | --- |
| **Durée** | 15 minutes |
| **Niveau** | Débutant |
| **Type** | Démonstration et configuration |

## Objectifs d'apprentissage

À la fin de ce labo, vous pourrez :

* Comprendre les concepts CI/CD appliqués aux tests automatisés
* Lire et modifier un workflow GitHub Actions
* Exécuter les suites fonctionnelle et d'accessibilité dans des tâches matricielles indépendantes
* Consulter les résultats et les artefacts dans GitHub
* Choisir les déclencheurs : push, demande de tirage ou planification

## Prérequis

* Avoir terminé le labo 03
* Avoir le droit de pousser des modifications dans le dépôt GitHub

## Exercices

### Exercice 1 : Examiner le workflow

Ouvrez [.github/workflows/playwright-tests.yml](https://github.com/devopsabcs-engineering/playwright-101/blob/main/.github/workflows/playwright-tests.yml)
dans VS Code. Le workflow se déclenche lors des push et des demandes de tirage
(PR) ciblant `main`. Il permet aussi une exécution manuelle avec **Run workflow**.
Examinez cette matrice extraite du workflow complet :

{% raw %}

```yaml
jobs:
  test:
    name: Playwright ${{ matrix.suite }}
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      max-parallel: 2
      matrix:
        include:
          - suite: functional
            junitPath: test-results/junit.xml
            reportPath: playwright-report
            resultsPath: test-results
          - suite: accessibility
            junitPath: test-results/accessibility/junit.xml
            reportPath: playwright-report/accessibility
            resultsPath: test-results/accessibility
```

Chaque entrée dispose de son propre agent Ubuntu. `max-parallel: 2` autorise deux
exécutions simultanées si la capacité est disponible. `fail-fast: false` permet
à une suite de terminer même si l'autre échoue. Aucune suite ne dépend de l'autre.

Lisez les étapes qui suivent la matrice dans le workflow complet :

* La récupération du code et l'installation de Node.js 24 préparent chaque agent.
* `npm ci` installe les dépendances verrouillées dans `playwright-tests`.
* `npx playwright install --with-deps chromium` installe le navigateur.
* `npm run test:${{ matrix.suite }}` choisit la configuration de la suite.
* `PLAYWRIGHT_SCREENSHOT: 'on'` capture chaque test; la configuration commune
  enregistre les traces lors de la première nouvelle tentative.
* Le script de résumé lit `JUNIT_PATH` dans la matrice et publie les nombres et
  les détails des tests dans le résumé de la tâche. Un fichier JUnit absent fait
  échouer cette étape.
* Les étapes de publication utilisent `if: always()` pour conserver le rapport
  HTML, le XML JUnit, les captures et les traces même après un échec, si ces
  fichiers ont été générés. Un chemin d'artefact absent fait échouer la publication.
  Les artefacts sont conservés pendant 30 jours.

{% endraw %}

### Exercice 2 : Pousser une modification

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

Vous pouvez aussi sélectionner **Actions > Playwright Tests > Run workflow** pour
exécuter le workflow sur `main` sans modifier un test, une fois le workflow fusionné.

### Exercice 3 : Suivre le pipeline

1. Ouvrez votre dépôt dans GitHub.
2. Sélectionnez l'onglet **Actions**.
3. Trouvez l'exécution déclenchée par votre PR ou votre lancement manuel.
4. Vérifiez les tâches **Playwright functional** et **Playwright accessibility**.
5. Ouvrez chaque tâche pour consulter ses étapes et ses journaux indépendamment.

Le workflow récupère le code, installe les dépendances et le navigateur, exécute
les tests et publie les artefacts. Chaque étape possède son propre journal.

### Exercice 4 : Consulter les résultats

Après l'exécution :

1. Vérifiez le statut global : réussite en vert ou échec en rouge.
2. Lisez le résumé de chaque tâche pour ses nombres de tests et ses échecs.
3. Dans **Artifacts**, retrouvez les quatre artefacts propres aux suites :

| Suite | Rapport HTML | JUnit, captures et traces |
| --- | --- | --- |
| Fonctionnelle | `playwright-report-functional` | `test-results-functional` |
| Accessibilité | `playwright-report-accessibility` | `test-results-accessibility` |

### Exercice 5 : Ouvrir le rapport HTML

1. Téléchargez et extrayez un artefact de rapport HTML.
2. Depuis `playwright-tests`, exécutez `npx playwright show-report <extracted-report-directory>`
   en remplaçant le paramètre par le répertoire extrait.
3. Explorez les noms, les durées, les statuts et les captures des tests en échec
   lorsqu'elles sont configurées.

Ces rapports correspondent aux commandes locales `npm run test:functional` et
`npm run test:accessibility`. Chaque rapport ne contient que sa propre suite.

### Exercice 6 : Discussion

Discutez de ces stratégies :

* Exiger les deux vérifications dans une règle de protection ou un ensemble de
  règles sur `main`. Le workflow seul ne bloque pas les fusions.
* Ajouter un déclencheur `schedule` nocturne pour détecter les changements du site externe.
* Étendre la matrice à d'autres navigateurs après avoir ajouté leurs projets et
  leurs étapes d'installation.

## Point de vérification

Les deux tâches terminent, chacune possède un résumé et les quatre artefacts
sont disponibles lorsque les tests s'exécutent. En cas d'échec du site en ligne,
identifiez la suite concernée et examinez son rapport au lieu de supposer que
tous les tests doivent réussir.

La suite fonctionnelle contient des tests `@failure-demo` volontairement en échec
pour pratiquer le diagnostic. Ils peuvent rendre la tâche rouge même si les
scénarios normaux réussissent. La tâche d'accessibilité doit terminer indépendamment.

## Résumé

Les pipelines CI/CD exécutent les tests à chaque modification sans intervention
manuelle. Le workflow automatise l'installation du navigateur, les tests et les
rapports dans un environnement propre pour détecter les régressions avant la production.

## Étape suivante

Continuez avec le [labo 05 : Tests d'accessibilité](../lab-05-accessibility/) pour
explorer axe, diagnostiquer les violations et pratiquer les vérifications manuelles.
Ce complément facultatif de 20 minutes suit le parcours principal d'une heure.

### Pour approfondir

* [Documentation Playwright](https://playwright.dev)
* [Microsoft Learn : tests de bout en bout avec Playwright](https://learn.microsoft.com/fr-fr/training/modules/build-with-playwright/)
* [Documentation GitHub Actions](https://docs.github.com/fr/actions)
* [Azure Test Plans](https://learn.microsoft.com/fr-fr/azure/devops/test/overview)
