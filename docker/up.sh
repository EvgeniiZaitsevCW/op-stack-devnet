#!/bin/bash

set -euo pipefail # see https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425

cd node-01-main
pwd
echo "Up node 1:"
sudo ./up.sh
echo ""

cd ../node-02
pwd
echo "Up node 2:"
sudo ./up.sh
echo ""

cd ../node-03
pwd
echo "Up node 3:"
sudo ./up.sh
