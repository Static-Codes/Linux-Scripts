#!/bin/bash

# https://librewolf.net/installation/debian/#main-debian-repository
install_librewolf() {
	echo "[INFO] Librewolf installation started."

	sudo apt update && sudo apt install extrepo -y

	sudo extrepo enable librewolf

	sudo apt update && sudo apt install librewolf -y

	echo "[INFO] Librewolf installed."
}