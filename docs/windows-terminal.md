# Using the Docker Container in Windows Terminal

This guide provides instructions for setting up and using the Docker container in Windows Terminal. Follow the steps below to configure your environment.

## Prerequisites

Ensure you have the following installed on your system:
- Docker
- Windows Terminal
- PowerShell

## Setting Up the Container

To run the container, create the following files inside a new directory:

### `docker-compose.yaml`

```yaml
services:
  app:
    image: ghcr.io/maxine-n/devops-tools-image:main
    user: "1000:1000"
    command: /bin/sh -c "/usr/bin/chezmoi init --apply <GitHubUserName> && exec zsh"
    stdin_open: true
    tty: true
    volumes:
      - type: bind
        source: ~/.ssh/
        target: /home/user/.ssh/
        read_only: false
      - type: bind
        source: ~/.kube/
        target: /home/user/.kube/
        read_only: false
      - type: bind
        source: ~/.gitconfig
        target: /home/user/.gitconfig
        read_only: false
      - type: bind
        source: ~/AppData/Roaming/sops/age
        target: /home/user/.sops/age/
        read_only: false
      - type: bind
        source: ~/Dev
        target: /mnt
      - type: bind
        source: ./root_folder/.zsh_history
        target: /home/user/.zsh_history
    ports:
      - target: 80
        published: 80
        protocol: tcp
        mode: bridge
      - target: 8080
        published: 8080
        protocol: tcp
        mode: bridge
      - target: 8081
        published: 8081
        protocol: tcp
        mode: bridge
```

### `start-or-attach-container.ps1`

```ps1
# Define the service name
$serviceName = "app"

# Define the chezmoi command to clone and apply dotfiles
$chezmoiInitCommand = "chezmoi init --apply <GitHubUserName>"

# Check if the container is already running
$containerStatus = docker compose ps -a -q $serviceName

if ($containerStatus) {
    # If the container is running, attach to it using zsh
    Write-Output "Container is already running. Attaching to it..."
    docker compose exec $serviceName zsh
} else {
    # If the container is not running, start it and run chezmoi
    Write-Output "Container is not running. Starting it..."
    docker compose pull
    docker compose run --rm $serviceName sh -c "$chezmoiInitCommand && zsh"
}
```

## Configuring Windows Terminal

You can set up a profile in Windows Terminal to use the container. There are two methods to achieve this:

### Method 1: Adding a New Profile via the UI

1. Open Windows Terminal settings with `CTRL+,`.
2. Click on `+ Add new profile`.
3. Configure the profile with the following settings:
   - **Name**: `Dev Env`
   - **Command line**: 
     ```ps1
     powershell.exe -NoExit -File <PathToYourDirectory>\start-or-attach-container.ps1
     ```
   - **Starting directory**: 
     ```ps1
     <PathToYourDirectory>
     ```

### Method 2: Adding a New Profile via `settings.json`

1. Open the `settings.json` file in Windows Terminal.
2. Add the following profile configuration:

```json
{
    "profiles": {
        "list": [
            {
                "closeOnExit": "never",
                "commandline": "powershell.exe -NoExit -File \"<PathToYourDirectory>\\start-or-attach-container.ps1\"",
                "guid": "{40d9ee7a-83e0-4ae0-af4e-a71aa27efb15}",
                "icon": "<PathToYourDirectory>\\icon.png",
                "name": "Dev Env",
                "startingDirectory": "<PathToYourDirectory>"
            }
        ]
    }
}
```

### Example Configuration

Here is an example configuration with specific paths:

```json
{
    "profiles": {
        "list": [
            {
                "closeOnExit": "never",
                "commandline": "powershell.exe -NoExit -File \"C:\\Users\\maxine\\DEV\\dev-env\\start-or-attach-container.ps1\"",
                "guid": "{40d9ee7a-83e0-4ae0-af4e-a71aa27efb15}",
                "icon": "C:\\Users\\maxine\\DEV\\dev-env\\icon.png",
                "name": "Dev Env",
                "startingDirectory": "C:\\Users\\maxine\\DEV\\dev-env"
            }
        ]
    }
}
```

## Notes

- Replace `<PathToYourDirectory>` with the actual path to your directory.
- Replace `<GitHubUserName>` with your actual GitHub username.
- Ensure all paths and file names are correct for your environment.