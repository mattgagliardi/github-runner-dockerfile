FROM rockylinux:9

ARG RUNNER_VERSION="2.314.1"

RUN dnf upgrade -y && useradd -m podman

RUN dnf install -y \
    jq gcc gcc-c++ kernel-devel make openssl-devel libffi-devel python3-devel python3-pip \
    ansible-core

RUN cd /home/podman && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R podman ~podman && /home/podman/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER podman

ENTRYPOINT ["./start.sh"]
