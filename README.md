wireguard-vpn-masquerade
========================

[![Build Status](https://travis-ci.org/mmitch/wireguard-vpn-masquerade.svg?branch=master)](https://travis-ci.org/mmitch/wireguard-vpn-masquerade)
[![GPL 3+](https://img.shields.io/badge/license-GPL%203%2B-blue.svg)](http://www.gnu.org/licenses/gpl-3.0-standalone.html)

Generate a WireGuard configuration to allow multiple clients access to the internet via a server.  
Copyright (C) 2019  Christian Garbs <mitch@cgarbs.de>  
Licensed under GNU GPL v3 (or later)  
Homepage: https://github.com/mmitch/wireguard-vpn-masquerade  

## nomenclature

This guide talks about three different actors that are part of the whole:

* The _server_ is the system where the VPN tunnel ends and the
  _client's_ traffic emerges into the internet.  It needs a static IP
  address or name resolvable by DNS so the _clients_ know where to
  connect to.
  
* A _client_ is a device that uses the VPN tunnel to connect to the
  internet.  It can be a laptop, a desktop pc or a mobile device.

* The _configurator_ is the host that `wg-conf` runs on.  It can be
  run on the _server_ or on a _client_ or a completely different
  system.  Private keys will be kept here and the generated
  configuration must be copied to the _server_ and _clients_
  eventually.  Because the `wg(8)` binary is needed, the _server_ is a
  good candidate for the _configurator_.

## configuration

On the _configurator_:

1. edit `wg-conf.server` and include your network configuration
2. edit `wg-conf.clients` and include all your clients

In both cases, replace every `PRIVATE-KEY` placeholder the the result
of `wg genkey`.  Run it multiple times so that all keys are different.

3. run `wg-conf server` and copy the created configuration to your _server_
4. run `wg-conf client` for all clients and copy the configuration to
   your _clients_
   * for mobile clients run `wg-conf qr` instead and scan the generated
     QR code from the app

If your clients change, edit `wg-conf.clients` and re-run the steps
for both _server_ and _clients_.

### git integration

Be aware that both `wg-conf.server` and `wg-conf.clients` have been
added to `.gitignore` so that you don't accidentially check in your
configuration and reveal it to the world.

If you want to check in your configuration anyways, you can use `git add --force`.

Better yet: set up a local branch for your local configuration, remove
both files from `.gitignore` in that branch and check in your
configuration.  Then merge (or rebase) any official changes from the
master branch as needed.

## setup

These things have to be done only once.

### configurator setup

1. install `wireguard-vpn-masquerade` (eg `github clone
   https://github.com/mmitch/wireguard-vpn-masquerade`)
2. install `wg(8)`
   * either install full `wireguard` (see _server setup_)
   * or just copy the `wg` binary from the sevrer if possible
   `wg(8)` is only needed for `wg genkey` and `wg pubkey`
3. install `qr-encode` (eg. `apt install qrencode`) if you want to
   generate QR codes for mobile devices

### server setup

1. install `wireguard`, see https://www.wireguard.com/install/  
   For me, the following worked on Debian Buster:
   ```shell
   echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable.list
   printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable
   apt update
   apt install wireguard
   ```

2. activate masquerading
   * when using `nftables`, it is something like this:
     ```
     table ip nat {
             chain prerouting {
                     type nat hook prerouting priority 0; policy accept;
             }
             chain postrouting {
                     type nat hook postrouting priority 100; policy accept;
                     oifname ++EXTERNAL_INTERFACE++ masquerade
             }
     }
     ```
   * when using `iptables`, that would be
     ```shell
     iptables -t nat -A POSTROUTING -o ++EXTERNAL_INTERACE++ -j MASQUERADE
     ```
   In both cases `++EXTERNAL_INTERFACE++` must be replaced with 
   the name of the external interface on your server.

3. activate forwarding
   * to try it out once, use
     ```shell
     echo "1" > /proc/sys/net/ipv4/ip_forward
     ```
   * for a persistent configuration, look at `/etc/sysctl.conf` and add
     ```
     net.ipv4.ip_forward=1
     ```

### client setup

1. install `wireguard`
   * for mobiles, install the app
   * otherwise see _server setup_ above

