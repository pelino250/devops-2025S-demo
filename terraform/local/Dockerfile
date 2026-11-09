FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# SSH is the only service preinstalled so you can log in to the local
# simulated servers. PostgreSQL and Docker are intentionally left out.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       openssh-server sudo ca-certificates curl gnupg lsb-release \
    && mkdir -p /var/run/sshd /root/.ssh \
    && touch /root/.ssh/authorized_keys \
    && chmod 700 /root/.ssh \
    && chmod 600 /root/.ssh/authorized_keys \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
