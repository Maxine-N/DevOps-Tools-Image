# Using this Docker image as a devcontainer

Using this Docker image as a DevContainer is straightforward and can be accomplished with the following example. 

## DevContainer Configuration

Create a `.devcontainer` folder in the root of your project if it doesn't already exist. Inside this folder, create a `devcontainer.json` file with the following configuration:

```json
{
  "name": "DevOps Environment",
  "image": "ghcr.io/maxine-n/devops-tools-image:main",
  "remoteUser": "user",
  "containerUser": "user",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-kubernetes-tools.vscode-kubernetes-tools",
        "redhat.vscode-yaml"
      ]
    }
  },
  "mounts": [
    "source=${localEnv:USERPROFILE}/.ssh/,target=/home/user/.ssh/,type=bind",
    "source=${localEnv:USERPROFILE}/.kube/,target=/home/user/.kube/,type=bind",
    "source=${localEnv:USERPROFILE}/.gitconfig,target=/home/user/.gitconfig,type=bind"
  ],
  "containerEnv": {
    "KUBECONFIG": "/home/user/.kube/devops-test.yaml"
  },
  "postCreateCommand": "/usr/bin/chezmoi init --apply Maxine-N",
  "postStartCommand": "",
  "postAttachCommand": ""
}
```

### Notes
- `postCreateCommand`: Replace it with your GitHub username or remove if not needed.
- `mounts`: Ensure paths are correct for your environment.