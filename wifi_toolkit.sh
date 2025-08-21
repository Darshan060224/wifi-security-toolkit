#!/bin/bash

# Advanced Wi-Fi Security Testing Tool
# Enhanced version with modern security features

# Color codes for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Global variables
wifi_interface="wlan0"
monitor_interface=""
target_networks=()
handshake_dir="handshakes"
wordlist_dir="wordlists"

# Banner
display_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              Advanced Wi-Fi Security Testing Tool             ║"
    echo "║                     Enhanced Edition 2025                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Enhanced menu with modern features
display_menu() {
    echo -e "${WHITE}════════════════════════════════════════════════════════════════"
    echo -e "                    MAIN MENU"
    echo -e "════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Network Discovery & Analysis:${NC}"
    echo -e "  ${YELLOW}1.${NC}  Advanced Wi-Fi Network Scan"
    echo -e "  ${YELLOW}2.${NC}  Monitor Specific Network (with client detection)"
    echo -e "  ${YELLOW}3.${NC}  Detect WPS-enabled Networks"
    echo -e "  ${YELLOW}4.${NC}  Analyze Network Security (WEP/WPA/WPA2/WPA3)"
    echo ""
    echo -e "${GREEN}Attack Vectors:${NC}"
    echo -e "  ${YELLOW}5.${NC}  Targeted Client Deauthentication"
    echo -e "  ${YELLOW}6.${NC}  Mass Deauthentication Attack"
    echo -e "  ${YELLOW}7.${NC}  Evil Twin Attack Setup"
    echo -e "  ${YELLOW}8.${NC}  WPS PIN Attack"
    echo -e "  ${YELLOW}9.${NC}  Handshake Capture & Analysis"
    echo -e "  ${YELLOW}10.${NC} PMKID Attack (WPA/WPA2)"
    echo ""
    echo -e "${GREEN}Defense & Monitoring:${NC}"
    echo -e "  ${YELLOW}11.${NC} Monitor for Deauth Attacks"
    echo -e "  ${YELLOW}12.${NC} Detect Rogue Access Points"
    echo -e "  ${YELLOW}13.${NC} Network Health Check"
    echo ""
    echo -e "${GREEN}System & Configuration:${NC}"
    echo -e "  ${YELLOW}14.${NC} Adapter Management"
    echo -e "  ${YELLOW}15.${NC} Install/Update Dependencies"
    echo -e "  ${YELLOW}16.${NC} Generate Reports"
    echo -e "  ${YELLOW}17.${NC} Exit"
    echo ""
    echo -e "${BLUE}Enter your choice:${NC}"
    read choice
}

# Check and install dependencies
check_dependencies() {
    local deps=("aircrack-ng" "reaver" "hostapd" "dnsmasq" "hcxdumptool" "hcxtools" "hashcat")
    local missing_deps=()
    
    echo -e "${YELLOW}Checking dependencies...${NC}"
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}Missing dependencies: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}Install missing dependencies? (y/n):${NC}"
        read install_deps
        if [[ $install_deps =~ ^[Yy]$ ]]; then
            install_dependencies
        fi
    else
        echo -e "${GREEN}All dependencies are installed.${NC}"
    fi
}

# Install dependencies
install_dependencies() {
    echo -e "${YELLOW}Installing dependencies...${NC}"
    
    sudo apt update
    sudo apt install -y aircrack-ng reaver hostapd dnsmasq hcxdumptool hcxtools
    
    if ! command -v hashcat &> /dev/null; then
        sudo apt install -y hashcat
    fi
    
    mkdir -p "$handshake_dir" "$wordlist_dir" "reports" "logs" "scans" "monitors" "pmkid"
    
    echo -e "${GREEN}Dependencies installed successfully.${NC}"
}

# Adapter management
manage_adapter() {
    echo -e "${YELLOW}Current Wi-Fi adapters:${NC}"
    iwconfig 2>/dev/null | grep -E "^[a-zA-Z]" | cut -d' ' -f1
    echo ""
    
    echo -e "${BLUE}Options:${NC}"
    echo "1. Change interface"
    echo "2. Enable monitor mode"
    echo "3. Disable monitor mode"
    echo "4. Check adapter capabilities"
    echo "5. Kill interfering processes"
    echo ""
    echo "Enter choice:"
    read adapter_choice
    
    case $adapter_choice in
        1) echo "Enter new interface name:"; read wifi_interface; echo -e "${GREEN}Interface changed to $wifi_interface${NC}";;
        2) enable_monitor_mode ;;
        3) disable_monitor_mode ;;
        4) check_adapter_capabilities ;;
        5) kill_interfering_processes ;;
    esac
}

