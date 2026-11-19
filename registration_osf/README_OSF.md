# Analysis plan and addenda (plan and four addenda): "Accounting or Averaging Out? Public Wage Bills and Economic Growth"

This folder is the public deposit of the analysis plan of the article and of the four addenda that extended it. It also contains the material needed to verify when each document was written.

## Files

| File | What it is |
|---|---|
| `01_analysis_plan_2026-10-17.pdf` / `.md` | Analysis plan: hypotheses H1–H5 with predicted signs, preferred specification of each hypothesis, full list of specifications and the verdict rules. Written in Portuguese. Commit `2182199cbd7a3a4c775c06f0d5ae01f22c215218`, 17 October 2026, 16:16:00 (UTC−3). |
| `02_addendum1_2026-11-13.pdf` / `.md` | First addendum: replications, simulation under a calibrated null, local projections with predetermined shocks and other checks. Commit `3faa1ea65b7a1827107b30169962cf81732260ca`, 13 November 2026, 17:55:25. |
| `03_addendum2_2026-11-16.pdf` / `.md` | Second addendum: anchored simulation, bias checks, formal tests in the institutional replications, fiscal years, H2 with reverse-denominator controls, cumulative local projections. Commit `be45e06401f466d895f09826b28cfbe909ca2312`, 16 November 2026, 13:45:23. |
| `04_addendum3_2026-11-16.pdf` / `.md` | Third addendum: estimates requested for the final version. Commit `c402c35c7a051094634c5f469ef08ee5539014c9`, 16 November 2026, 19:26:08. |
| `05_addendum4_2026-11-17.pdf` / `.md` | Fourth addendum: re-estimates requested on version 5 (moment-matched simulation, drivers of the five-year estimate, common scale, formal tests, institutions). Commit `fb6c84b1fa0293f197deeafe6735fe974004ebf1`, 17 November 2026, 13:23:55. |
| `registration_timeline.md` | When the plan and each addendum were committed and when the analyses they govern were first run, including the exceptions: analyses whose earlier specifications were estimated before the plan. |
| `repo_until_addendum4.bundle` | A git bundle of the repository up to the commit of the fourth addendum (tag `kyklos-addendum-4`); `repo_until_addendum3.bundle` is the earlier bundle up to the third addendum. |
| `repo_until_addendum3.bundle` | A git bundle of the project repository up to the commit of the third addendum. It contains the full commit history (hashes, dates, messages, the plan, the addenda, the code under version control and its committed outputs). It contains no data files. It does include the author name and e-mail of the commits. |

The `.md` files are byte-for-byte copies of the committed documents (`git show <hash>:<path>`). The `.pdf` files are the same text with a header giving the commit and its date.

## How to verify

With git installed:

```
git bundle verify repo_until_addendum4.bundle
git clone repo_until_addendum4.bundle repo
cd repo
git log --format="%H %ad %cd %s" --date=iso
git show 2182199cbd7a3a4c775c06f0d5ae01f22c215218:docs/PLANO_REVISAO.md        > plan.md
git show 3faa1ea65b7a1827107b30169962cf81732260ca:docs/plan_addendum_kyklos.md   > a1.md
git show be45e06401f466d895f09826b28cfbe909ca2312:docs/plan_addendum_kyklos_2.md > a2.md
git show c402c35c7a051094634c5f469ef08ee5539014c9:docs/plan_addendum_kyklos_3.md > a3.md
git show fb6c84b1fa0293f197deeafe6735fe974004ebf1:docs/plan_addendum_kyklos_4.md > a4.md
```

Each extracted file should be identical to the corresponding `.md` in this folder (for example, `diff plan.md 01_analysis_plan_2026-10-17.md`). The commit hash depends on the content and on the history before it, so a document cannot be changed afterwards without changing its hash and the hashes of every later commit.

**What the timestamps prove.** The time stamp of the deposit in the registry fixes an upper bound for the date of every document in this folder. The git dates are those recorded by the authors' computer.

## Status of the analyses

- **The plan.** The verdicts on H1–H5 follow the plan.
- **The addenda.** Every analysis added by an addendum is exploratory ("post-plan, pre-registered in the addendum"). None changes the registered verdicts.
- **Known deviations.** They are listed in `registration_timeline.md` (section 4) and in the appendix of the article. In particular, the anchored simulation design of the second addendum was defined after the registered design of the first addendum had been run.
