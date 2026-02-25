#!/bin/bash

# Please enter the server IP for the target machine you wish to migrate the VMs to.
TARGET_IP=""

if [ -z $TARGET_IP ]; then;
    echo "Please specify TARGET_IP in migrate.sh on line 4"
    return 1
fi

echo "This script requires sudo privileges."
echo "Please enter your password: "
sudo -v || { echo "Sudo elevation failed"; return 1; }

DIR=$(dirname $0)

# Checks if a file exists with -f then import it if so.
import_file() {
    [ -f "$DIR/$1" ] && . "$DIR/$1"
}

# Importing the required application functions.
import_file "functions.sh"


VM_NAMES=$(virsh list --all --name)

# Converting the names to an iterable
readarray -t <<<"$VM_NAMES"

MACHINE_COUNT=${#MAPFILE[@]} 

# Ensuring VMs are found.
if [ "$MACHINE_COUNT" == 0 ]; then
    echo "Unable to locate any QEMU VMs on the current system, please ensure libvirt is running"
    return 1
fi

# Displaying a list of found VMs.
printf "[INFO]: Located ${MACHINE_COUNT} VMs on the current machine.\n"
echo "--------------------------------------------------------------"
printf "\n"

for (( i=0; i < MACHINE_COUNT; i++ )); do
    adjusted_number=$((i++))
    printf "$i: ${MAPFILE[$adjusted_number]}\n"
    ((i--))
done
printf "\n"
echo "--------------------------------------------------------------"
printf "\n"

# Handle selection via an interactive menu.
migration_selection "${MAPFILE[@]}"

echo "Machine Name: $MIGRATION_SELECTION_NAME"
echo "Machine Index: $MIGRATION_SELECTION_INDEX"
echo "Menu Choice: $MENU_SELECTION_INDEX"

migrate_vm "$MIGRATION_SELECTION_NAME" "$TARGET_IP"