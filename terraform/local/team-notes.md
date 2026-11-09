# Team Notes - Session 1 & 2 (Campus Notifier Platform)

## Overview & Track Choice
For this assignment, our team opted to use the **Local Track**. We chose this approach because it provided a faster feedback loop for testing the Ansible playbooks without relying on fluctuating cloud network latencies. It also allowed us to bypass strict organization-level cloud policies (like AWS SCPs) that were blocking EC2 and VPC access, ensuring we could focus on mastering configuration management.

## Infrastructure vs. Configuration Management
We separated our concerns effectively:
*   **Terraform (Provisioning):** We used Terraform to provision the foundational infrastructure. This included creating a dedicated Docker network (`campus-net`) and spinning up two separate Docker containers that simulate our App Server and Database Server. 
*   **Ansible (Configuration):** We used Ansible to configure the software *inside* those containers. This included installing PostgreSQL, configuring `pg_hba.conf` for network access, installing the Docker CLI, and deploying the application.

## Connectivity & Inventory
Our `inventory.ini` maps our two target servers (App and DB) to specific SSH ports on `localhost` (ports 2222 and 2223). 
*   We used the `ansible.builtin.ping` module to confirm connectivity before running any playbooks. 
*   **Troubleshooting:** Initially, we hit a "Connection refused" error on port 2223. We resolved this by verifying that the underlying Terraform/Docker containers were actually running and that the SSH daemon inside the containers had finished booting.

## Docker Installation & Configuration
During the manual setup phase, we noticed the instruction to run `docker --version` to see a "command not found" error. Because we are on the local track using a Docker-in-Docker setup, the Docker socket was mounted, but the CLI still needed installation. 
To satisfy the rubric, we explicitly avoided using `shell` or `command` modules for installation. Instead, we used:
*   `ansible.builtin.apt` to install `docker.io` and `python3-docker`.
*   `ansible.builtin.service` to ensure the Docker service was running and enabled.

## Idempotence: Manual vs. Ansible
The most important lesson from this session was understanding **idempotence**. 
*   **The Manual Way:** When we manually ran `docker run -d --name campus-notifier ...`, running it a second time failed with a `Conflict. The container name "/campus-notifier" is already in use` error. It is not idempotent.
*   **The Ansible Way:** In our playbook, we used the `community.docker.docker_container` module. Ansible checks the current state of the system against the desired state in the playbook. If the container exists, is running the correct image, and has the correct environment variables, Ansible does nothing. On our second consecutive run, the Play Recap showed `changed=0`, proving idempotence.

## Application Deployment & Health Checks
We deployed the Campus Event Notifier using the `community.docker.docker_container` module, passing in environment variables to connect to our PostgreSQL database. 
*   Instead of just assuming the app was running, we used the `ansible.builtin.uri` module to poll `http://127.0.0.1:8080/health/`.
*   We configured the task with `retries: 12` and `delay: 5` so Ansible would wait for the application to fully boot and connect to the database before declaring the playbook successful.
