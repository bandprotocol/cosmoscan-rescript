```sh

# generate graphql_schema.json
npx get-graphql-schema https://graphql-lt6.bandchain.org/v1/graphql -j > graphql_schema.json

# installed the dependencies
yarn

## run the complier
yarn start

# TESTNET
# (in another tab) Run the development server
RPC_URL=https://laozi-testnet6.bandchain.org/api GRAPHQL_URL=graphql-lt6.bandchain.org/v1/graphql LAMBDA_URL=https://asia-southeast1-testnet-instances.cloudfunctions.net/executer-cosmoscan GRPC=https://laozi-testnet6.bandchain.org/grpc-web FAUCET_URL=https://laozi-testnet6.bandchain.org/faucet yarn server

# DEVNET
# (in another tab) Run the development server
RPC_URL=https://devnet.d3n.xyz/rpc/ GRAPHQL_URL=devnet.d3n.xyz/hasura/v1/graphql LAMBDA_URL=https://asia-southeast2-band-playground.cloudfunctions.net/test-runtime-executor GRPC=https://devnet.d3n.xyz/grpc/ FAUCET_URL=https://devnet.d3n.xyz/faucet/request yarn server

# MAINNET
# (in another tab) Run the development server
RPC_URL=https://laozi1.bandchain.org/api GRAPHQL_URL=graphql-lm.bandchain.org/v1/graphql LAMBDA_URL=https://asia-southeast1-testnet-instances.cloudfunctions.net/executer-cosmoscan GRPC=https://laozi1.bandchain.org/grpc-web yarn server

# run test
GRPC=https://laozi-testnet6.bandchain.org/grpc-web yarn test

```
