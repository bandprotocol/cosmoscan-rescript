type base_account = {
  address: string,
  accountNumber: int,
  sequence: int,
}

type tx_response = {
  txhash: string,
  code: int,
  rawLog: string,
}

type voteOption =
  | VOTE_OPTION_UNSPECIFIED
  | VOTE_OPTION_YES
  | VOTE_OPTION_ABSTAIN
  | VOTE_OPTION_NO
  | VOTE_OPTION_NO_WITH_VETO

type proposalStatus =
  | PROPOSAL_STATUS_UNSPECIFIED
  | PROPOSAL_STATUS_DEPOSIT_PERIOD
  | PROPOSAL_STATUS_VOTING_PERIOD
  | PROPOSAL_STATUS_PASSED
  | PROPOSAL_STATUS_REJECTED
  | PROPOSAL_STATUS_FAILED

type councilType =
  | COUNCIL_TYPE_UNSPECIFIED
  | COUNCIL_TYPE_BAND_DAO
  | COUNCIL_TYPE_GRANT
  | COUNCIL_TYPE_TECH

type councilProposalStatus =
  | PROPOSAL_STATUS_UNSPECIFIED
  | PROPOSAL_STATUS_SUBMITTED
  | PROPOSAL_STATUS_WAITING_VETO
  | PROPOSAL_STATUS_IN_VETO
  | PROPOSAL_STATUS_REJECTED_BY_COUNCIL
  | PROPOSAL_STATUS_REJECTED_BY_VETO
  | PROPOSAL_STATUS_EXECUTED
  | PROPOSAL_STATUS_EXECUTION_FAILED
  | PROPOSAL_STATUS_TALLYING_FAILED

type voteOptionCouncil =
  | VOTE_OPTION_COUNCIL_UNSPECIFIED
  | VOTE_OPTION_COUNCIL_YES
  | VOTE_OPTION_COUNCIL_NO

module Client = {
  type t
  type reference_data_t = {
    pair: string,
    rate: float,
  }

  @module("@bandprotocol/bandchain.js") @new external create: string => t = "Client"
  @send
  external getReferenceData: (t, array<string>, int, int) => promise<array<reference_data_t>> =
    "getReferenceData"
  @send external getAccount: (t, string) => promise<base_account> = "getAccount"
  @send external getChainId: t => promise<string> = "getChainId"
  @send
  external sendTxBlockMode: (t, array<int>) => promise<tx_response> = "sendTxBlockMode"
  @send external sendTxSyncMode: (t, array<int>) => promise<tx_response> = "sendTxSyncMode"
}

module Address = {
  type t

  @module("@bandprotocol/bandchain.js") @scope(("Wallet", "Address")) @val
  external fromHex: string => t = "fromHex"

  @send external toAccBech32: t => string = "toAccBech32"
  @send external toHex: t => string = "toHex"
}

module PubKey = {
  type t

  @module("@bandprotocol/bandchain.js") @scope(("Wallet", "PublicKey")) @val
  external fromHex: string => t = "fromHex"

  @send external toHex: t => string = "toHex"
  @send external toBech32: (t, string) => string = "toBech32"
  @send external toAddress: t => Address.t = "toAddress"
  @send external toAccBech32: t => string = "toAccBech32"
}

module PrivateKey = {
  type t

  @module("@bandprotocol/bandchain.js") @scope(("Wallet", "PrivateKey")) @val
  external fromMnemonic: (string, string) => t = "fromMnemonic"

  @send external sign: (t, array<int>) => JsBuffer.t = "sign"
  @send external toHex: t => string = "toHex"
  @send external toPubkey: t => PubKey.t = "toPubkey"
}

module Coin = {
  type t

  @module("@bandprotocol/bandchain.js") @new external create: unit => t = "Coin"
  @send external getDenom: t => string = "getDenom"
  @send external setDenom: (t, string) => unit = "setDenom"
  @send external getAmount: t => string = "getAmount"
  @send external setAmount: (t, string) => unit = "setAmount"
}

module Fee = {
  type t

  @module("@bandprotocol/bandchain.js") @new external create: unit => t = "Fee"
  @send external setAmountList: (t, array<Coin.t>) => unit = "setAmountList"
  @send external getAmountList: t => array<Coin.t> = "getAmountList"

  @send external setGasLimit: (t, int) => unit = "setGasLimit"
  @send external getGasLimit: t => int = "getGasLimit"

  @send external setPayer: (t, string) => unit = "setPayer"
  @send external getPayer: t => string = "getPayer"

  @send external setGranter: (t, string) => unit = "setGranter"
  @send external getGranter: t => string = "getGranter"
}

module Proposal = {
  type t
  module TextProposal = {
    @module("@bandprotocol/bandchain.js") @scope("Proposal") @new
    external // (title: string, description: string)
    create: (string, string) => t = "TextProposal"
  }

