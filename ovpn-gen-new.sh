!#/bin/bash
cd ~/easy-rsa
./easyrsa --batch gen-req $1 nopass
cp pki/private/$1.key ~/client-configs/keys/
./easyrsa --batch import-req ./pki/reqs/$1.req $1
./easyrsa --batch sign-req client $1
cp ./pki/issued/$1.crt ~/client-configs/keys/
cd ~/client-configs/
./make_config.sh $1