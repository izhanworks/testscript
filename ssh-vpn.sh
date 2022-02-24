#!/bin/bash
# By Horasss
#
# ==================================================

# initializing var
export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- ipinfo.io/ip);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

#detail nama perusahaan
country=MY
state=Malaysia
locality=Malaysia
organization=www.vpnshopee.xyz
organizationalunit=www.vpnshopee.xyz
commonname=www.vpnshopee.xyz
email=admin@vpnshopee.xyz

# simple password minimal
wget -O /etc/pam.d/common-password "https://raw.githubusercontent.com/izhanworks/testscript/main/password"
chmod +x /etc/pam.d/common-password

# go to root
cd

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

#update
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y

# install wget and curl
apt -y install wget curl

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# install
apt-get --reinstall --fix-missing install -y bzip2 gzip coreutils wget screen rsyslog iftop htop net-tools zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch git lsof
echo "clear" >> .profile
echo "neofetch --ascii_distro SliTaz" >> .profile
echo "echo -e '\e[35m  Script Premium VPNshopee By \e[32mRARE \e[0m'" >> .profile
echo "echo -e '\e[35m Sila Type: info, untuk melihat info \e[0m'" >> .profile
echo "echo -e '\e[35m    Telegram:\e[0m \e[32m@vpnshopee \e[0m'" >> .profile
echo "echo ''" >> .profile
echo "echo -e '\e[35m  Type\e[5m \e[32mmenu\e[0m \e[35mUntuk Melihat Menu VPS anda \e[0m'" >> .profile
echo "echo ''" >> .profile

# install webserver
apt -y install nginx
cd
mkdir /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" | tee /etc/systemd/system/nginx.service.d/override.conf
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/izhanworks/testscript/main/nginx.conf"
mkdir -p /home/vps/public_html
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/izhanworks/testscript/main/vps.conf"
/etc/init.d/nginx restart

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/izhanworks/testscript/main/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500' /etc/rc.local
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500

# setting port ssh
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config

# install dropbear
apt -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/dropbear restart

# install squid
cd
apt -y install squid3
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/izhanworks/testscript/main/squid3.conf"
sed -i $MYIP2 /etc/squid/squid.conf

# setting vnstat
apt -y install vnstat
/etc/init.d/vnstat restart
apt -y install libsqlite3-dev
wget https://humdi.net/vnstat/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install
cd
vnstat -u -i $NET
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz
rm -rf /root/vnstat-2.6

# install stunnel
apt install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 888
connect = 127.0.0.1:109

[dropbear]
accept = 777
connect = 127.0.0.1:22

END

# make a certificate
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

#OpenVPN
wget https://raw.githubusercontent.com/izhanworks/testscript/main/vpn.sh &&  chmod +x vpn.sh && ./vpn.sh

# install fail2ban
apt -y install fail2ban

# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
apt install -y dnsutils tcpdump dsniff grepcidr
wget -qO ddos.zip "https://raw.githubusercontent.com/izhanworks/testscript/main/ddos-deflate.zip"
unzip ddos.zip
cd ddos-deflate
chmod +x install.sh
./install.sh
cd
rm -rf ddos.zip ddos-deflate
echo '...done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

# banner /etc/issue.net
wget -O /etc/issue.net "https://raw.githubusercontent.com/izhanworks/testscript/main/banner.conf"
echo "Banner /etc/issue.net" >>/etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear

