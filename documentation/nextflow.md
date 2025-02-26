# Nextflow Installation

## Installation
This has been directly copied from Nextflow, [refer to their website for updates](https://www.nextflow.io/docs/latest/install.html)

`if you are using a Windows-based computer for BFX, please get a macOS or Linux based system instead'

Nextflow requires Bash 3.2 (or later) and Java 17 (or later, up to 23) to be installed. To see which version of Java you have, run the following command:

```
java -version
```

If you don’t have a compatible version of Java installed, it is recommended that you install it through [SDKMAN!](https://sdkman.io/). 

```
 curl -s https://get.sdkman.io | bash
```

Open a new terminal/refresh terminal.

### Install Java:

```
sdk install java 17.0.10-tem
```

Confirm that Java is installed correctly:

```
java -version
```

### Install Nextflow:

Nextflow is distributed as a self-installing package, in order to make the installation process as simple as possible:

```
curl -s https://get.nextflow.io | bash
```

Make Nextflow executable:

```
chmod +x nextflow
```

Move Nextflow into an executable path. For example:

```
mkdir -p $HOME/.local/bin/
mv nextflow $HOME/.local/bin/
```

> **Tip:**
> Ensure the directory $HOME/.local/bin/ is included in your PATH variable. Temporarily add this directory to PATH by setting export PATH="$PATH:$HOME/.local/bin". Add the directory to PATH permanently by adding the export command to your shell configuration file, such as ~/.bashrc or ~/.zshrc. Alternatively, move the nextflow executable to a directory already in your PATH.

Nextflow will update its executable during the self update process, therefore the update can fail if the executable is placed in a directory with restricted permissions.

Confirm that Nextflow is installed correctly:

```
nextflow info
```
