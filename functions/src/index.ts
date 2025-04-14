/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onCall} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// Initialize Firebase Admin
admin.initializeApp();

interface NotificationData {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

// Cloud Function to send push notifications
export const sendPushNotification = onCall<NotificationData>(
  async (request) => {
    // Check if the user is authenticated
    if (!request.auth) {
      throw new Error("The function must be called while authenticated.");
    }

    const {token, title, body, data: messageData} = request.data;

    // Validate the input
    if (!token || !title || !body) {
      throw new Error(
        "The function must be called with token, title, and body."
      );
    }

    try {
      // Send the notification using Firebase Admin SDK
      await admin.messaging().send({
        token,
        notification: {
          title,
          body,
        },
        data: messageData,
        android: {
          priority: "high",
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              contentAvailable: true,
            },
          },
        },
      });

      return {success: true};
    } catch (error) {
      console.error("Error sending notification:", error);
      throw new Error("Error sending notification.");
    }
  }
);
