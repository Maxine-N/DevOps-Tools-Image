
# DevOps Docker Image

## Description
This Docker image includes a collection of tools that I regularly use as a DevOps Engineer. The image is available [on the GitHub Container Registry (GHCR)](https://github.com/Maxine-N/DevOps-Tools-Image/pkgs/container/devops-tools-image) and can be pulled using the command:
```sh
docker pull ghcr.io/maxine-n/devops-tools-image:main
```
A sample [docker-compose.yml](docker-compose.example.yaml) is also provided, which includes mounts for SSH and Kubernetes configurations, allowing you to use the configurations from your host system.

## Version Management
Most tool versions in this image are managed by [Renovate](https://renovatebot.com), which automatically creates pull requests when new versions become available.

## Included Tools
Tools marked with an asterisk (*) include completions.

### Shell
- [zsh](https://www.zsh.org)
- [ohmyzsh](https://ohmyz.sh)

### Infrastructure as Code (IaC) Tools
- [Ansible](https://www.ansible.com)
- [Terraform](https://www.terraform.io)*
- [OpenTofu](https://opentofu.org)*

### Kubernetes Tools
- [Kubectl](https://kubernetes.io/de/docs/reference/kubectl)*
- [Flux](https://fluxcd.io)*
- [Helm](https://helm.sh)*
- [K9s](https://k9scli.io)*

## How to Use This Image with Docker Compose
1. Run the container:
    ```sh
    docker-compose run app
    ```
2. Source ~/.zsh_completion
    ```sh
    source ~/.zsh_completion
    ```
3. Start using your DevOps tools as needed.

Step 2 can of course also be automated by including it in your `~/.zshrc` and mounting a persistent version of that. 

### Tips and tricks

For example by adding this to your docker-compose.yaml
```yaml
- type: bind
  source: ~/.zshrc
  target: /home/user/.zshrc
  read_only: false
```
It's also a good idea to persist the `.zsh_history`:
```yaml
- type: bind
  source: ~/.zsh_history
  target: /home/user/.zsh_history
  read_only: false
```

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.