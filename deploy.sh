#!/bin/bash -ex

# A unique identifier for the deployment. This could be a version number, or a
# date such as YYYY-MM-DD--#. In real setups this would be manually specified.
ID=$(date +%Y-%m-%d-%H-%M-%S)
DATASETS="db files"

COLOUR=$(hostname)
if [ $COLOUR == "blue" ]
then
  OTHER=green
else
  OTHER=blue
fi

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@$OTHER.local sudo systemctl stop mariadb

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
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@$OTHER.local sudo zfs receive -F $OTHER/$DATASET

  # Roll back any local changes from the destination to the snapshot we just
  # sent.
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@$OTHER.local sudo zfs rollback $OTHER/$DATASET@$ID
done

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@$OTHER.local sudo systemctl start mariadb
