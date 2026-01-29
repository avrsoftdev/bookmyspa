const { onDocumentUpdated, onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onSpaApproved = onDocumentUpdated("spas/{spaId}", async (event) => {
  const before = event.data.before.data() || {};
  const after = event.data.after.data() || {};
  const beforeStatus = before.status;
  const afterStatus = after.status;
  if (beforeStatus === afterStatus) return;
  if (afterStatus !== "approved") return;
  const ownerUid = after.ownerUid;
  if (!ownerUid) return;
  const userDoc = await admin.firestore().collection("users").doc(ownerUid).get();
  const data = userDoc.data() || {};
  const tokens = Array.isArray(data.fcmTokens) ? data.fcmTokens.filter(Boolean) : [];
  if (!tokens.length) return;
  const message = {
    notification: {
      title: "Congratulations!",
      body: "Congratulations!, Your Business is now listed"
    },
    data: {
      spaId: event.params.spaId
    }
  };
  try {
    const res = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: message.notification,
      data: message.data
    });
    const failed = res.responses.filter((r) => !r.success);
    if (failed.length) {
      const invalidTokens = failed
        .map((r, i) => ({ r, token: tokens[i] }))
        .filter((x) => {
          const code = x.r.error && x.r.error.code;
          return code === "messaging/registration-token-not-registered" || code === "messaging/invalid-argument";
        })
        .map((x) => x.token);
      if (invalidTokens.length) {
        await admin.firestore().collection("users").doc(ownerUid).update({
          fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens)
        });
      }
    }
  } catch (e) {
    console.error("FCM send error", e);
  }
});

exports.onSpaRejected = onDocumentUpdated("spas/{spaId}", async (event) => {
  const before = event.data.before.data() || {};
  const after = event.data.after.data() || {};
  const beforeStatus = before.status;
  const afterStatus = after.status;
  if (beforeStatus === afterStatus) return;
  if (afterStatus !== "rejected") return;
  const ownerUid = after.ownerUid;
  if (!ownerUid) return;
  const userDoc = await admin.firestore().collection("users").doc(ownerUid).get();
  const data = userDoc.data() || {};
  const tokens = Array.isArray(data.fcmTokens) ? data.fcmTokens.filter(Boolean) : [];
  if (!tokens.length) return;
  const reason = (after.rejectionReason || "").toString();
  const body = reason
    ? `Your business has been rejected. Reason: ${reason}`
    : "Your business has been rejected.";
  const message = {
    notification: {
      title: "Update on your business",
      body
    },
    data: {
      spaId: event.params.spaId,
      type: "rejected"
    }
  };
  try {
    const res = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: message.notification,
      data: message.data
    });
    const failed = res.responses.filter((r) => !r.success);
    if (failed.length) {
      const invalidTokens = failed
        .map((r, i) => ({ r, token: tokens[i] }))
        .filter((x) => {
          const code = x.r.error && x.r.error.code;
          return code === "messaging/registration-token-not-registered" || code === "messaging/invalid-argument";
        })
        .map((x) => x.token);
      if (invalidTokens.length) {
        await admin.firestore().collection("users").doc(ownerUid).update({
          fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens)
        });
      }
    }
  } catch (e) {
    console.error("FCM send error", e);
  }
});

exports.onSpaSubmitted = onDocumentCreated("spas/{spaId}", async (event) => {
  const after = event.data?.data() || {};
  const ownerUid = after.ownerUid;
  if (!ownerUid) return;
  const userDoc = await admin.firestore().collection("users").doc(ownerUid).get();
  const data = userDoc.data() || {};
  const tokens = Array.isArray(data.fcmTokens) ? data.fcmTokens.filter(Boolean) : [];
  if (!tokens.length) return;
  const message = {
    notification: {
      title: "Thank you!",
      body: "Thanks for submitting your business details! Our team will review them shortly. You’ll be notified once approved"
    },
    data: {
      spaId: event.params.spaId,
      type: "submission"
    }
  };
  try {
    const res = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: message.notification,
      data: message.data
    });
    const failed = res.responses.filter((r) => !r.success);
    if (failed.length) {
      const invalidTokens = failed
        .map((r, i) => ({ r, token: tokens[i] }))
        .filter((x) => {
          const code = x.r.error && x.r.error.code;
          return code === "messaging/registration-token-not-registered" || code === "messaging/invalid-argument";
        })
        .map((x) => x.token);
      if (invalidTokens.length) {
        await admin.firestore().collection("users").doc(ownerUid).update({
          fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens)
        });
      }
    }
  } catch (e) {
    console.error("FCM send error", e);
  }
});
