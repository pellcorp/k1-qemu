# Building qemu image

## Host Preparation

You will need qemu, qemu-user-static and qemu-user-static-binfmt or equivalent and unsquashfs

### K1 Firmware 

The rootfs.squashfs needs to be obtained from the k1 firmware, here is an example of how to get it:

```
wget https://file2-cdn.creality.com/file/6c53dfcbfa0d7e36938e01e97ba67e1a/CR4CU220812S11_ota_img_V1.3.3.26.img
#wget https://file2-cdn.creality.com/file/4ba071338e120558283f884266f9250d/CR4CU220812S11_ota_img_V1.3.3.8.img
7z x CR4CU220812S11_ota_img_V1.3.3.26.img -p"$(cat ~/.k1/firmware.passwd)"
cat CR4CU220812S11_ota_img_V1.3.3.26/ota_v1.3.3.26/rootfs.squashfs.* > rootfs.squashfs
rm -rf CR4CU220812S11_ota_img_V1.3.3.26
rm CR4CU220812S11_ota_img_V1.3.3.26.img
```

The '~/.k1/firmware.password' may vary depending on the firmware, left as an exercise for the user to figure it out!

### Create the Image


```
sudo ./create.sh
```

## Running it

```
sudo ./start.sh
```

## Chroot K1 Firmware rootfs

Login as ssh and do:

```
./chroot.sh
```

# Default Config

You can get the creality firmware to setup basic printer data by running:

```
/etc/init.d/S55klipper_service start
```

## Console too narrow?

After `./chroot.sh`, run the `resize` command

## Links

https://github.com/wtdcode/DebianOnQEMU
https://doma.ws/debian11_mips/

