#!/bin/bash
b="\x1b[34m"
y="\x1b[33m"
g="\x1b[32m"
w="\x1b[37m"
a="\x1b[30;1m"
r="\x1b[31m"
reset="\x1b[0m"
CHECK=" ${b}●${w} Checking the current installation.${reset}"
ATTACH=" ${b}●${w} Attaching the shell.${reset}"
CHECK_DONE=" \033[1A\033[K${g}●${w} Checking the current installation.${reset}"
ATTACH_DONE=" \033[1A\033[K${g}●${w} Attaching the shell.${reset}"
cd /home/container || exit 1
if [ -f ".lumenrc" ]; then
    source ".lumenrc"
fi
echo "Starting MilanVM"
clear
echo -e "${BANNER}"
echo -e "${CHECK}"
sleep 1
echo -e "${CHECK_DONE}"
echo -e "${ATTACH}"
sleep 1
echo -e "${ATTACH_DONE}"
PS1='\[\e[0m\]\[\e[37;1m\]\n> \[\e[0m\]'
while true; do
  read -p "Compix@MilanVM:~$(pwd)# "$'\n' command
  case "$command" in
    "exit")
      break
      ;;
    *)
      eval "$command"
      ;;
  esac
done
