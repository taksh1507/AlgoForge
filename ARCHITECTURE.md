# AlgoForge — Architecture (Firebase)

## System Overview

```
┌──────────────────────────────────────────────────────────────┐
│                      FLUTTER ANDROID APP                      │
│                    (Monad Design System)                       │
├──────────────┬──────────────┬──────────────┬─────────────────┤
│   Dashboard  │     Learn    │    Search    │     Profile     │
│   (Home)     │   (Topics)   │  (Problems)  │     (User)      │
├──────────────┴──────────────┴──────────────┴─────────────────┤
│                     STATE MANAGEMENT                          │
│                  (Provider + Riverpod)                         │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│                    DSA ENGINE (Dart)                          │
│         Runs locally on device — zero server latency         │
│  ┌──────────┬──────────┬──────────┬──────────┬────────────┐ │
│  │Knowledge │  Skill   │  Recom-  │ Revision │  Learning  │ │
│  │  Graph   │  Engine  │ mendation│  Engine  │    Path    │ │
│  │  (DAG)   │(Weighted)│(Max Heap)│(Min Heap)│ (TopoSort) │ │
│  ├──────────┼──────────┼──────────┼──────────┼────────────┤ │
│  │ Similar  │  Search  │ Spaced   │ Inverted │  Binary    │ │
│  │ Problems │  (Trie)  │  Repet.  │  Index   │  Search    │ │
│  │ (BFS/DFS)│          │ (SM-2)   │          │            │ │
│  └──────────┴──────────┴──────────┴──────────┴────────────┘ │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                   FIREBASE SERVICES                           │
├──────────┬──────────┬──────────┬──────────┬─────────────────┤
│Firestore │ Firebase │ Firebase │ Firebase │   Firebase      │
│(Realtime │  Auth    │ Cloud    │ Remote   │   Storage       │
│ Database)│          │Functions │ Config   │  (cache/backup) │
├──────────┴──────────┴──────────┴──────────┴─────────────────┤
│                                                              │
│  Firestore Collections:                                      │
│  users/{uid}          → profile, skill scores, settings     │
│  users/{uid}/attempts/{id} → problem attempt history         │
│  users/{uid}/revision/{slug} → spaced repetition cards       │
│  users/{uid}/recommendations → cached next problems          │
│  problems/{slug}      → problem metadata (shared read-only) │
│  knowledge_graph/{topic} → edges, prerequisites              │
│  company_index/{company} → inverted index → problem slugs    │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                  CLOUD FUNCTIONS (Backend)                     │
│            Triggered by Firestore events or HTTPS             │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  syncLeetCodeData   → triggered on user sync request   │  │
│  │  calculateSkills    → triggered after new attempts      │  │
│  │  generateRevision   → nightly cron → update cards       │  │
│  │  rebuildGraph       → admin trigger → rebuild edges     │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│              ALFA LEETCODE API (External)                     │
│         https://alfa-leetcode-api.onrender.com                │
│  Called by Cloud Functions only (never directly from app)    │
└──────────────────────────────────────────────────────────────┘
```

---

## Why Firebase (Not a Custom Backend)

| Concern | Firebase Solution |
|---------|-------------------|
| **Speed** | Firestore SDK handles local cache + sync — app loads instantly like system apps |
| **Realtime** | Firestore snapshots push updates to UI without polling |
| **Auth** | Firebase Auth (Google, GitHub, email) — no custom JWT |
| **Offline** | Firestore persistence built-in — works without internet |
| **Scaling** | Auto-scales to millions of users, zero server management |
| **Cost** | Free tier covers development; pay-as-you-go at scale |
| **DSA Engines** | Run locally in Dart on device — zero latency, no cold starts |

---

## Project Structure

