# Wi-Fi Security Toolkit 🔐📡

An **educational Wi-Fi penetration testing & monitoring toolkit** written in Bash.  
Supports scanning, deauthentication attacks, PMKID capture, rogue AP detection, and monitoring for DoS.  

⚠️ **DISCLAIMER**: This tool is for **educational purposes only**.  
Do not use against networks without **explicit permission**. Unauthorized use is illegal.

---

## ✨ Features
- Wi-Fi network scanner
- Targeted & mass deauthentication attack
- PMKID hash capture (WPA2 cracking support)
- Rogue AP detection
- Deauth attack monitoring
- Logging & report generation

---

## 📦 Requirements
- Linux (tested on Ubuntu/Kali/Parrot)
- `aircrack-ng`
- `hcxdumptool`
- `tcpdump`
- `iwconfig`

Install with:
```bash
sudo apt-get update
sudo apt-get install aircrack-ng hcxdumptool tcpdump -y
```

---

## 🚀 Usage
```bash
chmod +x wifi_toolkit.sh
./wifi_toolkit.sh
```

---

## 📜 Disclaimer
See [DISCLAIMER.md](DISCLAIMER.md) before usage.

---

## 📌 Author
Made by **Darshan** ✨ ([@Darshan060224](https://github.com/Darshan060224))
