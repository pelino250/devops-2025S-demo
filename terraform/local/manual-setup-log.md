# Campus Event Notifier — Manual Setup Log

Name:
Date:
Track: Local
Start time:
Finish time:

## Step 1 — Terraform / rebuild servers

| Time spent | Command/action | Expected result | Actual result / error / fix |
|---|---|---|---|
| | Set DOCKER_HOST | Terraform connects to Docker Desktop | |
| | terraform init | Providers installed | |
| | terraform validate | Configuration is valid | |
| | terraform apply | Two local servers created | |
| | terraform output | Required outputs displayed | |

Paste `terraform output` here (remove/blur account identifiers if any):

```text

```

## Step 2 — Database server

SSH command used:

```bash
ssh -i ~/.ssh/alu-devops -p 2223 root@127.0.0.1
```

| Time spent | Command/action | Expected result | Actual result / error / fix |
|---|---|---|---|
| | `sudo apt update` | Package index updated | |
| | `sudo apt install -y postgresql` | PostgreSQL installed | |
| | Create `campus` user | Database user created | |
| | Create `campus` database | Database created | |
| | `ls /etc/postgresql` | PostgreSQL version shown | |
| | Edit `postgresql.conf` | PostgreSQL listens on network interfaces | |
| | Edit `pg_hba.conf` | App server private IP is allowed | |
| | Restart PostgreSQL | PostgreSQL restarts | |
| | Verify database | `campus` database is listed | |

Notes/errors/fixes:

```text

```

## Step 3 — Application server

First capture the expected initial error:

```text
Paste the `docker: command not found` output here.
```

SSH command used:

```bash
ssh -i ~/.ssh/alu-devops -p 2222 root@127.0.0.1
```

| Time spent | Command/action | Expected result | Actual result / error / fix |
|---|---|---|---|
| | `docker --version` | Initially command not found | |
| | Install Docker / Docker CLI | Docker command becomes available | |
| | Run Campus Event Notifier container | App container starts | |
| | `sudo docker logs campus-notifier` | No database connection errors | |
| | Test `/health/` from laptop | `{"status":"ok"}` | |

Notes/errors/fixes:

```text

```

Health endpoint response:

```text

```

Home page screenshot filename/location:

## Step 4 — Destroy resources

| Time spent | Command/action | Expected result | Actual result / error / fix |
|---|---|---|---|
| | `terraform destroy` | Both local servers/network removed | |
| | `terraform state list` | No managed resources remain | |
| | Check Docker Desktop | No lab containers/network remain | |

Final notes: what took the most time, what failed, and what you learned:

```text

```
