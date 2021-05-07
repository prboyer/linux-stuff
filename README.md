# linux-stuff
---
A collection of ~~my~~ linux scripts and files _forked from [codeman6100.](https://github.com/codeman6100/linux-stuff)_

## What's it do?
*Well, a lot of things, but only when it's told to*
* ****Updates Ubuntu****
  * Update app packages currently installed
* ****Removes Unnecessary Applications****
  * Firefox
  * Thunderbird
* ****Installs New Applications****
  * Microsoft Edge (Chromium)
  * Visual Studio Code
  * Remmina Remote Desktop
  * PowerShell Core (*Always Installed when Script is run*)
  * ZSH
  * Oh My Zsh!
  * GParted
  * Net Tools
  * OpenSSH Server
  * Microsoft Teams for Linux
* ****Configures the Shell****
  * Oh-my-ZSH
  * Adds provisions for WSL (Windows Subsystem for Linux)
  * Default Username
  * Theme Downloads
    * Setting the Theme
  * Font Downloads
    * If using GNOME shell, you'll need to set the font in terminal prefs after installation
## Download
1. Clone the Repo and set your working directory to `./linux-stuff`
2. Run `bash ./setup.sh` to begin the process
## Usage
### [setup.sh](setup.sh)
```shell
setup.sh [-w|--WSL] [-n|--no-applications] [-u|--username <string>] [-t|--theme <string>] [-p|--update]
```
#### Options
- `-w|--WSL`
    - Option indicates that the script is being run in a WSL environment. It will prevent applications from being installed (the same as -n), except for PowerShell Core.
- `-n|--no-applications`
    - Option prevents applications from being installed, except for PowerShell Core.
- `-u|--username`
    - The username that ZSH should be configured with. The setup script passes along this variable to [zshsetup.sh](zshsetup.sh)
- `-t|--theme`
    - The name of the theme that ZSH should be configured with. The setup script passes along this variable to [zshsetup.sh](zshsetup.sh)
- `-p|--update`
    - Instructs the script to run the Linux package manager and update installed applications and binaries.

### [zshsetup.sh](zshsetup.sh)
```shell
zshsetup.sh [-w|--WSL] [-u|--username <string>] [-t|--theme <string>]
```
#### Options
- `-w|--WSL`
  - Option indicates that the script is being run in a WSL environment. It will cause the ZSH setup script to export the proper DISPLAY variable to `~/.zshrc` for compatibility with WSL.
- `-u|--username`
  - The username that ZSH should be configured with.
- `-t|--theme`
  - The name of the theme that ZSH should be configured with.