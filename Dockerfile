FROM alpine:3.19

# Infrastructure as code
ARG ansible_vesrion=8.6.1-r0
ARG terraform_version=1.8.1
ARG opentofu_version=1.6.2

# Kubernetes
ARG kubectl_version=v1.30.0
ARG flux_version=2.2.3
ARG helm_version=3.14.4

ARG python3_version=3.11.9-r0
ARG pip_version=23.3.1-r0

ARG git_version=2.43.0-r0

ARG openssl_version=3.1.4-r6
ARG curl_version=8.5.0-r0
ARG bash_version=5.2.21-r0
ARG bash_completion_version=2.11-r6

ARG openssh_version=9.6_p1-r0
ARG sshpass_version=1.10-r0

ARG nano_version=7.2-r1

ARG pre_commit_version=3.7.0
ARG ansible_community_general_version=8.5.0


# Install apk packagwe
RUN apk add --no-cache ansible=${ansible_vesrion} python3=${python3_version} py3-pip=${pip_version} && \
    apk add --no-cache git=${git_version} openssl=${openssl_version} openssh=${openssh_version} sshpass=${sshpass_version} && \
    apk add --no-cache curl=${curl_version} bash=${bash_version} bash-completion=${bash_completion_version} nano=${nano_version} 

# Download packages from their release websites
RUN mkdir -p /tmp/downloads/ && cd /tmp/downloads && \
    # Helm
    curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz && \
    tar -xvf helm.tar.gz && mv ./linux-amd64/helm /usr/local/bin/helm && chmod +x /usr/local/bin/helm &&\
    # Kubectl
    curl -fsSL -o kubectl https://dl.k8s.io/release/${kubectl_version}/bin/linux/amd64/kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl && \
    # Flux
    curl -fsSL -o flux.tar.gz https://github.com/fluxcd/flux2/releases/download/v${flux_version}/flux_${flux_version}_linux_amd64.tar.gz && \
    tar -xvf flux.tar.gz && mv ./flux /usr/local/bin/flux && chmod +x /usr/local/bin/flux &&\
    # Terraform
    curl -fsSL -o terraform.zip https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip &&  \
    unzip terraform.zip && mv ./terraform /usr/local/bin/terraform && chmod +x /usr/local/bin/terraform && \
    # OpenTofu
    curl -fsSL -o opentofu.zip https://github.com/opentofu/opentofu/releases/download/v${opentofu_version}/tofu_${opentofu_version}_linux_amd64.zip &&  \
    unzip opentofu.zip && mv ./tofu /usr/local/bin/tofu && chmod +x /usr/local/bin/tofu && \
    ansible-galaxy collection install community.general:==${ansible_community_general_version}

# Install bash completion scripts
RUN mkdir /etc/bash_completion.d && \ 
    kubectl completion bash > /etc/bash_completion.d/kubectl && chmod a+r /etc/bash_completion.d/kubectl && \ 
    flux completion bash > /etc/bash_completion.d/flux && chmod a+r /etc/bash_completion.d/flux && \ 
    helm completion bash > /etc/bash_completion.d/helm && chmod a+r /etc/bash_completion.d/helm

# Cleaunp
RUN rm -rf /var/cache/apk/ && rm -rf /tmp/downloads