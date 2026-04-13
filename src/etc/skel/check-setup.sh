#!/usr/bin/env zsh
# Validation script to ensure XDG and Services are correct
green='\e[32m'
red='\e[31m'
reset='\e[0m'

echo "--- System Audit ---"
[[ "$ZDOTDIR" == "$HOME/.config/zsh" ]] && echo -e "XDG Zsh: ${green}PASS${reset}" || echo -e "XDG Zsh: ${red}FAIL${reset}"
[[ -n "$CARGO_HOME" ]] && echo -e "XDG Rust: ${green}PASS${reset}" || echo -e "XDG Rust: ${red}FAIL${reset}"
systemctl is-active --quiet NetworkManager && echo -e "Network: ${green}UP${reset}" || echo -e "Network: ${red}DOWN${reset}"
