# Campus Event Notifier — Ansible Local Track

## 1. Recreate Terraform infrastructure

Navigate to terraform/local:

    cd terraform/local

Configure Docker:

    export DOCKER_HOST="$(docker context inspect --format '{{.Endpoints.docker.Host}}')"

Build the local server image:

    docker build -t campus-notifier-local-server:latest -f Dockerfile .

Build the application image from the repository root so it is available to
the Docker Desktop engine used by the app server:

    cd ../..
    docker build -t campus-notifier-app:local -f Dockerfile .
    cd terraform/local

Apply infrastructure:

    terraform init
    terraform validate
    terraform apply

View outputs:

    terraform output

On WSL when this repository is under `/mnt`, Ansible may ignore `ansible.cfg`
because Windows-mounted files are world-writable. Run Ansible commands with
`-i inventory.ini` from the `ansible` directory.

## 2. Verify servers are blank

Application server:

    ssh -i ~/.ssh/alu-devops -p 2222 root@127.0.0.1

    docker --version

Database server:

    ssh -i ~/.ssh/alu-devops -p 2223 root@127.0.0.1

    psql --version

Both commands should initially return command not found.

## 3. Install Ansible

    sudo apt update
    sudo apt install -y ansible

Verify:

    ansible --version

## 4. Install collections

    ansible-galaxy collection install community.docker community.postgresql

## 5. Test connectivity

Navigate to ansible directory:

    cd ../ansible

Install Python on both servers using raw:

    ansible -i inventory.ini all -m raw -a "apt-get update && apt-get install -y python3"

Test:

    ansible -i inventory.ini all -m ping

Expected result: pong.

## 6. Run playbook

    ansible-playbook -i inventory.ini site.yml

Enter the same PostgreSQL password when prompted.

## 7. Verify application

    curl http://127.0.0.1:8080/health

Expected:

    {"status": "ok"}

## 8. View application logs

    ssh -i ~/.ssh/alu-devops -p 2222 root@127.0.0.1

    docker logs campus-notifier
