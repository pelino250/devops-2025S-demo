# Submission checklist

- [ ] `terraform output` showing all required values:
      `instance_public_ip`, `instance_private_ip`, `ssh_user`, `app_port`,
      `db_public_ip`, `db_private_ip`, `db_ssh_port`
- [ ] Initial `docker: command not found` output from the app server
- [ ] Completed `manual-setup-log.md` for database and app setup
- [ ] `/health/` response from the laptop
- [ ] Screenshot of the Campus Event Notifier home page
- [ ] `terraform state list` after `terraform destroy`
- [ ] Confirmed both containers and the Docker network were removed
