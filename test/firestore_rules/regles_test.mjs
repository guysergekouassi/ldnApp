// Banc d'essai des règles Firestore, exécuté contre l'émulateur.
// Vérifie que l'application garde tous ses accès, et que rien de plus ne passe.
import fs from 'node:fs';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, deleteDoc, collection, getDocs, query, where } from 'firebase/firestore';

const REGLES = process.argv[2];

let reussis = 0;
let echoues = 0;

async function verifie(nom, promesse) {
  try {
    await promesse;
    reussis++;
    console.log('  OK   ' + nom);
  } catch (e) {
    echoues++;
    console.log('  ÉCHEC ' + nom + ' → ' + (e.message || e).toString().split('\n')[0]);
  }
}

const env = await initializeTestEnvironment({
  projectId: 'jep-rules-test',
  firestore: { rules: fs.readFileSync(REGLES, 'utf8'), host: '127.0.0.1', port: 8080 },
});

const alice = env.authenticatedContext('alice').firestore();
const bob = env.authenticatedContext('bob').firestore();
const anonyme = env.unauthenticatedContext().firestore();
// Le responsable de la communauté : il a un document dans `admins`.
const responsable = env.authenticatedContext('chantal').firestore();

// Contenu de départ, écrit en contournant les règles.
await env.withSecurityRulesDisabled(async (ctx) => {
  const db = ctx.firestore();
  await setDoc(doc(db, 'users/alice'), { fullName: 'Alice', email: 'a@x.fr' });
  await setDoc(doc(db, 'users/alice/challenges/defi1'), { completedDays: [] });
  await setDoc(doc(db, 'neuvaines/n1'), { title: 'Neuvaine' });
  await setDoc(doc(db, 'bible_plans/marc'), { title: 'Marc', readings: [] });
  await setDoc(doc(db, 'posts/p1'), { content: 'salut', likes: 0 });
  await setDoc(doc(db, 'intentions/i1'), { title: 'Pour la paix', count: 0 });
  await setDoc(doc(db, 'temoignages/t1'), { authorUid: 'alice', content: 'merci', likes: 0 });
  await setDoc(doc(db, 'temoignages/t2'), { authorUid: 'bob', content: 'merci', likes: 0 });
  await setDoc(doc(db, 'secret_non_declare/x'), { a: 1 });
  await setDoc(doc(db, 'fraternities/g1'), { name: 'Fratrie Cocody', memberCount: 0 });
  await setDoc(doc(db, 'sondages/s1'), { question: 'Q', options: ['a', 'b'], voix: [0, 0], semaine: '2026-S38' });
  await setDoc(doc(db, 'users/alice/stats/discipline'), { engagements: ['chapelet'] });
  await setDoc(doc(db, 'aide_besoins/deuil'), { titre: 'Je traverse un deuil', ordre: 1 });
  await setDoc(doc(db, 'parcours_avis/p1__alice'), { parcoursId: 'p1', authorUid: 'alice', note: 5 });
  await setDoc(doc(db, 'demandes_ecoute/d1'), { uid: 'alice', type: 'ecoute', message: 'besoin de parler' });
  await setDoc(doc(db, 'demandes_ecoute/d2'), { uid: 'bob', type: 'ecoute', message: 'prive' });
  await setDoc(doc(db, 'admins/chantal'), { nom: 'Chantal' });
});

