```sh

# generate graphql_schema.json
npx get-graphql-schema http://devnet.d3n.xyz/v1/graphql -j > graphql_schema.json

# installed the dependencies
yarn

## run the complier
yarn start

# (in another tab) Run the development server
RPC_URL=https://devnet.d3n.xyz/rpc/ GRAPHQL_URL=wss://devnet.d3n.xyz/hasura/v1/graphql LAMBDA_URL=https://asia-southeast2-band-playground.cloudfunctions.net/test-runtime-executor GRPC=https://devnet.d3n.xyz/grpc/ FAUCET_URL=https://devnet.d3n.xyz/faucet/request yarn server

```
