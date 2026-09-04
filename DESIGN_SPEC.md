# AlgoForge — Monad Design Spec
> Applying the Monad editorial design system to the Flutter app screens

This spec maps every screen in the AlgoForge navigation flow to the **Monad** style tokens (warm parchment canvas, Untitled Serif headlines, ABC Diatype Mono body/UI text, Lake Blue as the single accent).

---

## Global Foundations

```css
--color-parchment: #f6f3f1;      /* page/screen background — never pure white */
--color-lake-blue: #2b59d1;      /* single primary accent (CTAs, active tab, key numbers) */
--color-periwinkle-mist: #cfdaf5;/* elevated card surface (hero cards only) */
--color-off-black: #242424;      /* primary text, secondary buttons */
--color-graphite: #4e4d4d;       /* body copy */
--color-smoke: #797776;          /* helper/meta text */
--color-ash: #cecac8;            /* 1px hairline borders, dividers */
--color-mint: #a7fccd;           /* decorative accent only (progress/success dots) */
--color-coral: #ff9473;          /* decorative accent only (warnings/streaks) */
--color-gold: #ecda98;           /* decorative accent only */

--font-untitled-serif: headings only, weight 400, never bold
--font-abc-diatype-mono: all body copy, nav, buttons, badges, stats

--radius-cards: 40px
--radius-buttons: 100px
--radius-tags: 9999px
--spacing-card-padding: 40px
--shadow: none (use Ash borders instead)
```

**Mobile adaptation note:** Monad's 40px card radius/padding is desktop-scaled. For Flutter mobile screens, scale down proportionally: card radius → 20–24px, card padding → 20–24px, section gap → 32px, while keeping the *ratios and hierarchy* (serif headlines, mono everything else, single blue accent, hairline borders, no shadows).

---

## 1. Splash Screen
- Background: Parchment (`#f6f3f1`)
- App name: Untitled Serif, 48px (heading-lg), weight 400, Off-Black
- Tagline (optional): ABC Diatype Mono, 16px, Graphite
- No shadow, no gradient — pure typographic splash per Monad's "no photography, type-only hero" principle

---

## 2. Login Screen
- Background: Parchment
- Heading "Sync your progress" — Untitled Serif, 32px
- Username input: Parchment fill, 1px Ash border, 100px pill radius, mono 16px text, Off-Black
- "Sync My Data" button: **Primary Pill Button (Blue)** — Lake Blue fill, white mono 14px uppercase text, trailing ▸ arrow, 100px radius
- Helper text below input: mono 12px uppercase, Smoke

---

## 3. Dashboard Screen (Home Tab)
- Background: Parchment
- "Welcome, {username}" — Untitled Serif, 24px, Off-Black

- **Recommendation Card** (⭐ Next Problem): Elevated Feature Card style — Periwinkle Mist fill, 40px→24px radius (mobile), problem title in serif 24px, score/metadata in mono, this is the ONE colored card on the screen (Monad rule: only one surface breaks monochrome)

- **Revise Today card**: Feature Card style — Parchment/transparent fill, 1px Ash border, no shadow; urgent count badge as a Lake Blue pill tag (9999px radius)

- **Skill Profile (radar chart)**: chart strokes in Off-Black/Graphite, one Lake Blue accent ring for the "target" line, background grid in Ash at low opacity

- **Activity Calendar heatmap**: cells use grayscale-to-Lake-Blue intensity scale instead of green (keeps single-accent rule) — empty cells Ash, active cells scale toward Lake Blue

- **Stats row**: mono 20px numbers (Off-Black), mono 12px uppercase labels (Smoke), separated by thin Ash dividers, no boxes

---

## 4. Problem Detail Screen
- Header: back arrow (mono glyph) + "#167" tag as Pipeline Node Tag style (pill, Ash border, mono uppercase)
- Title "Two Sum II" — Untitled Serif 32px
- Difficulty/Topic — mono 14px uppercase tags, Ash border pills (Medium → Coral text accent used sparingly as decorative-only per Monad rule)
- "Why this problem?" AI explanation block — Feature Card style, Ash border, 24px radius, body in mono 16px Graphite
- Prerequisites checklist — mono list, ✅ in Mint accent dot / 🔲 outline in Ash
- Similar Problems — Pipeline Node Tag pills connected conceptually (can literally reuse the pipeline-diagram visual language: pill nodes + thin Ash connector lines)
- **[🚀 Start Solving]** — Primary Pill Button (Blue), full-width on mobile

---

## 5. After Solving — Rating Dialog
- Modal sheet: Parchment fill, 40px→24px top radius, 1px Ash top border
- Fields (Time, Attempts, Hints) — mono 16px inputs, underline or Ash-bordered boxes, no shadow
- Confidence stars — Off-Black outline, filled stars in Lake Blue (not gold, to preserve single-accent rule)
- **[✅ Done]** — Primary Pill Button (Black) since this is a confirming/secondary action relative to the primary flow

