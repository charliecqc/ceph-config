yes | rm -rf /var/lib/ceph/mon/*
mkdir -p /var/lib/ceph/mon/ceph.jsm3
ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
monmaptool --clobber --create --add jsm3 192.168.1.139 --fsid 3cce2191-fb12-4c2e-83a2-4daa0163cb3d  /tmp/monmap
ceph-mon --mkfs -i jsm3 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
ceph-mon -i jsm3

# Create pools and prepare for OSDs
ceph osd pool delete data
ceph osd pool delete metadata
ceph osd pool create data 64
ceph osd pool create metadata 64 
ceph osd crush add-bucket jsm3 host
ceph osd crush move jsm3 root=default

# create OSDs
mkdir -p /var/lib/ceph/osd

ceph osd out 0
ceph osd out 1
umount /var/lib/ceph/osd/osd.0
umount /var/lib/ceph/osd/osd.1
yes | rm -rf /var/lib/ceph/osd/*

ceph osd create
mkdir -p /var/lib/ceph/osd/osd.0

mkdir -p /var/lib/ceph/osd/ceph-0
#yes | mkfs -t ext4 -O ^has_journal /dev/sdb 
yes | mkfs -t ext4 /dev/sdb1 
#hdparm  -a 0 /dev/sdb1
mount -t ext4 -o user_xattr /dev/sdb1 /var/lib/ceph/osd/osd.0
ceph-osd -i 0 --mkfs --mkkey
ceph auth add osd.0 osd 'allow *' mon 'allow rwx' -i /var/lib/ceph/osd/osd.0/keyring
ceph osd crush add 0 1.0 pool=data host=jsm3
ceph-osd -i 0

ceph osd create
mkdir -p /var/lib/ceph/osd/osd.1
#yes | mkfs -t ext4 -O ^has_journal /dev/sdd 
yes | mkfs -t ext4 /dev/sdc
#hdparm  -a 0 /dev/sdb2
mount -t ext4 -o user_xattr /dev/sdc /var/lib/ceph/osd/osd.1
ceph-osd -i 1 --mkfs --mkkey
ceph auth add osd.1 osd 'allow *' mon 'allow rwx' -i /var/lib/ceph/osd/osd.1/keyring
ceph osd crush add 1 1.0 pool=data host=jsm3
ceph-osd -i 1


#ceph osd create
#mkdir /var/lib/ceph/osd/ceph-2
#yes | mkfs -t ext4 /dev/sdc
#hdparm  -a 0 /dev/sdc
#mount -t ext4 -o user_xattr /dev/sdc /var/lib/ceph/osd/ceph-2
#ceph-osd -i 2 --mkfs --mkkey
#ceph auth add osd.2 osd 'allow *' mon 'allow rwx' -i /var/lib/ceph/osd/ceph-2/keyring
#ceph osd crush add 2 1.0 pool=data host=infi14
#start ceph-osd id=2

# create MDS server

# creating MDS server when building from source
#mkdir /var/lib/ceph/mds/
rm -rf /var/lib/ceph/mds/*
mkdir -p /var/lib/ceph/mds/mds.jsm3
ceph auth get-or-create mds.jsm3 mds 'allow' osd 'allow *' mon 'allow rwx' > /var/lib/ceph/mds/mds.jsm3/mds.jsm3.keyring
ceph-mds -i jsm3


#ceph setting
# Creating and mounthing a file system
umount /mnt/mycephfs
ceph fs new cephfs metadata data
mkdir -p /mnt/mycephfs
secret=$(cat /etc/ceph/ceph.client.admin.keyring | grep key |awk '{print $3}')
mount -t ceph 192.168.1.139:6789:/ /mnt/mycephfs -o name=admin,secret=$secret

echo "Finished mouting cephfs on /mnt/mycephfs..."

## addr = 192.168.1.139:6789
