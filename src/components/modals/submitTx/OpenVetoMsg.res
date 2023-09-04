module Styles = {
  open CssJs

  let container = style(. [paddingBottom(#px(8))])
}

@react.component
let make = (~address, ~proposalID, ~totalDeposit, ~proposalName, ~setMsgsOpt) => {
  let (answerOpt, setAnswerOpt) = React.useState(_ => Vote.YesNo.Unknown)
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let accountSub = AccountSub.get(address)

  let (amount, setAmount) = React.useState(_ => EnhanceTxInput.empty)
  // React.useEffect1(_ => {
  //   let msgsOpt = {
  //     let answer = answerOpt->Belt.Option.getWithDefault(1)
  //     Some([
  //       Msg.Input.VoteMsg({
  //         voterAddress: address,
  //         proposalID,
  //         option: answer,
  //       }),
  //     ])
  //   }
  //   setMsgsOpt(_ => msgsOpt)
  //   None
  // }, [answerOpt])

  <>
    <div className=Styles.container>
      <Text
        value="A veto proposal can be opened to prevent a proposal from being approved. It requires a deposit of 1,000 BAND."
        size=Text.Body1
        weight=Text.Regular
        color={theme.neutral_700}
        block=true
      />
      <VSpacing size=Spacing.sm />
      <Text
        value="A veto proposal will pass and the proposal being vetoed will be rejected if the veto proposal has a quorum of more than 50% and the yes threshold exceeds 40%."
        size=Text.Body1
        weight=Text.Regular
        color={theme.neutral_700}
        block=true
      />
      <VSpacing size=Spacing.md />
      <Text
        value="Veto to"
        size=Text.Body2
        weight=Text.Regular
        color={theme.neutral_900}
        nowrap=true
        block=true
      />
      <VSpacing size=Spacing.xs />
      <Text
        value={`${proposalID->ID.Proposal.toString} ${proposalName}`}
        size=Text.Body1
        weight=Text.Semibold
        color=theme.neutral_900
        nowrap=true
        block=true
      />
      <VSpacing size=Spacing.md />
      {switch totalDeposit->Coin.getBandAmountFromCoins > 0. {
      | true =>
        <>
          <Text
            value="Total Deposit (BAND)"
            size=Text.Body2
            weight=Text.Regular
            color={theme.neutral_900}
            nowrap=true
            block=true
          />
          <VSpacing size=Spacing.xs />
          <div className={CssHelper.flexBox()}>
            <Text
              value={`${totalDeposit->Coin.getBandAmountFromCoins->Belt.Float.toString}/1,000`}
              size=Text.Body1
              weight=Text.Bold
              color=theme.neutral_900
              code=true
            />
            <Text
              value={`(${(1000. -. totalDeposit->Coin.getBandAmountFromCoins)
                  ->Belt.Float.toString} left)`}
              size=Text.Body2
              weight=Text.Regular
              color=theme.neutral_600
              code=true
            />
          </div>
          <VSpacing size=Spacing.md />
        </>
      | false => React.null
      }}
    </div>
    {switch accountSub {
    | Data({balance}) =>
      //  TODO: hard-coded tx fee
      let maxValInUband = balance->Coin.getUBandAmountFromCoins -. 5000.
      <EnhanceTxInput
        id="depositAmountInput"
        width=300
        inputData=amount
        setInputData=setAmount
        parse={Parse.getBandAmount(maxValInUband)}
        msg="Deposit Amount (BAND)"
        subMsg="Required 1,000 BAND to open proposal"
        placeholder="0.000000"
        inputType="number"
        code=true
        autoFocus=true
        helperText={<div className={CssHelper.flexBox(~wrap=#nowrap, ())}>
          <Text
            value="Available"
            size=Text.Caption
            weight=Text.Regular
            color={theme.neutral_900}
            nowrap=true
            block=true
          />
          <HSpacing size=Spacing.xs />
          <CTooltip
            tooltipPlacement=CTooltip.Bottom
            // TODO add text here
            tooltipText="">
            <Icon name="fal fa-info-circle" size=16 color={theme.neutral_400} />
          </CTooltip>
          <HSpacing size=Spacing.xs />
          <Text
            value={balance->Coin.getBandAmountFromCoins->Format.fCurrency ++ " BAND"}
            size=Text.Caption
            weight=Text.Regular
            color={theme.neutral_900}
            nowrap=true
            block=true
            code=true
          />
        </div>}
      />
    | _ => <EnhanceTxInput.Loading msg="Amount" code=true useMax=true placeholder="0.000000" />
    }}
  </>
}
