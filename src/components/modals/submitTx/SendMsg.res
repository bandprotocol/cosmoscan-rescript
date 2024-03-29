@react.component
let make = (~address, ~receiver, ~setMsgsOpt, ~targetChain) => {
  let accountSub = AccountSub.get(address)
  let (toAddress, setToAddress) = React.useState(_ => {
    switch receiver {
    | Some(receiver') => {
        open EnhanceTxInput
        {text: receiver'->Address.toBech32, value: Some(receiver')}
      }

    | None => EnhanceTxInput.empty
    }
  })
  let (amount, setAmount) = React.useState(_ => EnhanceTxInput.empty)

  React.useEffect2(_ => {
    let msgsOpt = {
      let toAddressValue = {
        switch toAddress.value {
        | Some(address) => address
        | None => Address.Address("")
        }
      }

      let amountValue = amount.value->Belt.Option.getWithDefault(0.)
      switch targetChain {
      | IBCConnectionQuery.BAND =>
        Some([
          Msg.Input.SendMsg({
            fromAddress: address,
            toAddress: toAddressValue,
            amount: list{amountValue->Coin.newUBANDFromAmount},
          }),
        ])
      | IBC({channel}) =>
        Some([
          Msg.Input.IBCTransfer({
            sourcePort: "transfer",
            sourceChannel: channel,
            receiver: toAddress.text, // Hack: use text instead
            token: amountValue->Coin.newUBANDFromAmount,
            timeoutTimestamp: (MomentRe.momentNow()
            ->MomentRe.Moment.defaultUtc
            ->MomentRe.Moment.toUnix
            ->Belt.Int.toFloat +. 600.) *. 1e9, // add 10 mins
            sender: address,
          }),
        ])
      }
    }
    setMsgsOpt(_ => msgsOpt)
    None
  }, (toAddress, amount))

  <>
    <Heading size=Heading.H5 value="Available Balance" marginBottom=8 />
    <div className={CssHelper.mb(~size=24, ())}>
      {switch accountSub {
      | Data({balance}) =>
        <div>
          <Text value={balance->Coin.getBandAmountFromCoins->Format.fPretty(~digits=6)} code=true />
          <Text value=" BAND" />
        </div>
      | _ => <LoadingCensorBar width=150 height=18 />
      }}
    </div>
    <ChainSelector targetChain />
    <EnhanceTxInput
      width=302
      inputData=toAddress
      setInputData=setToAddress
      parse={switch targetChain {
      | IBCConnectionQuery.BAND => Parse.address
      | IBC(_) => Parse.notBandAddress
      }}
      msg="Recipient Address"
      code=true
      id="recipientAddressInput"
      placeholder="Insert recipient address"
      autoFocus={switch toAddress.text {
      | "" => true
      | _ => false
      }}
    />
    {switch accountSub {
    | Data({balance}) =>
      //  TODO: hard-coded tx fee
      let maxValInUband = balance->Coin.getUBandAmountFromCoins -. 5000.
      <EnhanceTxInput
        width=300
        inputData=amount
        setInputData=setAmount
        parse={Parse.getBandAmount(maxValInUband)}
        maxValue={(maxValInUband /. 1e6)->Belt.Float.toString}
        msg="Send Amount (BAND)"
        inputType="number"
        code=true
        placeholder="0.000000"
        autoFocus={switch toAddress.text {
        | "" => false
        | _ => true
        }}
        id="sendAmountInput"
        maxWarningMsg=true
      />
    | _ =>
      <EnhanceTxInput.Loading
        msg="Send Amount (BAND)" code=true useMax=true placeholder="0.000000"
      />
    }}
  </>
}
