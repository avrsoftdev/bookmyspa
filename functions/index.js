const { onDocumentUpdated, onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
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
    await admin.firestore().collection("notifications").add({
      userId: ownerUid,
      spaId: event.params.spaId,
      type: "approved",
      title: message.notification.title,
      body: message.notification.body,
      ts: new Date().toISOString(),
      read: false
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
    await admin.firestore().collection("notifications").add({
      userId: ownerUid,
      spaId: event.params.spaId,
      type: "rejected",
      title: message.notification.title,
      body: message.notification.body,
      rejectionReason: reason,
      ts: new Date().toISOString(),
      read: false
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
      body: "Thanks for submitting your business details! You’ll be notified once approved"
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
    await admin.firestore().collection("notifications").add({
      userId: ownerUid,
      spaId: event.params.spaId,
      type: "submission",
      title: message.notification.title,
      body: message.notification.body,
      ts: new Date().toISOString(),
      read: false
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

exports.onBookingCreated = onDocumentCreated("bookings/{bookingId}", async (event) => {
  const booking = event.data?.data() || {};
  const spaId = booking.spaId;
  const bookingId = event.params.bookingId;
  console.log(`[onBookingCreated] Triggered for booking ${bookingId} spaId=${spaId}`);

  if (!spaId) return;
  const transactionId = (booking.transactionId || "").toString();
  
  try {
    const spaDoc = await admin.firestore().collection("spas").doc(spaId).get();
    const spa = spaDoc.data() || {};
    const ownerUid = spa.ownerUid;
    
    if (!ownerUid) {
      console.log(`[onBookingCreated] No ownerUid for spa ${spaId}`);
      return;
    }
    
    // Deduplicate: only notify once per transaction
    if (transactionId) {
      const existingSnap = await admin.firestore().collection("notifications")
        .where("userId", "==", ownerUid)
        .where("spaId", "==", spaId)
        .where("type", "==", "booking")
        .where("transactionId", "==", transactionId)
        .limit(1)
        .get();
      if (!existingSnap.empty) {
        console.log(`[onBookingCreated] Duplicate notification for transaction ${transactionId}`);
        return;
      }
    }
    
    const ownerDoc = await admin.firestore().collection("users").doc(ownerUid).get();
    const ownerData = ownerDoc.data() || {};
    const tokens = Array.isArray(ownerData.fcmTokens) ? ownerData.fcmTokens.filter(Boolean) : [];
    
    console.log(`[onBookingCreated] Sending to owner ${ownerUid}, tokens: ${tokens.length}`);

    const message = {
      notification: {
        title: "New booking received!",
        body: "Tap to view details."
      },
      data: {
        type: "booking",
        spaId,
        bookingId: bookingId,
        transactionId
      }
    };

    if (tokens.length) {
      const res = await admin.messaging().sendEachForMulticast({
        tokens,
        notification: message.notification,
        data: message.data
      });
      console.log(`[onBookingCreated] Owner push result: success=${res.successCount} failure=${res.failureCount}`);
      
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
          console.log(`[onBookingCreated] Removing ${invalidTokens.length} invalid tokens`);
          await admin.firestore().collection("users").doc(ownerUid).update({
            fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens)
          });
        }
      }
    } else {
      console.log(`[onBookingCreated] No tokens for owner ${ownerUid}`);
    }

    // Owner notification
    await admin.firestore().collection("notifications").add({
      userId: ownerUid,
      spaId,
      bookingId: bookingId,
      type: "booking",
      transactionId,
      title: message.notification.title,
      body: message.notification.body,
      ts: new Date().toISOString(),
      read: false
    });

    // Customer notification (single per transaction)
    const customerUid = (booking.userId || "").toString();
    if (customerUid) {
      const customerExisting = transactionId
        ? await admin.firestore().collection("notifications")
            .where("userId", "==", customerUid)
            .where("spaId", "==", spaId)
            .where("type", "==", "booking")
            .where("transactionId", "==", transactionId)
            .limit(1)
            .get()
        : { empty: true };
      
      if (customerExisting.empty) {
        const customerDoc = await admin.firestore().collection("users").doc(customerUid).get();
        const customerData = customerDoc.data() || {};
        const customerTokens = Array.isArray(customerData.fcmTokens) ? customerData.fcmTokens.filter(Boolean) : [];
        
        console.log(`[onBookingCreated] Sending to customer ${customerUid}, tokens: ${customerTokens.length}`);
        
        if (customerTokens.length) {
          await admin.messaging().sendEachForMulticast({
            tokens: customerTokens,
            notification: {
              title: "Booking confirmed!",
              body: "Tap to view your booking."
            },
            data: {
              type: "booking",
              spaId,
              transactionId
            }
          });
        }
        await admin.firestore().collection("notifications").add({
          userId: customerUid,
          spaId,
          type: "booking",
          transactionId,
          title: "Booking confirmed!",
          body: "Tap to view your booking.",
          ts: new Date().toISOString(),
          read: false
        });
      } else {
        console.log(`[onBookingCreated] Customer notification already exists for ${transactionId}`);
      }
    }
  } catch (e) {
    console.error("[onBookingCreated] Error", e);
  }
});

// Diagnostic: send a test push to a user's saved FCM tokens.
// Call: GET/POST with ?uid=<userId> or body { uid }
exports.sendTestPush = onRequest(async (req, res) => {
  try {
    const uid = (req.query.uid || (req.body && req.body.uid) || "").toString();
    if (!uid) {
      res.status(400).json({ ok: false, error: "uid required" });
      return;
    }
    const userDoc = await admin.firestore().collection("users").doc(uid).get();
    const data = userDoc.data() || {};
    const tokens = Array.isArray(data.fcmTokens) ? data.fcmTokens.filter(Boolean) : [];
    if (!tokens.length) {
      res.status(200).json({ ok: true, sent: 0, message: "No tokens for user" });
      return;
    }
    const result = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: "Test notification",
        body: "This is a test push from Cloud Functions."
      },
      data: {
        type: "test"
      }
    });
    const failed = result.responses.filter((r) => !r.success);
    if (failed.length) {
      const invalidTokens = failed
        .map((r, i) => ({ r, token: tokens[i] }))
        .filter((x) => {
          const code = x.r.error && x.r.error.code;
          return code === "messaging/registration-token-not-registered" || code === "messaging/invalid-argument";
        })
        .map((x) => x.token);
      if (invalidTokens.length) {
        await admin.firestore().collection("users").doc(uid).update({
          fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens)
        });
      }
    }
    res.status(200).json({ ok: true, sent: tokens.length, failed: failed.length });
  } catch (e) {
    console.error("sendTestPush error", e);
    res.status(500).json({ ok: false, error: e.message || String(e) });
  }
});
