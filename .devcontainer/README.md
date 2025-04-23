# Development Container for Renaissance Insurance App

This directory contains the configuration for the VS Code Development Container for the Renaissance Insurance Flutter application.

## Features

- Flutter SDK with all dependencies pre-installed
- Android SDK for mobile development
- Node.js and npm for potential backend services
- Git and GitHub CLI for version control
- VS Code extensions for Flutter/Dart development
- Persistent caches for Flutter and Gradle dependencies

## Getting Started

1. Install [Docker](https://www.docker.com/products/docker-desktop) on your machine
2. Install [VS Code](https://code.visualstudio.com/)
3. Install the [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension in VS Code
4. Clone this repository
5. Open the repository in VS Code
6. When prompted, click "Reopen in Container". Alternatively, press F1 and select "Remote-Containers: Reopen in Container"
7. Wait for the container to build and start (this may take some time initially)
8. You're now ready to develop in a containerized environment!

## Running the App

Once inside the container, you can run the Flutter app using:

```bash
cd renaissance_insurance
flutter run -d web-server --web-port=3000
```

For mobile development, you can connect a physical device via USB or use an emulator.

## Customization

Feel free to customize the devcontainer configuration files:

- `devcontainer.json`: VS Code settings, extensions, and container configuration
- `Dockerfile`: Container image definition and tool installation
- `docker-compose.yml`: Service configuration and volume mappings

## Troubleshooting

### Display Issues

For Linux users who want to run GUI applications like the Flutter emulator:
- Run `xhost +local:docker` on your host machine before starting the container
- Make sure the DISPLAY environment variable is properly set

### Android Device Connection

If you're having trouble connecting to Android devices:
- Make sure the container has access to the USB device (you may need to modify the docker-compose.yml file)
- Install Android device drivers on your host machine

### Performance

If you experience slow performance:
- Consider adjusting the volume mount options in the docker-compose.yml file
- Increase the resources allocated to Docker in Docker Desktop settings 