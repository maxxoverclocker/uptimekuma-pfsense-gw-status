# pfSense shell script for reporting gateway status to Uptime Kuma
Simple script that will report the current gateway status in pfSense to Uptime Kuma. Supports multiple WANs. Will report 'PACKETLOSS' and 'LATENCY' as msg to Uptime Kuma.

# Screenshots
![image](https://user-images.githubusercontent.com/23197375/167198311-1695aeed-4415-4925-b14d-24d688b2b273.png)

# Requirements
- pfSense 2.5.2,2.6O (Untested on any other release)
- pfSense Package: Shellcmd 1.0.5_2 (Untested on any other version)
- Python 3.8,3.8.12 (Untested on any other version)

# Installation
1. Create directory and place `dpinger-gateway-status.py`, `uptime-kuma-gateway-status.csh`, and `uptime-kuma-gateway-dictionary.txt`
```bash
mkdir -p /root/local-scripts/uptime-kuma-gateway-status
```
2. In Uptime Kuma: Add a New Mointor with the Monitor Type `Push` and copy the ID of the Push URL
3. Modify uptime-kuma-gateway-status.csh to reflect your WAN interface names and Uptime Kuma URL:
- `set wan_interfaces = 'WAN_1 WAN_2'`
- `set uptime_kuma_url = 'http://uptime-kuma.example.com:3001'`
3. Modify uptime-kuma-gateway-dictionary.txt to reflect both your WAN interface names as well as the unique Push URL generated from Uptime Kuma
4. Using the Shellcmd package in pfSense, create a new Shellcmd Configuration:
- Command: `nohup /bin/csh /root/local-scripts/uptime-kuma-gateway-status/uptime-kuma-gateway-status.csh >/dev/null 2>&1 &`
- Shellcmd Type: shellcmd
- Description: uptime-kuma-gateway-status.csh
5. Reboot and enjoy!
