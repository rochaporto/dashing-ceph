# Ubuntu Packaging

## Building the dashing-ceph package

[These instructions](http://packaging.ubuntu.com/html/packaging-new-software.html) should give full details.

Quick how to on building and pushing to ppa (update with appropriate version and ppa):
```
git clone git@github.com:rochaporto/dashing-ceph.git
cd dashing-ceph
vim debian/changelog
  <add new entry with appropriate info>
bundle install
cd ..
tar zcvf dashing-ceph_0.2.0.orig.tar.gz dashing-ceph
cd dashing-ceph
dpkg-buildpackage -fakeroot -d -us -uc  -S
cd ..
debsign dashing-ceph_0.2.0-1_source.changes
dput -f ppa:catalystit/dashing dashing-openstack_0.2.0-1_source.changes
```

## Issues

Currently the debian pkg files include all the ruby libraries it depends on.

This makes for quite big debs, but there is no easy way if we want to avoid gem installs
( specific ruby libraries are not usually packaged properly in debian/ubuntu ).
