# Alerte des demandes d'écoute

Quand quelqu'un dépose une demande d'écoute dans l'application, un courriel
part vers le responsable. Sans cela, la demande resterait invisible : les
règles Firestore ne la rendent lisible que par son auteur.

## Ce qu'il faut avant de déployer

1. **Le plan Blaze.** Les Cloud Functions n'existent pas sur le plan Spark.
   Blaze se facture à l'usage et comporte un palier gratuit : à quelques
   demandes par mois, la facture reste à zéro. Une carte bancaire est
   néanmoins exigée par Google.
   Console → *Paramètres du projet* → *Utilisation et facturation*.

2. **Un compte d'envoi.** N'importe quel serveur SMTP convient. Avec Gmail, il
   faut créer un *mot de passe d'application* (le mot de passe du compte est
   refusé), ce qui suppose la validation en deux étapes activée.

## Configuration

L'adresse du responsable et les identifiants ne sont pas dans le dépôt. Ils se
posent une fois, depuis ce dossier :

```bash
firebase functions:secrets:set SMTP_MOTDEPASSE
```

Les autres valeurs se saisissent au premier déploiement, ou dans un fichier
`.env` local (ignoré par git) :

```
SMTP_HOTE=smtp.gmail.com
SMTP_PORT=465
SMTP_UTILISATEUR=envoi@exemple.org
DESTINATAIRE=responsable@exemple.org
```

`DESTINATAIRE` accepte plusieurs adresses séparées par des virgules.

## Déploiement

```bash
cd functions && npm install
firebase deploy --only functions --project mlkitdemo-71316
```

Le `firebase.json` de la racine doit déclarer les fonctions. Il n'est pas
versionné (il porte les identifiants du projet), donc cette section est à
ajouter à la main sur une machine neuve :

```json
"functions": [{ "source": "functions", "codebase": "default" }]
```

## Vérifier

Déposer une demande depuis l'application, puis :

```bash
firebase functions:log --only alerteDemandeEcoute
```

## Ce que le courriel contient

Le type de demande, le sujet, le message, et la façon dont la personne veut
être recontactée. Le sujet du courriel reste volontairement sobre
(« Nouvelle demande : Être écouté ») : il s'affiche sur un écran de veille,
parfois devant d'autres personnes.

Ces messages sont des confidences. Elles transitent par le serveur d'envoi
choisi et se retrouvent dans la boîte du responsable : mieux vaut une adresse
dédiée, relevée par les seules personnes habilitées, qu'une boîte partagée.

## Ce que cela ne fait pas

Le courriel prévient, il ne permet pas de suivre. Marquer une demande comme
prise en charge puis terminée se fait encore dans la console Firebase,
collection `demandes_ecoute`, champ `statut`. Un écran d'administration dans
l'application reste à faire.
