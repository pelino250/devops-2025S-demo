# Security Findings Register

## Verified baseline finding

| Finding | Severity | Disposition | Justification and action | Owner / revisit |
|---|---|---|---|---|
| Bandit B105, hardcoded Django `SECRET_KEY` in `campus_notifier/settings.py:27` on the starter `main` branch | Low; Medium confidence | Remediated and verified locally | Django now reads `DJANGO_SECRET_KEY` from the environment. The old `django-insecure-` development placeholder remains in Git history, so removing it from the file is not the same as rotating a real credential. Treat it as exposed if it was ever used outside development and rotate that deployed value. | Repository maintainer; verify before deployment and revisit by 2026-11-16 |
| Checkov CKV_AWS_136, ECR encryption was not explicitly configured in `terraform/main.tf` on the starter `main` branch | IaC policy failure | Remediated and verified locally | The ECR resource now specifies `encryption_type = "KMS"` and uses the AWS-managed ECR key. | Repository maintainer; confirm in the PR Checkov job |

Local reruns after these fixes: Bandit reported 0 issues; Checkov reported 4 passed and 0 failed.

## Pull request scan results

Add a row for each finding reported by the Bandit, Trivy, or Checkov jobs after they run in your fork. Record actual Trivy HIGH/CRITICAL counts and Checkov findings from the Actions output; these depend on the live vulnerability database and the exact Terraform scan, so they are not guessed here. For each finding, record whether it was fixed, suppressed with a code comment, or accepted with an owner and revisit date. If a scan reports no findings, record zero only after the job completes successfully.
