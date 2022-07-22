A Simple init.d Script and Watchdog for Daemonizing IPFS
========================================================

A simple SysV init script for daemonizing IPFS. After you install ipfs run the install.sh script from this repo.

This will do a couple things.
- It will create a daemon user "ipfsd" and ipfsd service on the system, and add it to your boot sequence. 
- Add a watchdog cronjob which will try to restart ipfsd every now and then if it is stopped.

Future Work
-----------
The installer has a bit of system-specific instructions down at the bottom, which may need to be extended to properly set up rc.d files on other systems.

License
-------

Copyright (C) 2015 Jeff Cochran

This is open source software, licensed under the MIT License. See the
file LICENSE for details.

Forked from https://github.com/fhd/init-script-template
Which is released under MIT License as well, and is 
Copyright (C) 2012-2014 Felix H. Dahlke
