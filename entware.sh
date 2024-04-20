#!/bin/sh

# https://raw.githubusercontent.com/Guilouz/Creality-Helper-Script/main/files/entware/generic.sh

rm -rf /opt
rm -rf /usr/data/opt
mkdir -p /usr/data/opt
ln -nsf /usr/data/opt /opt

for folder in bin etc lib/opkg tmp var/lock
do
  mkdir -p /usr/data/opt/$folder
done

URL="http://bin.entware.net/mipselsf-k3.4/installer"
wget --no-check-certificate -P "/opt/bin/" "$URL/opkg"
wget --no-check-certificate -P "/opt/etc/" "$URL/opkg.conf"

chmod 755 /opt/bin/opkg
chmod 777 /opt/tmp

/opt/bin/opkg update
/opt/bin/opkg install entware-opt avrdude

for file in passwd group shells shadow gshadow; do
  if [ -f /etc/$file ]; then
    ln -sf /etc/$file /opt/etc/$file
  else
    [ -f /opt/etc/$file.1 ] && cp /opt/etc/$file.1 /opt/etc/$file
  fi
done

[ -f /etc/localtime ] && ln -sf /etc/localtime /opt/etc/localtime

echo 'export PATH="/opt/bin:/opt/sbin:$PATH"' > /etc/profile.d/entware.sh

echo '#!/bin/sh\n/opt/etc/init.d/rc.unslung "$1"' > /etc/init.d/S50unslung
chmod 755 /etc/init.d/S50unslung