```
dsa-platform/
│
├── DESIGN_SPEC.md                    # Monad UI tokens + screen specs
├── ARCHITECTURE.md                   # This file
├── README.md                         # Setup instructions
│
├── dsa_platform_flutter/             # Flutter Android app
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart                 # Firebase init + app entry
│   │   ├── app.dart                  # MaterialApp + routing
│   │   │
│   │   ├── models/
│   │   │   ├── problem.dart
│   │   │   ├── user_profile.dart
│   │   │   ├── skill_profile.dart
│   │   │   ├── recommendation.dart
│   │   │   ├── revision_card.dart
│   │   │   └── knowledge_graph.dart
│   │   │
│   │   ├── services/
│   │   │   ├── firebase_service.dart       # Firebase init + config
│   │   │   ├── auth_service.dart           # Firebase Auth wrapper
│   │   │   ├── firestore_service.dart      # Firestore CRUD
│   │   │   ├── leetcode_sync_service.dart  # Calls Cloud Function to sync
│   │   │   └── local_cache_service.dart    # Hive/Isar for offline
│   │   │
│   │   ├── engine/                         # DSA Engine (runs locally on device)
│   │   │   ├── knowledge_graph.dart        # DAG: topics, problems, prerequisites
│   │   │   ├── skill_engine.dart           # Weighted scoring per topic
│   │   │   ├── recommendation_engine.dart  # Max Heap: next problem scoring
│   │   │   ├── revision_engine.dart        # Min Heap + SM-2 spaced repetition
│   │   │   ├── learning_path_engine.dart   # Topological sort for learning order
│   │   │   ├── similar_problems_engine.dart# BFS/DFS on knowledge graph
│   │   │   ├── search_engine.dart          # Trie + Inverted Index
│   │   │   └── performance_analyzer.dart   # Sliding window stats
│   │   │
│   │   ├── providers/
│   │   │   ├── user_provider.dart
│   │   │   ├── problem_provider.dart
│   │   │   ├── recommendation_provider.dart
│   │   │   ├── revision_provider.dart
│   │   │   └── engine_provider.dart        # DSA engine state
│   │   │
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── problem_detail_screen.dart
│   │   │   ├── rate_problem_screen.dart
│   │   │   ├── learn_screen.dart
│   │   │   ├── learning_path_screen.dart
│   │   │   ├── search_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   └── revision_screen.dart
│   │   │
│   │   ├── widgets/
│   │   │   ├── recommendation_card.dart
│   │   │   ├── skill_radar_chart.dart
│   │   │   ├── calendar_heatmap.dart
│   │   │   ├── problem_card.dart
│   │   │   ├── topic_card.dart
│   │   │   ├── revision_card_widget.dart
│   │   │   ├── pipeline_node.dart
│   │   │   ├── pill_button.dart
│   │   │   └── stat_row.dart
│   │   │
│   │   └── utils/
│   │       ├── constants.dart              # Monad tokens
│   │       ├── app_theme.dart              # ThemeData
│   │       └── helpers.dart
│   │
│   ├── android/
│   ├── ios/
│   └── test/
│
├── functions/                              # Firebase Cloud Functions
│   ├── package.json
│   ├── tsconfig.json
│   ├── src/
│   │   ├── index.ts                        # All function exports
│   │   ├── leetcodeSync.ts                 # Sync LeetCode → Firestore
│   │   ├── skillCalculator.ts              # Calculate skill scores
│   │   ├── revisionGenerator.ts            # Nightly revision card update
│   │   └── graphBuilder.ts                 # Build knowledge graph edges
│   └── .eslintrc.js
│
├── firebase.json                           # Firebase project config
├── firestore.rules                         # Security rules
├── firestore.indexes.json                  # Composite indexes
└── .firebaserc                             # Project aliases
```

---

## Firestore Collections Schema

