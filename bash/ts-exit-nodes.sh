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
    echo "2) Connect to SoltrOS Server exit node (VPN)"
    echo "3) Connect to Ubuntu VPS Exit Node (Lansing/No VPN)"
    echo "4) Disconnect from Exit node entirely"
    echo "5) Show Tailscale online devices"
    echo "q) Quit"
    echo
    echo -e "${BLUE}================================${NC}"
    echo
    echo -n "Please select an option: "
}

# Validate IP address function
validate_ip() {
    if [[ $1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Execute command function
execute_command() {
    clear_screen
    echo -e "${GREEN}Executing command...${NC}"
    echo
    case $1 in
        1)
            echo -e "${BLUE}System Information:${NC}"
            curl ipinfo.io || echo -e "${RED}Error fetching IP information${NC}"
            ;;
        2)
            echo -e "${BLUE}SoltrOS Server Exit node:${NC}"
            ip="100.82.89.54"
            validate_ip "$ip" && sudo tailscale set --exit-node="$ip" --exit-node-allow-lan-access=true || echo -e "${RED}Invalid IP address${NC}"
            ;;
        3)
            echo -e "${BLUE}VPS exit node:${NC}"
            ip="100.125.225.77"
            validate_ip "$ip" && sudo tailscale set --exit-node="$ip" --exit-node-allow-lan-access=true || echo -e "${RED}Invalid IP address${NC}"
            ;;
        4)
            echo -e "${BLUE}Disconnect from Tailscale exit node:${NC}"
            sudo tailscale set --exit-node="" || echo -e "${RED}Error disconnecting from exit node${NC}"
            ;;
        5)
            echo -e "${BLUE}Show Tailscale online devices:${NC}"
            tailscale status | grep -v offline || echo -e "${RED}Error fetching online devices${NC}"
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

    if [[ $choice =~ ^[1-7]$ ]]; then
        execute_command "$choice"
    else
        echo -e "${RED}Invalid option. Press Enter to continue...${NC}"
        read -r
    fi
done
