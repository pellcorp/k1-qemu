#!/bin/sh

if [ "$1" = "facade" ]; then
  busybox rm /sbin/reboot
  busybox rm /bin/rm
  busybox rm /bin/cp
  busybox rm /usr/bin/find
  
  busybox cp /script /sbin/reboot
  busybox cp /script /bin/rm
  busybox cp /script /bin/cp
  busybox cp /script /bin/find
elif [ "$1" = "restore" ]; then
  busybox ln -sf /bin/busybox /sbin/reboot
  busybox ln -sf /bin/busybox /bin/rm
  busybox ln -sf /bin/busybox /bin/cp
  busybox ln -sf /bin/busybox /usr/bin/find
fi

