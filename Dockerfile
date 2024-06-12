FROM alpine:3.20

LABEL description="A Docker image containing all the tools I use for my tasks as a DevOps Engineer."

# Infrastructure as code
ARG ansible_vesrion=9.5.1-r0
ARG terraform_version=1.8.1
ARG opentofu_version=1.6.2

# Kubernetes
ARG kubectl_version=v1.30.0
ARG flux_version=2.2.3
ARG helm_version=3.14.4
ARG k9s_version=0.32.4

# Dependencies
ARG python3_version=3.12.3-r1
ARG pip_version=24.0-r2

ARG ansible_community_general_version=8.5.0

# Install apk packagwe
RUN apk add --no-cache ansible=${ansible_vesrion} python3=${python3_version} py3-pip-pyc=${pip_version} &&\
    apk add --no-cache git openssl openssh sshpass && \
    apk add --no-cache curl bash bash-completion nano

# Download packages from their release websites
RUN mkdir -p /tmp/downloads/ && cd /tmp/downloads && \
    # Helm
    mkdir -p /tmp/downloads/helm && cd /tmp/downloads/helm/ && \
    curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz && \
    tar -xvf helm.tar.gz && mv ./linux-amd64/helm /usr/local/bin/helm && chmod +x /usr/local/bin/helm &&\
    # Kubectl
    mkdir -p /tmp/downloads/kubectl && cd /tmp/downloads/kubectl/ && \
    curl -fsSL -o kubectl https://dl.k8s.io/release/${kubectl_version}/bin/linux/amd64/kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl && \
    # Flux
    mkdir -p /tmp/downloads/flux && cd /tmp/downloads/flux/ && \
    curl -fsSL -o flux.tar.gz https://github.com/fluxcd/flux2/releases/download/v${flux_version}/flux_${flux_version}_linux_amd64.tar.gz && \
    tar -xvf flux.tar.gz && mv ./flux /usr/local/bin/flux && chmod +x /usr/local/bin/flux &&\
    # K9s
    mkdir -p /tmp/downloads/k9s && cd /tmp/downloads/k9s/ && \
    curl -fsSL -o k9s.tar.gz https://github.com/derailed/k9s/releases/download/v${k9s_version}/k9s_Linux_amd64.tar.gz && \
    tar -xvf k9s.tar.gz && mv ./k9s /usr/local/bin/k9s && chmod +x /usr/local/bin/k9s &&\
    # Terraform
    mkdir -p /tmp/downloads/terraform && cd /tmp/downloads/terraform/ && \
    curl -fsSL -o terraform.zip https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip &&  \
    unzip terraform.zip && mv ./terraform /usr/local/bin/terraform && chmod +x /usr/local/bin/terraform && \
    # OpenTofu
    mkdir -p /tmp/downloads/opentofu && cd /tmp/downloads/opentofu/ && \
    curl -fsSL -o opentofu.zip https://github.com/opentofu/opentofu/releases/download/v${opentofu_version}/tofu_${opentofu_version}_linux_amd64.zip &&  \
    unzip opentofu.zip && mv ./tofu /usr/local/bin/tofu && chmod +x /usr/local/bin/tofu && \
    ansible-galaxy collection install community.general:==${ansible_community_general_version}

# Install bash completion scripts
RUN mkdir -p /etc/bash_completion.d && touch ~/.bashrc && \ 
    kubectl completion bash > /etc/bash_completion.d/kubectl && chmod a+r /etc/bash_completion.d/kubectl && \ 
    flux completion bash > /etc/bash_completion.d/flux && chmod a+r /etc/bash_completion.d/flux && \ 
    helm completion bash > /etc/bash_completion.d/helm && chmod a+r /etc/bash_completion.d/helm && \
    k9s completion bash > /etc/bash_completion.d/k9s && chmod a+r /etc/bash_completion.d/k9s && \
    terraform -install-autocomplete && \
    tofu -install-autocomplete

# Cleaunp
RUN rm -rf /var/cache/apk/ && rm -rf /tmp/downloads
