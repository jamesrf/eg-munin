# Evergreen Munin Plugins

## Overview
These are plugins for the monitoring tool Munin which can be used to monitor the number of active drones for any OpenSRF service.  There are three graphs available:

### Full Service Graph
![Full OpenSRF Services Sample Graph](http://github.com/sitka/eg-munin/raw/master/sample-images/full-sample.png)

This graph is quite messy but useful for an overview of services.

### Single Service (Max line) Graph
![OpenSRF Single Service (Max line) Sample Graph](http://github.com/sitka/eg-munin/raw/master/sample-images/lines-sample.png)

This graph represents the max_children as a red line and the number of drones in use as a green line.


### Single Service (Percent line) Graph
![OpenSRF Single Service (Percent line) Sample Graph](http://github.com/sitka/eg-munin/raw/master/sample-images/percent-sample.png)

This graph represents a single service's drones as a percentage of the max_children.

## Usage Instructions

### openils-full.pl (Full service graph)
Place somewhere with executable permissions for munin user, symlink to your munin plugins directory (/etc/munin/plugins)

### openils-lines.pl and openils-percent.pl (Single Service graphs)
Place somewhere with executable permissions for munin user, symlink to your munin plugins directory (/etc/munin/plugins).  The symlink should be named after the service you wish to monitor, for example:

    ln -sf /opt/eg-munin/openils-percent.pl /etc/munin/plugins/openils_cstore

That's it, enjoy.  See the source of the files to adjust the warnings or adjust the warnings in your munin.conf
