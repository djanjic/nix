#!/usr/bin/env bash

set -euf

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ensureLink () {
    from=$1
    to=$2
    if [ "$from" -ef "$to" ]; then
        echo "$from is already the same as $to"
    else
        echo "Linking $from to $to"
        sudo mkdir -p "$(dirname "$to")"
        sudo rm -rf $to
        sudo ln -s $from $to
    fi
}

echo "*** Setting up channels ***"
sudo nix-channel --add https://nixos.org/channels/nixos-25.11 nixos
sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
sudo nix-channel --update
if ! command -v home-manager &> /dev/null; then
    echo "Installing home-manager..."
    nix-shell '<home-manager>' -A install
else
    echo "home-manager already installed"
fi

echo "*** Decoding machine ***"
nix profile add nixpkgs#dmidecode 2>/dev/null || true
sysver=$(sudo dmidecode -s system-product-name)
echo "HW: $sysver"
case $sysver in
    *"Laptop 13"*)
        echo "Framework 13"
        SYSTEM_DIR=framework
        HOME_MANAGER_DIR=${SCRIPT_DIR}/laptop/home-manager
        ;;
    *"Standard PC"*)
        echo "Development VM"
        SYSTEM_DIR=development
        HOME_MANAGER_DIR=${SCRIPT_DIR}/home-manager
        ;;
    *)
        echo "Unknown system: $sysver"
        exit 1
        ;;
esac

echo "*** Linking config ***"
ensureLink ${SCRIPT_DIR}/system/${SYSTEM_DIR} /etc/nixos
ensureLink ${SCRIPT_DIR}/system/common /etc/nixos-common
ensureLink ${HOME_MANAGER_DIR} /home/darko/.config/home-manager

echo "*** System rebuild ***"
sudo nixos-rebuild switch

echo "*** Home manager rebuild ***"
home-manager switch

echo "*** Deleting old generations ***"
sudo nix-env --delete-generations 30d

echo "*** Garbage collecting ***"
sudo nix-collect-garbage -d
echo "*** Done ***"
