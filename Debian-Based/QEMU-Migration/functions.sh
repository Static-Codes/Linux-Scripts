#!/bin/bash

confirm() {
    CONTINUING="y"
    
    # If no confirmation message is provided, a default one is used.
    if [ -z "$1" ]; then
        echo "Would you like to continue: [y/n]: "
        read CONTINUING
    
    else
        echo "$1"
        read CONTINUING
    fi

    # If the previous conditional is not executed, this conditional is skipped.
    if [ $CONTINUING != "y" ]; then
        echo "Execution ended by user..."
        exit
    fi
    
    return 0
}

# "$@"" is the array of VM names
MIGRATION_SELECTION_NAME="Not Selected"
MENU_SELECTION_INDEX="Not Selected"
MIGRATION_SELECTION_INDEX="Not Selected"

migration_selection() {
    local MACHINES_FOUND=("$@")
    
    MACHINE_COUNT=${#MACHINES_FOUND[@]}
    
    # Defining the menu options
    MENU_OPTIONS=( "${MACHINES_FOUND[@]}" "( "Migrate All" "Cancel" )" )
    
    OPTIONS_COUNT=${#MENU_OPTIONS[@]}

    PS3=$'\e[34mChoose which machine to migrate \e[0;33m(1 - '$OPTIONS_COUNT$'): \e[0m'

    # "select" automatically creates a numbered menu from the array
    # We add "Cancel" to the end for safety
    select MACHINE_NAME in "${MACHINES_FOUND[@]}" "Migrate All" "Cancel"; do
        if [[ -n "$MACHINE_NAME" && "$MACHINE_NAME" != "Migrate All" && "$MACHINE_NAME" != "Cancel" ]]; then
            echo -e "\nSelected: \e[32m$MACHINE_NAME\e[0m"
            MIGRATION_SELECTION_NAME=$MACHINE_NAME
            MIGRATION_SELECTION_INDEX=$((REPLY - 1))
            MENU_SELECTION_INDEX="$REPLY"
            break 
        elif [[ "$MACHINE_NAME" == "Migrate All" ]]; then
            echo -e "\e[0;33mYou are about to migrate $MACHINE_COUNT machines.\e[0m"
            confirm
            break
        elif [[ "$MACHINE_NAME" == "Cancel" ]]; then
            echo -e "\e[0;31mOperation aborted.\e[0m"

            break
        else
            echo -e "\e[1;31mInvalid selection.\e[0m"
            echo -e "Please enter a number between 1 and (($MACHINE_COUNT + 1)).\n"
            echo -e "\e[1;35mChoice: \e[Om"
        fi
    done
}

migrate_vm() {
    LIBVIRT_IMAGE_DIR="/var/lib/libvirt/images"
    VM_NAME="$1"
    TARGET_IP="$2"
    
    NETWORK_PATH="root@$TARGET_IP"
    MIGRATION_DIR="$HOME/MIGRATION/$VM_NAME"
    
    XML_FILENAME="$VM_NAME.xml"
    XML_MIGRATION_PATH="$MIGRATION_DIR/$XML_FILENAME"

    if [ ! -d "$MIGRATION_DIR" ]; then
        mkdir -p "$MIGRATION_DIR"
    fi

    echo "Dumping $VM_NAME to $XML_FILENAME, you will be prompted for your password below."
    sudo virsh dumpxml "$VM_NAME" > "$XML_MIGRATION_PATH" || { echo "Failed to dump $XML_MIGRATION_PATH, please try again"; return 1; }
    echo "Dumped $XML_FILENAME to $MIGRATION_DIR, continuing.."
    
    STORAGE_FILENAME=$VM_NAME
    VM_STORAGE_FILE="$LIBVIRT_IMAGE_DIR/$STORAGE_FILENAME.qcow2"

    if [ ! -e "$VM_STORAGE_FILE" ]; then
        echo "Unable to locate storage file at: '$VM_STORAGE_FILE'";
        echo "You will be prompted for the path to storage file associated with the VM '$VM_NAME'"
        echo "Note: This file is almost certainly located in '$LIBVIRT_IMAGE_DIR'"
        read -p "Path to storage file: " STORAGE_FILENAME

        if [ ! -e "$STORAGE_FILENAME" ]; then
            echo "Failed to locate a file at the path specified, please check your input and try again."
            return 1;
        fi

        VM_STORAGE_FILE=$STORAGE_FILENAME
    fi



    DESTINATION_DIR="$NETWORK_PATH:$LIBVIRT_IMAGE_DIR"

    echo "Ensuring rsync is installed on the target machine '$NETWORK_PATH'"
    ssh $NETWORK_PATH "apt install rsync -y" || { echo "Check failed, on the target machine please run: apt install rsync openssh-server -y"; return 1; }
    echo "rsync is installed, continuing..."

    echo -e "Transferring the storage file for machine name: '$VM_NAME'...\n"
    echo -e "Source File: $VM_STORAGE_FILE\n"
    echo -e "Destination Dir: $DESTINATION_DIR\n"
    sudo rsync -avP "$VM_STORAGE_FILE" "$DESTINATION_DIR" || { echo "Transfer failed, please try again."; return 1; }
    echo "Storage transfer complete!"

    REMOTE_TMP_PATH="/tmp/$XML_FILENAME"
    echo "Transferring the xml dump for machine '$VM_NAME' to target at $REMOTE_TMP_PATH"
    
    scp "$XML_MIGRATION_PATH" "$NETWORK_PATH:/tmp/" || { echo "Failed to transfer XML, please try again."; return 1; }
    echo "Transfer complete!"

    echo "Fixing file ownership on target machine..."
    ssh $NETWORK_PATH "chown libvirt-qemu:libvirt-qemu $LIBVIRT_IMAGE_DIR/$VM_NAME.qcow2"

    echo "Defining $VM_NAME on target machine, please wait.."
    ssh $NETWORK_PATH "virsh define $REMOTE_TMP_PATH"
    echo "Successfully migrated $VM_NAME to target!"

    # Killing the keep alive loop for sudo, now that execution has completed.
    kill $! 2>/dev/null
}