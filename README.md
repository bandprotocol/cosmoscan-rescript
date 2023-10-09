<p>&nbsp;</p>
<p align="center">

<img src="bandprotocol_logo.svg" width=500>

</p>

<p align="center">
BandChain - Decentralized Data Delivery Network<br/><br/>
</p>

## What is Cosmoscan

Cosmoscan is block explorer for BandChain network

## How to Run on local machine

### generate graphql_schema.json

```sh
npx get-graphql-schema https://graphql-lt6.bandchain.org/v1/graphql -j > graphql_schema.json
```

### installed the dependencies

npx get-graphql-schema https://graphql-lm.bandchain.org/v1/graphql -j > graphql_schema.json

# installed the dependencies

yarn

````

### run the complier

```sh
yarn start
````

### start web server

```sh
# TESTNET
# (in another tab) Run the development server
RPC_URL=https://laozi-testnet6.bandchain.org/api GRAPHQL_URL=graphql-lt6.bandchain.org/v1/graphql LAMBDA_URL=https://asia-southeast1-testnet-instances.cloudfunctions.net/executer-cosmoscan GRPC=https://laozi-testnet6.bandchain.org/grpc-web FAUCET_URL=https://laozi-testnet6.bandchain.org/faucet yarn server

# DEVNET
# (in another tab) Run the development server
RPC_URL=https://devnet.d3n.xyz/rpc/ GRAPHQL_URL=devnet.d3n.xyz/hasura/v1/graphql LAMBDA_URL=https://asia-southeast2-band-playground.cloudfunctions.net/test-runtime-executor GRPC=https://devnet.d3n.xyz/grpc/ FAUCET_URL=https://devnet.d3n.xyz/faucet/request yarn server

# HACKATHON
RPC_URL=https://laozi-hackathon.bandchain.org/api GRAPHQL_URL=rpc.laozi-hackathon.bandchain.org/hasura/v1/graphql LAMBDA_URL=https://asia-southeast1-testnet-instances.cloudfunctions.net/executer-cosmoscan GRPC=https://laozi-hackathon.bandchain.org/grpc-web/ FAUCET_URL=https://laozi-hackathon.bandchain.org/faucet yarn server

# MAINNET
# (in another tab) Run the development server
RPC_URL=https://laozi1.bandchain.org/api GRAPHQL_URL=graphql-lm.bandchain.org/v1/graphql LAMBDA_URL=https://asia-southeast1-testnet-instances.cloudfunctions.net/executer-cosmoscan GRPC=https://laozi1.bandchain.org/grpc-web yarn server

# run test
GRPC=https://laozi-testnet6.bandchain.org/grpc-web yarn test

```
