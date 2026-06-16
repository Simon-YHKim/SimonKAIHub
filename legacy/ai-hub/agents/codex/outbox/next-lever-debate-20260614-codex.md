---
type: response
ref: next-lever-debate-20260614
agent: codex
created_at: 2026-06-14T00:45:09+09:00
---

# Position: build the daily ritual first

## Codebase read

I checked the current capture, onboarding, records, graph, insights, and auth-gate paths:

- `src/app/capture.tsx`
- `src/lib/records/create.ts`
- `src/lib/journal/streak.ts`
- `src/lib/journal/daily-prompts.ts`
- `src/lib/journal/insights.ts`
- `src/app/insights.tsx`
- `src/lib/graph/card-insights.ts`
- `src/app/index.tsx`
- `src/app/onboarding.tsx`
- `src/lib/onboarding/state.ts`
- `src/lib/capture/draft.ts`
- `src/lib/auth/AuthContext.tsx`
- `src/app/_layout.tsx`
- `src/app/(auth)/sign-up.tsx`
- `src/app/(auth)/sign-in.tsx`
- `src/app/(auth)/complete-profile.tsx`
- `locales/en/capture.json`
- `locales/ko/capture.json`

## Lever A: daily ritual + week-1 first glimpse

### Smallest viable implementation in this codebase

Use the existing authenticated `/capture` journal mode as the ritual surface. It already defaults to journal, saves to `records` through `createRecord()`, has draft survival, has a saved panel, computes a KST streak through `computeStreak()`, and loads recent records with `listRecentRecords()`.

Concrete touch points:

- `src/app/capture.tsx`
  - Replace or augment the current single daily prompt card in journal mode with a compact "3 things" ritual: three short prompts, still ending in one `createRecord({ kind: "journal" })` save.
  - Keep the persisted row as a normal journal record. No new table is required for MVP.
  - After save, use the existing post-save `listRecentRecords(userId)` refresh to decide whether the user has 3 to 7 journal entries.
  - When the threshold is met, render a first-glimpse card inside the existing saved panel area instead of opening a new modal.
- `src/lib/journal/daily-prompts.ts` or a new small pure helper such as `src/lib/journal/ritual.ts`
  - Provide KST-stable daily three-prompt copy, or a deterministic rotation.
- `src/lib/journal/insights.ts`
  - Reuse `computeInsights()` for an honest pattern card: record count, top tag/topic, recent conclusion, week count. Avoid LLM inference for week 1.
  - If needed, add a small pure `firstGlimpse()` selector on top of existing `InsightsResult`.
- `locales/en/capture.json` and `locales/ko/capture.json`
  - Add ritual labels and first-glimpse copy with EN as canonical.
- Tests:
  - Add focused tests for the pure first-glimpse selector and prompt rotation.
  - Existing `computeInsights()` and `computeStreak()` already cover the hard date math.

Rough effort: 1 to 2 focused days for a conservative MVP, including i18n and tests. More if we insist on three separate fields with polished focus handling and Android keyboard QA.

### Main risk or conflict

The main product risk is graph honesty. Journal saves land in `records`, not `sources`, and `src/app/index.tsx` explicitly protects that boundary: records-only users get "Saved in your records. Clip a link to light the graph." The first-glimpse card must therefore not imply a graph node, source citation, or AI-discovered pattern. It should be framed as "from your recent entries" and link to `/records` or `/insights`, not to the graph.

Safety and consent are comparatively low risk because this path stays behind the existing auth/profile gates:

- `/capture` redirects unauthenticated users to `/sign-in`.
- `hasProfile === false` redirects to `/complete-profile`.
- `createRecord()` already runs crisis classification for non-LLM paths and routes red-zone output through the existing crisis UI.
- Optional Advisor remains off by default and Brain-gated through `canUsePremium("advisor", progression.tier)`.

Android risk is moderate if the ritual becomes three separate inputs. The existing capture screen already handles `KeyboardAvoidingView`, dynamic bottom padding, and draft persistence, so the safest MVP is to keep a single multiline body with structured prompt support or add only a small number of fixed-height inputs.

### Existing screens it reuses

- `/onboarding` already routes first-run users to `/capture?entry=firstRun`.
- `/capture` journal mode is the ritual screen.
- The existing `/capture` saved panel becomes the first-glimpse confirmation surface.
- `/records` remains the honest destination for journal entries.
- `/insights` can remain the deeper recap destination, since it already aggregates both `records` and `sources`.

