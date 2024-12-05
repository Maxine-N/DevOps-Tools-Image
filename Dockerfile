FROM alpine:3.20

LABEL description="A Docker image containing all the tools I use for my tasks as a DevOps Engineer."

# Infrastructure as code
ARG ANSIBLE_VERSION=9.5.1-r0
ARG TERRAFORM_VERSION=1.10.1 # github-releases/hashicorp/terraform
ARG OPENTOFU_VERSION=1.8.7 # github-releases/opentofu/opentofu

# Kubernetes
ARG KUBECTL_VERSION=v1.31.3 # github-releases/kubernetes/kubernetes
ARG KREW_VERSION=v0.4.4 # github-releases/kubernetes-sigs/krew
ARG FLUX_VERSION=2.4.0 # github-releases/fluxcd/flux2
ARG ARGOCD_VERSION=2.13.1 # github-releases/argoproj/argo-cd
ARG HELM_VERSION=3.16.3 # github-releases/helm/helm
ARG LONGHORNCTL_VERSION=v1.7.2 # github-releases/longhorn/cli
ARG K9S_VERSION=0.32.7 # github-releases/derailed/k9s
ARG SOPS_VERSION=3.9.2 # github-releases/getsops/sops

# Ansible Galaxy
ARG ANSIBLE_COMMUNITY_GENERAL_VERSION=9.1.0

# Install apk packagwe
RUN apk add --no-cache ansible python3 && \
    apk add --no-cache py3-pip py3-virtualenv py3-jmespath && \
    apk add --no-cache git openssl openssh sshpass age chezmoi && \
    apk add --no-cache curl zsh tmux nano font-fira-code-nerd viddy && \
    apk add --no-cache jq xq yq-go fzf fzf-zsh-plugin fzf-tmux kubectx kubectx-zsh-completion && \
    apk add --no-cache sudo shadow

# Download packages from their release websites
RUN mkdir -p /tmp/downloads/ && cd /tmp/downloads && \
    # Helm
    echo "Installing Helm" && mkdir -p /tmp/downloads/helm && cd /tmp/downloads/helm/ && \
    curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xvf helm.tar.gz && mv ./linux-amd64/helm /usr/local/bin/helm && chmod +x /usr/local/bin/helm &&\
    # Kubectl
    echo "Installing Kubectl" && mkdir -p /tmp/downloads/kubectl && cd /tmp/downloads/kubectl/ && \
    curl -fsSL -o kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl && \
    # Krew
    echo "Installing krew" && mkdir -p /tmp/downloads/krew && cd /tmp/downloads/krew/ && \
    curl -fsSL -o krew.tar.gz https://github.com/kubernetes-sigs/krew/releases/download/${KREW_VERSION}/krew-linux_amd64.tar.gz && \
    tar -xvf krew.tar.gz && ./krew-linux_amd64 install krew &&\
    # Flux
    echo "Installing Flux" && mkdir -p /tmp/downloads/flux && cd /tmp/downloads/flux/ && \
    curl -fsSL -o flux.tar.gz https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz && \
    tar -xvf flux.tar.gz && mv ./flux /usr/local/bin/flux && chmod +x /usr/local/bin/flux &&\
    # Argocd
    echo "Installing argocd" && mkdir -p /tmp/downloads/argocd && cd /tmp/downloads/argocd/ && \
    curl -fsSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64 && \
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd &&\
    # longhornctl
    echo "Installing longhornctl & longhornctl-local" && mkdir -p /tmp/downloads/longhornctl && cd /tmp/downloads/longhornctl/ && \
    curl -fsSL -o longhornctl https://github.com/longhorn/cli/releases/download/${LONGHORNCTL_VERSION}/longhornctl-linux-amd64   && \
    curl -fsSL -o longhornctl-local https://github.com/longhorn/cli/releases/download/${LONGHORNCTL_VERSION}/longhornctl-local-linux-amd64  && \
    mv ./longhornctl /usr/local/bin/longhornctl && chmod +x /usr/local/bin/longhornctl && \
    mv ./longhornctl-local /usr/local/bin/longhornctl-local && chmod +x /usr/local/bin/longhornctl-local && \
    # K9s
    echo "Installing K9s" && mkdir -p /tmp/downloads/k9s && cd /tmp/downloads/k9s/ && \
    curl -fsSL -o k9s.tar.gz https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz && \
    tar -xvf k9s.tar.gz && mv ./k9s /usr/local/bin/k9s && chmod +x /usr/local/bin/k9s &&\
    # Terraform
    echo "Installing Terraform" && mkdir -p /tmp/downloads/terraform && cd /tmp/downloads/terraform/ && \
    curl -fsSL -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip &&  \
    unzip terraform.zip && mv ./terraform /usr/local/bin/terraform && chmod +x /usr/local/bin/terraform && \
    # OpenTofu
    echo "Installing OpenTofu" && mkdir -p /tmp/downloads/opentofu && cd /tmp/downloads/opentofu/ && \
    curl -fsSL -o opentofu.zip https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_amd64.zip &&  \
    unzip opentofu.zip && mv ./tofu /usr/local/bin/tofu && chmod +x /usr/local/bin/tofu && \
    # sops 
    echo "Installing sops " && mkdir -p /tmp/downloads/sops && cd /tmp/downloads/sops/ && \
    curl -fsSL -o sops https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64 && \
    mv sops /usr/local/bin/sops && chmod +x /usr/local/bin/sops && \
    # Ansible Galaxy
    ansible-galaxy collection install community.general:==${ANSIBLE_COMMUNITY_GENERAL_VERSION}

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/zsh --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Cleaunp
RUN rm -rf /var/cache/apk/ && rm -rf /tmp/downloads

# Set the default user
USER $USERNAME
# Change the dir to the users home
WORKDIR "/home/user/"

# Install ohmyzsh
RUN mkdir -p /home/user/downloads/ohmyzsh && cd /home/user/downloads/ohmyzsh && \
    curl -fsSl -o ohmyzsh.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh && \
    sh ohmyzsh.sh && \
    rm -rf /home/user/downloads/

RUN echo "source <(kubectl completion zsh)" >> ~/.zsh_completion && \
    echo "source <(flux completion zsh)" >> ~/.zsh_completion && \
    echo "source <(helm completion zsh)" >> ~/.zsh_completion && \
    echo "source <(k9s completion zsh)" >> ~/.zsh_completion && \
    echo "complete -C /usr/local/bin/terraform terraform" >> ~/.zsh_completion && \
    echo "complete -C /usr/local/bin/tofu tofu" >> ~/.zsh_completion

CMD ["/bin/zsh"]