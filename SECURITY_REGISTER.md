# DevSecOps Findings Register

| # | Drill | Tool | Finding | Severity | Decision | Justification / Owner / Revisit |
|---|---|---|---|---|---|---|
| 1 | 2 | Bandit | B105 `hardcoded_password_string` — `SECRET_KEY` hardcoded in `campus_notifier/settings.py:27` | Low | Remediated | Moved to `.env` as `DJANGO_SECRET_KEY`, read via `os.environ["DJANGO_SECRET_KEY"]`. The old key is still in git history, so removal from the file is not rotation — the key is considered burned and must not be reused in any deployed environment. |
| 2 | 2 | gitleaks (CI) | `django-insecure-...` placeholder in `settings.py` | N/A | No action | gitleaks does not flag this pattern — it is Django's own dev-placeholder prefix, not a real credential. Superseded by finding #1's fix anyway. |
| 3 | 3 | Trivy | Image scan of `campus-notifier:dev` (HIGH/CRITICAL OS + dependency CVEs) | HIGH/CRITICAL (counts vary by base-image patch level at scan time) | Gate set to block | Policy: `severity: CRITICAL`, `exit-code: "1"` — any CRITICAL CVE with a published fix now fails the build. HIGH findings are reported but non-blocking for now (stricter policy would also block HIGH). Remedy for any CRITICAL hit: bump the base image / vulnerable package to the patched version named in the Trivy table. |
| 4 | 4 | Checkov | `CKV_AWS_136` — ECR repository (`terraform/main.tf`) not encrypted with a customer-managed KMS key | Medium | Accepted risk (suppressed) | AES256 default encryption-at-rest is already active; this is a `Testing`-tagged class/demo repository with no sensitive images. Customer-managed KMS adds key-management overhead not justified here. Suppressed inline with `#checkov:skip=CKV_AWS_136:...`. Owner: Jongkuch Anyar. Revisit: 2026-12-10. |

## Gate policy (Drill 5)

| Job | Before | After | Rationale |
|---|---|---|---|
| `secrets` (gitleaks) | Blocking | Blocking (unchanged) | Any real secret, ever — no threshold. |
| `image` (Trivy) | `severity: HIGH,CRITICAL`, `exit-code: "0"` (warn) | `severity: CRITICAL`, `exit-code: "1"` (block) | CRITICAL CVEs with a published fix should never ship; HIGH stays visible but non-blocking to avoid an unmaintainable gate. |
| `iac` (Checkov) | `soft_fail: true` (warn) | `soft_fail: false` (block) | Terraform that opens something to the internet must fail the build. The one real finding is suppressed with a written, owned justification rather than silently ignored. |
| `code` (Bandit) | `continue-on-error: true` (warn) | `continue-on-error: false` (block) | Today's finding was Low severity but trivial to fix correctly (env var instead of hardcoded string) — blocking keeps that fix pattern enforced going forward. |