console.log('\n— Ce que l’application doit pouvoir faire —');
await verifie('alice lit son profil', assertSucceeds(getDoc(doc(alice, 'users/alice'))));
await verifie('alice écrit son profil', assertSucceeds(setDoc(doc(alice, 'users/alice'), { fullName: 'Alice B' }, { merge: true })));
await verifie('alice suit un défi', assertSucceeds(updateDoc(doc(alice, 'users/alice/challenges/defi1'), { completedDays: ['2026-09-18'] })));
await verifie('alice épingle une intention', assertSucceeds(setDoc(doc(alice, 'users/alice/pinnedIntentions/i1'), { pinnedAt: 1 })));
await verifie('alice lit les neuvaines', assertSucceeds(getDoc(doc(alice, 'neuvaines/n1'))));
await verifie('alice amorce un plan de lecture', assertSucceeds(setDoc(doc(alice, 'bible_plans/philippiens'), { title: 'Ph', readings: [] })));
await verifie('alice lit le fil d’actualité', assertSucceeds(getDocs(collection(alice, 'posts'))));
await verifie('alice aime une publication', assertSucceeds(updateDoc(doc(alice, 'posts/p1'), { likes: 1 })));
await verifie('alice publie une intention', assertSucceeds(setDoc(doc(alice, 'intentions/i2'), { title: 'x', count: 0 })));
await verifie('alice s’unit à une intention', assertSucceeds(updateDoc(doc(alice, 'intentions/i1'), { count: 1 })));
await verifie('alice dépose un témoignage en son nom', assertSucceeds(setDoc(doc(alice, 'temoignages/t3'), { authorUid: 'alice', content: 'ok' })));
await verifie('bob aime le témoignage d’alice', assertSucceeds(updateDoc(doc(bob, 'temoignages/t1'), { likes: 1 })));
await verifie('alice supprime son témoignage', assertSucceeds(deleteDoc(doc(alice, 'temoignages/t3'))));
await verifie('alice écrit au classement', assertSucceeds(setDoc(doc(alice, 'gamification_leaderboard/alice'), { uid: 'alice', points: 10 })));
await verifie('alice enregistre sa règle de vie', assertSucceeds(setDoc(doc(alice, 'users/alice/stats/discipline'), { engagements: ['chapelet', 'messe'] })));
await verifie('alice coche un engagement du jour', assertSucceeds(setDoc(doc(alice, 'users/alice/discipline_progress/2026-09-18'), { engagements: ['chapelet'] })));
await verifie('alice lit l’annuaire des groupes', assertSucceeds(getDocs(collection(alice, 'fraternities'))));
await verifie('alice rejoint un groupe', assertSucceeds(setDoc(doc(alice, 'users/alice/groupes/g1'), { name: 'Fratrie Cocody' })));
await verifie('l’effectif du groupe est mis à jour', assertSucceeds(updateDoc(doc(alice, 'fraternities/g1'), { memberCount: 1 })));
await verifie('alice lit le sondage', assertSucceeds(getDoc(doc(alice, 'sondages/s1'))));
await verifie('alice vote', assertSucceeds(updateDoc(doc(alice, 'sondages/s1'), { voix: [1, 0] })));
await verifie('alice enregistre son vote', assertSucceeds(setDoc(doc(alice, 'users/alice/votes/s1'), { option: 0 })));
await verifie('alice lit les besoins d’aide', assertSucceeds(getDocs(collection(alice, 'aide_besoins'))));
await verifie('alice lit les avis d’un parcours', assertSucceeds(getDocs(query(collection(alice, 'parcours_avis'), where('parcoursId', '==', 'p1')))));
await verifie('alice dépose son avis', assertSucceeds(setDoc(doc(alice, 'parcours_avis/p2__alice'), { parcoursId: 'p2', authorUid: 'alice', note: 4 })));
await verifie('alice modifie son avis', assertSucceeds(setDoc(doc(alice, 'parcours_avis/p1__alice'), { parcoursId: 'p1', authorUid: 'alice', note: 3 })));
await verifie('alice dépose une demande d’écoute', assertSucceeds(setDoc(doc(alice, 'demandes_ecoute/d3'), { uid: 'alice', message: 'aide' })));
await verifie('alice relit ses demandes', assertSucceeds(getDocs(query(collection(alice, 'demandes_ecoute'), where('uid', '==', 'alice')))));
await verifie('alice annule sa demande', assertSucceeds(deleteDoc(doc(alice, 'demandes_ecoute/d3'))));

