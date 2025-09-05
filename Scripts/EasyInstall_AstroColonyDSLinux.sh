#!/bin/sh

# Copyright (c) 2023-2024 FuriosIra
# Author: FuriosIra
# Helper: Kinton_Hiryuu
# https://github.com/FuriosIra/AstroColonyServerScript
# My Discord link : https://discord.gg/paS5eYF
# Astro Colony Discord link : https://discord.com/invite/EFzAA3w

export NEWT_COLORS='root=,black
border=green,black
title=green,black
roottext=red,black
window=red,black
textbox=white,black
button=black,green
compactbutton=white,black
listbox=white,black
actlistbox=black,white
actsellistbox=black,green
checkbox=green,black
actcheckbox=black,green
'

defaultServerName=`whoami`"'s Super Server"
defaultServerPassword=""
defaultServerPort="27015"
defaultServerAdminList=""
defaultServerMaxPlayers="5"
defaultServerSavegameName="AstroColony save"
defaultServerMapName="AstroColony game"
defaultServerSeed="7300"

MENU=$(
whiptail --title "Script for Astro Colony server" --menu "Choose something" 15 56 8 \
	"Install"	"Server installation." \
	"Config"	"Create start file and server settings." \
	"Backup"	"Backup configs and saves." \
	"Update"	"Update server." \
	"Exit"		"Leave the script." 3>&2 2>&1 1>&3
)

