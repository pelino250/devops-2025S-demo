# Campus Event Notifier DevOps Demo

This repository includes a local Docker lab provisioned with Terraform and configured with Ansible. The steps below were run from Ubuntu on WSL 2 with Docker Desktop.

## Requirements

- Docker Desktop for Windows, running with WSL integration enabled for your Ubuntu distribution. In Docker Desktop, open **Settings → Resources → WSL Integration**, enable Ubuntu, then apply the change.
- Terraform and Ansible installed in WSL Ubuntu.
- An SSH key at `~/.ssh/alu-devops` and its public key at `~/.ssh/alu-devops.pub`.

Create the key if it does not already exist:

```bash
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/alu-devops -C "campus-notifier-local"
chmod 600 ~/.ssh/alu-devops
```

Never commit or share the private key.

## Provision the local servers

Open Ubuntu and move to the repository. For example, if it is checked out on `D:`:

```bash
cd /mnt/d/Git/devops-2025S-demo
docker version
```

`docker version` must show both Client and Server sections. If Docker is unavailable, start Docker Desktop and enable WSL integration for the Ubuntu distribution you are using.

Build the SSH-only image used by the two simulated servers, then provision them with Terraform:

```bash
cd terraform/local
export DOCKER_HOST="$(docker context inspect --format '{{.Endpoints.docker.Host}}')"
docker build -t campus-notifier-local-server:latest .
terraform init
terraform validate
terraform apply
```

Type `yes` when Terraform asks to create the resources. The apply creates an app server, a database server, and their private Docker network. The app server has SSH on port `2222`; the database server has SSH on port `2223`.

Inspect the servers' private IP addresses if needed:

```bash
terraform output -raw db_private_ip
terraform output -raw instance_private_ip
```

The inventory connects to the lab servers through their forwarded SSH ports on `127.0.0.1`. The app reaches PostgreSQL by the database container's Docker network name, so you do not need to copy changing private IPs into Ansible inventory.

## Build and deploy the application

Build the app image from the repository root. Docker Desktop's daemon is shared with the app lab server through the mounted Docker socket, so Ansible can use this local image.

```bash
cd ../..
docker build -t campus-notifier-app:local -f Dockerfile .
```

Install the Ansible collections, prepare Python on the new servers, and verify connectivity:

```bash
cd ansible
ansible-galaxy collection install community.docker community.postgresql
ansible -i inventory.ini all -m raw -a "apt-get update && apt-get install -y python3"
ansible -i inventory.ini all -m ping
```

Both hosts should return `pong`. Then run the playbook:

```bash
ansible-playbook -i inventory.ini site.yml
```

Choose a PostgreSQL password at the first prompt and enter the same password at the second prompt. The playbook installs PostgreSQL, creates the `campus` database and user, and starts the app container.

Check the app's health endpoint:

```bash
curl http://127.0.0.1:8080/health
```

Expected response:

```json
{"status": "ok"}
```

### WSL note

When the repository is on a Windows-mounted path such as `/mnt/d`, Ansible may warn that the directory is world-writable and ignore `ansible.cfg`. The commands above pass `-i inventory.ini` explicitly so they still use the repository inventory.

## Remove the local lab

When finished, destroy the Terraform-managed servers and network:

```bash
cd /mnt/d/Git/devops-2025S-demo/terraform/local
terraform destroy
```

Type `yes` to confirm. Check the remaining Terraform state with `terraform state list`.

## AWS Terraform example

`aws-terraform` is a separate one-instance starter example. It is not currently wired to the local Ansible inventory or the two-server Campus Event Notifier setup.
