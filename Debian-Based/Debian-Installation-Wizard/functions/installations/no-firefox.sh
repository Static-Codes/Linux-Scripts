#!/bin/bash

uninstall_firefox() {
    echo "[Info] Removing firefox.."

    sudo apt-get purge firefox

    sudo rm -rf /etc/firefox

    sudo rm -rf /usr/lib/firefox

    sudo rm -rf /usr/lib/firefox-addons
}