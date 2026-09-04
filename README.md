# AlgoForge

Adaptive DSA Learning & Revision Platform — Flutter Android app with Firebase backend.

## Architecture

- **Frontend**: Flutter (Dart) with Monad design system
- **Backend**: Firebase (Firestore, Auth, Cloud Functions)
- **DSA Engine**: Runs locally on device (zero latency)

## DSA Concepts Demonstrated

| Concept | Implementation |
|---------|---------------|
| HashMap | User skill lookup, problem indexing |
| HashSet | Solved problem tracking |
| Graph (Adjacency List) | Knowledge graph — topics ↔ problems |
| BFS | Related problem discovery (1 hop) |
| DFS | Deep topic traversal (2 hops) |
| DAG | Prerequisite relationships |
| Topological Sort | Learning path ordering (Kahn's algorithm) |
| Max Heap | Recommendation scoring |
| Min Heap | Revision scheduling |
| Trie | Prefix-based problem search |
| Inverted Index | Company/tag/difficulty filtering |
| Sliding Window | Recent performance stats |
| Binary Search | Difficulty targeting |
| Spaced Repetition (SM-2) | Adaptive revision intervals |

## Setup

### Prerequisites
- Flutter SDK 3.x
- Firebase CLI
- Node.js 18+

### 1. Flutter App
```bash
cd dsa_platform_flutter
flutter pub get
flutter run
```

### 2. Firebase Functions
```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

### 3. Firestore
```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

## Project Structure

```
dsa-platform/
├── DESIGN_SPEC.md              # Monad UI design tokens
├── ARCHITECTURE.md             # System architecture
├── firebase.json               # Firebase config
├── firestore.rules             # Security rules
├── firestore.indexes.json      # Composite indexes
│
├── dsa_platform_flutter/       # Flutter app
│   ├── lib/
│   │   ├── main.dart           # Entry point
│   │   ├── app.dart            # Routing
│   │   ├── models/             # Data models
│   │   ├── services/           # Firebase services
│   │   ├── engine/             # DSA algorithms (runs on device)
│   │   ├── providers/          # State management
│   │   ├── screens/            # UI screens
│   │   ├── widgets/            # Reusable widgets
│   │   └── utils/              # Theme, constants
│   └── pubspec.yaml
│
├── functions/                  # Firebase Cloud Functions
│   ├── src/index.ts            # All functions
│   ├── package.json
│   └── tsconfig.json
│
└── data/
    └── knowledge_graph.json    # Topic/prerequisite graph
```

## Screens

1. **Splash** — App intro
2. **Login** — Enter LeetCode username
3. **Dashboard** — Recommendations, revisions, skills, calendar
4. **Problem Detail** — Why this problem, prerequisites, similar
5. **Rate Problem** — Time, attempts, hints, confidence
6. **Learn** — Topic cards with progress
7. **Learning Path** — Topological sort path
8. **Search** — Trie prefix search + filters
9. **Profile** — Skills, calendar, achievements
10. **Revision** — Spaced repetition queue
