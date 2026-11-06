# Campus Notifier

Solo submission

## What I built
- **Terraform:** one Ubuntu 24.04 EC2 server, a security group (SSH from my IP only, HTTP open), a key pair from my public key, an ECR registry, and an Ansible inventory file.
- **Ansible:** installs Docker and Git, clones the repo, builds the image, runs the app on port 80, and checks /health/.

- The Django SECRET_KEY was hard-coded in settings.py. It is now read from an environment variable, and Ansible creates it on the server.
- AWS credentials stay in ~/.aws on my laptop,
- .gitignore covers tfstate, tfvars, .env, SSH keys and the inventory.

## Pull requests
- PR 1: Move secret key out of Git 
- PR 2: Terraform for EC2 server
- PR 3: Ansible deploy playbook 
- PR 4: Team notes

