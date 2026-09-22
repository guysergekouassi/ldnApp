/**
 * Prévient un responsable par courriel dès qu'une demande d'écoute arrive.
 *
 * Les demandes d'écoute ne sont lisibles que par leur auteur (voir
 * `firestore.rules`) : sans cette alerte, elles dormiraient dans Firestore
 * jusqu'à ce que quelqu'un pense à ouvrir la console. Quelqu'un qui demande à
 * être écouté ne doit pas attendre.
 *
 * Rien n'est écrit en dur ici : l'adresse du responsable et les identifiants
 * d'envoi sont des secrets, posés à l'extérieur du dépôt (voir README.md).
 */

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { defineSecret, defineString } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const nodemailer = require("nodemailer");

const SMTP_HOTE = defineString("SMTP_HOTE", {
  description: "Serveur d'envoi, par exemple smtp.gmail.com",
});
const SMTP_PORT = defineString("SMTP_PORT", { default: "465" });
const SMTP_UTILISATEUR = defineString("SMTP_UTILISATEUR", {
  description: "Compte d'envoi",
});
const SMTP_MOTDEPASSE = defineSecret("SMTP_MOTDEPASSE");
const DESTINATAIRE = defineString("DESTINATAIRE", {
  description: "Adresse du ou des responsables, séparées par des virgules",
});

/** Libellés, repris du modèle Dart pour que le courriel se lise comme l'app. */
const TYPES = {
  ecoute: "Être écouté",
  accompagnement: "Un accompagnement spirituel",
  priere: "Être porté dans la prière",
  question: "Poser une question sur la foi",
};

const MOYENS = {
  app: "Dans l'application",
  telephone: "Par téléphone",
  whatsapp: "Par WhatsApp",
  email: "Par email",
  personne: "En personne, lors d'une rencontre",
};

/** Neutralise le HTML : le message vient d'un formulaire, pas d'un gabarit. */
function echapper(texte) {
  return String(texte || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

exports.alerteDemandeEcoute = onDocumentCreated(
  {
    document: "demandes_ecoute/{demandeId}",
    region: "europe-west1",
    secrets: [SMTP_MOTDEPASSE],
    retry: false,
  },
  async (event) => {
    const demande = event.data && event.data.data();
    if (!demande) return;

    const destinataire = DESTINATAIRE.value();
    if (!destinataire) {
      logger.error(
        "Aucun destinataire configuré : la demande " +
          event.params.demandeId +
          " n'a été signalée à personne."
      );
      return;
    }

    const type = TYPES[demande.type] || "Demande";
    const moyen = MOYENS[demande.moyenContact] || "Au choix";
    const coordonnee = (demande.coordonnee || "").trim();
    const sujet = (demande.sujet || "").trim() || "(sans sujet)";

    const corps = `
      <p><strong>${echapper(type)}</strong></p>
      <p><strong>Sujet :</strong> ${echapper(sujet)}</p>
      <p style="white-space:pre-wrap">${echapper(demande.message)}</p>
      <hr>
      <p><strong>Recontacter :</strong> ${echapper(moyen)}${
      coordonnee ? " &mdash; " + echapper(coordonnee) : ""
    }</p>
      <p style="color:#666;font-size:12px">
        Demande ${echapper(event.params.demandeId)}.
        Elle reste consultable dans Firestore, collection
        <code>demandes_ecoute</code>, pour y noter son avancement.
      </p>
    `;

    const transport = nodemailer.createTransport({
      host: SMTP_HOTE.value(),
      port: Number(SMTP_PORT.value()),
      secure: Number(SMTP_PORT.value()) === 465,
      auth: {
        user: SMTP_UTILISATEUR.value(),
        pass: SMTP_MOTDEPASSE.value(),
      },
    });

    try {
      await transport.sendMail({
        from: `"Application JEP" <${SMTP_UTILISATEUR.value()}>`,
        to: destinataire,
        // Le sujet reste sobre : il s'affiche sur un écran de veille, parfois
        // devant d'autres personnes.
        subject: `Nouvelle demande : ${type}`,
        html: corps,
      });
      logger.info("Demande " + event.params.demandeId + " signalée.");
    } catch (erreur) {
      // On journalise sans relancer : un envoi raté ne doit pas faire rejouer
      // la fonction et envoyer deux fois la même confidence.
      logger.error("Envoi impossible : " + erreur.message);
    }
  }
);
