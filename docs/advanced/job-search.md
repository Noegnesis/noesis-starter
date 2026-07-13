# Job Search as a System

The `/jobs` module automates a method. This doc teaches the method, so you can
run it — or adapt it — even without the tooling. Install the tooling with
`setup`, personalize it with `/jobs-setup`.

> [!IMPORTANT]
> The whole system rests on one rule: **never let a claim outrun the evidence.**
> Everything below is scaffolding around that.

## Lanes: aim before you fire

A lane is one coherent story about what you're for — "backend infrastructure,"
"mixed-methods product research." One to three lanes, no more. Every lane gets
its own résumé fragment and its own keyword set for discovery. If a posting
doesn't fit a lane, it isn't a lead; it's a distraction.

## Anchors and the Facts Ledger

Anchors are the handful of real projects/roles that back your lanes. The Facts
Ledger (`applications/Facts Ledger.md`) locks their exact wording: claim, where
it's true, whether it's bullseye or stretch, and — just as important — the
**Never claim** list for work you were near but didn't own.

> [!WARNING]
> Fix a fact in the Ledger FIRST, then propagate it to résumés and letters.
> The moment two documents disagree about your own history, you've lost the
> thread — and interviews find the thread.

## Honest tiering

Score every role before tailoring anything: **A** = tailor now, **B** = watch,
**C** = skip. Map the JD's top requirements to your anchors and grade the
overlap honestly. Two hard rules:

- Eligibility gates (work authorization, clearance, location) are gates, not
  points off. Blocked is blocked.
- A seniority/years-of-experience hard fail **caps the tier at C** regardless
  of topic fit. A perfect-topic senior role is still a C for a new grad.

> [!TIP]
> A clear "skip" verdict that saves you an application is a win, not a failure.
> The pipeline's job is to spend your effort only where it can land.

## Discovery: pull, don't scroll

`/jobs discover` pulls from three source classes: the ATS boards of companies
you actually care about (`greenhouse:acme` etc.), remote-job feeds, and the
Adzuna aggregator (optional API key in `.env`). Roles are filtered by your lane
keywords, checked for liveness, deduped against everything you've already seen,
and written into the tracker as `status: discovered` stubs for scoring.

Keep lane keywords high-precision: "mixed methods" finds researchers;
"research" finds everything.

## The judge loop

Never send the first draft. For A-tier roles, draft the cover letter from your
base (reusable open and close, per-role middle), then judge it twice — an ATS
screen (are the JD's top requirements literally evidenced?) and a
hiring-manager skim (30 seconds: interview or archive?). Revise until both
score ≥ 80 and every claim checks out against the Facts Ledger. Keep every
version: finals in the kit with scores attached, one ledger row per version.

## The company scan (and its price)

When you'd rather pick companies than postings, the scan workflow fans one
agent out per company to find live, matching roles, then ranks the merged
shortlist. It is the most powerful and the most expensive move in the module.

> [!CAUTION]
> Multi-agent scans burn roughly 75k tokens per company — a 16-company scan
> cost about 1.2 million tokens in practice. The workflow therefore defaults to
> 5 companies, always prints an estimate first, and refuses to run until you
> explicitly confirm the cost.

## One loop, end to end

Discover (or scan) → score honestly → tailor from fragments + Ledger → judge
loop → apply → track in `Applications.base`. The tooling automates the motion;
the discipline — lanes, evidence, honest tiers — is the part that gets you
interviews.
