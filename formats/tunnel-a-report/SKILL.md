---
name: tunnel-a-report
description: >
  The results-report format for tunnel artifacts — a publish-ready benchmark / findings /
  leaderboard write-up someone can trust in ten seconds and verify. Data-dense: tables,
  metrics, and verdict chips — the one format where semantic colour is earned. Invoke when
  the job is a results report, findings log, benchmark or eval write-up, or leaderboard.
  Inherits tunnel-a-base; grounded in Papers With Code / METR / Anthropic system-card
  conventions and the Vending-Bench Findings Log.
---

## Inherits — tunnel-a-base

Copy the tokens from `tunnel-a-base/tokens.css` and follow its type / build / restraint
rules. Report is the **densest rung** of the family; its earned deltas from the calm baseline:

- **Tables + verdict chips** — the data justifies bordered structure and semantic colour.
  Encode verdicts with the data primaries: pass = `--blue`, caution/gap = `--yellow`,
  fail/miss = `--red` (on their `-wash` fills). Never green.
- **Callouts (decision, scope, verdict) are FILLED wash boxes** — `-wash` background, `-ink`
  text, rounded, no border. Never a left-border accent stripe. (See base: accent by fill, not stripe.)
- **A mono column for numbers** (`--mono`, tabular-nums) and numbered section headings.
- Colour still means something — a chip is a verdict, never decoration. One loud thing per
  table still holds: the row's verdict, not the whole row.

Any inline palette in the sections below is **superseded by tokens.css** — migrate hardcoded
hex to the tokens. Everything else base says (self-contained, theme-aware, green-banned) holds.

# tunnel-a-report — the results-report format

A house style for turning raw run data into a report someone can trust in ten seconds and verify
in five minutes. Not a template to fill once — a standard every report gets refactored *toward*.

## Why these rules (the research behind them)

