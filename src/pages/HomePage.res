@react.component
let make = () => {
  // this is used for debug graphql
  // will remove later
  // check ing binding is work
  let (accountOpt, _) = React.useContext(AccountContext.context)

  let doSmth = async () => {
    open BandChainJS

    let mnemo = "mule way gather advance quote endorse boat liquid kite mad cart"
    let privKey = PrivateKey.fromMnemonic(mnemo, "m/44'/494'/0'/0/0")
    let pub = privKey -> PrivateKey.toPubkey 
    let address = pub -> PubKey.toAddress -> Address.toAccBech32

    Js.log(address)
    Js.log(pub -> PubKey.toHex)
    Js.log(pub -> PubKey.toAddress -> Address.toHex -> PubKey.fromHex -> PubKey.toHex)
    // Js.log("0212de71dbfc3b2f6580751d6d5a9fe8c98e2eb6b399045ea08c164505ddd45b66" -> Address.fromHex)

    let client = Client.create(Env.grpc)
    let obi = Obi.create("{symbols:[string],multiplier:u64}/{rates:[u64]}")

    Js.log("calldata")
    let calldata =  Obi.encodeInput(obi, `{ "symbols": ["ETH"], "multiplier": 100 }` -> Js.Json.parseExn)


    let coin = Coin.create()
    coin -> Coin.setDenom("uband")
    coin -> Coin.setAmount("1000000")

    Js.log(coin->Coin.getDenom)

    let feeCoin = Coin.create()
    feeCoin -> Coin.setDenom("uband")
    feeCoin -> Coin.setAmount("10000")

    Js.log("create msg")
    let msg = Message.MsgRequest.create(
      37,
      calldata,
      4,
      3,
      "BandProtocol",
      address,
      [coin],
      Some(50000),
      Some(200000),
    )

    let sendMsg = Message.MsgTransfer.create(
      "transfer",
      "channel-25",
      "band13eznuehmqzd3r84fkxu8wklxl22r2qfmtlth8c",
      "cosmos15d4apf20449ajvwycq8ruaypt7v6d34522frnd",
      coin,
      1677512323000.
    )

    Js.log(sendMsg->Message.MsgTransfer.toJSON->Js.Json.stringifyAny)

    let fee = Fee.create()
    fee -> Fee.setAmountList([feeCoin])
    fee -> Fee.setGasLimit(1000000)

    Js.log("create txn")
    let txn = Transaction.create()
    txn -> Transaction.withFee(fee)
    txn -> Transaction.withMessages(msg)
    txn -> Transaction.withChainId("6")

    let rawTx = await txn -> Transaction.withSender(client, address)
    let signDoc = txn -> Transaction.getSignDoc(pub)
    let signature = privKey -> PrivateKey.sign(signDoc)
    

    // let signature = await Wallet.sign(rawTx->BandChainJS.Transaction.getSignMessage->JsBuffer.toUTF8, account.wallet)
    let signedTx = rawTx->BandChainJS.Transaction.getTxData(signature, pub, 127)
    let response = await client->BandChainJS.Client.sendTxBlockMode(signedTx)

    Js.log(response)
  }

  let jest = async () => {
    open BandChainJS

    let client = Client.create(Env.grpc)
    let obj = await client->Client.getReferenceData(["BTC/USD"], 3, 4) 
    Js.log(obj)
    // let obj = client->Client.getReferenceData(["BTC/USD"]) 
  }

  <Section>
    <div className=CssHelper.container id="proposalsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
      <Button onClick={_ => doSmth() -> ignore}>{ "Do something" -> React.string}</Button>
      <Button onClick={_ => jest() -> ignore}>{ "Jeest" -> React.string}</Button>
        // <Col col=Col.Twelve>
        //   {
        //     switch requestsByDs {
        //       | Data(data) => <Text value={data[0].txHash -> Belt.Option.getExn -> Hash.toHex} size=Text.Body1 />
        //       | Loading => <Text value="Loading" size=Text.Body1 />
        //       | NoData => <Text value="NoData" size=Text.Body1 />
        //       | Error(err) => <Text value=err.message size=Text.Body1 />
        //     }
        //   }
        // </Col>
        // <Col col=Col.Twelve>
        //   {
        //     switch requestsByTxHash {
        //       | Data(data) => <Text value={data[0].txHash -> Belt.Option.getExn -> Hash.toHex} size=Text.Body1 />
        //       | Loading => <Text value="Loading" size=Text.Body1 />
        //       | NoData => <Text value="NoData" size=Text.Body1 />
        //       | Error(err) => <Text value=err.message size=Text.Body1 />
        //     }
        //   }
        // </Col>
        <SeperatedLine />
        // {
        //   switch requestsByTxHashSub {
        //     | Data(res) => res -> Belt.Array.map(
        //       ({id,responseTime}) =>
        //       <>
        //         <Col col=Col.Twelve>
        //           <Text value={id ->ID.OracleScript.toString} size=Text.Body1 />
        //         </Col>
        //         <Col col=Col.Twelve>
        //           <Text value={responseTime -> Belt.Float.toString} size=Text.Body1 />
        //         </Col>
        //         <SeperatedLine/>
        //       </>
        //     ) -> React.array
        //     | Loading => <Text value="Loading" size=Text.Body1 />
        //     | NoData => <Text value="NoData" size=Text.Body1 />
        //     | Error(err) => <Text value=err.message size=Text.Body1 />
        //   }
        // }
      </Row>
    </div>
  </Section>
}
