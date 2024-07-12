FROM alpine:3.20

LABEL description="A Docker image containing all the tools I use for my tasks as a DevOps Engineer."

# Infrastructure as code
ARG ANSIBLE_VERSION=9.5.1-r0
ARG TERRAFORM_VERSION=1.8.5 # github-releases/hashicorp/terraform
ARG OPENTOFU_VERSION=1.7.2 # github-releases/opentofu/opentofu

# Kubernetes
ARG KUBECTL_VERSION=v1.30.2 # github-releases/kubernetes/kubernetes
ARG FLUX_VERSION=2.2.3 # github-releases/fluxcd/flux2
ARG HELM_VERSION=3.15.2 # github-releases/helm/helm
ARG K9S_VERSION=0.32.5 # github-releases/derailed/k9s

# Dependencies
ARG PYTHON3_VERSION=3.12.3-r1
ARG PIP_VERSION=24.0-r2
ARG VIRTUALENV_VERSION=20.26.2-r0
ARG JMESPATH_VERSION=1.0.1-r3

ARG ANSIBLE_COMMUNITY_GENERAL_VERSION=9.1.0

# Install apk packagwe
RUN apk add --no-cache ansible=${ANSIBLE_VERSION} python3=${PYTHON3_VERSION} && \
    apk add --no-cache py3-pip=${PIP_VERSION} py3-virtualenv=${VIRTUALENV_VERSION} py3-jmespath=${JMESPATH_VERSION} && \
    apk add --no-cache git openssl openssh sshpass && \
    apk add --no-cache curl zsh tmux nano && \
    apk add --no-cache jq xq yq-go yq-go-bash-completion

# Download packages from their release websites
RUN mkdir -p /tmp/downloads/ && cd /tmp/downloads && \
    # Helm
    mkdir -p /tmp/downloads/helm && cd /tmp/downloads/helm/ && \
    curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xvf helm.tar.gz && mv ./linux-amd64/helm /usr/local/bin/helm && chmod +x /usr/local/bin/helm &&\
    # Kubectl
    mkdir -p /tmp/downloads/kubectl && cd /tmp/downloads/kubectl/ && \
    curl -fsSL -o kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl && \
    # Flux
    mkdir -p /tmp/downloads/flux && cd /tmp/downloads/flux/ && \
    curl -fsSL -o flux.tar.gz https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz && \
    tar -xvf flux.tar.gz && mv ./flux /usr/local/bin/flux && chmod +x /usr/local/bin/flux &&\
    # K9s
    mkdir -p /tmp/downloads/k9s && cd /tmp/downloads/k9s/ && \
    curl -fsSL -o k9s.tar.gz https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz && \
    tar -xvf k9s.tar.gz && mv ./k9s /usr/local/bin/k9s && chmod +x /usr/local/bin/k9s &&\
    # Terraform
    mkdir -p /tmp/downloads/terraform && cd /tmp/downloads/terraform/ && \
    curl -fsSL -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip &&  \
    unzip terraform.zip && mv ./terraform /usr/local/bin/terraform && chmod +x /usr/local/bin/terraform && \
    # OpenTofu
    mkdir -p /tmp/downloads/opentofu && cd /tmp/downloads/opentofu/ && \
    curl -fsSL -o opentofu.zip https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_amd64.zip &&  \
    unzip opentofu.zip && mv ./tofu /usr/local/bin/tofu && chmod +x /usr/local/bin/tofu && \
    # ohmyzsh
    mkdir -p /tmp/downloads/ohmyzsh && cd /tmp/downloads/ohmyzsh/ && \
    curl -fsSl -o ohmyzsh.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh && \
    sh ohmyzsh.sh && \
    # Ansible Galaxy
    ansible-galaxy collection install community.general:==${ANSIBLE_COMMUNITY_GENERAL_VERSION}

RUN mkdir -p ~/.oh-my-zsh/completions && \
    echo "source <(kubectl completion zsh)" >> ~/.zsh_completion && \
    echo "source <(flux completion zsh)" >> ~/.zsh_completion && \
    echo "source <(helm completion zsh)" >> ~/.zsh_completion && \
    echo "source <(k9s completion zsh)" >> ~/.zsh_completion && \
    echo "complete -C /usr/local/bin/terraform terraform" >> ~/.zsh_completion && \
    echo "complete -C /usr/local/bin/tofu tofu" >> ~/.zsh_completion

# Cleaunp
RUN rm -rf /var/cache/apk/ && rm -rf /tmp/downloads

CMD ["zsh"]