# Running a single-node L2 network based on OP-Stack without Docker

This instruction is actual for the following versions of OP-Stack repositories:
* [optimism](https://github.com/ethereum-optimism/optimism), tag: `op-node/v1.1.3`;
* [op-geth](https://github.com/ethereum-optimism/op-geth), tag: `v1.101106.0`.

*WARING:* The instruction below is for test purposes only and should not be used in production. At least you should protect private keys of accounts that are used to create and run the L2 network and appropriate contracts on the L1 network. It is strongly recommended to use hardware keys or special services to generate and use private keys like [OpenZeppelin Defender](https://docs.openzeppelin.com/defender/).



## 1. Prerequisites and notes

1.  Ensure that the following software is installed on your local machine:
    * `curl`;
    * `direnv`;
    * `foundry`;
    * `git`;
    * `go`;
    * `jq`;
    * `node`;
    * `make`;
    * `pnpm`.

    *IMPORTANT:* `direnv` should be [hooked](https://direnv.net/docs/hook.html) into your shell. E.g. for `bash` add line `eval "$(direnv hook bash)"` in file `~/.bashrc`.

2.  This instruction was checked on:
    * `Ubuntu  20.04 LTS`;
    * `curl`, `direnv`, `git`, `jq`, `make` installed as `sudo apt install -y curl direnv git jq make`;
    * `foundry 0.2.0` installed as `curl -L https://foundry.paradigm.xyz | bash; foundryup -v 1.20`;
    * `go 1.20` installed as `sudo apt update; wget https://go.dev/dl/go1.20.linux-amd64.tar.gz; tar xvzf go1.20.linux-amd64.tar.gz; sudo cp go/bin/go /usr/bin/go; sudo mv go /usr/lib; echo export GOROOT=/usr/lib/go >> ~/.bashrc`;
    * `node 16.19.1` installed via [nvm](https://github.com/nvm-sh/nvm);
    * `pnpm 8.6.12` installed as `sudo npm install -g pnpm@8.6.12`;


3.  Chose a name for your network configuration like:
    ```
    local-op-devnet
    ```
    This name will be used for some directory and file names.


4.  Chose the chain ID for your L2 network, like:
    ```
    3007
    ```


5.  Select the L1 network to use. It can be `Ethereum Mainnet`, `Polygon`, `Goerli`, or a locally running [Ganache](https://trufflesuite.com/ganache/) or locally running [Hardhat](https://hardhat.org/hardhat-network/docs/overview), or any other EVM-compatible network. You need to know the following parameters of the chosen L1 network:
    * the RPC URL;
    * the chain ID (network ID).

    This instruction was checked using `Ganache` as the L1 network with the RPC URL `http://localhost:8333` and the following `Ganache` settings:
    * IP4 address for accepted RPC connections: `0.0.0.0` (any address);
    * TCP port for connection: `8333`;
    * chain ID (network ID): `1337`;
    * automine: `false`;
    * mining block time (seconds): `2`;
    * autogenerate mnemonic: `false`;
    * accounts' mnemonic: Hardhat [test one](https://hardhat.org/hardhat-network/docs/reference#initial-state) `test test test test test test test test test test test junk`.


6.  This instruction assumes that all the necessary repositories will be cloned to your home directory (`~/`). If this is not the case, please replace `~` with the path to the required directory.



## 2. Clone, fix, and build repositories

*Tip:* Subsections 2.1 and 2.2 below can be executed in parallel.

### 2.1. Optimism Monorepo

1.  Clone [Optimism Monorepo](https://github.com/ethereum-optimism/optimism.git) and check out tag `op-node/v1.1.3`:
    ```bash
    cd ~
    git clone https://github.com/ethereum-optimism/optimism.git
    cd optimism
    git checkout op-node/v1.1.3
    ```


2.  Fix a bug by replacing `blockHash.String()` => `"latest"` in the file `./op-node/sources/eth_client.go`. There should be 2 replacements.


3.  If you are using [nvm](https://github.com/nvm-sh/nvm) replace the NodeJs version in the `./.nvmrc` file with the version you are currently using:
    ```bash
    echo "v16.19.1" > ./.nvmrc
    ```


4.  Build Optimism Monorepo:
    ```bash
    pnpm install
    make op-node op-batcher op-proposer
    pnpm build
    ```


### 2.2. Op-geth

1.  Clone another Optimism repository, `op-geth`: https://github.com/ethereum-optimism/op-geth.git, and check out tag `v1.101106.0`:
    ```bash
    cd ~
    git clone https://github.com/ethereum-optimism/op-geth.git
    cd op-geth
    git checkout v1.101106.0
    ```


2.  Build `op-geth`:
    ```bash
    make geth
    ```


## 3. Generate accounts and fund them

1.  Chose a mnemonic and generate 4 accounts using it: `Admin`, `Batcher`, `Proposer`, `Sequencer`.
    This instruction uses the Hardhat [test mnemonic](https://hardhat.org/hardhat-network/docs/reference#initial-state):
    ```
    Mnemonic: test test test test test test test test test test test junk

    Admin:
    Address:     0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
    Private Key: ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

    Proposer:
    Address:     0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    Private Key: 59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

    Batcher:
    Address:     0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
    Private Key: 5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

    Sequencer:
    Address:     0x90F79bf6EB2c4f870365E785982E1f101E93b906
    Private Key: 7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6
    ```


2.  Generate a random account for Batch Inbox:
    ```
    Batch Inbox (random):
    Address:     0xdC1b47B5bf778faA50C22a6f3E4566B3550E744C
    Private Key: a000000000000000000000000000000bc000000000000000000000000000000d
    ```


3.  Fund the first three accounts (`Admin`, `Batcher`, `Proposer`) with some native tokens in your L1 network. Recommended funding for Goerli:
    ```
    Admin — 2 ETH
    Proposer — 5 ETH
    Batcher — 10 ETH
    ```
    *Tip:* If you use Ganache with the settings provided in p.1.5, all the accounts are already funded at the Ganache startup.



## 4. Configure the network

1.  In the Optimism root directory, navigate to the `packages/contracts-bedrock` directory:
    ```bash
    cd ~/optimism/packages/contracts-bedrock
    ```


2.  Inside the `contracts-bedrock` directory, copy the environment file
    ```bash
    cp .envrc.example .envrc
    ```


3.  Fill out the environment variables in the `.envrc` file as follows:
    ```bash
    # RPC for the network to deploy to
    export ETH_RPC_URL=http://localhost:8333

    # Sets the deployer's key to match the first default hardhat account
    export PRIVATE_KEY=ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

    # Name of the deployed network
    export DEPLOYMENT_CONTEXT=local-op-devnet

    # Optional Tenderly details for a simulation link during deployment
    export TENDERLY_PROJECT=
    export TENDERLY_USERNAME=
    ```


4.  Pull the environment variables into context using `direnv`:
    ``` bash
    direnv allow .
    ```


5. Pick an L1 block to serve as the starting point for your L2 network. It's best to use a finalized L1 block as the starting block:
    ```bash
    cast block finalized --rpc-url $ETH_RPC_URL | grep -E "(timestamp|hash|number)"
    ```

    The result will look like:
    ```
    hash                 0xd2d3243998eba9c136fb14a9ecc40805cec567d3a43bc1f396498a687c105a12
    number               205
    timestamp            1693216327
    ```


6.  Create a configuration JSON file in the `deploy-config` subdirectory like:
    ```bash
    touch deploy-config/local-op-devnet.json
    ```

    Fill the new file like:
    ```json
    {
      "numDeployConfirmations": 1,

      "finalSystemOwner": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      "portalGuardian": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",

      "l1StartingBlockTag": "0xd2d3243998eba9c136fb14a9ecc40805cec567d3a43bc1f396498a687c105a12",

      "l1ChainID": 1337,
      "l2ChainID": 3007,
      "l2BlockTime": 1,

      "maxSequencerDrift": 600,
      "sequencerWindowSize": 3600,
      "channelTimeout": 300,

      "p2pSequencerAddress": "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
      "batchInboxAddress": "0xdC1b47B5bf778faA50C22a6f3E4566B3550E744C",
      "batchSenderAddress": "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",

      "l2OutputOracleSubmissionInterval": 120,
      "l2OutputOracleStartingBlockNumber": 0,
      "l2OutputOracleStartingTimestamp": 1693216327,

      "l2OutputOracleProposer": "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
      "l2OutputOracleChallenger": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",

      "finalizationPeriodSeconds": 12,

      "proxyAdminOwner": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      "baseFeeVaultRecipient": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      "l1FeeVaultRecipient": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      "sequencerFeeVaultRecipient": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",

      "baseFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
      "l1FeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
      "sequencerFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
      "baseFeeVaultWithdrawalNetwork": 0,
      "l1FeeVaultWithdrawalNetwork": 0,
      "sequencerFeeVaultWithdrawalNetwork": 0,

      "gasPriceOracleOverhead": 1,
      "gasPriceOracleScalar": 1,

      "enableGovernance": true,
      "governanceTokenSymbol": "OP",
      "governanceTokenName": "Optimism",
      "governanceTokenOwner": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",

      "l2GenesisBlockGasLimit": "0x3fffffff",
      "l2GenesisBlockBaseFeePerGas": "0x1",
      "l2GenesisRegolithTimeOffset": "0x0",

      "eip1559Denominator": 50,
      "eip1559Elasticity": 10,

      "fundDevAccounts": true
    }

    ```

    The default values can be found in the `packages/contracts-bedrock/deploy-config/getting-started.json` file of Optimism Monorepo.

    Notes about the modified fields above (from top to bottom):
    * `finalSystemOwner`, `portalGuardian`, `controller`, `l2OutputOracleChallenger`, `proxyAdminOwner`, `baseFeeVaultRecipient`, `l1FeeVaultRecipient`, `sequencerFeeVaultRecipient`, `governanceTokenOwner` -- the address of account `Admin` chosen in [section 3](#3-generate-accounts-and-fund-them);
    * `l1StartingBlockTag` -- the hash of the starting L1 block obtained in the previous step;
    * `l1ChainID` -- the chain ID of the selected L1 network;
    * `l2ChainID` -- the chain ID of the future L2 network chosen in [section 1](#1-prerequisites-and-notes);
    * `l2BlockTime` -- the block time of the future L2 network in seconds;
    * `p2pSequencerAddress` -- the address of account `Sequencer` chosen in [section 3](#3-generate-accounts-and-fund-them);
    * `batchInboxAddress` -- the address of account `Batch Inbox` chosen in [section 3](#3-generate-accounts-and-fund-them);
    * `batchSenderAddress` -- the address of account `Batcher` chosen in [section 3](#3-generate-accounts-and-fund-them);
    * `l2OutputOracleStartingTimestamp` -- the timestamp of the starting L1 block obtained in the previous step;
    * `l2OutputOracleProposer` -- the address of account `Proposer` chosen in [section 3](#3-generate-accounts-and-fund-them);
    * `gasPriceOracleOverhead`, `gasPriceOracleScalar` -- gas price related fields, they were set to the minimum possible value (zero is not allowed here);
    * `l2GenesisBlockGasLimit` -- the initial block gas limit, a very large but theoretically safe value is set here.
    * `fundDevAccounts` -- the "true" value of this field will cause large initial balances of native tokens for some accounts in the future L2 network, including [Hardhat test accounts](https://hardhat.org/hardhat-network/docs/reference#initial-state).



## 5. Deploy the L1 contracts

1.  Navigate to the `packages/contracts-bedrock` directory within the Optimism Monorepo:
    ```bash
    cd ~/optimism/packages/contracts-bedrock
    ```


2.  Create a deployment directory like:
    ```bash
    mkdir deployments/$DEPLOYMENT_CONTEXT
    ```


3.  Deploy the L1 smart contracts by calling
    ```bash
    forge script scripts/Deploy.s.sol:Deploy --private-key $PRIVATE_KEY --broadcast --rpc-url $ETH_RPC_URL --slow
    ```
    and then
    ```bash
    forge script scripts/Deploy.s.sol:Deploy --sig 'sync()' --private-key $PRIVATE_KEY --broadcast --rpc-url $ETH_RPC_URL
    ```

    Contract deployment can take up to 15 minutes. Please wait for all smart contracts to be fully deployed before proceeding to the next step.

    Flag `--slow` in the first command is needed to be sure that transactions are minted one by one, not in a single block.


4.  Retrieve the address of the newly deployed `L2OutputOracleProxy` smart contract in the L1 network:
    ```bash
    cat deployments/local-op-devnet/L2OutputOracleProxy.json | grep -m 1 \"address\":
    ```

    The result will look like:
    ```
    "address": "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9",
    ```

   5.  Retrieve the address of the newly deployed `L1StandardBridgeProxy` smart contract in the L1 network:
       ```bash
       cat deployments/local-op-devnet/L1StandardBridgeProxy.json | grep -m 1 \"address\":
       ```

       The result will look like:
       ```
       "address": "0x0165878A594ca255338adfa4d48449f69242Eb8F",
       ```



## 6. Generate L2 configuration files

1.  Create the `op_env.sh` file with environment variables like:
    ```bash
    touch ~/op_env.sh
    ```


2.  Populate the `op_env.sh` file with data obtained from the previous sections:
    ```bash
    #!/bin/bash
    export CW_OP_SEQUENCER_KEY="7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6"
    export CW_OP_SEQUENCER_ADDRESS="0x90F79bf6EB2c4f870365E785982E1f101E93b906"
    export CW_OP_L1_RPC_URL="http://localhost:8333"
    export CW_OP_L1_RPC_KIND="basic" # Available options are: alchemy, quicknode, parity, nethermind, debug_geth, erigon, basic, and any
    export CW_OP_BATCHER_KEY="5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a"
    export CW_OP_PROPOSER_KEY="59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
    export CW_OP_L2OOP_ADDRESS="0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9" # Address of the "L2OutputOracleProxy" contract on L1
    export CW_OP_L1SBP_ADDRESS="0x0165878A594ca255338adfa4d48449f69242Eb8F" # Address of the "L1StandardBridgeProxy" contract on L1
    export CW_OP_CONFIG_NAME="local-op-devnet"
    export CW_OP_L2_NETWORK_ID=3007
    ```


3.  Head over to the `op-node` directory:
    ```bash
    cd ~/optimism/op-node
    ```


4.  Generate the genesis and rollup configuration JSON files:
    ```bash
    . ~/op_env.sh # Load environment variables
    go run cmd/main.go genesis l2 \
    --deploy-config ../packages/contracts-bedrock/deploy-config/$CW_OP_CONFIG_NAME.json \
    --deployment-dir ../packages/contracts-bedrock/deployments/$CW_OP_CONFIG_NAME/ \
    --outfile.l2 genesis.json \
    --outfile.rollup rollup.json \
    --l1-rpc $CW_OP_L1_RPC_URL
    ```
    You should find the `genesis.json` and `rollup.json` files within the `op-node` directory.


5.  You have now prepared the L1 network and obtained all the necessary files (`op_env.sh`, `genesis.json`, `rollup.json`) to initialize and run your L2 network.




## 7. Initialize L2

1.  If you skipped previous sections and obtained the configuration files (`genesis.json`, `rollup.json`, `op_env.sh`) from someone else:
    * put files `genesis.json`, `rollup.json` into the `~/optimism/op-node/` directory;
    * put file `op_env.sh` into your home directory.


2.  Head over to the op-node package:
    ```bash
    cd ~/optimism/op-node
    ```


3.  Generate the `jwt.txt` file (used for communication between different apps) with the following command:
    ```bash
    openssl rand -hex 32 > jwt.txt
    ```


4.  Copy files `genesis.json` and `jwt.txt` into `op-geth` so they can be used to initialize and run `op-geth` in just a minute:
    ```bash
    cp genesis.json ~/op-geth
    cp jwt.txt ~/op-geth
    ```


5.  Head over to the `op-geth` repository directory and initialize it:
    ```bash
    cd ~/op-geth # Switch to the needed directory
    . ~/op_env.sh  # Load environment variables 
    rm -rf datadir # Remove the previous data
    mkdir datadir
    build/bin/geth init --datadir=datadir genesis.json
    ```



## 8. Run and manage the L2 node software

1.  Run `op-geth` from the appropriate directory:
    ```bash
    cd ~/op-geth  # Switch to the needed directory
    . ~/op_env.sh  # Load environment variables
    ./build/bin/geth \
      --datadir=./datadir \
      --http \
      --http.corsdomain="*" \
      --http.vhosts="*" \
      --http.addr=0.0.0.0 \
      --http.port=8545 \
      --http.api=web3,debug,eth,txpool,net,engine \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.port=8546 \
      --ws.origins="*" \
      --ws.api=debug,eth,txpool,net,engine \
      --syncmode=full \
      --gcmode=archive \
      --nodiscover \
      --maxpeers=0 \
      --networkid=$CW_OP_L2_NETWORK_ID \
      --authrpc.vhosts="*" \
      --authrpc.addr=0.0.0.0 \
      --authrpc.port=8551 \
      --authrpc.jwtsecret=./jwt.txt \
      --rollup.disabletxpoolgossip=true
    ```

    If you got an error stop the app and try to execute steps of section [7](#7-initialize-l2) again. Then run `op-geth` again.


2.  Open another terminal and run `op-node` from the appropriate directory:
    ```bash
    cd ~/optimism/op-node # Switch to the needed directory
    . ~/op_env.sh # Load environment variables 
    ./bin/op-node \
      --l2=http://localhost:8551 \
      --l2.jwt-secret=./jwt.txt \
      --sequencer.enabled \
      --sequencer.l1-confs=3 \
      --verifier.l1-confs=3 \
      --rollup.config=./rollup.json \
      --rpc.addr=0.0.0.0 \
      --rpc.port=8547 \
      --rpc.enable-admin \
      --p2p.disable \
      --p2p.sequencer.key=$CW_OP_SEQUENCER_KEY \
      --l1=$CW_OP_L1_RPC_URL \
      --l1.rpckind=$CW_OP_L1_RPC_KIND
    ```


3.  Open another terminal and run `op-batcher` from the appropriate directory, like:
    ```bash
    cd ~/optimism/op-batcher # Switch to the needed directory
    . ~/op_env.sh # Load environment variables 
    ./bin/op-batcher \
        --l2-eth-rpc=http://localhost:8545 \
        --rollup-rpc=http://localhost:8547 \
        --poll-interval=1s \
        --sub-safety-margin=6 \
        --num-confirmations=1 \
        --safe-abort-nonce-too-low-count=3 \
        --resubmission-timeout=30s \
        --rpc.addr=0.0.0.0 \
        --rpc.port=8548 \
        --rpc.enable-admin \
        --l1-eth-rpc=$CW_OP_L1_RPC_URL \
        --private-key=$CW_OP_BATCHER_KEY \
        --max-channel-duration=15
    ```
    *Tip:* The `--max-channel-duration=n` setting tells the batcher to write all the data to L1 every `n` L1 blocks. When it is low, transactions are written to L1 frequently, withdrawals are quick, and other nodes can synchronize from L1 fast. When it is high, transactions are written to L1 less frequently, and the batcher spends less ETH. 


4.  Open another terminal and run `op-proposer` from the appropriate directory, like:
    ```bash
    cd ~/optimism/op-proposer # Switch to the needed directory
    . ~/op_env.sh # Load env variables 
    ./bin/op-proposer \
        --poll-interval 12s \
        --rpc.port 8560 \
        --rollup-rpc http://localhost:8547 \
        --l2oo-address $CW_OP_L2OOP_ADDRESS \
        --private-key $CW_OP_PROPOSER_KEY \
        --l1-eth-rpc $CW_OP_L1_RPC_URL
    ```

5.  To stop the network just terminate the applications run previously.


6.  To reinitialize the network stop it and repeat steps of section [7](#7-initialize-l2) again.  



## 9. Use the newly created L2 network

1.  The URL to access RPC API endpoint of the network is: `http://localhost:8545`.


2.  You can verify that blocks are being produced with the following script:
    ```bash
    RPC_URL="http://localhost:8545"
    REQUEST_DATA='{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}'
    curl -H "Content-Type: application/json" -d "$REQUEST_DATA" "$RPC_URL" | jq
    ```


3.  If you previously set `"fundDevAccounts": true` in the section [4](#4-configure-the-network) you will have [Hardhat test accounts](https://hardhat.org/hardhat-network/docs/reference#initial-state) with a generous amount of native tokens (ETH) in the newly created L2 network to use.

    Otherwise, to obtain some ETH in an L2 account, you will need to transfer the desired amount of ETH from that account to the `L1StandardBridgeProxy` contract within the L1 network and wait for the amount to appear in the L2 network. You can find the contract's address in the `op_env.sh` file.
