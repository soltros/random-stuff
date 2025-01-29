#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Clear screen function
clear_screen() {
    clear
}

# Draw menu function
draw_menu() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${GREEN}        System Commands${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
    echo "1) Show IP information"
    echo "2) Connect to NixOS Server exit node"
    echo "3) Connect to RPi4 Server exit node (VPN)"
    echo "4) Connect to NixOS Data Server exit node"
    echo "5) Disconnect from Exit node entirely"
    echo "6) Route all traffic through the node"
    echo "7) Show Tailscale online devices"
    echo "q) Quit"
    echo
    echo -e "${BLUE}================================${NC}"
    echo
    echo -n "Please select an option: "
}

# Execute command function
execute_command() {
    clear_screen
    echo -e "${GREEN}Executing command...${NC}"
    echo
    case $1 in
        1)
            echo -e "${BLUE}System Information:${NC}"
            curl ipinfo.io
            ;;
        2)
            echo -e "${BLUE}NixOS Exit node:${NC}"
            sudo tailscale set --exit-node=nixos-server
            ;;
        3)
            echo -e "${BLUE}RPi Server exit node (VPN):${NC}"
            sudo tailscale set --exit-node=pi4-nixos-server
            ;;
        4)
            echo -e "${BLUE}NixOS Data Server Exit node:${NC}"
            sudo tailscale set --exit-node="nixos-data-server"
            ;;
        5)
            echo -e "${BLUE}Disconnect from Tailscale exit node:${NC}"
            sudo tailscale set --exit-node=""
            ;;
        6)
            echo -e "${BLUE}Route all traffic through the node:${NC}"
            sudo tailscale set --exit-node-allow-lan-access=true
            ;;
        7)
            echo -e "${BLUE}Show Tailscale online devices:${NC}"
            tailscale status | grep -v offline
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
    echo
    echo -e "${GREEN}Press Enter to continue...${NC}"
    read -r
}

# Main loop
while true; do
    clear_screen
    draw_menu
    read -r choice
    
    if [[ $choice == "q" ]]; then
        clear_screen
        echo -e "${GREEN}Goodbye!${NC}"
        exit 0
    fi
    
    if [[ $choice =~ ^[1-6]$ ]]; then
        execute_command "$choice"
    else
        echo -e "${RED}Invalid option. Press Enter to continue...${NC}"
        read -r
    fi
done
