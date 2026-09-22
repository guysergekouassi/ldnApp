# Banc d'essai des règles Firestore

Vérifie [`firestore.rules`](../../firestore.rules) contre l'émulateur Firestore :
d'un côté tout ce que l'application doit pouvoir faire, de l'autre tout ce qui
doit rester refusé.

Ces tests ne passent pas par `flutter test` — ce sont des tests JavaScript, car
l'outil officiel de test des règles (`@firebase/rules-unit-testing`) n'existe
qu'en JS. Ils tournent hors de l'application, sur l'émulateur.

## Lancer les tests

```bash
cd test/firestore_rules
npm install
npm test
```

Sortie attendue : `51 vérification(s) au vert, 0 au rouge.`

## Prérequis

- Node 18 ou plus.
- Un JDK 11 ou plus, pour l'émulateur Firestore. Le `firebase-tools` installé
  ici est volontairement figé en version 13 : à partir de la 15, l'émulateur
  réclame un JDK 21.

## Quand les relancer

À chaque modification de `firestore.rules`, **avant** de déployer avec :

```bash
firebase deploy --only firestore:rules --project mlkitdemo-71316
```

Un déploiement remplace les règles en production pour tous les utilisateurs.
Un joker récursif mal placé y suffit : `match /{chemin=**}` correspond aussi à
*zéro* segment, et couvre donc le document parent en plus de ses
sous-collections — c'est précisément le défaut que ces tests ont attrapé sur la
première version des règles.

## Ce qui n'est pas couvert ici

L'activation des fournisseurs d'authentification (Google, email, **anonyme**)
ne relève pas des règles Firestore : elle se fait dans la console Firebase,
sous *Authentication → Sign-in method*.
