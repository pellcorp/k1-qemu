# Building qemu image

## Host Preparation

You will need qemu, qemu-user-static and qemu-user-static-binfmt or equivalent and unsquashfs

### K1 Firmware 

The rootfs.squashfs needs to be obtained from the k1 firmware, here is an example of how to get it:

```
wget https://file2-cdn.creality.com/file/0c96dc76c1455460ef66a8adaa367902/CR4CU220812S11_ota_img_V1.3.3.5.img
7z x CR4CU220812S11_ota_img_V1.3.3.5.img -p'XXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
cat CR4CU220812S11_ota_img_V1.3.3.5/ota_v1.3.3.5/rootfs.squashfs.* > rootfs.squashfs
rm -rf CR4CU220812S11_ota_img_V1.3.3.5
```

The 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXX' may vary depending on the firmware, left as an exercise for the user to figure it out

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
