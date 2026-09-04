# AlgoForge 🚀

**AlgoForge** is an intelligent, adaptive Data Structures and Algorithms (DSA) learning and revision platform built with Flutter and Firebase. It dynamically syncs your real-time LeetCode progress and utilizes spaced repetition and a custom knowledge graph to help you master competitive programming efficiently.

---

## ✨ Key Features

* **🔗 Live LeetCode Sync:** Connects directly to a custom Alfa API backend to fetch your exact LeetCode profile, solved problems, current streaks, and attempt history. No manual tracking required!
* **🕸️ Dynamic Skill Breakdown:** Uses your LeetCode data to generate a dynamic "Radar Chart" (spiderweb graph) that maps out your strengths and weaknesses across 15+ DSA topics (Dynamic Programming, Trees, Graphs, Arrays, etc.).
* **🧠 Spaced Repetition System (SRS):** A built-in "Revise Today" queue that tracks the problems you solve and uses scientifically proven spaced repetition algorithms to remind you to practice problems right before you forget them.
* **🗺️ Smart Knowledge Graph:** Features an underlying directed acyclic graph (DAG) structure that understands DSA topic relationships (e.g., you must learn "Arrays" before "Hash Tables").
* **🎯 Personalized Recommendations:** The recommendation engine combines the Knowledge Graph with your personal Skill Radar to pinpoint exactly which problem you should solve next to maximize improvement.
* **🔍 Offline-First Problem Search:** A powerful search engine pre-seeded with real LeetCode problems (fetched from the API) allowing you to filter by title, difficulty, and topic tags.

## 🛠 Tech Stack

* **Frontend:** Flutter (Dart)
* **State Management:** Provider pattern (MVVM-inspired architecture)
* **Backend:** Firebase (Cloud Firestore NoSQL database, Firebase Auth)
* **API Integration:** REST HTTP polling to the [Alfa LeetCode API](https://github.com/alfa-leetcode-api)
* **UI/UX:** Custom Monad design system with rich typography and micro-animations.

---

## 🏗 Architecture & Codebase

The project is structured into clear layers for maintainability:
* `lib/models/`: Core data models (User, Problem, SkillProfile, RevisionCard).
* `lib/providers/`: State management and business logic orchestrators.
* `lib/services/`: External integrations (FirestoreService, AuthService, LeetcodeSyncService).
* `lib/engine/`: Pure Dart algorithms for the Knowledge Graph, Recommendation Engine, and SRS algorithms.
* `lib/screens/` & `lib/widgets/`: UI layer.

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (v3.10+)
* A Firebase Project with Firestore enabled.
* An active deployment of the [Alfa LeetCode API](https://github.com/alfa-leetcode-api) (e.g., on Render or Vercel).

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/taksh1507/AlgoForge.git
   cd AlgoForge/dsa_platform_flutter
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   * Add your `google-services.json` to `android/app/`.
   * Add your `GoogleService-Info.plist` to `ios/Runner/`.

4. **Run the App:**
   ```bash
   flutter run
   ```

5. **Sync Your Data:**
   * Create an account / login.
   * Go to the Profile or Dashboard tab.
   * Enter your LeetCode username and tap **Sync My Data**. The app will fetch your data, populate your radar chart, and build your personalized revision queue!

---
*Built for the grind. Happy coding! 💻*
