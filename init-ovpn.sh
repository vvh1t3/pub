sudo apt update
sudo apt -y install easy-rsa openvpn
cp -r ./client-configs/ ~/
mkdir ~/easy-rsa
ln -s /usr/share/easy-rsa/* ~/easy-rsa/
chmod 700 /home/$(whoami)/easy-rsa
namehost=$(uname -n)
cd ~/easy-rsa      
./easyrsa init-pki
export EASYRSA_REQ_CN="$namehost"
./easyrsa --batch build-ca nopass         
sudo cp ./pki/ca.crt /usr/local/share/ca-certificates/ca.crt
sudo cp ./pki/ca.crt /etc/openvpn/server
sudo update-ca-certificates
./easyrsa --batch  gen-req ovpn-$namehost nopass
sudo cp /home/user/easy-rsa/pki/private/ovpn-$namehost.key /etc/openvpn/server/
./easyrsa --batch  import-req  ./pki/reqs/ovpn-$namehost.req ovpn-$namehost
./easyrsa --batch  sign-req server ovpn-$namehost
sudo cp ./pki/issued/ovpn-$namehost.crt /etc/openvpn/server
sudo openvpn --genkey secret  ta.key
sudo cp ta.key /etc/openvpn/server
mkdir -p ~/client-configs/keys
cp ./pki/ca.crt ~/client-configs/keys
sudo cp  ta.key ~/client-configs/keys
sudo sudo chown $(id -u):$(id -g) ~/client-configs/keys/ta.key
mkdir -p ~/client-configs/files
chmod -R 700 ~/client-configs
cd ~/pub/
sed -i "s/cert ovpn-srv.crt/cert ovpn-$namehost.crt/" server.conf
sed -i "s/key ovpn-srv.key/key ovpn-$namehost.key/" server.conf

sudo cp server.conf /etc/openvpn/server
sudo mkdir /etc/openvpn/server/ccd
sudo systemctl restart openvpn-server@server