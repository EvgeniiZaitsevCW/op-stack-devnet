#!/bin/bash

set -euo pipefail # see https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425

sudo rm -fr ./node-01-main/credentials/
sudo rm -fr ./node-01-main/datadir/
sudo rm -fr ./node-01-main/p2p/

sudo rm -fr ./node-02/credentials/
sudo rm -fr ./node-02/datadir/
sudo rm -fr ./node-02/p2p/

sudo rm -fr ./node-03/credentials/
sudo rm -fr ./node-03/datadir/
sudo rm -fr ./node-03/p2p/