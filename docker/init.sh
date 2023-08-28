#!/bin/bash

set -euo pipefail # see https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425

cd node-01-main/
pwd
echo "Init node 01:"
sudo ./init.sh
echo ""

cd ../node-02/
pwd
echo "Init node 02:"
sudo ./init.sh
echo ""

cd ../node-03/
pwd
echo "Init node 03:"
sudo ./init.sh
