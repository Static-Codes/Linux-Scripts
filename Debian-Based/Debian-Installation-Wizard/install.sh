#!/bin/bash


DIR=$(dirname $0)

# Checks if a file exists with -f then import it if so.
import_file() {
    [ -f "$DIR/$1" ] && . "$DIR/$1"
}

# Import all .sh scripts from /functions and /functions/helpers
import_functions(){
    for script in functions/installations/*.sh; do
        . "$script"
    done

    for script in functions/helpers/*.sh; do
        . "$script"
    done
}


import_file "config.sh"
import_functions


if ! is_native_x86_64; then
    echo "This script is designed for machines with the following requirements:\n"
    echo "- An x86-64 CPU"
    echo "- A Debian-based Linux Distro\n"
fi


# If librewolf isn't selected and the user selected to uninstall firefox.
if [ $LIBREWOLF -eq 0 ] && [ $NO_FIREFOX -eq 1 ]; then
    
    echo "[INFO] You've selected to uninstall firefox but didn't select to install librewolf."
    
    # Imported from functions/helpers/confirmation.sh
    confirm 
    
    # Imported from functions/installations/no-firefox.sh
    uninstall_firefox

# If the user wants to install Librewolf.
elif [ $LIBREWOLF -eq 1 ]; then
    echo "[INFO] Installing Librewolf, please wait."
    install_librewolf

# If the user wants to uninstall Firefox.
elif [ $NO_FIREFOX -eq 1 ]; then
    echo "[INFO] Uninstalling Firefox, please wait."
    uninstall_firefox

fi



# Checks QEMU status
if [ $QEMU_X86 -eq 1 ] && [ $QEMU_ARM -eq 1 ]; then
    echo "[INFO] You've selected both the x86-64 native and ARM emulation packages of QEMU."
    echo "[INFO] The QEMU ARM Package installs all the requirements for the x86-64 package."
    install_qemu_arm
    
elif [ $QEMU_X86 -eq 1 ]; then install_qemu_x86
    
elif [ $QEMU_ARM -eq 1 ]; then install_qemu_arm
    
fi


# Checks Codium status
if [ $CODIUM -eq 1 ]; then 
    install_codium 
fi