openssl req -config ssl.cnf -x509 -sha256 -nodes -days 1826 -newkey rsa:2048 -keyout idp.key -out idp.crt
cp -a idp.key idp-encryption.key  
cp -a idp.key idp-signing.key
cp -a idp.crt idp-encryption.crt
cp -a idp.crt idp-signing.crt
