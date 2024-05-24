##################################################################################
#      AstroColony Dedicated Server Installation Verification script             #
##################################################################################
# Copyright (c) 2023-2024 Marquisian
# Author: Marquisian
# Helper: FuriosIra
# FuriosIra Discord link : https://discord.gg/paS5eYF
# Astro Colony Discord link : https://discord.com/invite/EFzAA3w



[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$false)] [String] $steamcmdLocation,
        [Parameter(Mandatory=$false)] [Switch] $Installsteamcmd,
        [Parameter(Mandatory=$false)] [Switch] $installPrereqs
	)


    $script:defaultServerName="$Env:USERNAME's Super Server"
    $script:defaultServerPassword=""
    $script:defaultServerQueryPort="27015"
    $script:defaultServerAdminList=""
    $script:defaultServerMaxPlayers="5"
    $script:defaultServerMapName="AstroColony game"
    $script:defaultServerSeed="7300"
    $script:defaultsteamCmdlocation="c:\steamcmd"
    $script:defaultServerlocation="c:\servers\astrocolony"
    
    
    If ([string]::isnullOrEmpty($steamcmdLocation))        
    {
        $steamcmdLocation = $defaultsteamcmdLocation
    }


#Let's create some functions as we need to call these commands multiple times
Function Install-SteamCmd
{

    # Check if folders exists:
    If (-not(test-path $steamcmdLocation))
    {
       mkdir $steamcmdLocation
    }

   
    $downloadPath = Join-Path -Path "$env:Userprofile\downloads" -ChildPath 'steamcmd.zip'
    $webClient = New-Object System.Net.WebClient
   
    try {
        $webClient.DownloadFile('https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip', "$downloadpath")    
    }
    catch {
        $exception = $_.Exception
        $base = $Exception.GetBaseException()
    }
    if ([string]::IsNullOrEmpty($exception))
    {
        Expand-Archive -Path "$env:userprofile\downloads\steamcmd.zip" -DestinationPath $steamcmdLocation -Force
    } else {
        write-host $base
    }

    # winget version:
    #$winget = (Get-command winget.exe).Path
    #Start-Process "$winget" -ArgumentList "Install Valve.SteamCMD --accept-source-agreements --disable-interactivity -l $steamcmdlocation" -NoNewWindow -Wait
}

Function Install-Prerequisites
{

    write-host "Checking Prerequisites"
    # Check if prereqs are installed:
    $list = @()
    $installed = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
	$subkeys = get-ChildItem -path $installed | select-object Name -ExpandProperty name
    foreach ($subkey in $subkeys)
    {
        $regkey = $subkey.replace("HKEY_LOCAL_MACHINE","HKLM:")
        $item = get-item -path $regkey 
        $list += $item.GetValue("Displayname")
    }
    $prereqs = "Microsoft Visual C++ 2022 X64 Minimum Runtime*","Microsoft Visual C++ 2022 X64 Additional Runtime*","Microsoft.DirectX" 
 
    foreach ($requirement in $prereqs)
    {
        $installed = $list | where-object {$_ -like $requirement}
        if ([string]::isnullOrEmpty($installed))
        {
            write-host "You are missing $requirement"
        }
    }

    Write-host "Installing Prerequisites just to make sure you have them all.."
    #Install prereqs:
    $commonredist = $defaultServerlocation + "\" + "_CommonRedist"
    write-host "Checking installation files in $commonredist"
    Start-Process -filepath "$commonredist\DirectX\Jun2010\DXSETUP.exe" -ArgumentList "/silent" -wait
    Start-Process -filepath "$commonredist\vcredist\2022\VC_redist.x86.exe" -ArgumentList " /q /norestart" -wait
    Start-Process -filepath "$commonredist\vcredist\2022\VC_redist.x64.exe" -ArgumentList " /q /norestart" -wait
    
   
}
#Let's handle the special commandline options first:
If ($installsteamcmd)
{
    Install-SteamCmd
}

if ($installprereqs)
{
    Install-Prerequisites
}

#Clear-Host
$title = "                 Astro Colony Dedicated Server Powershell Script`r`n`r`n" 
$question = 'Make your choice:'
$Choices = @(
[System.Management.Automation.Host.ChoiceDescription]::new("&Installation", "Install server and configure it")
[System.Management.Automation.Host.ChoiceDescription]::new("&Configuration", "(Re)Configure Server")
[System.Management.Automation.Host.ChoiceDescription]::new("&Backup", "Backup Configuration and Save games")
[System.Management.Automation.Host.ChoiceDescription]::new("&Update", "Update the Dedicated from Steam" )
[System.Management.Automation.Host.ChoiceDescription]::new("&Exit", "Exit the script")
)
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)

