#!/bin/sh

/etc/init.d/S55klipper_service start

echo "Installing nginx and moonraker..."
/root/curl -L "https://raw.githubusercontent.com/Guilouz/Creality-K1-and-K1-Max/main/Scripts/files/moonraker/moonraker.tar.gz" -o /usr/data/moonraker.tar.gz
tar -zxf /usr/data/moonraker.tar.gz -C /usr/data
rm /usr/data/moonraker.tar.gz
cp /usr/data/nginx/S50nginx /etc/init.d/
cp /usr/data/moonraker/S56moonraker_service /etc/init.d/

echo "Starting nginx and moonraker..."
/etc/init.d/S50nginx start
/etc/init.d/S56moonraker_service start

echo "Waiting for moonraker to start ..."
while true; do
  MRK_KPY_OK=`curl localhost:7125/server/info | jq .result.klippy_connected`
  if [ "$MRK_KPY_OK" = "true" ]; then
    break;
  fi
  sleep 10
done

# sh -c "GS_RESTART_KLIPPER=y GS_DECREALITY=y $(wget --no-check-certificate -qO - https://raw.githubusercontent.com/pellcorp/guppyscreen/jp_configure_confirm_install/installer.sh)"

