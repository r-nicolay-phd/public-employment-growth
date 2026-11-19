#!/usr/bin/env bash
# Commands to publish the replication package of the Kyklos submission.
# NOT executed: docs/PUBLISH_OK.txt (with the line publish=yes) did not exist when the package was prepared.
# Run from the project folder (the one that contains replication_kyklos/), in Git Bash, after reviewing
# replication_kyklos/ (no non-redistributable data inside) and filling in LICENSE.txt and README.md.
# Requires the GitHub CLI (https://cli.github.com/), which was not installed on this machine.
set -euo pipefail

# 0. Authentication
gh auth status

# 1. Publish ONLY replication_kyklos/ as a new public repository. The research repository is not published:
#    it contains working material (earlier versions of the article, internal reports) that should not be public.
WORK="$(mktemp -d)"
cp -r replication_kyklos/. "$WORK/"
cd "$WORK"
git init -b main
git add .
git commit -m "Replication package for the Kyklos submission"
gh repo create kyklos-wage-bill-replication --public --source=. --remote=origin --push

# 2. Analysis plan: the plan is attached as docs/analysis_plan.pdf (exact copy of the plan at commit
#    2182199cbd7a3a4c775c06f0d5ae01f22c215218, tag analysis-plan-2026-10-17 of the research repository).
#    The tag is recorded in the new repository as a lightweight pointer to the commit that adds the PDF,
#    with the original hash in the tag message.
git tag -a analysis-plan-2026-10-17 -m "Analysis plan committed on 2026-10-17 16:16 (UTC-3) as commit 2182199cbd7a3a4c775c06f0d5ae01f22c215218 of the research repository; exact copy in docs/analysis_plan.pdf"
git push origin analysis-plan-2026-10-17

# 3. Release (Zenodo mints a DOI for each GitHub release once the integration is switched on)
#    Before this step, switch on the repository in https://zenodo.org/account/settings/github/
gh release create v1.0-kyklos-submission --title "Replication package, Kyklos submission" \
  --notes "Replication package for 'Accounting, Not Averaging Out: Public Wage Bills and Economic Growth'. Analysis plan: docs/analysis_plan.pdf (commit 2182199cbd7a3a4c775c06f0d5ae01f22c215218)." \
  docs/analysis_plan.pdf

# 4. Afterwards: copy the repository URL and the Zenodo DOI into output/kyklos/submission_texts.md
#    ([REPOSITORY], [DOI/URL], [ID], [REPOSITORY URL]) and into the manuscript footnotes 1 and 2.
