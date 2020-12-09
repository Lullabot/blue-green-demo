#!/bin/bash -ex

# A unique identifier for the deployment. This could be a version number, or a
# date such as YYYY-MM-DD--#. In real setups this would be manually specified.
ID=$(date +%Y-%m-%d-%H-%M-%S)
SSH="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
DATASETS="db files"

COLOUR=$(hostname)
if [ $COLOUR == "blue" ]
then
  OTHER=green
else
  OTHER=blue
fi

echo "This demo doesn't deploy or sync code.
If you want to test that, do it by hand and press enter to continue..."
read

$SSH vagrant@$OTHER.local sudo systemctl stop mariadb

for DATASET in $DATASETS
do
  # Create a local snapshot based on the deployment. Note that the ID is used
  # to reference the datasets just before code and content updates are
  # deployed. Snapshots are also required for zfs send.
  zfs snapshot $COLOUR/$DATASET@$ID

  # base is the first snapshot. We hardcode this for now as this will
  # replicate all snapshots in the range from "base" to $ID. Since it's
  # unlikely snapshots will be wanted to be kept forever, eventually this
  # should be a parameter.
  zfs send -R -I $COLOUR/$DATASET@base $COLOUR/$DATASET@$ID | \
    $SSH vagrant@$OTHER.local sudo zfs receive -F $OTHER/$DATASET

  # Roll back any local changes from the destination to the snapshot we just
  # sent.
  $SSH vagrant@$OTHER.local sudo zfs rollback $OTHER/$DATASET@$ID
done

$SSH vagrant@$OTHER.local sudo systemctl start mariadb

echo "This demo doesn't run database updates or clear caches.
Do it now by hand on $OTHER if you need to."
