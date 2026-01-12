FROM ubuntu:24.04

LABEL description="A Docker image containing all the tools I use for my tasks as a DevOps Engineer."

# Infrastructure as code
ARG TERRAFORM_VERSION=1.10.5 # github-releases/hashicorp/terraform
ARG OPENTOFU_VERSION=1.11.2 # github-releases/opentofu/opentofu

# Kubernetes
ARG CHEZMOI_VERSION=2.66.1 # github-releases/twpayne/chezmoi
ARG TALOSCTL_VERSION=v1.9.3 # github-releases/siderolabs/talos
ARG KUBECTL_VERSION=v1.31.3 # github-releases/kubernetes/kubernetes
ARG KREW_VERSION=v0.4.4 # github-releases/kubernetes-sigs/krew
ARG FLUX_VERSION=2.4.0 # github-releases/fluxcd/flux2
ARG ARGOCD_VERSION=2.14.1 # github-releases/argoproj/argo-cd
ARG HELM_VERSION=3.17.0 # github-releases/helm/helm
ARG DOCKER_CLI_VERSION=28.5.1 # github-tags/docker/cli
ARG STACKIT_CLI_VERSION=0.47.0 # github-releases/stackitcloud/stackit-cli
ARG VIDDY_VERSION=1.3.0 # github-releases/sachaos/viddy
ARG KIND_VERSION=v0.29.0 # github-releases/kubernetes-sigs/kind
ARG LONGHORNCTL_VERSION=v1.8.0 # github-releases/longhorn/cli
ARG K9S_VERSION=0.50.18 # github-releases/derailed/k9s
ARG SOPS_VERSION=3.9.4 # github-releases/getsops/sops

# Ansible Galaxy
ARG ANSIBLE_COMMUNITY_GENERAL_VERSION=9.1.0

# Install via apt 
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ansible-core \
      python3 python3-pip python3-virtualenv python3-jmespath \
      git openssl openssh-client openssh-server sshpass gpg gpg-agent age \
      curl zsh tmux nano fonts-firacode \
      jq yq fzf kubectx sudo unzip locales && \
    # Clean up
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set locales
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Download packages from their release websites
RUN mkdir -p /tmp/downloads/ && cd /tmp/downloads && \
    # chezmoi
    echo "Installing chezmoi" && mkdir -p chezmoi && cd chezmoi && \
    curl -fsSL -o chezmoi.deb https://github.com/twpayne/chezmoi/releases/download/v${CHEZMOI_VERSION}/chezmoi_${CHEZMOI_VERSION}_linux_amd64.deb && \
    dpkg -i chezmoi.deb && \
    # Helm
    echo "Installing helm" && mkdir -p ../helm && cd ../helm && \
    curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xzf helm.tar.gz && mv linux-amd64/helm /usr/local/bin/helm && chmod +x /usr/local/bin/helm && \
    # Docker CLI
    echo "Installing docker-cli" && mkdir -p ../docker-cli && cd ../docker-cli && \
    curl -fsSL -o docker-cli.deb https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/docker-ce-cli_${DOCKER_CLI_VERSION}-1~ubuntu.24.04~noble_amd64.deb && \
    dpkg -i docker-cli.deb && \
    # Stackit CLI
    echo "Installing stackit-cli" && mkdir -p ../stackit-cli && cd ../stackit-cli && \
    curl -fsSL -o stackit-cli.deb https://github.com/stackitcloud/stackit-cli/releases/download/v${STACKIT_CLI_VERSION}/stackit_${STACKIT_CLI_VERSION}_linux_amd64.deb && \
    dpkg -i stackit-cli.deb && \
    # Kubectl
    echo "Installing kubectl" && mkdir -p ../kubectl && cd ../kubectl && \
    curl -fsSL -o kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl && \
    # talosctl
    echo "Installing talosctl" && mkdir -p ../talosctl && cd ../talosctl && \
    curl -fsSL -o talosctl https://github.com/siderolabs/talos/releases/download/${TALOSCTL_VERSION}/talosctl-linux-amd64 && \
    mv talosctl /usr/local/bin/talosctl && chmod +x /usr/local/bin/talosctl && \
    # Flux
    echo "Installing flux" && mkdir -p ../flux && cd ../flux && \
    curl -fsSL -o flux.tar.gz https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz && \
    tar -xzf flux.tar.gz && mv flux /usr/local/bin/flux && chmod +x /usr/local/bin/flux && \
    # viddy
    echo "Installing viddy" && mkdir -p ../viddy && cd ../viddy && \
    curl -fsSL -o viddy.tar.gz https://github.com/sachaos/viddy/releases/download/v${VIDDY_VERSION}/viddy-v${VIDDY_VERSION}-linux-x86_64.tar.gz && \
    tar -xzf viddy.tar.gz && mv viddy /usr/local/bin/viddy && chmod +x /usr/local/bin/viddy && \
    # Argo CD
    echo "Installing argocd" && mkdir -p ../argocd && cd ../argocd && \
    curl -fsSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64 && \
    install -m 555 argocd-linux-amd64 /usr/local/bin/argocd && \
    # Longhornctl
    echo "Installing longhornctl & longhornctl-local" && mkdir -p ../longhornctl && cd ../longhornctl && \
    curl -fsSL -o longhornctl https://github.com/longhorn/cli/releases/download/${LONGHORNCTL_VERSION}/longhornctl-linux-amd64 && \
    curl -fsSL -o longhornctl-local https://github.com/longhorn/cli/releases/download/${LONGHORNCTL_VERSION}/longhornctl-local-linux-amd64 && \
    mv longhornctl longhornctl-local /usr/local/bin/ && chmod +x /usr/local/bin/longhornctl* && \
    # K9s
    echo "Installing k9s" && mkdir -p ../k9s && cd ../k9s && \
    curl -fsSL -o k9s.tar.gz https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz && \
    tar -xzf k9s.tar.gz && mv k9s /usr/local/bin/k9s && chmod +x /usr/local/bin/k9s && \
    # Terraform
    echo "Installing terraform" && mkdir -p ../terraform && cd ../terraform && \
    curl -fsSL -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform.zip && mv terraform /usr/local/bin/terraform && chmod +x /usr/local/bin/terraform && \
    # OpenTofu
    echo "Installing opentofu" && mkdir -p ../opentofu && cd ../opentofu && \
    curl -fsSL -o opentofu.zip https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_amd64.zip && \
    unzip opentofu.zip && mv tofu /usr/local/bin/tofu && chmod +x /usr/local/bin/tofu && \
    # sops
    echo "Installing sops" && mkdir -p ../sops && cd ../sops && \
    curl -fsSL -o sops https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64 && \
    mv sops /usr/local/bin/sops && chmod +x /usr/local/bin/sops && \
    # MinIO client
    echo "Installing mc" && mkdir -p ../minio && cd ../minio && \
    curl -fsSL -o mc https://dl.min.io/client/mc/release/linux-amd64/mc && \
    mv mc /usr/local/bin/mc && chmod +x /usr/local/bin/mc && \
    # Kind
    echo "Installing kind" && mkdir -p ../kind && cd ../kind && \
    curl -fsSL -o kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64 && \
    mv kind /usr/local/bin/kind && chmod +x /usr/local/bin/kind && \
    # Ansible Galaxy
    ansible-galaxy collection install community.general:==${ANSIBLE_COMMUNITY_GENERAL_VERSION}

