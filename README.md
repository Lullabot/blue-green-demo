# Blue / Green Deployments with ZFS

This is a demo showing how one could use ZFS snapshots to do blue / green
deployments for a Drupal website. In this setup, instead of having a "stage"
and "production" environment, two identical "production" environments are set
up and swapped between on each deployment. While there is an unavoidable delay
in production deployments to sync environments, rollbacks become near-instant.
ZFS snapshots are block level and incremental, so they should be much faster
than rsync or other tools that have to walk the whole filesystem. This is
especially noticeable with large image libraries uploaded into Drupal.

## Getting Started

1. You'll need Vagrant and Virtualbox to run the virtual machines.
1. Run `vagrant up` and wait a few minutes as blue and green are initially set
   up.
1. Run `vagrant provision` again for blue to complete setup now that green is
   running.
1. Browse to http://blue.local and you should see the Umami demo profile with
   environment indicator.
1. Browse to http://green.local and you'll see an error because the first
   deployment to green hasn't run yet.
1. Run `vagrant ssh blue`, then `sudo -i`, and finally `/vagrant/deploy.sh` to
   deploy to green.
1. Browse to http://green.local and you'll see the Drupal site but in the green
   environment.
1. Log in and make some content changes in green. The site code is in
   `/var/www/site` along with drush to run `drush -l green.local user:login`.
1. Run `vagrant ssh green`, `sudo -i`, `/vagrant/deploy.sh` to send Green's
   content to blue.
1. Browse to http://blue.local and you'll see your changes.

## Deployment process

See [deploy.sh](deploy.sh) for line-by-line details. In summary:

1. A new snapshot of the database and files directory is created.
1. mariadb is stopped on the destination environment to close any open database files.
1. `zfs send` is used to send the snapshot to the other environment over
   `ssh`.
1. `zfs recv` is used to apply the snapshot. Any local changes in the active
   filesystem are reverted.
1. mariadb is started again on the destination environment.

## Not implemented

1. The actual site code isn't synced between the environments. In practice this
   is not the hard part of blue / green deployments, and leaving this "by hand"
   leaves the opportunity to try out failure scenarios.
1. Likewise, `drush updatedb` / `cache:rebuild` are not called automatically.
1. [Read-only mode](https://www.drupal.org/project/readonlymode) during deployments.
1. A front-end proxy to transparently redirect HTTP requests to the active
   environment. This can be done with Varnish or a CDN like Fastly.
1. Snapshot cleanup. There may not actually be much value in this, given
   that most Drupal sites are constantly adding, and not deleting content.
   Note that there can start to be performance issues when listing thousands
   of ZFS snapshots, so considering this in production is important.

