$password = Get-Content -Path ./password.txt
$sudo = "echo $password | sudo -S"
$apt = "$sudo apt-get update; $sudo apt-get full-upgrade -y; $sudo apt-get autoremove -y;"
$proxmox = "apt-get update; apt-get dist-upgrade -y; apt-get autoremove -y"

$proxmoxservers = @(
    "Mysterium",
    "EmiliaServer", 
    "RemServer", 
    "RamServer"
)

$aptonlyservers = @(
    "SparkBot",
    "Sonarr",
    "ArchiSteamFarm",
    "Bittorrent",
    "Plex",
    "Owncast",
    "Heimdall",
    "NadekoBot",
    "Gallery-DL",
    "PiHole",
    "HomeAssistant",
    "OwnCloud",
    "MineOS"
)

if ($args) {
    if ($args[0] = "-h"){
        $help = "
        -h: Show this help
        -p NAME: Update a specific Proxmox server
        -s NAME: Update a specific server
        "
        Write-Host $help
        exit
    }
    if ($args[0] = "-p") {
        ssh root@$($args[1]) "$proxmox"
        exit
    }
    if ($args[0] = "-s") {
        ssh $($args[1]) "$apt"
        exit
    }
}


Write-Host "Gallery-DL - Part 1" -ForegroundColor red
ssh gallery-dl "pip3 install --upgrade gallery-dl"

Write-Host "PiHole - Part 1" -ForegroundColor red
ssh pihole "$sudo pihole -up"

Write-Host "HomeAssistant - Part 1" -ForegroundColor red
ssh homeassistant "$sudo service home-assistant@homeassistant stop"
ssh homeassistant@homeassistant "source /srv/homeassistant/bin/activate; pip3 install --upgrade homeassistant"
ssh homeassistant "$sudo service home-assistant@homeassistant start"

foreach ($server in $aptonlyservers) {
    Write-Host $server -ForegroundColor red
    ssh $server "$apt"
}

foreach ($server in $proxmoxservers) {
    Write-Host $server -ForegroundColor red
    ssh root@$server "$proxmox"
}
