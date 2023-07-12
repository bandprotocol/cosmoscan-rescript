module Styles = {
  open CssJs

  let yesnoImg = style(. [width(#px(16)), height(#px(16)), marginRight(#px(4))])
  let councilMember = (theme: Theme.t) => style(. [color(theme.primary_600)])

  let smallDot = color =>
    style(. [
      width(#px(8)),
      height(#px(8)),
      borderRadius(#percent(50.)),
      backgroundColor(color),
      marginRight(#px(8)),
    ])

  let msgContainer = style(. [selector("> div + div", [marginTop(#px(24))])])
}

@react.component
let make = (~vetoProposal: CouncilProposalSub.VetoProposal.t) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let (_, dispatchModal) = React.useContext(ModalContext.context)

  // let depositCountSub = DepositSub.count(vetoProposal.id)
  let openDepositors = () => Syncing->OpenModal->dispatchModal

  <Row marginTopSm=24>
    <Col col=Col.Seven>
      <Heading
        value="Reject Details"
        size=Heading.H4
        weight=Heading.Semibold
        color={theme.neutral_600}
        marginBottom=8
      />
    </Col>
    <Col col=Col.Twelve>
      <InfoContainer py=24 px=24>
        <Row>
          <Col col=Col.Five>
            <div className={CssHelper.flexBox()}>
              <Heading
                value="Open status"
                size=Heading.H5
                weight=Heading.Regular
                color={theme.neutral_900}
                marginRight=8
              />
            </div>
          </Col>
          <Col col=Col.Seven>
            <div className={CssHelper.flexBox()}>
              <img alt="Pending Icon" src=Images.pending />
              <HSpacing size=Spacing.sm />
              <Text value="Incomplete" size=Text.Body1 color=theme.neutral_900 />
            </div>
          </Col>
        </Row>
        <Row marginTop=16>
          <Col col=Col.Five>
            <div className={CssHelper.flexBox()}>
              <Heading
                value="Total deposit"
                size=Heading.H5
                weight=Heading.Regular
                color={theme.neutral_900}
                marginRight=8
              />
            </div>
          </Col>
          <Col col=Col.Seven>
            <div className={CssHelper.flexBox()}>
              <Text
                value={`${vetoProposal.totalDeposit
                  ->Coin.getBandAmountFromCoins
                  ->Format.fPretty(~digits=0)}/1,000 BAND`}
                size=Text.Body1
                code=true
                color=theme.neutral_900
              />
              <HSpacing size=Spacing.sm />
              <Button variant={Text}> {"Deposit"->React.string} </Button>
            </div>
          </Col>
        </Row>
        <Row marginTop=16>
          <Col>
            <div className={CssHelper.clickable} onClick={_ => openDepositors()}>
              <Text
                value="View deposit transactions"
                size=Text.Body2
                weight=Text.Thin
                color=theme.primary_600
                spacing=Text.Em(0.05)
                block=true
              />
            </div>
          </Col>
        </Row>
      </InfoContainer>
    </Col>
  </Row>
}
