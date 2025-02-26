# Docker Documentation
## Install and run Docker Desktop on Mac
### Install interactively
Download the installer using the download buttons at the top of the page, or from the release notes.

Double-click `Docker.dmg` to open the installer, then drag the Docker icon to the Applications folder. By default, Docker Desktop is installed at `/Applications/Docker.app`.

Double-click `Docker.app` in the Applications folder to start Docker.

The Docker menu displays the Docker Subscription Service Agreement.

Here’s a summary of the key points:
```
Docker Desktop is free for small businesses (fewer than 250 employees AND less than $10 million in annual revenue), personal use, education, and non-commercial open source projects.
Otherwise, it requires a paid subscription for professional use.
Paid subscriptions are also required for government entities.
Docker Pro, Team, and Business subscriptions include commercial use of Docker Desktop.
```

Select `Accept` to continue.

Note that Docker Desktop won't run if you do not agree to the terms. You can choose to accept the terms at a later date by opening Docker Desktop.

From the installation window, select either:
```
Use recommended settings (Requires password). This lets Docker Desktop automatically set the necessary configuration settings.
Use advanced settings. You can then set the location of the Docker CLI tools either in the system or user directory, enable the default Docker socket, and enable privileged port mapping. See Settings, for more information and how to set the location of the Docker CLI tools.
```

Select Finish. If you have applied any of the previous configurations that require a password in step 6, enter your password to confirm your choice.

### Install from the command line

After downloading `Docker.dmg` from either the download buttons at the top of the page or from the release notes, run the following commands in a terminal to install Docker Desktop in the Applications folder:
```
sudo hdiutil attach Docker.dmg

sudo /Volumes/Docker/Docker.app/Contents/MacOS/install

sudo hdiutil detach /Volumes/Docker
```

By default, Docker Desktop is installed at `/Applications/Docker.app`. As macOS typically performs security checks the first time an application is used, the install command can take several minutes to run.

The install command accepts the following flags:

`--accept-license`: Accepts the Docker Subscription Service Agreement now, rather than requiring it to be accepted when the application is first run.

`--allowed-org=<org name>`: Requires the user to sign in and be part of the specified Docker Hub organization when running the application

`--user=<username>`: Performs the privileged configurations once during installation. This removes the need for the user to grant root privileges on first run. For more information, see Privileged helper permission requirements. To find the username, enter ls /Users in the CLI.

`--admin-settings`: Automatically creates an admin-settings.json file which is used by administrators to control certain Docker Desktop settings on client machines within their organization. For more information, see Settings Management.
- It must be used together with the `--allowed-org=<org name>` flag.
- For example: `--allowed-org=<org name> --admin-settings="{'configurationFileVersion': 2, 'enhancedContainerIsolation': {'value': true, 'locked': false}}"`

`--proxy-http-mode=<mode>`: Sets the HTTP Proxy mode. The two modes are system (default) or manual.

`--override-proxy-http=<URL>`: Sets the URL of the HTTP proxy that must be used for outgoing HTTP requests. It requires `--proxy-http-mode` to be manual.

`--override-proxy-https=<URL>`: Sets the URL of the HTTP proxy that must be used for outgoing HTTPS requests, requires `--proxy-http-mode` to be manual.

`--override-proxy-exclude=<hosts/domains>`: Bypasses proxy settings for the hosts and domains. It's a comma-separated list.

## Install and run Docker Desktop on Linux
Refer to the [Docker website](https://docs.docker.com/desktop/setup/install/linux/) for Linux install

### Image Download
All custom images are currently hosted on Ethan McQuhae's Docker repo.

To download an image, run the following:
```
docker pull ethanmcq/<IMAGENAME>
```
From the Docker Dashboard, you should be able to see the downloaded container in the `Images` tab.

### Image build
If you want to build the images on your local computer you can follow this format below
```
cd <DOCKERFILE LOCATION>

# if on macOS platform=linux/arm64, if on linux platform=linux/amd64
docker build --platform=linux/amd64 -t <IMAGENAME> .

# You can then run the image with an interactive terminal
docker run -it <IMAGENAME>
```