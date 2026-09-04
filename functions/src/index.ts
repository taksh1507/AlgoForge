import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

/**
 * syncLeetCodeData
 * Triggered by HTTPS callable from Flutter app.
 * Fetches user data from Alfa LeetCode API and writes to Firestore.
 */
export const syncLeetCodeData = functions.https.onCall(async (data, context) => {
  const { username, uid } = data;

  if (!username || !uid) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Username and UID are required"
    );
  }

  const BASE_URL = "https://alfa-leetcode-api.onrender.com";

  try {
    // Fetch from Alfa API
    const [profileRes, solvedRes, skillRes, submissionRes] = await Promise.all([
      fetch(`${BASE_URL}/${username}`),
      fetch(`${BASE_URL}/${username}/solved`),
      fetch(`${BASE_URL}/${username}/skill`),
      fetch(`${BASE_URL}/${username}/acSubmission?limit=50`),
    ]);

    const profile = await profileRes.json();
    const solved = await solvedRes.json();
    const skill = await skillRes.json();
    const submissions = await submissionRes.json();

    // Write user profile
    await db.collection("users").doc(uid).set({
      username,
      displayName: profile.name || username,
      rating: profile.rating || 0,
      totalSolved: solved.totalSolved || 0,
      easySolved: solved.easySolved || 0,
      mediumSolved: solved.mediumSolved || 0,
      hardSolved: solved.hardSolved || 0,
      contestRanking: profile.contestRanking || 0,
      streak: profile.streak || 0,
      syncedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // Write skill scores
    if (skill?.tagProblemCounts) {
      const skillBatch = db.batch();
      const skillsRef = db.collection("users").doc(uid).collection("skills");

      for (const [topic, count] of Object.entries(skill.tagProblemCounts)) {
        const topicData = count as any;
        const solved = (topicData?.easy || 0) + (topicData?.medium || 0) + (topicData?.hard || 0);
        const score = Math.min(100, solved * 10); // Simple scoring

        skillBatch.set(skillsRef.doc(topic), {
          topic,
          score,
          problemsSolved: solved,
          problemsAttempted: solved,
          avgTimeMin: 0,
          avgConfidence: 3,
          recentTrend: 0,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      await skillBatch.commit();
    }

    // Write recent submissions as attempts
    if (Array.isArray(submissions)) {
      const attemptBatch = db.batch();
      const attemptsRef = db.collection("users").doc(uid).collection("attempts");

      for (const sub of submissions.slice(0, 20)) {
        attemptBatch.set(attemptsRef.doc(), {
          problemSlug: sub.titleSlug || "",
          problemTitle: sub.title || "",
          status: sub.statusDisplay || "SOLVED",
          timeTakenMin: 0,
          attempts: 1,
          hintsUsed: 0,
          solutionViewed: false,
          confidence: 3,
          topics: [],
          difficulty: sub.difficulty || "MEDIUM",
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      await attemptBatch.commit();
    }

    return { success: true, message: "Sync complete" };
  } catch (error) {
    console.error("Sync error:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to sync LeetCode data"
    );
  }
});

/**
 * calculateSkills
 * Triggered after new attempts are written.
 * Recalculates skill scores.
 */
export const calculateSkills = functions.firestore
  .document("users/{uid}/attempts/{attemptId}")
  .onWrite(async (change, context) => {
    const uid = context.params.uid;

    // Get all attempts for this user
    const attemptsSnap = await db
      .collection("users")
      .doc(uid)
      .collection("attempts")
      .orderBy("timestamp", "desc")
      .limit(50)
      .get();

    const attempts = attemptsSnap.docs.map((doc) => doc.data());

    // Group by topic and calculate scores
    const topicMap: Record<string, any[]> = {};
    for (const attempt of attempts) {
      const topics = attempt.topics || [];
      for (const topic of topics) {
        if (!topicMap[topic]) topicMap[topic] = [];
        topicMap[topic].push(attempt);
      }
    }

    // Write skill scores
    const batch = db.batch();
    const skillsRef = db.collection("users").doc(uid).collection("skills");

    for (const [topic, topicAttempts] of Object.entries(topicMap)) {
      const solved = topicAttempts.filter(
        (a) => a.status === "SOLVED" || a.status === "MASTERED"
      ).length;
      const total = topicAttempts.length;
      const score = total > 0 ? (solved / total) * 100 : 0;

      batch.set(skillsRef.doc(topic), {
        topic,
        score: Math.min(100, score),
        problemsAttempted: total,
        problemsSolved: solved,
        avgTimeMin: 0,
        avgConfidence: 3,
        recentTrend: 0,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  });

/**
 * revisionGenerator
 * Nightly cron job to update revision cards.
 */
export const revisionGenerator = functions.pubsub
  .schedule("0 2 * * *")
  .timeZone("UTC")
  .onRun(async () => {
    const usersSnap = await db.collection("users").get();

    for (const userDoc of usersSnap.docs) {
      const uid = userDoc.id;
      const revisionsSnap = await db
        .collection("users")
        .doc(uid)
        .collection("revision")
        .get();

      const batch = db.batch();

      for (const revDoc of revisionsSnap.docs) {
        const card = revDoc.data();
        const nextReview = card.nextReview?.toDate();

        if (nextReview && nextReview <= new Date()) {
          // Card is due - no action needed, Flutter app handles display
        }
      }

      await batch.commit();
    }
  });
