type block_t = {timestamp: MomentRe.Moment.t}

type t = {
  id: int,
  txHash: Hash.t,
  blockHeight: ID.Block.t,
  success: bool,
  gasFee: list<Coin.t>,
  gasLimit: int,
  gasUsed: int,
  sender: Address.t,
  timestamp: MomentRe.Moment.t,
  messages: list<Msg.t>,
  memo: string,
  errMsg: string,
}

type internal_t = {
  id: int,
  txHash: Hash.t,
  blockHeight: ID.Block.t,
  success: bool,
  gasFee: list<Coin.t>,
  gasLimit: int,
  gasUsed: int,
  sender: Address.t,
  block: block_t,
  messages: Js.Json.t,
  memo: string,
  errMsg: option<string>,
}

type account_transaction_t = {transaction: internal_t}

module Mini = {
  type block_t = {timestamp: MomentRe.Moment.t}
  type t = {
    hash: Hash.t,
    blockHeight: ID.Block.t,
    block: block_t,
    gasFee: list<Coin.t>,
  }
}

let toExternal = ({
  id,
  txHash,
  blockHeight,
  success,
  gasFee,
  gasLimit,
  gasUsed,
  sender,
  memo,
  block,
  messages,
  errMsg,
}) => {
  id,
  txHash,
  blockHeight,
  success,
  gasFee,
  gasLimit,
  gasUsed,
  sender,
  memo,
  timestamp: block.timestamp,
  messages: // let msg = messages->Js.Json.decodeArray->Belt.Option.getExn->Belt.List.fromArray

  {
    let msg = messages->Js.Json.decodeArray
    switch msg {
    | Some(msg) => msg->Belt.List.fromArray
    | None => []->Belt.List.fromArray
    }->Belt.List.map(each => Msg.decodeMsg(each, success))
  },
  // msg->Belt.List.map(each => Msg.decodeMsg(each, success))

  errMsg: errMsg->Belt.Option.getWithDefault(""),
}

module SingleConfig = %graphql(`
  subscription Transaction($tx_hash: bytea!) {
    transactions_by_pk(hash: $tx_hash) @ppxAs(type: "internal_t") {
      id
      txHash: hash @ppxCustom(module: "GraphQLParserModule.Hash")
      blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
      success
      memo
      gasFee: gas_fee @ppxCustom(module: "GraphQLParserModule.Coins")
      gasLimit: gas_limit
      gasUsed: gas_used
      sender  @ppxCustom(module: "GraphQLParserModule.Address")
      messages
      errMsg: err_msg
      block @ppxAs(type:"block_t") {
        timestamp @ppxCustom(module: "GraphQLParserModule.Date")
      }
    }
  },
`)

module MultiConfig = %graphql(`
  subscription Transactions($limit: Int!, $offset: Int!) {
    transactions(offset: $offset, limit: $limit, order_by: [{id: desc}]) @ppxAs(type: "internal_t") {
      id
      txHash: hash @ppxCustom(module: "GraphQLParserModule.Hash")
      blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
      success
      memo
      gasFee: gas_fee @ppxCustom(module: "GraphQLParserModule.Coins")
      gasLimit: gas_limit
      gasUsed: gas_used
      sender  @ppxCustom(module: "GraphQLParserModule.Address")
      messages
      errMsg: err_msg
      block @ppxAs(type:"block_t") {
        timestamp @ppxCustom(module: "GraphQLParserModule.Date")
      }
    }
  }
`)

module MultiByHeightConfig = %graphql(`
  subscription TransactionsByHeight($height: Int!) {
    transactions(where: {block_height: {_eq: $height}}, order_by: [{id: desc}]) @ppxAs(type: "internal_t") {
      id
      txHash: hash @ppxCustom(module: "GraphQLParserModule.Hash")
      blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
      success
      memo
      gasFee: gas_fee @ppxCustom(module: "GraphQLParserModule.Coins")
      gasLimit: gas_limit
      gasUsed: gas_used
      sender  @ppxCustom(module: "GraphQLParserModule.Address")
      messages
      errMsg: err_msg
      block @ppxAs(type: "block_t") {
        timestamp @ppxCustom(module: "GraphQLParserModule.Date")
      }
    }
  }
`)

module MultiBySenderConfig = %graphql(`
  subscription TransactionsBySender($sender: String!, $limit: Int!, $offset: Int!) {
    accounts_by_pk(address: $sender) {
      account_transactions(offset: $offset, limit: $limit, order_by: [{transaction_id: desc}]) @ppxAs(type: "account_transaction_t"){
        transaction @ppxAs(type: "internal_t") {
          id
          txHash: hash @ppxCustom(module: "GraphQLParserModule.Hash")
          blockHeight: block_height @ppxCustom(module: "GraphQLParserModule.BlockID")
          success
          memo
          gasFee: gas_fee @ppxCustom(module: "GraphQLParserModule.Coins")
          gasLimit: gas_limit
          gasUsed: gas_used
          sender  @ppxCustom(module: "GraphQLParserModule.Address")
          messages
          errMsg: err_msg
          block @ppxAs(type: "block_t") {
            timestamp  @ppxCustom(module: "GraphQLParserModule.Date")
          }
        }
      }
    }

  }
`)

module TxCountBySenderConfig = %graphql(`
  subscription TransactionsCountBySender($sender: String!) {
    accounts_by_pk(address: $sender) {
      account_transactions_aggregate {
        aggregate {
          count 
        }
      }
    }
  }
`)

let get = txHash => {
  let hash = txHash->Hash.toHex->(x => "\\x" ++ x)->Js.Json.string

  let result = SingleConfig.use({tx_hash: hash})

  result
  ->Sub.fromData
  ->Sub.flatMap(({transactions_by_pk}) => {
    switch transactions_by_pk {
    | Some(data) => Sub.resolve(data->toExternal)
    | None => Sub.NoData
    }
  })
}

let getList = (~page, ~pageSize, ()) => {
  let offset = (page - 1) * pageSize
  let result = MultiConfig.use({limit: pageSize, offset})

  result->Sub.fromData->Sub.map(({transactions}) => transactions->Belt.Array.map(toExternal))
}

let getListBySender = (~sender, ~page, ~pageSize) => {
  let offset = (page - 1) * pageSize
  let result = MultiBySenderConfig.use({
    limit: pageSize,
    offset,
    sender: sender->Address.toBech32,
  })

  result
  ->Sub.fromData
  ->Sub.flatMap(({accounts_by_pk}) => {
    switch accounts_by_pk {
    | Some(data) =>
      Sub.resolve(
        data.account_transactions->Belt.Array.map(({transaction}) => transaction->toExternal),
      )
    | None => Sub.resolve([])
    }
  })
}

let getListByBlockHeight = height => {
  let result = MultiByHeightConfig.use({height: height->ID.Block.toInt})

  result->Sub.fromData->Sub.map(({transactions}) => transactions->Belt.Array.map(toExternal))
}

let countBySender = sender => {
  let result = TxCountBySenderConfig.use({sender: sender->Address.toBech32})
  result
  ->Sub.fromData
  ->Sub.map(data =>
    data.accounts_by_pk->Belt.Option.mapWithDefault(0, account =>
      account.account_transactions_aggregate.aggregate->Belt.Option.mapWithDefault(0, x => x.count)
    )
  )
}