Switch ($decision)
{
    0  #Install
        {
            If (-not(test-path $defaultServerlocation))
            {
                mkdir $defaultServerlocation
            }

            $appcommand =  "$steamcmdLocation" + "\steamcmd.exe"            
            write-host "Starting $appcommand"
            $appArguments = "+force_install_dir $defaultServerLocation +login anonymous +app_update 2662210 validate +@sSteamCmdForcePlatformType windows +quit"
            write-host "With Arguments: $apparguments"
            $proc = Start-Process -filepath $appcommand -argumentlist $apparguments -PassThru -nonewwindow -Wait 
            $Exitcode = $proc.ExitCode
            Write-host "Exitcode was $($exitcode)"

            copy-item -path $defaultServerlocation -Filter *64.dll -Destination "$defaultServerLocation\AstroColony\Binaries\Win64\" -force

            Install-Prerequisites
        }
        
    1  #configure
    {
        write-host "How do you want to name your server ? default : $defaultServerName"
		$servername = read-host 
		if ([string]::IsNullOrEmpty($servername))
        {
        	$serverName=$defaultServerName
        }
        
		write-host "Your server name will be $serverName"
		write-host ""
		write-host ""
				
		write-host "Which password will be needed to connect ? Press enter for no password (security risk)"
		$serverPassword = read-host 
		if ([string]::IsNullOrEmpty($serverPassword))
        {
        	$serverPassword=$defaultServerPasword
        }
        write-host "Your server password will be $serverPassword"
		write-host ""
		write-host ""
		
		write-host "Which port will be used to connect ? default : $defaultServerqueryPort (recommended) must be within 1-65535"
		$serverqueryPort = read-host 
        if ([int]$serverqueryPort -ge 0 -and [int]$serverqueryPort -lt 65536)
        {
            write-host "Query port will be $serverqueryPort"
        }
        else {
            $serverqueryPort=$defaultServerQueryPort
        }	

				
		write-host "Your server Query port will be $serverQueryPort /udp - dont forget to open this port on your firewall/router"
		write-host ""
		write-host ""
		
		write-host "Add Admins to manage server once ingame (default : none)"
		write-host "This must be a list of steamid64 separated by commas : 76561198125852136,76561198262568532,76561198193923467"
		write-host "To get your steamid64, you may want to go on https://steamid.io"
		$serverAdminList = read-host 
        if ([string]::IsNullOrEmpty($serverAdminList))
        {
            $serverAdminList=$defaultServerAdminList
        }

			
		write-host "Registered Admins steamdid64 are $serverAdminList"
		write-host ""
		write-host ""
		
		write-host "How many players do you want maximum connected together on your server ? default : $defaultServerMaxPlayers"
		$serverMaxPlayers = Read-Host
        if ([string]::IsNullOrEmpty($serverMaxPlayers))
        {
            $serverMaxPlayers=$defaultserverMaxPlayers
        }
			
		write-host "There will be maximum $serverMaxPlayers players online on your server"
		write-host ""
		write-host ""
		
		
		write-host "How do you want to name map ? (it will show in Steam server list) default : $defaultServerMapName"
		$servermapname = read-host 
        if ([string]::IsNullOrEmpty($servermapname))
        {
            $servermapname=$defaultservermapname
        }
			
		write-host "$erverMapName will be displayed as this server's map name"
		write-host ""
		write-host ""
		
		write-host "What seed will be used for generation ? default : $defaultServerSeed. Must be only number or it will default to 113"
		$serverseed = read-host
        if ([string]::IsNullOrEmpty($serverseed))
        {
            $serverseed=$defaultserverseed
        }
		#astro colony seeds shinanigan, if the seed contain something else than number it will fallback to 113
        If ($serverseed)
        {
            # [^[:digit:] 
        }
			
		write-host "You entered a alphanumeric seed, unfortunately if the seed is not only number, it will be 113 whatever you try"
							
		write-host "Your default map's seed will be $serverSeed"
		write-host ""
		write-host ""
		
		#settings recap
		clear-host
        write-host
		write-host "Here are the settings you just defined :"
		write-host "Server display name : $serverName"
		write-host "Server access password : $serverPassword"
		write-host "Server Port used : $serverqueryPort/udp - dont forget to open it on your firewall/router even for lan game"
		write-host "Admin's steamid64 : $serverAdminList"
		
		write-host "Map name display in Steam : $serverMapName"
		write-host "Default world's seed : $serverSeed"
		write-host ""
		write-host "These settings will be editable later in the config files (check github and/or official discord server for help)"
		write-host "Is everything as you want it ? Press enter to continue"
		$installserver = read-host
		
        $serversettings = $defaultServerlocation + "\AstroColony\Saved\Config\WindowsServer\ServerSettings.ini"
       
		set-content -Value "[/Script/AstroColony.EHServerSubsystem]" -path $ServerSettings
		add-content -Value "ServerPassword=$serverPassword" -path $ServerSettings
		add-content -Value "MapName=$serverMapName" -path $ServerSettings
		add-content -Value "Seed=$serverSeed" -path $ServerSettings
		add-content -Value "MaxPlayers=$serverMaxPlayers" -path $ServerSettings
		#add-content -Value "ShouldLoadLatestSavegame=True" -path $ServerSettingsIniFile
		add-content -Value "AdminList=$serverAdminList" -path $ServerSettings
		add-content -Value "SharedTechnologies=True" -path $ServerSettings
		add-content -Value "OxygenConsumption=True" -path $ServerSettings
		add-content -Value "FreeConstruction=False" -path $ServerSettings
		add-content -Value "AutosaveInterval=5.0" -path $ServerSettings
		add-content -Value "AutosavesCount=10" -path $ServerSettings
		
		Set-Location $defaultServerlocation
		
		Set-Content"$defaultServerLocation\AstroColonyServer.exe -QueryPort=$serverqueryPort -SteamServerName=\"$serverName\" -log" -path StartACserver.cmd	 
    }
    2  #backup
    {

    }
    3  #Update
    {
        $appcommand =  "$steamcmdLocation" + "\steamcmd.exe"            
        write-host "Starting $appcommand"
        $appArguments = "+force_install_dir $defaultServerLocation +login anonymous +app_update 2662210 validate +@sSteamCmdForcePlatformType windows +quit"
        write-host "With Arguments: $apparguments"
        $proc = Start-Process -filepath $appcommand -argumentlist $apparguments -PassThru -nonewwindow -Wait 
        $Exitcode = $proc.ExitCode
        Write-host "Exitcode was $($exitcode)"
    }
    4  #Exit
    {
        Exit
    }
}
	
	