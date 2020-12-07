1. Create pool with code, db, and files
1. zfs snapshot blue/db@init
1. zfs snapshot blue/files@init
1. zfs send -R blue/db | ssh vagrant@green.local sudo zfs receive -F green/db
1. zfs send -R blue/files | ssh vagrant@green.local sudo zfs receive -F green/files

Switch steps
