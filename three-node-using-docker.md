# Running a three-node L2 network based on OP-Stack using Docker

This instruction is actual for the following versions of OP-Stack repositories:
* [optimism](https://github.com/ethereum-optimism/optimism), tag: `op-node/v1.1.3`;
* [op-geth](https://github.com/ethereum-optimism/op-geth), tag: `v1.101106.0`.

*WARING:* The instruction below is for test purposes only and it should not be used in production. At least you should protect private keys of accounts that are used to create and run the L2 network and appropriate contracts on L1 network. It is strongly recommended to use hardware keys or special services to generate and use private keys (like OpenZeppelin Defender).

## 1. Prerequisites and notes

1.  The following software should be installed:
    * `docker`;
    * `jq`.


2.  This instruction was checked on:
    * `Ubuntu  20.04 LTS`;
    * `docker version 24.0.5, build ced0996` installed according to the [official instructions](https://docs.docker.com/desktop/install/ubuntu/);
    * `jq` installed as `sudo apt install -y jq`.


3.  *IMPORTANT!* The following conditions must be met:
    * a. The network that is used as L1 is up and running.
    * b. All the needed L1 contracts have been deployed in it.
    * c. You have the following files to run the L2 network:
        * `op_env.sh` contains main settings of the network;
        * `genesis.json` contains the genesis information of the L2 network;
        * `rollup.json` contains the configuration of the L2 network.
    * d. No other L2 nodes with the same set of `genesis.json` and `rollup.json` files are running. 

    If one of the conditions is not met follow the instruction [here](./single-node-no-docker.md). Execute all the steps in order until you meet all the mentioned conditions.


4.  The following Docker images are used in this instruction:
    * [zesgen/op-node:v1.1.3](https://hub.docker.com/layers/zesgen/op-node/v1.1.3/images/sha256-5974f4becb19ec290bd2474ad6abe12d32c80ab805ec351e5f3e34cff5c94659?context=explore);
    * [zesgen/op-batcher:v1.1.3](https://hub.docker.com/layers/zesgen/op-batcher/v1.1.3/images/sha256-c7907e0e9d69b3ed81873bc714999109b93747caf4302710c62b4e53ed4625fc?context=explore);
    * [zesgen/op-proposer:v1.1.3](https://hub.docker.com/layers/zesgen/op-proposer/v1.1.3/images/sha256-47fa1bc0d890a40fca60bd4bf82021a25eed284b98c558f34366e26b6114582d?context=explore).
    * [zesgen/op-geth:v1.101106.0](https://hub.docker.com/layers/zesgen/op-geth/v1.101106.0/images/sha256-27cff53792ed8a084b2555e0465f605be62407737aaac0d36261c847d8fbbf9e?context=explore);

    If you want to use your own images created from scratch follow the instruction [here](./docker-images.md).


5.  Be sure subnet `192.168.10.0/24` is not used on your local machine and there is no Docker network named `op-local`.


6.  All the docker commands in this instruction are executed from the superuser using the `sudo` prefix.



## 2. Generate P2P keys and IDs for nodes

1.  Generate or select some 32-bit (64 hex chars) private keys, like:
    ```
    d01aba27820aeeb60ead4aed481eb30107426c18fd2e3133f1abac8fcd570d01
    d02aba27820aeeb60ead4aed481eb30107426c18fd2e3133f1abac8fcd570d02
    d03aba27820aeeb60ead4aed481eb30107426c18fd2e3133f1abac8fcd570d03
    ```
    Those keys are needed to organize P2P communications between nodes of the future L2 network.


2.  For each private key generate the appropriate P2P ID with the following commands:
    ```bash
    sudo docker run -itd --name op_node_p2p_generation zesgen/op-node:v1.1.3
    sudo docker exec op_node_p2p_generation sh -c 'echo "<put_first_private_key_here>" | op-node p2p priv2id'
    sudo docker exec op_node_p2p_generation sh -c 'echo "<put_second_private_key_here>" | op-node p2p priv2id'
    sudo docker exec op_node_p2p_generation sh -c 'echo "<put_third_private_key_here>" | op-node p2p priv2id'
    sudo docker rm -f op_node_p2p_generation
    ```
        
    With the private keys from above you'll get the following IDs:
    ```
    16Uiu2HAmFj2KVQEQQtgURtJKSWUmCgRsgeGs4piWP1YCREe64VLZ
    16Uiu2HAmMgZfTriZqMDDrHCUAibcaKyv8ByV8qWuSFXLpss8Rjxb
    16Uiu2HAmDKq53ypBfPNfAnwKvKwxXWjmVZ2viQahhWaaGntEqtPC
    ```
    The IDs are needed to organize P2P communications between nodes of the future L2 network. 



## 3. Configure the infrastructure

1.  Head over to the [docker/prerequisite](./docker/prerequisite) directory of this repository:
    ```bash
    cd ./docker/prerequisite
    ```
    This directory contains files with settings of the future L2 network.


2.  Replace files `genesis.json` and `rollup.json` with ones your have.


3.  Open file [envfile](./docker/prerequisite/envfile). Replace its content with parameters form the `op_env.sh` file you have and data you got previously, like:
    ```bash
    #!/bin/bash
    # Main parameters
    export CW_OP_SEQUENCER_KEY="7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6"
    export CW_OP_SEQUENCER_ADDRESS="0x90F79bf6EB2c4f870365E785982E1f101E93b906"
    export CW_OP_L1_RPC_URL="http://dockerhost:8333"
    export CW_OP_L1_RPC_KIND="basic" # Available options are: alchemy, quicknode, parity, nethermind, debug_geth, erigon, basic, and any
    export CW_OP_BATCHER_KEY="5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a"
    export CW_OP_PROPOSER_KEY="59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
    export CW_OP_L2OOP_ADDRESS="0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9" # Address of the "L2OutputOracleProxy" contract on L1
    export CW_OP_L1SBP_ADDRESS="0x0165878A594ca255338adfa4d48449f69242Eb8F" # Address of the "L1StandardBridgeProxy" contract on L1
    export CW_OP_CONFIG_NAME="local-op-devnet"
    export CW_OP_L2_NETWORK_ID=3007
    
    # Docker images for node apps
    export CW_OP_IMAGE_OP_NODE="zesgen/op-node:v1.1.3"
    export CW_OP_IMAGE_OP_BATCHER="zesgen/op-batcher:v1.1.3"
    export CW_OP_IMAGE_OP_PROPOSER="zesgen/op-proposer:v1.1.3"
    export CW_OP_IMAGE_OP_GETH="zesgen/op-geth:v1.101106.0"
    
    # P2P parameters
    export CW_OP_P2P_PRIVATE_KEY_NODE1="d01aba27820aeeb60ead4aed481eb30107426c18fd2e3133f1abac8fcd570d01"
    export CW_OP_P2P_PRIVATE_KEY_NODE2="d02aba27820aeeb60ead4aed481eb30107426c18fd2e3133f1abac8fcd570d02"
    export CW_OP_P2P_PRIVATE_KEY_NODE3="d03aba27820aeeb60ead4aed481eb30107426c18fd2e3133f1abac8fcd570d03"
    export CW_OP_P2P_ID_NODE1="16Uiu2HAmFj2KVQEQQtgURtJKSWUmCgRsgeGs4piWP1YCREe64VLZ"
    export CW_OP_P2P_ID_NODE2="16Uiu2HAmMgZfTriZqMDDrHCUAibcaKyv8ByV8qWuSFXLpss8Rjxb"
    export CW_OP_P2P_ID_NODE3="16Uiu2HAmDKq53ypBfPNfAnwKvKwxXWjmVZ2viQahhWaaGntEqtPC"
    ```
    
    *Tip:* If your use the L1 network running locally on your machine do not forget to replace the `CW_OP_L1_RPC_URL` env variable from `localhost` to `dockerhost`. Otherwise, Docker containers will not be able to access you machine.



## 4. Run and manage containers

1.  Head over to the [docker](./docker) directory of this repository:
    ```bash
    cd ./docker
    ```
    The subdirectories like `node-0x...` of this directory contains `docker-compose` files and scripts to run Docker containers with node apps of the future L2 network. 


2.  If you want to change or completely remove the forwarding ports from the containers to your local machine edit `ports` sections in all `docker-compose.yaml` files in the directory.

    <details>
    <summary>The current set of forwarded ports is in this hidden section</summary>
    
    ```yaml
    node1:
      op-geth:
        ports:
          - "8551" # Authenticated RPC, to communicate with the `op-node`
          - "8545" # RPC
          - "8546" # WebSocket
      op-node:
        ports:
          - "8547" # Rollup RPC, to execute special commands of the node
      op-batcher:
        ports:
          - "8548" # Batcher RPC, to safe stop and maybe some other commands
      op-proposer:
        ports:
          - "8560" # Proposer RPC, just for possible future usage
       
    node2:
      op-geth:
        ports:
          - "8571" # Authenticated RPC, to communicate with the `op-node`
          - "8565" # RPC
          - "8566" # WebSocket
      op-node:
        ports:
          - "8567" # Rollup RPC, to execute special commands of the node
    
    node3:
      op-geth:
        ports:
          - "8581" # Authenticated RPC, to communicate with the `op-node`
          - "8575" # RPC
          - "8576" # WebSocket
      op-node:
        ports:
          - "8577" # Rollup RPC, to execute special commands of the node
    ```
    </details>


3.  Execute the [init.sh](./docker/init.sh) script to initialize all the needed files to run the containers:
    ```bash
    sudo ./init.sh
    ```
    Be sure there is no warnings and errors during its execution.


4.  Execute the [up.sh](./docker/up.sh) script to up and run all the containers:
    ```bash
    sudo ./up.sh
    ```


5.  Be sure that all containers are working using the command:
    ```bash
    sudo docker ps -a --format 'table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.RunningFor}}\t{{.Status}}\t{{.Names}}'
    ```
    You should see something like:
    ```
    CONTAINER ID   IMAGE                        COMMAND                  CREATED         STATUS         NAMES
    c9eb5a971c9f   zesgen/op-node:v1.1.3        "op-node --l2=http:/…"   4 seconds ago   Up 3 seconds   node3-op-node
    76101d0f51c3   zesgen/op-geth:v1.101106.0   "geth --datadir=/dat…"   4 seconds ago   Up 3 seconds   node3-op-geth
    dfbae494d754   zesgen/op-node:v1.1.3        "op-node --l2=http:/…"   5 seconds ago   Up 4 seconds   node2-op-node
    7c665f62e6c4   zesgen/op-geth:v1.101106.0   "geth --datadir=/dat…"   5 seconds ago   Up 4 seconds   node2-op-geth
    25bdf7981473   zesgen/op-batcher:v1.1.3     "op-batcher --l2-eth…"   6 seconds ago   Up 4 seconds   node1-op-batcher
    1b26882da506   zesgen/op-proposer:v1.1.3    "op-proposer --poll-…"   6 seconds ago   Up 4 seconds   node1-op-proposer
    9c9128d42515   zesgen/op-node:v1.1.3        "op-node --l2=http:/…"   6 seconds ago   Up 5 seconds   node1-op-node
    4f3b983a53e0   zesgen/op-geth:v1.101106.0   "geth --datadir=/dat…"   6 seconds ago   Up 5 seconds   node1-op-geth
    ```
    If some containers are stopped, just repeat the previous step again. Usually `proposer` or `batcher` might not start the first time due to delays in other containers.
    
    If after 3 tries some containers are still stopped (especially `op-node` or `op-geth`), explorer their logs using the appropriate docker command, like:
    ```bash
    sudo docker logs node1-op-node
    ```


7.  To stop and remove all the containers (but not their data) execute the [down.sh](./docker/down.sh) script:
    ```bash
    sudo ./down.sh
    ```
    After that, if you execute the [up.sh](./docker/up.sh) script again the network will start with the already existing blockchain history (minted blocks and transactions).


8.  To delete the data of all containers after stopping them execute the [clear.sh](./docker/clear.sh) script:
    ```bash
    sudo ./clear.sh
    ```
    After that, you'll have to execute the [init.sh](./docker/init.sh) script before running the network again. In that case the network will start from scratch (without previously minted blocks and transactions, except the genesis block).



## 9. Use the newly created L2 network

1.  The nodes of the network can be accessed through their Docker internal IP addresses and ports or through the forwarded ports if you configured them (see the `docker-compose.yml` files). E.g. the default RPC URL of nodes are listed in the table bellow:

    | Node | Container | In-container RPC URL | Forwarded port RPC URL |
    |---|---|---|---|
    | 1 | node1-op-node | http://192.168.10.11:8545 | http://127.0.0.1:8545|
    | 2 | node2-op-node | http://192.168.10.21:8545 | http://127.0.0.1:8565|
    | 3 | node3-op-node | http://192.168.10.31:8545 | http://127.0.0.1:8575|

2.  You can check that blocks are being produced and can be accessed through each node with the following script:
    ```bash
    REQUEST_DATA='{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}'
    RPC_URL="http://192.168.10.11:8545"
    echo "RPC URL: $RPC_URL"
    curl -H "Content-Type: application/json" -d "$REQUEST_DATA" "$RPC_URL" | jq
    
    RPC_URL="http://192.168.10.21:8545"
    echo "RPC URL: $RPC_URL"
    curl -H "Content-Type: application/json" -d "$REQUEST_DATA" "$RPC_URL" | jq
    
    RPC_URL="http://192.168.10.31:8545"
    echo "RPC URL: $RPC_URL"
    curl -H "Content-Type: application/json" -d "$REQUEST_DATA" "$RPC_URL" | jq
    ```

    The last block number of all three nodes should differ by no more than 1. 


3.  Information about getting native tokens (ETH) inside the newly created L2 network see [here](single-node-no-docker.md#9-use-the-newly-created-l2-network).
