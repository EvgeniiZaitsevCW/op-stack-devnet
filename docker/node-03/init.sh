#!/bin/bash

set -euo pipefail # see https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425

source ../prerequisite/envfile # use environment variables

# Prepare the needed credentials 
mkdir credentials
openssl rand -hex 32 > credentials/jwt.txt
cp ../prerequisite/genesis.json credentials/
cp ../prerequisite/rollup.json credentials/

echo $CW_OP_P2P_PRIVATE_KEY_NODE3 > credentials/opnode_p2p_priv.txt

# Prepare other needed directories
mkdir datadir
mkdir -p p2p/opnode_discovery_db/
mkdir -p p2p/opnode_peerstore_db/

# Prepare the account and init the node database
sudo docker run -it -v ./credentials:/credentials -v ./datadir:/datadir --name op_geth_init $CW_OP_IMAGE_OP_GETH geth init --datadir=/datadir /credentials/genesis.json

# Removed the exited docker containers that have been run above
sudo docker rm op_geth_init
