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