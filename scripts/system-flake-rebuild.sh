#!/usr/bin/env bash

if [ ! -z $1 ]; then
	export HOST=$1
else
	export HOST=$(hostname)
fi

nix run home-manager/release-24.05 switch
# nixos-rebuild --impure --flake .#$HOST switch
