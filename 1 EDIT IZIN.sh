IZIN=$( curl https://raw.githubusercontent.com/racunzx/ipbosku/main/aashahwjusisjsnajakajannaiajanajam | grep $MYIP )
if [ $MYIP = $IZIN ]; then
echo -e "${green}Permission Accepted...${NC}"
else
echo -e "${red}Permission Denied!${NC}";
echo -e "${red}Please Contact Admin  # NAK DAFTAR IP ? CONTACT SAYA @vpnshopee DI TELEGRAM | WhatsApp wa.me/60104557217#${NC}"
rm -f setup.sh
exit 0
fi