#!/usr/bin/env zsh
green='\e[32m'
red='\e[31m'
blue='\e[34m'
reset='\e[0m'

echo -e "${blue}--- System Check ---${reset}"
[[ "$ZDOTDIR" == "$HOME/.config/zsh" ]] && echo -e "XDG: ${green}PASS${reset}" || echo -e "XDG: ${red}FAIL${reset}"
systemctl is-active --quiet snapper-timeline.timer && echo -e "Snapper: ${green}ACTIVE${reset}" || echo -e "Snapper: ${red}INACTIVE${reset}"
systemctl is-active --quiet grub-btrfsd.service && echo -e "Grub-Btrfs: ${green}ACTIVE${reset}" || echo -e "Grub-Btrfs: ${red}INACTIVE${reset}"
echo -n "Admin Tools: "
command -v nmap &>/dev/null && echo -e "${green}OK${reset}" || echo -e "${red}FAIL${reset}"
echo -n "VConsole Font: "
grep -q "ter-v16b" /etc/vconsole.conf && echo -e "${green}OK${reset}" || echo -e "${red}FAIL${reset}"
