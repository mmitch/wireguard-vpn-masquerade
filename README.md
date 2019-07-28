wireguard-vpn-masquerade
========================

[![Build Status](https://travis-ci.org/mmitch/wireguard-vpn-masquerade.svg?branch=master)](https://travis-ci.org/mmitch/wireguard-vpn-masquerade)
[![GPL 3+](https://img.shields.io/badge/license-GPL%203%2B-blue.svg)](http://www.gnu.org/licenses/gpl-3.0-standalone.html)

* wireguard-vpn-masquerade - generate a WireGuard configuration to allow multiple clients access to the internet via a server
* Copyright (C) 2019  Christian Garbs <mitch@cgarbs.de>
* Licensed under GNU GPL v3 (or later)
* Homepage: https://github.com/mmitch/wireguard-vpn-masquerade

### configuration

Be aware that both `wg-conf.server` and `wg-conf.clients` have been
added to `.gitignore` so that you don't accidentially check in your
configuration and reveal it to the world.

If you want to check in your configuration anyways, you can use `git add --force`.

Better yet: set up a local branch for your local configuration, remove
both files from `.gitignore` in that branch and check in your
configuration.  Then merge (or rebase) any official changes from the
master branch as needed.
