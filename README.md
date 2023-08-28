# OP-Stack Development Network

This repository contains instructions and scripts to run your own development blockchain based on [OP-Stack](https://stack.optimism.io/).

The blockchain will be operated on a network consisting of one or more nodes, serving as a layer 2 (L2) solution backed by another blockchain, which acts as layer 1 (L1).

The instructions provided in this repository draw heavily from the [OP-Stack Getting Started Guide](https://stack.optimism.io/docs/build/getting-started/). However, we have included several tips based on our practical experience and solutions to found issues.

These instructions are actual for the following versions of OP-Stack repositories:
* [optimism](https://github.com/ethereum-optimism/optimism), tag: `op-node/v1.1.3`;
* [op-geth](https://github.com/ethereum-optimism/op-geth), tag: `v1.101106.0`.

For alternative versions, please refer to the other branches and tags available in this repository.

Available options:
1. [Running a single-node network without Docker](./single-node-no-docker.md): This option provides a fully autonomous startup.
2. [Running a three-node network using Docker](./three-node-using-docker.md): This option requires specific files as outlined in option 1.