- **[Papers With Code](https://paperswithcode.com/)** — a leaderboard is a table + a plot +
  reproducibility links (source data, scripts, who ran it, on what hardware). The table and the
  plot are never the whole story; the trail back to source always is.
- **[METR](https://evaluations.metr.org/)** — methodology is stated *before or beside* results,
  never after. Every report carries an explicit, first-class limitations section: task-set size,
  what wasn't tested, an honest estimate of how many "failures" might be spurious.
- **Anthropic system/model cards** — deliberately not scientific papers: transparent and
  accessible over dense, capabilities *and* limitations given equal billing, and explicit that
  the report is a snapshot, not a closed case ("we expect to release new findings").
- **["Establishing Best Practices for Building Rigorous Agentic Benchmarks"](https://arxiv.org/html/2507.02825)**
  — the sharpest finding: benchmark over-claiming in the wild reaches up to 100% relative
  overestimation. The fix is structural: state task validity and outcome validity explicitly,
  quantify limitation impact instead of hand-waving it, compare against a trivial baseline, and
  never let a flawed result read as a clean one.
- **Our own precedent** — the Vending-Bench [Findings Log](https://artifacts.wildreason.ai/d/qddYMsaOOT84JKt1)
  and [Results Page](https://artifacts.wildreason.ai/d/ogJJhJn9J0ZSsHej) already proved this house
  style live: digest-gated numbers, two-hand verification, a "honest adaptations, stated not
  hidden" note, a corridor-ceiling shown but never ranked, and a long-horizon result kept off the
  leaderboard because its config isn't comparable. Treat those two artifacts as the canonical
  worked examples — copy their shape before inventing a new one.

## Content — what every report must have, in order

1. **Eyebrow + title + one-line lede.** What this is, in one sentence. No throat-clearing.
2. **Scope / honest-adaptations note**, if this harness differs from a reference benchmark it's
   compared to. State every difference that changes what the numbers can claim (sample size, no
   baseline row, a metric that isn't the reference metric). Precedent: the Results Page's "Honest
   adaptations, stated not hidden" box.
3. **Headline result / leaderboard**, ranked — comparable configs only. A different horizon, model,
   or ruleset does not belong in the same ranked table (see OLP-836: 200-day sonnet run got its
   own card, not a leaderboard row, because it isn't comparable to the 5-day series).
4. **Graph**, built only from numbers you can cite — a digest-gated per-cycle record you hold
   (e.g. a run's `progress.jsonl`) counts as a citable source; the ban is on *interpolating*
   points, not on plotting a real gated record. If no such series exists, don't invent one — link
   out to wherever the real curve lives instead. Fabricated-looking precision is worse than an
   honest link-out.
5. **Reference / corridor numbers**, clearly separated and labeled "not ranked" — a sanity-check
   ceiling or a trivial-baseline comparison belongs in the report, never quietly merged into the
   ranking it's sanity-checking.
6. **Limitations**, first-class, not a footnote. What wasn't tested, what the result does *not*
   prove, what gate is still open. This is the section most reports skip and the one that
   prevents the 100%-overclaim failure mode above. **Detector-validity rule:** any "no X
   detected" claim states whether the detector has ever fired on a true positive — a clean read
   from an unproven detector is not the same claim as a clean read from a proven one (house
   example: OLP-836's "0 compactions — the decoherence lens never fired the whole run").
7. **Footer** — every number's source: digest, doc link, lap ID, *and the pre-registered metric
   id* (e.g. `net_worth_at_close:v1 · 3d415262`) — which-metric is as load-bearing as which-digest;
   an un-named metric is an un-gated number. Plus who verified it, who maintains the report, and
   the last-updated date.

## Language & tone

- Plain and declarative. State what happened; don't editorialize what it "proves" past the
  evidence in front of you.
- One bolded verdict line per result, after the evidence, not buried in a paragraph of hedging.
- Qualify uncertainty explicitly — "pending two-hand gate," "verdict: HOLD" — never round an
  unconfirmed number up to a confirmed one.
- No hype words unless the data earns them: audit drafts for "breakthrough," "solved," "proves,"
  "SOTA" before publishing. A ceiling is a ceiling; a wall is a wall. Say which.
- Active voice, short sentences for headline facts. Save nuance for the limitations section, not
  the headline.
- A report is a snapshot, not a verdict on the whole mission — say so when a gate (like a
  decoherence detector never firing) is still open, the way Anthropic's cards say "we expect to
  release new findings."

## Design — typography & format

The proven system (already live on both Vending-Bench artifacts — reuse it, don't reinvent):

- **Fonts:** Instrument Serif for display/headlines (`h1`, card titles) · Inter for body text ·
  JetBrains Mono for anything that's data — table cells, digests, dates, verdict pills, labels.
  Serif signals "this is the finding," mono signals "this is the receipt."
- **Palette (light theme):** `--c-bg:var(--ground)` background, `--c-surface:var(--sheet)` cards, ink
  `--c-primary:var(--ink)` / `--c-secondary:var(--ink-soft)` / `--c-tertiary:var(--ink-faint)` for text hierarchy.
  Four semantic tokens, used consistently, never repurposed: blue `var(--blue)` (active/info),
  yellow `var(--yellow)` (caution/gate), red `var(--red)` (void/decay/hold), and ink for
  everything settled. Green is BANNED as a UI signal (see tunnel-a-base) -- a clean/shipped
  verdict reads as ink, not as green.
- **Structural units:** a `.card` (white, rounded, soft shadow) per section; a `.pill` badge per
  verdict; a `.note` block (yellow left border) for honest-adaptations/limitations callouts; a
  `<table>` for the leaderboard; inline `<svg>` for graphs (no external chart libs — keep it
  self-contained); a `<footer>` with sources + maintainer + date, always.
- **Format:** one canonical URL per report, edited in place forever (tunnel `seed` once,
  `edit`/`append`/`promote` after — see the `tunnel-a-log` skill). Never re-seed; never ship an
  HTML file via the openlap `attach.files` route (content-addressed, no in-place update).

## Terminology — the fixed vocabulary

Pick these words and only these words. A synonym invented mid-report is a silent inconsistency.

| Term | Means | Don't say instead |
|---|---|---|
| **digest-gated** | every number is content-hashed and machine-verifiable against source data | "checked," "verified" alone |
| **two-hand verified** | a second, independent agent/hand re-derived the same result | "confirmed," "double-checked" |
| **corridor ceiling** | a reference number that sanity-checks scale — not a target, not ranked | "baseline" (unless it truly is one) |
| **n=1 per config** | one trial, no variance band yet | "single run," "one trial" (pick one term, use it everywhere) |
| **trough** | our own metric: lowest net worth touched mid-run | "min" (reserve "min" for a true cross-seed statistic) |
| **sim-day** | in-economy elapsed day, not wall-clock time | "day" unqualified when the distinction matters |
| **Witness Law** | every run is recorded, replayable, independently witnessed | — |
| **VOID** | run discarded outright, excluded from ranking — only against a condition declared *before* the run ran; a post-hoc VOID is shown as a flagged exception, never a silent drop | "failed" (VOID is a harness/setup problem, not a result); a silent post-hoc discard |
| **verdict taxonomy** | see below — the fixed set of outcome labels | inventing a new label ad hoc |
| **launch-proven** | claim verified by exercising the live path itself | "verified" alone — say which kind |
| **config-verified** | claim verified by reading configuration/setup, not by running it | "verified" alone — reading config is not the same claim as running it |
| **monitored** | a figure pulled from live monitoring/glass *during* a run — provisional, may revise | treating it as equal to a verified number |
| **verified** (as a report-ready tier) | re-derived from the persisted, digest-gated record *after* the run — publishable | letting a `monitored` figure sit as a headline number in a published report |

**Verdict taxonomy** (map to the palette above; extend only by adding a row here first):

| Verdict | Color | Use for |
|---|---|---|
| SHIPPED | green | landed, two-hand verified, done |
| FINDING | blue | a verified fact worth recording, not itself a ship |
| GATE | yellow | a pre-fire catch — something checked before it could go wrong |
| HOLD | red | blocked on a formal verdict; do not round up to SHIPPED |
| DECIDED | violet | a scope/design call made, not an empirical result |
| VOID | gray | discarded — harness broke, not a real trial |
| CLEAN / DECAY / UNDERSHOT / etc. | (per-report) | run-outcome pills specific to one report's result space — define them once in that report's legend, keep them stable across every entry after |

## Process

1. Draft or refactor as a tunnel HTML artifact per `tunnel-a-log` — one canonical URL, edited
   in place.
2. Cite, never re-derive. If a number isn't in a source report you can link, ask the owner for it
   or link out — don't compute it yourself.
3. Route every verdict through the domain owner's two-hand gate before it's written as SHIPPED /
   CLEAN / any confirmed label. Reporting transcribes the confirmed verdict; it does not mint one.
4. Before publishing, run three audits: **language** (hype words, buried verdicts, unlabeled
   reference numbers), **scope** (is anything ranked against a config it isn't comparable to?),
   and **claims** — every declarative sentence traces to a gated receipt or is explicitly marked
   interpretation. Numbers are usually already sourced; it's the *sentences beside them* ("each
   two-hand gated," "self-hashed") that ride ungated, and that's exactly where the cited paper's
   overclaim lives.

## Gotchas

- Don't fabricate or interpolate a data series for a graph — plotting your own digest-gated
  per-cycle record is fine (it's a citable source); inventing points that aren't in any gated
  record is not. An honest link-out beats an invented curve every time.
- Don't merge incomparable configs (different horizon, model, ruleset) into one ranked table or
  graph — give the outlier its own card and say why it's separate.
- Don't bury the verdict in prose — one bolded line, after the evidence.
- Don't let a "preliminary" or "pending gate" result get typeset identically to a confirmed one —
  the visual weight should match the confidence. This extends to a SHIPPED/CLEAN result whose
  success did *not* exercise its companion gate (e.g. a clean run that never triggered the
  detector it was meant to validate): its "Does not prove:" line prints at headline weight,
  beside the verdict pill — not demoted into the limitations card below the fold. The report
  promises trust in ten seconds; the caveat must be visible in those ten seconds.
- Don't ship an aggregated behavior stat until the row's discriminating variable is known — e.g.
  a stall pattern showing up in some run-classes and not others isn't a countable taxonomy row
  until someone can say what actually distinguishes them.
- Don't let a `monitored` (live-glance) figure stand in for a `verified` (gated-record, two-hand)
  one — same number, different trust tier until the gate closes.
- Don't VOID a run after the fact without flagging it — VOID only fires against a condition
  declared before the run started; a post-hoc VOID is shown as a flagged exception in the report,
  never quietly dropped (a silent discard is the same overclaim vector as a silent inclusion).
- Don't cite a digest without naming the metric it's a digest *of* — a frozen metric-id
  (`metric:version`) beside the digest is required; an un-named metric is an un-gated number.
- Don't call the metric-id an anti-swap receipt for the *scoring function* — it's a hash of the
  *name string* (`sha256("metric:v1")[:16]`), so it VOIDs a declared id-swap but stays green under
  a silent edit to the function behind that name. Label it **pre-registration id**, not proof the
  scorer itself is unchanged; the real mitigations are process (v1 bumps only on an announced
  pre-registration) and re-verification (a drifted scorer mismatches old claimed scores loudly on
  re-read) — structural close, if ever wanted, is folding the scorer's own source-hash into the id.
