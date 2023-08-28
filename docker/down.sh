#!/bin/bash

set -euo pipefail # see https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425

cd node-03
pwd
echo "Down node 3:"
sudo ./down.sh
echo ""

cd ../node-02
pwd
echo "Down node 2:"
sudo ./down.sh
echo ""

cd ../node-01-main
pwd
echo "Down node 1:"
sudo ./down.sh
echo ""