result=$(whoami)
case $MENU in
	"Install")
		#Check if the prerequisites are present if not download them
		if [ -e "steamcmd" ] && [ -e "steamcmd/steamcmd.sh" ]
			then
				cd ~/steamcmd
				# Downloading server files
				./steamcmd.sh +force_install_dir ../serverfiles +login anonymous +app_update 2934900 validate +quit
				# Downloading dependances
				./steamcmd.sh +force_install_dir ../libsteam +login anonymous +app_update 1007 validate +quit
				# Copying dependencies to the binary folder
				cp ~/libsteam/linux64/steamclient.so ~/serverfiles/AstroColony/Binaries/Linux/steamclient.so && cd ~/
			else
				# Downloading SteamCMD
				mkdir -p ~/steamcmd && cd ~/steamcmd
				wget http://media.steampowered.com/client/steamcmd_linux.tar.gz && tar -xvzf steamcmd_linux.tar.gz
				# Downloading server files
				./steamcmd.sh +force_install_dir ../serverfiles +login anonymous +app_update 2934900 validate +quit
				# Downloading dependances
				./steamcmd.sh +force_install_dir ../libsteam +login anonymous +app_update 1007 validate +quit
				# Copying dependencies to the binary folder
				cp ~/libsteam/linux64/steamclient.so ~/serverfiles/AstroColony/Binaries/Linux/steamclient.so && cd ~/
		fi
	;;
	"Config")
		echo "How do you want to name your server ? default : ${defaultServerName}"
		read serverName
		if [ -z $serverName ]
			then 
				serverName=$defaultServerName
		fi
		echo "Your server name will be ${serverName}"
		echo ""
		echo ""
				
		echo "Which password will be needed to connect ? Press enter for no password (security risk)"
		read serverPassword
			if [ -z $serverPassword ]
				then 
				serverPassword=$defaultServerPassword
			fi
		echo "Your server password will be ${serverPassword}"
		echo ""
		echo ""
		
		echo "Which port will be used to connect ? default : ${defaultServerPort} (recommended) must be within 1-65535"
		read serverPort
			if [ -z $serverPort ] && [ $serverPort -ge 0 ] && [ 65536 -ge $serverPort  ]
				then 
				serverPort=$defaultServerPort
			fi
		echo "Your server port will be ${serverPort}/udp - dont forget to open this port on your firewall/router"
		echo ""
		echo ""
		
		echo "Add Admins to manage server once ingame (default : none)"
		echo "This must be a list of steamid64 separated by commas : 76561198125852136,76561198262568532,76561198193923467"
		echo "To get your steamid64, you may want to go on https://steamid.io"
		read serverAdminList
			if [ -z $serverAdminList ]
				then 
					serverAdminList=$defaultServerAdminList
			fi
		echo "Registered Admins steamdid64 are ${serverAdminList}"
		echo ""
		echo ""
		
		echo "How many players do you want maximum connected together on your server ? default : ${defaultServerMaxPlayers}"
		read serverMaxPlayers
			if [ -z $serverMaxPlayers ]
				then 
				serverMaxPlayers=$defaultServerMaxPlayers
			fi
		echo "There will be maximum ${serverMaxPlayers} players online on your server"
		echo ""
		echo ""
		
		echo "SavegameName setting skipped. Feel free to uncomment when this is working"
		#echo "How do you want to name your save file ? default : ${defaultServerSavegameName}"
		#read serverSavegameName
		#if [ -z $serverSavegameName ]
		#then 
			serverSavegameName=$defaultServerSavegameName
		#fi
		#echo "Your local savefile will be named ${serverSavegameName}"
		echo ""
		echo ""
		
		echo "How do you want to name map ? (it will show in Steam server list) default : ${defaultServerMapName}"
		read serverMapName
			if [ -z $serverMapName ]
				then 
				serverMapName=$defaultServerMapName
			fi
		echo "${serverMapName} will be displayed as this server's map name"
		echo ""
		echo ""
		
		echo "What seed will be used for generation ? default : ${defaultServerSeed}. Must be only number or it will default to 113"
		read serverSeed
			if [ -z $serverSeed ]
				then 
				serverSeed=$defaultServerSeed
		#astro colony seeds shinanigan, if the seed contain something else than number it will fallback to 113
			elif [ serverSeed =~ [^[:digit:]  ]; then
		echo "You entered a alphanumeric seed, unfortunately if the seed is not only number, it will be 113 whatever you try"
				serverSeed=113
			fi
		echo "Your default map's seed will be ${serverSeed}"
		echo ""
		echo ""
		
		#settings recap
		clear
		echo "Here are the settings you just defined :"
		echo "Server display name : ${serverName}"
		echo "Server access password : ${serverPassword}"
		echo "Server Port used : ${serverPort}/udp - dont forget to open it on your firewall/router even for lan game"
		echo "Admin's steamid64 : ${serverAdminList}"
		#echo "Save Game Name : ${serverSavegameName}"
		echo "Map name display in Steam : ${serverMapName}"
		echo "Default world's seed : ${serverSeed}"
		echo ""
		echo "These settings will be editable later in the config files (check github and/or official discord server for help)"
		echo "Is everything as you want it ? Press enter to continue"
		read installServer
		
		mkdir -p ~/serverfiles/AstroColony/Saved/Config/LinuxServer && cd ~/serverfiles/AstroColony/Saved/Config/LinuxServer
		echo "[/Script/ACFeature.EHServerSubsystem]" >> ServerSettings.ini
		echo "ServerPassword=${serverPassword}" >> ServerSettings.ini
		echo "MapName=${serverMapName}" >> ServerSettings.ini
		echo "Seed=${serverSeed}" >> ServerSettings.ini
		echo "MaxPlayers=${serverMaxPlayers}" >> ServerSettings.ini
		echo "SavegameName=${serverSavegameName}" >> ServerSettings.ini
		echo "ShouldLoadLatestSavegame=True" >> ServerSettings.ini
		echo "AdminList=${serverAdminList}" >> ServerSettings.ini
		echo "SharedTechnologies=True" >> ServerSettings.ini
		echo "OxygenConsumption=True" >> ServerSettings.ini
		echo "FreeConstruction=False" >> ServerSettings.ini
		echo "Sandbox=True" >> ServerSettings.ini
		echo "AutosaveInterval=5.0" >> ServerSettings.ini
		echo "AutosavesCount=10" >> ServerSettings.ini
		
		cd ~/serverfiles
		echo '#!/bin/sh' >> StartACserver.sh
		echo "./AstroColonyServer.sh -QueryPort=${serverPort} -SteamServerName=\"${serverName}\" -log" >> StartACserver.sh
		chmod +x StartACserver.sh
	;;
	"Backup")
		#Create the Backup and Temp folder
		mkdir -p ~/backups/temps/AstroColony/Saved/Config/LinuxServer && mkdir -p ~/backups/temps/AstroColony/Saved/SaveGames/DedicatedServer
		#Checks if files are present and copies in temporary folder
		if [ -e "serverfiles/StartACserver.sh" ] && [ -e "serverfiles/AstroColony/Saved/Config/LinuxServer/ServerSettings.ini" ] && [ -e "serverfiles/AstroColony/Saved/SaveGames/DedicatedServer/" ]
			then
				cp -r ~/serverfiles/StartACserver.sh ~/backups/temps/
				cp -r ~/serverfiles/AstroColony/Saved/Config/LinuxServer/ServerSettings.ini ~/backups/temps/AstroColony/Saved/Config/LinuxServer
				cp -r ~/serverfiles/AstroColony/Saved/SaveGames/DedicatedServer/*.sav ~/backups/temps/AstroColony/Saved/SaveGames/DedicatedServer
				cd ~/backups/temps/ && tar -pczf ~/backups/Backup.$(date '+%F').tar.gz .
				echo "File creation successful"
			else
				echo "Absence of one of the conditions for continuing the backup procedure."
		fi
	;;
	"Update")	
		#Check if the prerequisites are present if not stop update with message
		if [ -e "steamcmd" ] && [ -e "steamcmd/steamcmd.sh" ] && [ -e "libsteam" ] && [ -e "serverfiles" ]
			then
				cd ~/steamcmd
				# Downloading server files
				./steamcmd.sh +force_install_dir ../serverfiles +login anonymous +app_update 2934900 validate +quit
				# Downloading dependances
				./steamcmd.sh +force_install_dir ../libsteam +login anonymous +app_update 1007 validate +quit
				# Copying dependencies to the binary folder
				cp ~/libsteam/linux64/steamclient.so ~/serverfiles/AstroColony/Binaries/Linux/steamclient.so && cd ~/
			else
				echo ""
				echo ""
				echo "An error has been detected and the update cannot continue."
				echo "Make sure the steamcmd, libsteam and serverfiles folders exist in the profile root."
				echo "If not, restart the script and perform a new installation."
				echo ""
				echo ""
		fi
    ;;
	"Exit") 	exit
    ;;
esac
