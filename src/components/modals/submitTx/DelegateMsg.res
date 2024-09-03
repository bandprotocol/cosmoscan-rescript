module Styles = {
  open CssJs

  let container = style(. [paddingBottom(#px(24))])

  let info = style(. [display(#flex), justifyContent(#spaceBetween)])

  let validator = style(. [
    display(#flex),
    flexDirection(#column),
    alignItems(#flexEnd),
    width(#px(330)),
  ])
}

@react.component
let make = (~address, ~validator: option<Address.t>, ~setMsgsOpt) => {
  let accountSub = AccountSub.get(address)
  let validatorsSub = ValidatorSub.getList(~filter=Active, ())

  let allSub = Sub.all2(accountSub, validatorsSub)

  let (amount, setAmount) = React.useState(_ => EnhanceTxInput.empty)
  let (validatorOpt, setValidatorOpt) = React.useState(_ => validator)

  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  React.useEffect2(_ => {
    switch validatorOpt {
    | Some(val) =>
      let msgsOpt = {
        let amountValue = amount.value->Belt.Option.getWithDefault(0.)

        Some([
          Msg.Input.DelegateMsg({
            validatorAddress: val,
            delegatorAddress: address,
            amount: amountValue->Coin.newUBANDFromAmount,
            moniker: (),
            identity: (),
          }),
        ])
      }
      setMsgsOpt(_ => msgsOpt)
    | None => ()
    }

    None
  }, (amount, validatorOpt))

  <>
    <div className=Styles.container>
      <Heading
        value="Delegate to"
        size=Heading.H5
        marginBottom=8
        align=Heading.Left
        weight=Heading.Regular
        color={theme.neutral_600}
      />
      // <Text value={validator->Address.toOperatorBech32} />
      {switch validatorsSub {
      | Data(validators) =>
        <div>
          {
            let filteredValidators =
              validators->Belt_Array.keep(validator => validator.commission !== 100.)
            <ValidatorSelection filteredValidators setValidatorOpt />
          }
        </div>
      | Error(err) => <Text value={err.message} />
      | NoData => <Text value={"No Data"} />
      | _ => <LoadingCensorBar width=300 height=34 />
      }}
    </div>
    <div className=Styles.container>
      <Heading
        value="Account Balance"
        size=Heading.H5
        marginBottom=8
        align=Heading.Left
        weight=Heading.Regular
        color={theme.neutral_600}
      />
      {switch allSub {
      | Data(({balance}, _)) =>
        <div>
          <Text value={balance->Coin.getBandAmountFromCoins->Format.fPretty(~digits=6)} code=true />
          <Text value=" BAND" />
        </div>
      | _ => <LoadingCensorBar width=150 height=18 />
      }}
    </div>
    {switch allSub {
    | Data(({balance}, _)) =>
      //  TODO: hard-coded tx fee
      let maxValInUband = balance->Coin.getUBandAmountFromCoins -. 5000.
      <EnhanceTxInput
        width=300
        inputData=amount
        setInputData=setAmount
        parse={Parse.getBandAmount(maxValInUband)}
        maxValue={(maxValInUband /. 1e6)->Belt.Float.toString}
        msg="Amount"
        placeholder="0.000000"
        inputType="number"
        code=true
        autoFocus=true
        id="delegateAmountInput"
        maxWarningMsg=true
      />
    | _ => <EnhanceTxInput.Loading msg="Amount" code=true useMax=true placeholder="0.000000" />
    }}
  </>
}
