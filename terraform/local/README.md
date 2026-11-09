# Campus Event Notifier — Local Terraform track

This folder creates two Ubuntu containers on your local Docker Desktop engine:
- an application server (SSH on localhost:2222; app published on localhost:8080)
- a database server (SSH on localhost:2223)

The image includes SSH access only. You install PostgreSQL on the database server
and the Docker CLI/Engine on the application server manually as part of the lab.

## 1. Prepare SSH access (WSL Ubuntu)

If you already have both files `~/.ssh/alu-devops` and
`~/.ssh/alu-devops.pub`, keep using them. Otherwise create them:

```bash
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/alu-devops -C "campus-notifier-local"
chmod 600 ~/.ssh/alu-devops
```

Do not share or commit the private key (`~/.ssh/alu-devops`).

## 2. Start Docker and configure Terraform

Make sure Docker Desktop is running and WSL integration is enabled for your Ubuntu
distribution. From this `terraform/local` directory run:

```bash
export DOCKER_HOST="$(docker context inspect --format '{{.Endpoints.docker.Host}}')"
docker build -t campus-notifier-local-server:latest .
terraform init
terraform validate
terraform apply
terraform output
```

If your SSH public key is stored somewhere else, update
`ssh_public_key_path` in `terraform.tfvars` to its full WSL path.

## 3. SSH commands

Application server:

```bash
ssh -i ~/.ssh/alu-devops -p 2222 root@127.0.0.1
```

Database server:

```bash
ssh -i ~/.ssh/alu-devops -p 2223 root@127.0.0.1
```

The private Docker-network IPs from `terraform output` are used for
server-to-server communication. From the app server, the database host is
`db_private_ip` and PostgreSQL listens on port `5432`.

## Important local-track differences

These are Docker containers acting as two local servers, not cloud VMs. Their
private IPs are Docker-network addresses and may change after recreation.
The database container does not run systemd by default, so after editing the
PostgreSQL configuration use:

```bash
sudo service postgresql restart
```

rather than `systemctl restart postgresql`.

The app server has the host Docker socket mounted so Docker commands inside it
can use Docker Desktop's daemon. This is a local-lab convenience; do not use
this socket-mount pattern on an untrusted or production server.

When installing Docker in the app server, follow your course's required Ubuntu
steps. If the full Docker Engine installation cannot start a daemon inside the
container, install the Docker CLI and use the mounted socket; the Docker daemon
is already running in Docker Desktop.

## 4. Cleanup

From `terraform/local`:

```bash
terraform destroy
terraform state list
```

After destroy, `terraform state list` should report no managed resources.