```
firestore/
│
├── users/{uid}
│   ├── username: string                    # LeetCode username
│   ├── displayName: string
│   ├── email: string
│   ├── rating: int
│   ├── totalSolved: int
│   ├── easySolved: int
│   ├── mediumSolved: int
│   ├── hardSolved: int
│   ├── streak: int
│   ├── contestRanking: int
│   ├── syncedAt: timestamp
│   ├── createdAt: timestamp
│   └── settings: map
│       ├── notificationsEnabled: bool
│       └── dailyGoal: int
│
├── users/{uid}/attempts/{attemptId}
│   ├── problemSlug: string
│   ├── problemTitle: string
│   ├── status: string                      # "ATTEMPTED" | "SOLVED" | "MASTERED"
│   ├── timeTakenMin: int
│   ├── attempts: int
│   ├── hintsUsed: int
│   ├── solutionViewed: bool
│   ├── confidence: int                     # 1-5
│   ├── topics: array<string>
│   ├── difficulty: string
│   └── timestamp: timestamp
│
├── users/{uid}/skills/{topic}
│   ├── topic: string
│   ├── score: float                        # 0-100
│   ├── problemsAttempted: int
│   ├── problemsSolved: int
│   ├── avgTimeMin: float
│   ├── avgConfidence: float
│   ├── recentTrend: float                  # + = improving
│   └── updatedAt: timestamp
│
├── users/{uid}/revision/{problemSlug}
│   ├── problemSlug: string
│   ├── problemTitle: string
│   ├── nextReview: timestamp
│   ├── intervalDays: int
│   ├── easeFactor: float                   # SM-2 ease factor
│   ├── repetitions: int
│   ├── lastResult: string                  # "solved" | "failed"
│   └── updatedAt: timestamp
│
├── users/{uid}/recommendations
│   ├── problems: array<map>                # Cached top 5 recommendations
│   │   ├── slug: string
│   │   ├── score: float
│   │   └── reason: string
│   └── updatedAt: timestamp
│
├── problems/{problemSlug}                  # SHARED — read-only, seeded by Cloud Function
│   ├── title: string
│   ├── questionId: int
│   ├── difficulty: string                  # "EASY" | "MEDIUM" | "HARD"
│   ├── topics: array<string>
│   ├── companies: array<string>
│   ├── url: string
│   ├── isPaidOnly: bool
│   └── acceptanceRate: float
│
├── knowledge_graph/{topic}                 # SHARED — read-only, seeded by Cloud Function
│   ├── topic: string
│   ├── prerequisites: array<string>        # Topics you need first
│   ├── relatedTopics: array<string>
│   ├── problems: array<string>             # Problem slugs in this topic
│   ├── difficulty: string                  # Avg difficulty
│   └── description: string
│
└── company_index/{company}                 # SHARED — inverted index
    ├── company: string
    └── problemSlugs: array<string>
```

---

## Data Flow (Firebase)

### 1. Initial Sync Flow
```
User enters LeetCode username
        │
        ▼
┌───────────────────────┐
│  login_screen.dart    │
│  "Sync My Data" tap   │
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────┐
│  firestore_service    │
│  Create/update user   │
│  doc in Firestore     │
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────┐
│  Cloud Function       │
│  syncLeetCodeData     │
│                       │
│  Calls Alfa API:      │
│  ├─ /:username        │
│  ├─ /:username/solved │
│  ├─ /:username/skill  │
│  ├─ /acSubmission     │
│  ├─ /calendar         │
│  └─ /contest/history  │
│                       │
│  Writes to Firestore: │
│  ├─ users/{uid}       │
│  ├─ users/{uid}/attempts│
│  ├─ users/{uid}/skills│
│  └─ users/{uid}/revision│
└─────────┬─────────────┘
          │
          ▼ (Firestore realtime listener)
┌───────────────────────┐
│  Flutter UI rebuilds  │
│  automatically        │
└───────────────────────┘
```

### 2. Recommendation Flow (Runs Locally on Device)
```
Dashboard loads
        │
        ▼
┌───────────────────────┐
│  Firestore snapshot   │
│  Listen to            │
│  users/{uid}/skills   │
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────┐
│  Load knowledge graph │
│  from Firestore       │
│  (cached locally)     │
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────────────────────────────┐
│  DART ENGINE (runs on device, zero latency):   │
│                                                │
│  For each unsolved problem:                    │
│    score = weak_topic_boost      (0-30 pts)    │
│          + prerequisite_relevance (0-25 pts)   │
│          + pattern_reinforcement (0-15 pts)    │
│          + difficulty_suitability (0-15 pts)   │
│          + revision_urgency      (0-10 pts)    │
│          + similarity_boost      (0-5 pts)     │
│          - already_seen_penalty  (-20 pts)     │
│          - excessive_difficulty  (-15 pts)     │
│                                                │
│  Insert into Max Heap (score, problem)         │
│  Pop top 3                                     │
└─────────┬─────────────────────────────────────┘
          │
          ▼
┌───────────────────────┐
│  Show in UI           │
│  Recommendation Card  │
└───────────────────────┘
```

