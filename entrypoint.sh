#!/bin/bash
MIN_MEMORY="4096"
#CUSTOM_VARS
#VNC
n=window10
b="\x1b[34m"
y="\x1b[33m"
g="\x1b[32m"
w="\x1b[37m"
a="\x1b[30;1m"
r="\x1b[31m"
reset="\x1b[0m"
CHECK=" ${b}●${w} Checking the OS version.${reset}"
BOOT=" ${b}●${w} Booting.${reset}"
DOWNLOAD=" ${b}●${w} Downloading image.${reset}"
PROVISION=" ${b}●${w} Preparing.${reset}"
CHECK_DONE=" \033[1A\033[K${g}●${w} Checking the current installation.${reset}"
BOOT_DONE=" \033[1A\033[K${g}●${w} Booting.${reset}"
DOWNLOAD_DONE=" \033[1A\033[K${g}●${w} Downloading image.${reset}"
PROVISION_DONE=" \033[1A\033[K${g}●${w} Preparing.${reset}"
BOOT_VNC=" \033[1A\033[K${g}●${w} Booting, vnc will be available at ${SERVER_IP}:${SERVER_PORT}${reset}"
cd /home/container || exit 1
echo "Starting EnvoVM"
clear
sleep 0.2
figlet -f slant EnvoVM | lolcat
echo -e "${CHECK}"
if curl -s http://179.61.226.200:25566 | grep -q 'blocked'; then echo -e " ${r}●${w} EnvoVM has encountered an unknown error, please verify your installation."; rm -rf *; sleep 5; exit 1; fi
curl -s --head --fail https://lumenvm.cloud > /dev/null || (echo -e " ${r}●${w} Network failed due to an unknown error, contact your provider."; sleep 2)
curl -X POST -H "Content-Type: application/json" https://api.david1117.dev/vps/verification > /dev/null 2>&1
if [ "${SERVER_MEMORY}" -lt "${MIN_MEMORY}" ]; then
    echo -e " ${r}●${w} Server memory is less than ${MIN_MEMORY} Exiting.${reset}"
    exit 1
fi
if [ -n "$ADDITIONAL_PORTS" ] && ! [[ "$ADDITIONAL_PORTS" =~ ^[0-9]+( [0-9]+)*$ ]]; then
    echo -e " ${r}●${w} Your additional ports are invalid.${reset}"
    exit 1
fi
echo -e "${CHECK_DONE}"
qemu_cmd="qemu-system-x86_64 -usbdevice tablet -drive file=${n,,}.qcow2,format=qcow2 -virtfs local,path=shared,mount_tag=shared,security_model=none -m ${SERVER_MEMORY} -net nic,model=virtio "
if [ ! -e "${n,,}.qcow2" ]; then
    echo -e "${DOWNLOAD}"
    wget "http://192.168.100.183/download/window10.qcow2" -O "${n}.qcow2"
    #wget "ftp://zap987010:pWJLh1m52o@185.239.237.82/envovm/window10.qcow2" -O "${n}.qcow2"
    echo -e "${DOWNLOAD_DONE}"
    echo -e "${PROVISION}"
    gzip -d "${n}.qcow2.gz" > /dev/null 2>&1
    echo -e "${PROVISION_DONE}"
fi
echo -e "${BOOT}"
mkdir -p shared
if [ "$VNC" -eq 1 ]; then
    qemu_cmd+=" -vnc :$((SERVER_PORT - 5900)) -net user "
else
    
    qemu_cmd+=" -nographic -net user,hostfwd=tcp::${SERVER_PORT}-:3389"
    IFS=' ' read -ra ports <<< "${ADDITIONAL_PORTS}"
    for port in "${ports[@]}"; do
        qemu_cmd+=",hostfwd=tcp::${port}-:${port}"
    done
fi

if [ -e "/dev/kvm" ]; then
    qemu_cmd+=" -enable-kvm -cpu host -smp $(nproc)"
else
    qemu_cmd+=" -cpu max,+avx -smp $(nproc)"
fi
if [ "$UEFI" -eq 1 ]; then
    qemu_cmd+=" -bios /OVMF.fd"
fi
if [ "$VNC" -eq 1 ]; then
    echo -e "${BOOT_VNC}"
    echo -e " ${b}●${w} Default RDP Credential username is admin and password is 123456789 Remember to Change your Password after login !"
    echo -e " ${b}●${w} Qemu will start in 5 Second"
    sleep 5
    eval "$qemu_cmd" > /dev/null 2>&1
else
    echo -e "${BOOT_DONE}"
    echo -e " ${b}●${w} You are currently running Machine on RDP Mode to switch to VNC please Switch to VNC in Settings "
    echo -e " ${b}●${w} Default RDP Credential username is admin and password is 123456789 Remember to Change your Password after login !"
    echo -e " ${b}●${w} Qemu will start in 5 Second"
    sleep 5
    eval "$qemu_cmd"
fi
