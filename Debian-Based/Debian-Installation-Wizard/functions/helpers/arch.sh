#!/bin/bash

arch=$(dpkg --print-architecture)

is_native_x86_64()
{
    if [ -z $arch ]; then
        echo Unable to determine CPU architecture.
        exit
    
    elif [ $arch != "x86_64" ] && [ $arch != "amd64" ]; then
        return 1

    else 
        return 0

    fi
}