---

## 6. Learn Screen (Learn Tab)
- Heading "Learning Paths" — Untitled Serif 32px
- Topic cards — Feature Card style, Ash border, 24px radius, stacked vertically
  - Progress bar: track in Ash, fill in Lake Blue
  - Weak areas (low %) get a Coral text label ("Needs work") as the one permitted decorative-accent callout
  - Topic name in mono 500 weight (emphasized UI label), % in mono 14px Smoke

---

## 7. Learning Path Detail Screen
- "← Sliding Window Path" — mono 14px link with arrow, Off-Black
- Vertical TopoSort chain — this maps directly onto Monad's **Pipeline Node Tag** component: each stage is a pill node (Parchment fill, Ash border, mono uppercase label) connected by thin curved Ash lines, exactly like the data-pipeline diagram in the reference
  - Done nodes: Off-Black text + small check glyph
  - Current node: Lake Blue border/text (the one accent break)
  - Locked/future nodes: Smoke text, dashed Ash border
- Problems-in-order list below — plain mono rows with status glyphs (✅🟡🔴⬜), thin Ash row dividers, no card wrapper needed

---

## 8. Search Screen (Search Tab)
- Search input — pill shape (9999px radius), Ash border, mono 16px, magnifying-glass mono icon left
- Suggestions (Trie results) — plain mono list rows, 📌 icon, hover/tap state = Periwinkle Mist background tint only (no shadow)
- Filters (difficulty/company/tag) — Tag/pill components, 9999px radius, unselected = Ash border transparent fill, selected = Off-Black fill with white text (reserve Lake Blue for the single primary action elsewhere, not for filter toggles)
- Results list — mono rows, problem number in Smoke, title in Off-Black, thin Ash divider between rows

---

## 9. Profile Screen (Profile Tab)
- "👤 username" — Untitled Serif 32px; "LeetCode Rating: 1842" — mono 16px Graphite beneath
- Skill Breakdown radar chart — Elevated Feature Card (Periwinkle Mist) as the one hero card on this screen
- Submission Calendar — same grayscale→Lake-Blue heatmap treatment as Dashboard
- Achievements — small Pipeline-Node-style pill tags (🔥 💯 🎯), Ash border, mono uppercase
- Contest History graph — line chart, single Lake Blue line, Ash gridlines, no fill/gradient under the line (keep it flat/editorial, not "dashboard-y")

---

## 10. Revision Screen
- Header: "🔄 Revision Queue" — Untitled Serif 24px; "Due today: 3" — mono Smoke
- Swipeable cards — Feature Card style, Ash border, 24px radius, 24px padding (scaled), no shadow (use a subtle Ash border shift or scale transform for the swipe affordance instead of elevation)
  - "Last: Failed" → Coral mono label (decorative accent, sparingly)
  - "Last: Solved" → Mint mono label
  - Interval — mono 12px uppercase Smoke
- **[✅ Got it]** → Primary Pill Button (Black), **[❌ Forgot]** → Ghost Pill Button (Off-Black border, transparent fill)

---

## Flutter Implementation Notes

Map tokens into a `constants.dart` / `AppTheme`:

```dart
class AppColors {
  static const parchment = Color(0xFFF6F3F1);
  static const lakeBlue = Color(0xFF2B59D1);
  static const periwinkleMist = Color(0xFFCFDAF5);
  static const offBlack = Color(0xFF242424);
  static const graphite = Color(0xFF4E4D4D);
  static const smoke = Color(0xFF797776);
  static const ash = Color(0xFFCECAC8);
  static const mint = Color(0xFFA7FCCD);
  static const coral = Color(0xFFFF9473);
  static const gold = Color(0xFFECDA98);
}

class AppRadii {
  static const card = 24.0;   // scaled down from 40px desktop token
  static const button = 100.0;
  static const tag = 9999.0;
}

class AppTypography {
  // Headings: serif, weight 400 only — never bold
  static const heading = TextStyle(fontFamily: 'UntitledSerif', fontWeight: FontWeight.w400);
  // Everything else: mono
  static const body = TextStyle(fontFamily: 'ABCDiatypeMono', fontWeight: FontWeight.w400);
  static const label = TextStyle(fontFamily: 'ABCDiatypeMono', fontWeight: FontWeight.w500);
}
```

**Do:**
- Keep exactly one Lake Blue element per screen (primary CTA, active nav icon, or the "current" state in a chain)
- Use `AppColors.ash` 1px borders instead of `BoxShadow` everywhere
- Reserve `periwinkleMist` for the single hero/featured card per screen (Recommendation card on Dashboard, Radar chart on Profile)

**Don't:**
- No pure white (`#FFFFFF`) backgrounds anywhere — always parchment
- No bold serif headings
- No drop shadows on cards — border + fill-color contrast only