ARG USERNAME=user
ARG USER_UID=1010
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
 && useradd -m -s /bin/zsh --uid $USER_UID --gid $USER_GID $USERNAME \
 && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
 && chmod 0440 /etc/sudoers.d/$USERNAME

# Clean up downloads\ 

RUN rm -rf /tmp/downloads

# Switch to non-root user
USER $USERNAME
WORKDIR /home/$USERNAME

# Oh My Zsh + Krew plugins
RUN echo "Installing ohmyzsh" && mkdir -p ~/downloads/ohmyzsh && cd ~/downloads/ohmyzsh && \
    curl -fsSL -o install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh && \
    sh install.sh && mkdir -p ~/.oh-my-zsh/custom/completions && mkdir -p ~/.oh-my-zsh/custom/plugins \
    # ohmyzsh - fzf-zsh 
    echo "Installing ohmyzsh - fzf-zsh" && \
    git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git ~/.oh-my-zsh/custom/plugins/fzf-zsh-plugin && \
    # ohmyzsh - kubectx
    echo "Installing ohmyzsh - kubectx" && \
    git clone --depth 1 https://github.com/ahmetb/kubectx.git ~/.kubectx && \
    mv ~/.kubectx/completion/_kubectx.zsh ~/.oh-my-zsh/custom/completions/_kubectx.zsh && \
    mv ~/.kubectx/completion/_kubens.zsh ~/.oh-my-zsh/custom/completions/_kubens.zsh && \
    rm -rf ~/.kubectx && \
    # krew
    echo "Installing krew" && mkdir -p ~/downloads/krew && cd ~/downloads/krew && \
    curl -fsSL -o krew.tar.gz https://github.com/kubernetes-sigs/krew/releases/download/${KREW_VERSION}/krew-linux_amd64.tar.gz && \
    tar -xzf krew.tar.gz && ./krew-linux_amd64 install krew && \
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" && \
    kubectl krew install stern explore node-shell ctx ns && \
    rm -rf ~/downloads

# Zsh completions
RUN echo "source <(kubectl completion zsh)" >> ~/.zsh_completion && \
    echo "source <(talosctl completion zsh)" >> ~/.zsh_completion && \
    echo "source <(flux completion zsh)" >> ~/.zsh_completion && \
    echo "source <(helm completion zsh)" >> ~/.zsh_completion && \
    echo "source <(k9s completion zsh)" >> ~/.zsh_completion && \
    echo "complete -C /usr/local/bin/terraform terraform" >> ~/.zsh_completion && \
    echo "complete -C /usr/local/bin/tofu tofu" >> ~/.zsh_completion

CMD ["/bin/zsh"]