console.log('\n— Ce qui doit être refusé —');
await verifie('bob ne lit pas le profil d’alice', assertFails(getDoc(doc(bob, 'users/alice'))));
await verifie('bob n’écrit pas le profil d’alice', assertFails(setDoc(doc(bob, 'users/alice'), { fullName: 'pirate' })));
await verifie('bob ne lit pas la progression d’alice', assertFails(getDoc(doc(bob, 'users/alice/challenges/defi1'))));
await verifie('bob ne supprime pas le témoignage d’alice', assertFails(deleteDoc(doc(bob, 'temoignages/t1'))));
await verifie('alice ne publie pas au nom de bob', assertFails(setDoc(doc(alice, 'temoignages/t4'), { authorUid: 'bob', content: 'faux' })));
await verifie('on ne supprime pas une publication', assertFails(deleteDoc(doc(alice, 'posts/p1'))));
await verifie('on ne supprime pas une intention', assertFails(deleteDoc(doc(alice, 'intentions/i1'))));
await verifie('on ne supprime pas un profil', assertFails(deleteDoc(doc(alice, 'users/alice'))));
await verifie('bob ne lit pas la règle de vie d’alice', assertFails(getDoc(doc(bob, 'users/alice/stats/discipline'))));
await verifie('bob ne voit pas le vote d’alice', assertFails(getDoc(doc(bob, 'users/alice/votes/s1'))));
await verifie('on ne supprime pas un sondage', assertFails(deleteDoc(doc(alice, 'sondages/s1'))));
await verifie('bob ne lit pas la demande d’écoute d’alice', assertFails(getDoc(doc(bob, 'demandes_ecoute/d1'))));
await verifie('bob ne liste pas toutes les demandes', assertFails(getDocs(collection(bob, 'demandes_ecoute'))));
await verifie('bob ne liste pas les demandes d’alice', assertFails(getDocs(query(collection(bob, 'demandes_ecoute'), where('uid', '==', 'alice')))));
await verifie('bob ne supprime pas la demande d’alice', assertFails(deleteDoc(doc(bob, 'demandes_ecoute/d1'))));
await verifie('bob ne dépose pas une demande au nom d’alice', assertFails(setDoc(doc(bob, 'demandes_ecoute/d4'), { uid: 'alice', message: 'usurpation' })));
await verifie('la responsable lit toutes les demandes', assertSucceeds(getDocs(collection(responsable, 'demandes_ecoute'))));
await verifie('la responsable lit la demande d’alice', assertSucceeds(getDoc(doc(responsable, 'demandes_ecoute/d1'))));
await verifie('la responsable prend une demande en charge', assertSucceeds(updateDoc(doc(responsable, 'demandes_ecoute/d1'), { statut: 'prise_en_charge', traitePar: 'chantal' })));
await verifie('la responsable sait qu’elle est responsable', assertSucceeds(getDoc(doc(responsable, 'admins/chantal'))));

console.log('\n— Ce qui doit rester refusé, même à un responsable —');
await verifie('la responsable ne réécrit pas le message d’alice', assertFails(updateDoc(doc(responsable, 'demandes_ecoute/d1'), { message: 'réécrit' })));
await verifie('la responsable ne réattribue pas la demande', assertFails(updateDoc(doc(responsable, 'demandes_ecoute/d1'), { uid: 'chantal' })));
await verifie('la responsable ne supprime pas la demande d’alice', assertFails(deleteDoc(doc(responsable, 'demandes_ecoute/d1'))));
await verifie('bob ne se déclare pas responsable', assertFails(setDoc(doc(bob, 'admins/bob'), { nom: 'Bob' })));
await verifie('bob ne lit pas la liste des responsables', assertFails(getDoc(doc(bob, 'admins/chantal'))));

await verifie('bob ne signe pas un avis au nom d’alice', assertFails(setDoc(doc(bob, 'parcours_avis/p3__alice'), { parcoursId: 'p3', authorUid: 'alice', note: 1 })));
await verifie('bob ne supprime pas l’avis d’alice', assertFails(deleteDoc(doc(bob, 'parcours_avis/p1__alice'))));
await verifie('une collection non déclarée est fermée', assertFails(getDoc(doc(alice, 'secret_non_declare/x'))));
await verifie('un visiteur non connecté ne lit rien', assertFails(getDoc(doc(anonyme, 'neuvaines/n1'))));
await verifie('un visiteur non connecté n’écrit rien', assertFails(setDoc(doc(anonyme, 'posts/p2'), { content: 'spam' })));
await verifie('un visiteur non connecté ne lit pas le fil', assertFails(getDocs(collection(anonyme, 'posts'))));

await env.cleanup();

console.log(`\n${reussis} vérification(s) au vert, ${echoues} au rouge.`);
process.exit(echoues === 0 ? 0 : 1);