enable_monitor_mode() {
    echo -e "${YELLOW}Enabling monitor mode on $wifi_interface...${NC}"
    sudo airmon-ng check kill > /dev/null 2>&1
    sudo airmon-ng start "$wifi_interface" > /dev/null 2>&1
    monitor_interface=$(iwconfig 2>/dev/null | grep -o "^[a-zA-Z0-9]*mon")
    if [ -z "$monitor_interface" ]; then
        monitor_interface="${wifi_interface}mon"
    fi
    if iwconfig "$monitor_interface" 2>/dev/null | grep -q "Mode:Monitor"; then
        echo -e "${GREEN}Monitor mode enabled on $monitor_interface${NC}"
    else
        echo -e "${RED}Failed to enable monitor mode${NC}"
    fi
}

disable_monitor_mode() {
    echo -e "${YELLOW}Disabling monitor mode...${NC}"
    sudo airmon-ng stop "$monitor_interface" > /dev/null 2>&1
    echo -e "${GREEN}Monitor mode disabled${NC}"
}

check_adapter_capabilities() {
    echo -e "${YELLOW}Adapter capabilities for $wifi_interface:${NC}"
    if iw list 2>/dev/null | grep -A 20 "Wiphy.*$(iw dev "$wifi_interface" info 2>/dev/null | grep wiphy | cut -d' ' -f2)" | grep -q "monitor"; then
        echo -e "${GREEN}✓ Monitor mode supported${NC}"
    else
        echo -e "${RED}✗ Monitor mode not supported${NC}"
    fi
    echo -e "${BLUE}Supported bands:${NC}"
    iw list 2>/dev/null | grep -A 10 "Band.*:" | grep "MHz"
    echo -e "${BLUE}Current status:${NC}"
    iwconfig "$wifi_interface" 2>/dev/null || echo "Interface not found"
}

kill_interfering_processes() {
    echo -e "${YELLOW}Killing interfering processes...${NC}"
    sudo airmon-ng check kill
    echo -e "${GREEN}Interfering processes killed${NC}"
}

# (Other functions remain the same as your original script — advanced_wifi_scan, parse_scan_results,
# monitor_network, targeted_deauth, pmkid_attack, detect_rogue_aps, monitor_deauth_attacks, generate_report, etc.)

# Enhanced disclaimer
show_disclaimer() {
    echo -e "${RED}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                           DISCLAIMER                          ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  This tool is for AUTHORIZED SECURITY TESTING ONLY            ║"
    echo "║                                                              ║"
    echo "║  • Only use on networks you own or have explicit permission   ║"
    echo "║  • Unauthorized access to networks is ILLEGAL                 ║"
    echo "║  • You are responsible for compliance with local laws         ║"
    echo "║  • This tool is for educational and research purposes only    ║"
    echo "║  • The authors/maintainers are NOT responsible for misuse     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    read -p "Do you accept these terms? (yes/no): " acceptance
    if [[ ! $acceptance =~ ^[Yy][Ee][Ss]$ ]]; then
        echo -e "${RED}Terms not accepted. Exiting...${NC}"
        exit 1
    fi
}

# Main execution
main() {
    display_banner
    show_disclaimer
    check_dependencies
    while true; do
        display_banner
        display_menu
        case $choice in
            1) advanced_wifi_scan ;;
            2) monitor_network ;;
            3) echo "WPS detection feature - Under development" ;;
            4) echo "Security analysis feature - Under development" ;;
            5) targeted_deauth ;;
            6) echo "Mass deauth - Use option 5 without client MAC" ;;
            7) echo "Evil Twin setup - Under development" ;;
            8) echo "WPS PIN attack - Under development" ;;
            9) echo "Handshake capture - Under development" ;;
            10) pmkid_attack ;;
            11) monitor_deauth_attacks ;;
            12) detect_rogue_aps ;;
            13) echo "Network health check - Under development" ;;
            14) manage_adapter ;;
            15) install_dependencies ;;
            16) generate_report ;;
            17) 
                echo -e "${GREEN}Cleaning up...${NC}"
                if [ -n "$monitor_interface" ]; then
                    disable_monitor_mode
                fi
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0 ;;
            *) echo -e "${RED}Invalid choice. Please try again.${NC}" ;;
        esac
        echo ""
        read -p "Press Enter to continue..."
    done
}

main
