# Creating Docker images of the OP-stack node apps

This instruction is actual for the following versions of OP-Stack repositories:
* [optimism](https://github.com/ethereum-optimism/optimism), tag: `op-node/v1.1.3`;
* [op-geth](https://github.com/ethereum-optimism/op-geth), tag: `v1.101106.0`.

## 1. Prerequisites and Notes

1.  Ensure the following software is installed:
    * `docker`


2.  This instruction was checked on:
    * `Ubuntu 20.04 LTS`;
    * `docker version 24.0.5, build ced0996` installed according to the [official instructions](https://docs.docker.com/desktop/install/ubuntu/)


3.  Choose a path, name, and tag for the future images, like:
    * <some_image_path>/op-node:v1.1.3;
    * <some_image_path>/op-batcher:v1.1.3;
    * <some_image_path>/op-proposer:v1.1.3;
    * <some_image_path>/op-geth:v1.101106.0.


4. The instruction assumes that all the necessary repositories will be cloned to your home directory (`~/`). If this is not the case, please replace `~` with the path to the required directory.



## 2. Clone, fix, and build repositories

Follow the appropriate section of the instruction [here](./single-node-no-docker.md).




## 3. Create images

1.  Head over to the root directory of this repository, like:
    ```bash
    cd ~/op-stack-devnet
    ```

2.  Copy Docker files from the [dockerfiles](./dockerfiles) directory of this repository to the appropriate directories of `optimism` and `op-geth` repositories, like:
    ```bash
    cp ./dockerfiles/op-node/Dockerfile.with_utils ~/optimism/op-node/
    cp ./dockerfiles/op-batcher/Dockerfile.with_utils ~/optimism/op-batcher/
    cp ./dockerfiles/op-proposer/Dockerfile.with_utils ~/optimism/op-proposer/
    cp ./dockerfiles/op-geth/Dockerfile.with_utils ~/op-geth/
    ```


3. Switch to the Optimism Monorepo directory:
    ```bash
    cd ~/optimism/
    ```


4.  Build the image for apps `op-node`, `op-batcher`, `op-proposer`, like:
    ```bash
    sudo docker build --network=host -f op-node/Dockerfile.with_utils -t <some_image_path>/op-node:v1.1.3 .
    sudo docker build --network=host -f op-batcher/Dockerfile.with_utils -t <some_image_path>/op-batcher:v1.1.3 .
    sudo docker build --network=host -f op-proposer/Dockerfile.with_utils -t <some_image_path>/op-proposer:v1.1.3 .
    ```


5.  If needed, push the built images to a remote repository, like:
    ```bash
    sudo docker image push <some_image_path>/op-node:v1.1.3
    sudo docker image push <some_image_path>/op-batcher:v1.1.3
    sudo docker image push <some_image_path>/op-proposer:v1.1.3
    ```


6.  Switch to the `op-geth` repository:
    ```bash
    cd ~/op-geth/
    ```


7.  Build the image of the `op-geth` app, like:
    ```bash
    sudo docker build --network=host -f Dockerfile.with_utils -t test/op-geth:v1.101106.0 .
    ```


8.  If needed, push the built image to a remote repository like:
    ```bash
    sudo docker image push <some_image_path>/op-geth:v1.101106.0
    ```
