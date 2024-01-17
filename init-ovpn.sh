sudo apt update
sudo apt -y install easy-rsa openvpn
mkdir ~/easy-rsa
ln -s /usr/share/easy-rsa/* ~/easy-rsa/
chmod 700 /home/$(whoami)/easy-rsa
namehost=$(uname -n)
cd ~/easy-rsa      
./easyrsa init-pki
./easyrsa build-ca nopass           
sudo cp ./pki/ca.crt /usr/local/share/ca-certificates/ca.crt
sudo cp ./pki/ca.crt /etc/openvpn/server
sudo update-ca-certificates
./easyrsa gen-req ovpn-$namehost nopass
sudo cp /home/user/easy-rsa/pki/private/ovpn-$namehost.key /etc/openvpn/server/
./easyrsa import-req  ./pki/reqs/ovpn-$namehost.req ovpn-$namehost
./easyrsa sign-req server ovpn-$namehost
sudo cp ./pki/issued/ovpn-$namehost.crt /etc/openvpn/server
sudo openvpn --genkey secret  ta.key
sudo cp ta.key /etc/openvpn/server
mkdir -p ~/client-configs/keys
cp ./pki/ca.crt ~/client-configs/keys
cp  ta.key ~/client-configs/keys
mkdir -p ~/client-configs/files
chmod -R 700 ~/client-configs