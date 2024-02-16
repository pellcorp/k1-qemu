#!/bin/sh

if [ "$1" = "facade" ]; then
  busybox rm /sbin/reboot
  busybox rm /bin/rm
  busybox rm /bin/cp
  busybox rm /usr/bin/find
  busybox cp /root/script /sbin/reboot
  busybox cp /root/script /bin/rm
  busybox cp /root/script /bin/cp
  busybox cp /root/script /bin/find
elif [ "$1" = "restore" ]; then
  busybox ln -sf /bin/busybox /sbin/reboot
  busybox ln -sf /bin/busybox /bin/rm
  busybox ln -sf /bin/busybox /bin/cp
  busybox ln -sf /bin/busybox /bin/find
fi

