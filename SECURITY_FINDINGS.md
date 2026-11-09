# DevSecOps findings register

This register tracks the Week 5 DevSecOps activity. Populate scan-specific counts and finding IDs from the GitHub Actions run before treating the exercise as complete.

| Source | Finding or check | Disposition | Justification / evidence | Owner | Revisit |
|---|---|---|---|---|---|
| Bandit (CI) | Hardcoded Django `SECRET_KEY` (`B105`) | Remediated in working tree | Settings now read `DJANGO_SECRET_KEY` from the environment; the local value belongs in the ignored `.env`. Run Bandit in CI to confirm. Any key previously committed to Git history would still need rotation if it were a real credential. | Repository maintainer | Before merge |
| Gitleaks (pre-commit and CI) | Secret detection | Enforced gate | The commit hook scans staged changes; CI scans repository history on pull requests. Record the passing or failing run here. | Repository maintainer | Every pull request |
| Trivy (CI) | CRITICAL image vulnerabilities | Enforced gate | Only CRITICAL findings fail the build. Record image digest, finding IDs, counts, and remediation from the actual scan. | Repository maintainer | Every pull request |
| Checkov (CI) | Terraform policy findings | Enforced gate | Findings must be fixed or suppressed in Terraform with a specific justification comment. Record finding IDs and disposition from the actual scan; no findings are claimed here before the workflow runs. | Repository maintainer | Every pull request |

## Policy choice

Bandit is blocking. A hardcoded Django signing key can compromise sessions and related trust assumptions; the finding is remediated in the working tree, so the pipeline should fail if it returns. Image scanning blocks CRITICAL severity only, while Checkov and Gitleaks block on their findings.

## Run status

The workflow is prepared locally. GitHub Actions results, Trivy vulnerability counts, and Checkov finding IDs require a pushed branch and a pull request; no results are asserted until those scans run.