  module CommunityPoolSpendProposal = {
    @module("@bandprotocol/bandchain.js") @scope("Proposal") @new
    external // (title: string, description: string, recipient: string, amount: Coin[])
    create: (string, string, string, array<Coin.t>) => t = "CommunityPoolSpendProposal"
  }

  module ParameterChangeProposal = {
    @module("@bandprotocol/bandchain.js") @scope("Proposal") @new
    external // (title: string, description: string, changes: ParamChange[])
    create: (string, string, Js.Json.t) => t = "ParameterChangeProposal"
  }

  module SoftwareUpgradeProposal = {
    @module("@bandprotocol/bandchain.js") @scope("Proposal") @new
    external // (title: string, description: string, plan: Plan)
    create: (string, string, Js.Json.t) => t = "SoftwareUpgradeProposal"
  }

  module CancelSoftwareUpgradeProposal = {
    @module("@bandprotocol/bandchain.js") @scope("Proposal") @new
    external // (title: string, description: string)
    create: (string, string) => t = "CancelSoftwareUpgradeProposal"
  }

  module VetoProposal = {
    @module("@bandprotocol/bandchain.js") @scope("Proposal") @new
    external // (proposalId: number, description: string)
    create: (int, string) => t = "VetoProposal"
  }
}

module Message = {
  type t
  module MsgSend = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, string, array<Coin.t>) => t = "MsgSend"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgDelegate = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, string, Coin.t) => t = "MsgDelegate"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgUndelegate = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, string, Coin.t) => t = "MsgUndelegate"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgRedelegate = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, string, string, Coin.t) => t = "MsgBeginRedelegate"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgWithdrawReward = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, string) => t = "MsgWithdrawDelegatorReward"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgSubmitProposal = {
    //  (initialDepositList: Coin[], proposer: string, content?: Proposal.Content);
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (array<Coin.t>, string, Proposal.t) => t = "MsgSubmitProposal"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgDeposit = {
    //  (proposalId: number, depositor: string, amountList: Coin[]);
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (int, string, array<Coin.t>) => t = "MsgDeposit"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgVote = {
    // (proposalId: number, voter: string, option: VoteOptionMap[keyof VoteOptionMap],)
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (int, string, voteOption) => t = "MsgVote"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgSubmitCouncilProposal = {
    //  (title: string, council: CouncilTypeMap[keyof CouncilTypeMap], proposer: string, messagesList: Array<BaseMsg>, metadata: string);
    // TODO: currently recieve messagesList: Array<BaseMsg> as JSON. find the way to define BaseMsg type
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, councilType, Js.Json.t, string) => t = "MsgSubmitCouncilProposal"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgVoteCouncil = {
    //  (proposalId: number, voter: string, option: VoteOptionMapCouncil[keyof VoteOptionMapCouncil]);
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (int, string, voteOptionCouncil) => t = "MsgVoteCouncil"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgRequest = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (
      int,
      JsBuffer.t,
      int,
      int,
      string,
      string,
      array<Coin.t>,
      option<int>,
      option<int>,
    ) => t = "MsgRequestData"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }

  module MsgTransfer = {
    @module("@bandprotocol/bandchain.js") @scope("Message") @new
    external create: (string, string, string, string, Coin.t, float) => t = "MsgTransfer"

    @send external toJSON: t => Js.Json.t = "toJSON"
  }
}

module Transaction = {
  type transaction_t

  @module("@bandprotocol/bandchain.js") @new external create: unit => transaction_t = "Transaction"
  @send external withMessages: (transaction_t, Message.t) => unit = "withMessages"
  @send external withChainId: (transaction_t, string) => unit = "withChainId"
  @send external withSender: (transaction_t, Client.t, string) => Js.Promise.t<unit> = "withSender"
  @send external withAccountNum: (transaction_t, int) => unit = "withAccountNum"
  @send external withSequence: (transaction_t, int) => unit = "withSequence"
  @send external withFee: (transaction_t, Fee.t) => unit = "withFee"
  @send external withMemo: (transaction_t, string) => unit = "withMemo"
  @send external getSignDoc: (transaction_t, PubKey.t) => array<int> = "getSignDoc"
  @send external getTxData: (transaction_t, JsBuffer.t, PubKey.t, int) => array<int> = "getTxData"
  @send external getSignMessage: transaction_t => JsBuffer.t = "getSignMessage"
}

module Obi = {
  type t

  @module("@bandprotocol/bandchain.js") @new external create: string => t = "Obi"
  @send external encodeInput: (t, 'a) => JsBuffer.t = "encodeInput"
  @send external encodeOutput: (t, 'a) => JsBuffer.t = "encodeOutput"
  @send external decodeInput: (t, JsBuffer.t) => 'a = "decodeInput"
  @send external decodeOutput: (t, JsBuffer.t) => 'a = "decodeOutput"
}
