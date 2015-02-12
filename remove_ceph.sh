umount /mnt/mycephfs
pid=$(ps aux | grep ceph-osd | grep -v grep | awk '{print $2 }')
kill -9 $pid
pid1=$(ps aux | grep ceph-mds | grep -v grep | awk '{print $2 }')
kill -9 $pid1
pid2=$(ps aux | grep ceph-mon | grep -v grep | awk '{print $2 }')
kill -9 $pid2

sleep 5
umount /mnt/myceph
echo "umount /dev/sd*............"
umount /dev/sdb1
umount /dev/sdc
#umount /dev/sdd
#umount /dev/sde
#umount /dev/sdf
#umount /dev/sdg

#echo "rmmod pxt4, jbd3........"
#rmmod pxt4.ko
#rmmod jbd3.ko
