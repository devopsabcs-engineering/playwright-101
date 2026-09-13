---
layout: default
title: "Labo 01 : Des récits utilisateurs aux cas de test"
nav_order: 3
description: "Relier les récits utilisateurs et les critères d'acceptation à des scénarios testables"
permalink: /fr/labs/lab-01-test-planning/
---

| | |
| --- | --- |
| **Durée** | 10 minutes |
| **Niveau** | Débutant |
| **Type** | Concepts et démonstration |

## Objectifs d'apprentissage

À la fin de ce labo, vous pourrez :

* Relier les récits utilisateurs aux critères d'acceptation, puis aux cas de test
* Dégager des scénarios testables à partir des exigences
* Organiser les cas de test selon leur priorité et leur complexité

## Prérequis

* Avoir terminé le [labo 00 : Prérequis](../lab-00-prerequisites/)

## Exercices

### Exercice 1 : Lire le récit utilisateur

Considérez ce récit utilisateur de ServiceOntario :

> **En tant que** citoyen,
> **je veux** rechercher des services gouvernementaux sur ontario.ca
> **afin de** trouver rapidement les renseignements dont j'ai besoin.

Ce récit décrit une fonction réelle d'ontario.ca. La suite de tests de l'atelier
cible précisément cette fonction et fournit un exemple concret pour chaque test.

### Exercice 2 : Définir les critères d'acceptation

Les critères d'acceptation définissent ce qui rend un récit utilisateur terminé.
À partir du récit ci-dessus, demandez-vous : « Quelles conditions doivent être
remplies pour que cette fonction soit correcte? »

| Nº | Critère d'acceptation |
| --- | --- |
| AC-1 | La recherche renvoie des résultats pertinents pour une requête donnée |
| AC-2 | Les résultats peuvent être filtrés par sujet |
| AC-3 | Les résultats peuvent être triés par date |
| AC-4 | La pagination fonctionne pour les ensembles de résultats volumineux |
| AC-5 | Une recherche vide ou incohérente affiche un message approprié |

Chaque critère peut être vérifié indépendamment, ce qui en fait une bonne base
pour un test automatisé.

### Exercice 3 : Créer les scénarios de test

Associez un scénario à chaque critère. Le tableau relie les critères aux tests
réels dans `ontario-search.spec.ts`. Les noms restent en anglais pour vous permettre
de les retrouver dans le fichier.

| Critère d'acceptation | Scénario de test | Nom du test dans le fichier |
| --- | --- | --- |
| AC-1 : Résultats de recherche | Vérifier les résultats pour « driver licence » | `search for driver licence returns results` |
| AC-2 : Filtre par sujet | Appliquer un filtre et vérifier la mise à jour des résultats | `filter by topic narrows results` |
| AC-3 : Tri par date | Choisir « Updated date » et vérifier le rechargement | `sort results by updated date` |
| AC-4 : Pagination | Passer à la page 2 et vérifier la page active | `pagination navigates to next page` |
| AC-5 : Recherche sans résultat | Saisir une requête incohérente et vérifier « 0 results » | `search with no results shows empty state` |

Deux autres tests complètent les scénarios normaux :

* `navigate to Ontario.ca search page` vérifie le chargement et le titre de la page
* `search input field is visible and functional` vérifie que le champ accepte
  de nouvelles requêtes

### Exercice 4 : Prioriser les scénarios de test

Classez les scénarios selon leur risque et leur incidence sur les utilisateurs :

1. **Résultats de recherche** : risque le plus élevé, fonction principale
2. **Filtre par sujet** : risque élevé, principal moyen d'affiner la recherche
3. **Tri par date** : risque moyen, moyen secondaire d'affiner les résultats
4. **Pagination** : risque moyen, nécessaire pour les longues listes
5. **Recherche sans résultat** : risque moindre, mais incidence sur la confiance
6. **Navigation de base** : risque moindre, fondation rarement défaillante seule
7. **Champ de recherche** : risque moindre, vérification de présence dans l'interface

Ce classement vous aide à décider où investir en premier lors de la création ou
de la maintenance d'une suite de tests.

### Exercice 5 : Discussion

Réfléchissez au passage des cas de test manuels à l'automatisation :

* Les critères d'acceptation restent les mêmes pour un test manuel ou automatisé.
* L'automatisation permet de répéter les mêmes assertions à chaque modification.
* Les tests manuels restent utiles pour les scénarios exploratoires difficiles à coder.
* Le tableau de l'exercice 3 devient votre liste de travaux d'automatisation.

> [!NOTE]
> En entreprise, des outils comme
> [Azure Test Plans](https://learn.microsoft.com/fr-fr/azure/devops/test/overview)
> assurent la traçabilité des exigences jusqu'aux résultats d'exécution.
> La démarche pratiquée ici s'applique aussi à ce processus.

## Point de vérification

Vous disposez de cinq à sept scénarios issus du récit utilisateur, chacun associé
à un critère d'acceptation et à un test nommé dans le fichier de spécification.

## Résumé

La planification est la base de l'automatisation. Vous avez transformé un récit
utilisateur en critères d'acceptation, relié ces critères à des scénarios concrets
et classé les scénarios selon le risque. Le prochain labo les met en pratique avec
Playwright.

## Étape suivante

Passez au [labo 02 : Votre premier test Playwright](../lab-02-playwright-basics/).
