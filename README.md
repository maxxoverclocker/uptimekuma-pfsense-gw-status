# pfSense shell script for reporting gateway status to Uptime Kuma
Simple script that will report the current gateway status in pfSense to Uptime Kuma. Supports multiple WANs. Will report 'PACKETLOSS' and 'LATENCY' as 'msg' to Uptime Kuma as well as 'UP' or 'DOWN' as 'status'.

# Screenshots
![image](https://user-images.githubusercontent.com/23197375/167198311-1695aeed-4415-4925-b14d-24d688b2b273.png)

# Requirements
- pfSense 2.5.2, 2.6.0 (Untested on any other release)
- pfSense Package: Shellcmd 1.0.5_2 (Untested on any other version)
- pfSense Package: Cron 0.3.8_1
- Python 3.8 (Untested on any other version)

# Install/Use
1. In a local directory ex: `/root/local-scripts/uptime-kuma-gateway-status`, place `dpinger-gateway-status.py`, `uptime-kuma-gateway-status.csh`, and `uptime-kuma-gateway-dictionary.txt`

2. Modify uptime-kuma-gateway-status.csh to reflect your WAN gateway names and Uptime Kuma URL:
- `set gateway_names = 'WAN_1_DHCP WAN_2_DHCP'`
- `set uptime_kuma_url = 'http://uptime-kuma.example.com:3001'`

3. Modify uptime-kuma-gateway-dictionary.txt to reflect both your WAN gateway names as well as the unique Push URL generated from Uptime Kuma

4. Using the Shellcmd package in pfSense, create a new Shellcmd Configuration:
- Command: `nohup /bin/csh /root/local-scripts/uptime-kuma-gateway-status/uptime-kuma-gateway-status.csh >/dev/null 2>&1 &`
- Shellcmd Type: `shellcmd`
- Description: `uptime-kuma-gateway-status.csh`
![image](https://github.com/maxxoverclocker/uptimekuma-pfsense-gw-status/assets/23197375/4a65dd6c-54f1-4c7a-8e56-e88668edc4dd)

5. NEW - Using the Cron package in pfSense, create a new Cron schedule:
- Minute: `*/15`
- Hour: `*`
- Day of the Month: `*`
- Month of the Year: `*`
- Day of the Week: `*`
- User: `root`
- Command: `nohup /bin/csh /root/local-scripts/uptime-kuma-gateway-status/uptime-kuma-gateway-status.csh >/dev/null 2>&1 &`
![image](https://github.com/maxxoverclocker/uptimekuma-pfsense-gw-status/assets/23197375/66c9d8c0-e085-45e6-a87f-a6d8f0058f97)

7. Reboot and enjoy!