# blockir torrent
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# download script
cd /usr/bin
# menu
wget -O menu "https://raw.githubusercontent.com/izhanworks/testscript/main/menu.sh"
# menu ssh-ovpn
wget -O m-sshovpn "https://raw.githubusercontent.com/izhanworks/testscript/main/m-sshovpn.sh"
wget -O usernew "https://raw.githubusercontent.com/izhanworks/testscript/main/usernew.sh"
wget -O trial "https://raw.githubusercontent.com/izhanworks/testscript/main/trial.sh"
wget -O renew "https://raw.githubusercontent.com/izhanworks/testscript/main/renew.sh"
wget -O hapus "https://raw.githubusercontent.com/izhanworks/testscript/main/hapus.sh"
wget -O cek "https://raw.githubusercontent.com/izhanworks/testscript/main/cek.sh"
wget -O member "https://raw.githubusercontent.com/izhanworks/testscript/main/member.sh"
wget -O delete "https://raw.githubusercontent.com/izhanworks/testscript/main/delete.sh"
wget -O autokill "https://raw.githubusercontent.com/izhanworks/testscript/main/autokill.sh"
wget -O ceklim "https://raw.githubusercontent.com/izhanworks/testscript/main/ceklim.sh"
wget -O tendang "https://raw.githubusercontent.com/izhanworks/testscript/main/tendang.sh"
# menu wg
wget -O m-wg "https://raw.githubusercontent.com/izhanworks/testscript/main/m-wg.sh"
# menu ssr
wget -O m-ssr "https://raw.githubusercontent.com/izhanworks/testscript/main/m-ssr.sh"
#  menu v2ray
wget -O v2ray-vmess "https://raw.githubusercontent.com/izhanworks/testscript/main/v2ray-vmess.sh"
wget -O v2ray-vless "https://raw.githubusercontent.com/izhanworks/testscript/main/v2ray-vless.sh"
# menu xray
wget -O xray-vmess "https://raw.githubusercontent.com/izhanworks/testscript/main/xray-vmess.sh"
wget -O xray-vless "https://raw.githubusercontent.com/izhanworks/testscript/main/xray-vless.sh"
wget -O xray-xtls "https://raw.githubusercontent.com/izhanworks/testscript/main/xray-xtls.sh"
# menu trojan
wget -O m-trojan "https://raw.githubusercontent.com/izhanworks/testscript/main/m-trojan.sh"
# menu system
wget -O m-system "https://raw.githubusercontent.com/izhanworks/testscript/main/m-system.sh"
wget -O domain-menu "https://raw.githubusercontent.com/izhanworks/testscript/main/domain-menu.sh"
wget -O add-host "https://raw.githubusercontent.com/izhanworks/testscript/main/add-host.sh"
wget -O cff "https://raw.githubusercontent.com/izhanworks/testscript/main/cff.sh"
wget -O cfd "https://raw.githubusercontent.com/izhanworks/testscript/main/cfd.sh"
wget -O cfh "https://raw.githubusercontent.com/izhanworks/testscript/main/cfh.sh"
wget -O certv2ray "https://raw.githubusercontent.com/izhanworks/testscript/main/certv2ray.sh"
wget -O port-change "https://raw.githubusercontent.com/izhanworks/testscript/main/port-change.sh"
   # change port
wget -O port-ssl "https://raw.githubusercontent.com/izhanworks/testscript/main/port-ssl.sh"
wget -O port-ovpn "https://raw.githubusercontent.com/izhanworks/testscript/main/port-ovpn.sh"
wget -O port-wg "https://raw.githubusercontent.com/izhanworks/testscript/main/port-wg.sh"
wget -O port-ws "https://raw.githubusercontent.com/izhanworks/testscript/main/port-ws.sh"
wget -O port-vless "https://raw.githubusercontent.com/izhanworks/testscript/main/port-vless.sh"
wget -O port-xws "https://raw.githubusercontent.com/izhanworks/testscript/main/port-xws.sh"
wget -O port-xvless "https://raw.githubusercontent.com/izhanworks/testscript/main/port-xvless.sh"
wget -O port-xtls "https://raw.githubusercontent.com/izhanworks/testscript/main/port-xtls.sh"
wget -O port-tr "https://raw.githubusercontent.com/izhanworks/testscript/main/port-tr.sh"
wget -O port-squid "https://raw.githubusercontent.com/izhanworks/testscript/main/port-squid.sh"
# menu system
wget -O webmin "https://raw.githubusercontent.com/izhanworks/testscript/main/webmin.sh"
wget -O running "https://raw.githubusercontent.com/izhanworks/testscript/main/running.sh"
wget -O ram "https://raw.githubusercontent.com/izhanworks/testscript/main/ram.sh"
wget -O speedtest "https://raw.githubusercontent.com/izhanworks/testscript/main/speedtest_cli.py"
wget -O info "https://raw.githubusercontent.com/izhanworks/testscript/main/info.sh"
wget -O about "https://raw.githubusercontent.com/izhanworks/testscript/main/about.sh"
wget -O bbr "https://raw.githubusercontent.com/izhanworks/testscript/main/bbr.sh"
wget -O auto-reboot "https://raw.githubusercontent.com/izhanworks/testscript/main/auto-reboot.sh"
wget -O clear-log "https://raw.githubusercontent.com/izhanworks/testscript/main/clear-log.sh"
wget -O restart "https://raw.githubusercontent.com/izhanworks/testscript/main/restart.sh"
wget -O bw "https://raw.githubusercontent.com/izhanworks/testscript/main/bw.sh"
wget -O resett "https://raw.githubusercontent.com/izhanworks/testscript/main/resett.sh"
wget -O update "https://raw.githubusercontent.com/izhanworks/testscript/main/update.sh"
wget -O kernel-updt "https://raw.githubusercontent.com/izhanworks/testscript/main/kernel-update.sh"
# uNLOCATED
wget -O swap "https://raw.githubusercontent.com/izhanworks/testscript/main/swapkvm.sh"
wget -O user-limit "https://raw.githubusercontent.com/izhanworks/testscript/main/user-limit.sh"
wget -O xp "https://raw.githubusercontent.com/izhanworks/testscript/main/xp.sh"