## Lever B: zero-friction owned-capture proof before account creation

### Smallest viable implementation in this codebase

This cannot be a small tweak to `/capture`, because `/capture` is intentionally auth-gated and draft storage is scoped by `userId`. The smallest honest version is a pre-auth local pending capture on the auth screen, then an import after legal profile completion.

Concrete touch points:

- New helper, likely `src/lib/capture/preauth-vault.ts`
  - Store one pending one-line entry in localStorage or AsyncStorage.
  - Keep it small and bounded to avoid Android AsyncStorage size issues.
  - Provide `savePendingCapture()`, `loadPendingCapture()`, `clearPendingCapture()`.
- `src/app/(auth)/sign-up.tsx`
  - Add a one-line capture input near the account form.
  - On text entry or a save tap, persist locally and show immediate confirmation.
  - Copy must be precise: if it is local-only before account creation, "saved on this device" is more truthful than "saved to your vault."
- `src/app/(auth)/complete-profile.tsx`
  - OAuth sign-ups need the pending capture carried through profile completion because consent and DOB are collected here.
- `src/app/onboarding.tsx` or post-signup handoff
  - After account creation/profile completion, import the pending entry into `records` with `createRecord()` and then clear local pending state.
  - If import fails, keep the local pending entry and offer a retry after sign-in.
- `locales/en/auth.json` and `locales/ko/auth.json`
  - Add confirmation and recovery copy.
- Tests:
  - Pure tests for pending-capture storage.
  - Auth-flow tests to ensure sign-up, OAuth complete-profile, age gate, and import sequencing do not redirect-loop or drop the pending line.

Rough effort: 3 to 5 days for a version I would trust. A local-only visual proof can be prototyped faster, but the moment it claims "vault" or imports after account creation, it crosses auth, consent, and safety boundaries.

### Main risk or conflict

The current auth model deliberately blocks product surfaces before consent/profile:

- `src/app/_layout.tsx` globally redirects profile-less authenticated users to `/complete-profile`.
- `/capture` redirects signed-out users to `/sign-in`.
- `AuthContext` treats missing profile as not ready for feature access.

That is the right shape for C10. A pre-account text box creates a new category: user-authored personal data before DOB and consent are known. If the user is under 14, we may have stored their text locally before discovering they cannot register directly. If the text contains red-zone language, we cannot use the normal audited Gemini path because there is no `userId`, no age tier, and no consent. Running no classifier avoids C3/C9 conflicts but means the app accepts sensitive text without routing support; running a classifier before account creation creates attribution and audit problems.

There is also an honesty risk. "Your vault saved this" sounds like server-backed account storage, but before account creation the only safe MVP store is device-local pending state. The copy has to say that, or the feature overpromises.

Graph honesty is not the main blocker here, but the imported item should land as a journal `record`, not a `source`, unless the text is explicitly treated as capture content after sign-in. That means no graph node should be promised.

### Existing screens it reuses

- `/sign-up` auth gate hero and form.
- `/complete-profile` for OAuth users and profile-less sessions.
- `/onboarding` as the handoff surface after account creation.
- `/capture` saved panel patterns only after the pending line is imported into a real `record`.
- `/records` as the honest destination for the imported entry.

## Recommendation

Build Lever A first.

The reason is code-grounded: the app already has almost every primitive Lever A needs in the right legal and safety context. `/capture` journal mode is the default first-run destination, `createRecord()` already protects journal saves with the safety classifier and audit path, `computeStreak()` is KST-correct, `computeInsights()` already produces non-LLM recaps from records and sources, and `src/app/index.tsx` already encodes the honesty rule that journal records are not graph nodes.

Lever B is valuable, but it fights the current architecture. The auth gate is not accidental; it is the boundary that keeps C10 consent, DOB, minor routing, and LLM safety/audit sequencing coherent. A pre-account capture proof would require a new pending-data lifecycle across sign-up, OAuth profile completion, age-gate failure, local storage limits, and post-auth import. That is too much risk for week 1 compared with a daily ritual that can ship inside the existing `/capture` -> `records` -> `/records`/`/insights` path.

My proposed first build is therefore: a three-prompt journal ritual in `/capture`, plus a non-LLM first-glimpse card after 3 journal entries, grounded only in saved entries and linking to `/records` or `/insights`.
