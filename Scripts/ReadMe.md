# Operating systems compatibility  
## Linux :penguin:  
The quick installation script for Linux systems has been tested on the following systems :  
- [x] Debian 12  
- [x] Ubuntu 22.04/23.04/23.10  
  
## Setup procedure for Linux  
### Prerequisites
To ensure that the script and the Steam library run smoothly, the following packages must be installed with the `Root` user.  
- Debian/Ubuntu `apt install screen tar unzip lib32gcc-s1 -y`  
Next, create a dedicated user, for example `steam` with `adduser steam`, following the classic procedure (if you're a Linux user, you'll know how).  
### Installation  
Log in with the user account `steam` with the command `su - steam`.  
Download the easy installation file with the command `wget https://raw.githubusercontent.com/FuriosIra/AstroColony/main/Scripts/EasyInstall_AstroColonyDSLinux.sh && chmod +x EasyInstall_AstroColonyDSLinux.sh`.  
Finally, run the script `./EasyInstall_AstroColonyDSLinux.sh`, which will bring up a selection menu described below.  
- `Install` To be selected first, the process will download and decompress `SteamCMD`, then use `SteamCMD` to download the Astro Colony dedicated server and `Steam` libraries.  
- `Config` Choose the second one, and the process will ask you to answer several questions to set up the `ServerSettings.ini` file and create a `StartACserver.sh` file.  
- `Backup` \(Optional) Allows you to make a backup of the `ServerSettings.ini` and `StartACserver.sh` files, as well as manual and automatic backups of the dedicated server, in the `~/backups` folder.  
- `Update` Allows you to quickly update your dedicated server and Steam libraries.  
- `Exit` As its name implies, exits the script.  
### Utilisation
Log in with the user account `steam` with the command `su - steam`.  
Run the script, either with `./serverfiles/StartACserver.sh` or `cd serverfiles/` and `./StartACserver.sh`.  
You can also use `screen` to create a detachable shell with `screen -S AstroDS` from the `Root` user and do the above process.  
To exit the `screen` window without closing the process, hold down CTRL and press the A and D keys alternately, the message `[detached from xxxx.AstroDS]` (here xxxx is just to indicate random numbers).  
## Setup procedure for Windows 
Currently being written. 
  
# To-do list
- [x] :memo: Writing of a user guide for Linux systems.   
- [ ] :toolbox: Added verification that the linux script is executed outside the Root account.  
- [ ] :hammer_and_wrench: Code enhancement.  
- [ ] \(Optional) Creation of a PowerShell GUI script to facilitate installation under Windows.