### 3. Revision Flow (Runs Locally on Device)
```
User opens revision tab
        │
        ▼
┌───────────────────────┐
│  Firestore query:     │
│  users/{uid}/revision │
│  where nextReview     │
│  <= now()             │
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────┐
│  DART ENGINE:         │
│  Min Heap by          │
│  (now - nextReview)   │
│  = most urgent first  │
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────┐
│  Swipeable cards      │
│  [Got it] [Forgot]    │
└─────────┬─────────────┘
          │
          ▼ (on swipe)
┌───────────────────────┐
│  SM-2 Algorithm:      │
│  if "got it":         │
│    interval *= ease   │
│    ease += 0.1        │
│  if "forgot":         │
│    interval = 1 day   │
│    ease -= 0.2        │
│                       │
│  Write updated card   │
│  to Firestore         │
└───────────────────────┘
```

### 4. Learning Path Flow (Runs Locally on Device)
```
User taps "Sliding Window" topic
        │
        ▼
┌───────────────────────┐
│  Load knowledge graph │
│  from Firestore cache │
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────┐
│  DART ENGINE:         │
│  1. BFS from target   │
│     to find all       │
│     prerequisites     │
│                       │
│  2. Topological Sort  │
│     (Kahn's algorithm)│
│     on prerequisite   │
│     subgraph          │
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────┐
│  Return ordered path: │
│  Arrays → Hashing →   │
│  Two Pointers →       │
│  Sliding Window →     │
│  Advanced SW          │
│                       │
│  Each with user's     │
│  progress %           │
└───────────────────────┘
```

### 5. Search Flow (Runs Locally on Device)
```
User types "binary sea"
        │
        ▼
┌───────────────────────┐
│  DART ENGINE:         │
│  Trie prefix match    │
│  on problem titles    │
│  (loaded once, cached)│
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────┐
│  Inverted Index:      │
│  Filter by company/   │
│  tag/difficulty from  │
│  Firestore cache      │
└─────────┬─────────────┘
          │
          ▼
┌───────────────────────┐
│  Show suggestions:    │
│  Binary Search        │
│  Binary Search Tree   │
│  Search in Rotated... │
└───────────────────────┘
```

---

## Firebase Cloud Functions

### `syncLeetCodeData`
- **Trigger**: HTTPS callable from Flutter app
- **What**: Calls Alfa LeetCode API for user data, writes to Firestore
- **Writes**: `users/{uid}`, `users/{uid}/attempts/*`, `users/{uid}/skills/*`

### `calculateSkills`
- **Trigger**: Firestore document trigger on `users/{uid}/attempts` (on write)
- **What**: Recalculates skill scores based on recent attempts
- **Writes**: `users/{uid}/skills/*`

### `revisionGenerator`
- **Trigger**: Scheduled (nightly cron, 2 AM UTC)
- **What**: Scans all users, updates revision card intervals using SM-2
- **Writes**: `users/{uid}/revision/*`

### `graphBuilder`
- **Trigger**: Admin SDK callable
- **What**: Rebuilds knowledge graph and company index from problems collection
- **Writes**: `knowledge_graph/*`, `company_index/*`

---

## Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own data
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;

      match /attempts/{attemptId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
      match /skills/{topic} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
      match /revision/{slug} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
      match /recommendations {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }

    // Problems are public read-only
    match /problems/{slug} {
      allow read: if true;
      allow write: if false;  // Only Cloud Functions can write
    }

    // Knowledge graph is public read-only
    match /knowledge_graph/{topic} {
      allow read: if true;
      allow write: if false;
    }

    // Company index is public read-only
    match /company_index/{company} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

---

## Firebase Firestore Indexes

```json
{
  "indexes": [
    {
      "collectionGroup": "attempts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "timestamp", "order": "DESCENDING" },
        { "fieldPath": "problemSlug", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "attempts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "revision",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "nextReview", "order": "ASCENDING" }
      ]
    }
  ]
}
```

---

## DSA Concepts Map (Dart Engine)

| DSA Concept | Implementation | File |
|---|---|---|
| **HashMap** | User skill lookup, problem indexing | `engine/skill_engine.dart` |
| **HashSet** | Solved problem tracking, dedup | `engine/recommendation_engine.dart` |
| **Graph (Adj List)** | Knowledge graph — topics ↔ problems | `engine/knowledge_graph.dart` |
| **BFS** | Related problem discovery (1-2 hops) | `engine/similar_problems_engine.dart` |
| **DFS** | Full topic coverage traversal | `engine/similar_problems_engine.dart` |
| **DAG** | Prerequisite relationships | `engine/knowledge_graph.dart` |
| **Topological Sort** | Learning path (Kahn's algorithm) | `engine/learning_path_engine.dart` |
| **Max Heap** | Recommendation scoring | `engine/recommendation_engine.dart` |
| **Min Heap** | Revision scheduling | `engine/revision_engine.dart` |
| **Trie** | Prefix-based problem search | `engine/search_engine.dart` |
| **Inverted Index** | Company/tag filtering | `engine/search_engine.dart` |
| **Sliding Window** | Recent performance stats | `engine/performance_analyzer.dart` |
| **Binary Search** | Difficulty targeting | `engine/recommendation_engine.dart` |
| **Spaced Repetition (SM-2)** | Adaptive revision intervals | `engine/revision_engine.dart` |

---

## Flutter Navigation

```
MaterialApp
    │
    ├── Splash Screen
    │       │ (check auth state)
    │       ▼
    ├── Login Screen
    │       │ (Firebase Auth + sync)
    │       ▼
    ├── MainShell (BottomNavBar)
    │       │
    │       ├── Home Tab ──► Dashboard Screen
    │       │                   ├── Recommendation Card ──► Problem Detail
    │       │                   ├── Revision Today Card ──► Revision Screen
    │       │                   ├── Skill Radar Chart
    │       │                   ├── Calendar Heatmap
    │       │                   └── Stats Row
    │       │
    │       ├── Learn Tab ──► Learn Screen
    │       │                   └── Topic Card ──► Learning Path Screen
    │       │                                       └── Problem ──► Problem Detail
    │       │
    │       ├── Search Tab ──► Search Screen
    │       │                   ├── Search Bar (Trie suggestions)
    │       │                   ├── Filter Pills
    │       │                   └── Results List ──► Problem Detail
    │       │
    │       └── Profile Tab ──► Profile Screen
    │                               ├── Skill Radar Chart
    │                               ├── Calendar Heatmap
    │                               ├── Achievements
    │                               └── Contest History
    │
    └── Overlay Routes
            ├── Problem Detail ──► Rate Problem (Bottom Sheet)
            └── Revision Screen (from Dashboard)
```

---

## pubspec.yaml (Key Dependencies)

```yaml
dependencies:
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_functions: ^4.6.0
  firebase_remote_config: ^4.4.0

  # State Management
  provider: ^6.1.1
  riverpod: ^2.4.9

  # Local Cache (offline-first)
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Charts
  fl_chart: ^0.66.0
  radar_chart: ^2.0.0

  # HTTP (for Cloud Function calls)
  dio: ^5.4.0

  # UI
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  swipeable_card: ^1.4.0

  # Utils
  intl: ^0.19.0
  uuid: ^4.2.1
```

---

## Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| Mobile App | Flutter 3.x + Dart | Cross-platform, fast rendering |
| State Management | Provider + Riverpod | Reactive, Firebase-friendly |
| Database | Cloud Firestore | Realtime, offline-first, scales |
| Auth | Firebase Auth | Google/GitHub/email, zero custom backend |
| Backend Logic | Firebase Cloud Functions | Serverless, event-driven, auto-scaling |
| Local DSA Engine | Dart (on device) | Zero latency, no cold starts |
| Local Cache | Hive | Fast key-value offline storage |
| API Source | Alfa LeetCode API | Free, well-documented |
| Testing | flutter_test + firebase_emulator | Local testing without live Firebase |