chmod +x menu
chmod +x m-sshovpn
chmod +x usernew
chmod +x trial
chmod +x renew
chmod +x hapus
chmod +x cek
chmod +x member
chmod +x delete
chmod +x autokill
chmod +x ceklim
chmod +x tendang
chmod +x m-wg
chmod +x m-ssr
chmod +x v2ray-vmess
chmod +x v2ray-vless
chmod +x xray-vmess
chmod +x xray-vless
chmod +x xray-xtls
chmod +x m-trojan
chmod +x m-system
chmod +x domain-menu
chmod +x add-host
chmod +x cff
chmod +x cfd
chmod +x cfh
chmod +x certv2ray
chmod +x port-change
chmod +x port-ssl
chmod +x port-ovpn
chmod +x port-wg
chmod +x port-ws
chmod +x port-vless
chmod +x port-xws
chmod +x port-xvless
chmod +x port-xtls
chmod +x port-tr
chmod +x port-squid
chmod +x port-trgo
chmod +x webmin
chmod +x running
chmod +x ram
chmod +x speedtest
chmod +x info
chmod +x about
chmod +x bbr
chmod +x auto-reboot
chmod +x clear-log
chmod +x restart
chmod +x bw
chmod +x resett
chmod +x update
chmod +x del-trgo
chmod +x add-trgo
chmod +x cek-trgo
chmod +x renew-trgo
chmod +x swap
chmod +x user-limit
chmod +x xp
chmod +x kernel-updt

echo "0 0 * * * root /sbin/hwclock -w   # synchronize hardware & system clock each day at 00:00 am" >> /etc/crontab
echo "0 5 * * * root /sbin/shutdown -r now  # reboot everyday at 05:0 am" >> /etc/crontab
echo "0 4 * * * root /usr/bin/clear-log # clear log everyday at 04:0 am" >> /etc/crontab
echo "55 23 * * * root /usr/bin/xp # delete expired user" >> /etc/crontab
# remove unnecessary files
cd
apt autoclean -y
apt -y remove --purge unscd
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove bind9*;
apt-get -y remove sendmail*
apt autoremove -y
# finishing
cd
chown -R www-data:www-data /home/vps/public_html
/etc/init.d/nginx restart
/etc/init.d/openvpn restart
/etc/init.d/cron restart
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/fail2ban restart
/etc/init.d/stunnel4 restart
/etc/init.d/vnstat restart
/etc/init.d/squid restart
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
history -c
echo "unset HISTFILE" >> /etc/profile

cd
rm -f /root/key.pem
rm -f /root/cert.pem
rm -f /root/ssh-vpn.sh

# finihsing
clear
