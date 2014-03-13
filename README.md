dashing-ceph
============

## Description

dashing based dashboard displaying health and stats of a CEPH cluster.

==============

Overview
--------

This repo contains the widgets, the dashboard definition, and the required `pool`, `traffic` and `health` jobs.

It provides one single dashboard with the following components:

* Health monitoring display
* Storage usage meter
* Pool usage (two pools, configurable)
* Traffic display (read and write)

Screenshots
-----------

![image](https://raw.github.com/rochaporto/dashing-ceph/master/public/ceph_ok.png)

![image](https://raw.github.com/rochaporto/dashing-ceph/master/public/ceph_warn.png)

Requirements
------------

You need a working CEPH client configured in the machine running the dashing instance.

For now it requires the `admin` client (keyring).

Setup
-----

After cloning this repository, check the config.yaml file to define the pools to monitor.

Below the default configuration, which includes pools `images` and `volumes`.

    pools:
      images:
        display_name: 'Images'
      volumes:
        display_name: 'Volumes'

You can then start the instance as usual:

    dashing start -p 3000

`-p` for port is optional.

Limitations
-----------

No configuration for the ceph user possible right now (assumes `admin`).

It would be nice to add additional views (with new dashboards running in the same instance).

Development
-----------

All contributions more than welcome, just send pull requests.

License
-------

GPLv3 (check LICENSE).

Contributors
------------

Ricardo Rocha <ricardo@catalyst.net.nz>

Support
-------

Please log tickets and issues at the [github home](https://github.com/rochaporto/dashing-ceph/issues).
