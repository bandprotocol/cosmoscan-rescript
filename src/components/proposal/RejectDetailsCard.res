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
}

module Wait = {
  @react.component
  let make = (~vetoId: int, ~totalDepositOpt: option<float>) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let openDepositors = () => vetoId->Depositors->OpenModal->dispatchModal

    <Row marginTopSm=24>
      <Col col=Col.Twelve mb=8 style={CssHelper.flexBox()}>
        <Heading
          value="Reject Details" size=Heading.H4 weight=Heading.Semibold color={theme.neutral_600}
        />
        <HSpacing size=Spacing.xs />
        <CTooltip
          tooltipPlacement=CTooltip.Top
          tooltipText="A veto proposal can be opened to prevent a proposal from being approved. It requires a deposit of 1,000 BAND.  
A veto proposal will pass and the proposal being vetoed will be rejected if the veto proposal has a quorum of more than 50% and the yes threshold exceeds 40%.">
          <Icon name="fal fa-info-circle" size=16 color={theme.neutral_400} />
        </CTooltip>
        <HSpacing size=Spacing.xs />
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
      <Col col=Col.Twelve>
        <InfoContainer py=24 px=24>
          <Row>
            <Col col=Col.Five>
              <div className={CssHelper.flexBox()}>
                <Heading
                  value="Open status"
                  size=Heading.H4
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
                  size=Heading.H4
                  weight=Heading.Regular
                  color={theme.neutral_900}
                  marginRight=8
                />
              </div>
            </Col>
            <Col col=Col.Seven>
              <div className={CssHelper.flexBox()}>
                <Text
                  // if none totalDepositOpt exist getWithDefault with 0
                  value={`${totalDepositOpt
                    ->Belt.Option.getWithDefault(0.)
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
}

module Vote = {
  @react.component
  let make = (
    ~vetoProposal: CouncilProposalSub.VetoProposal.t,
    ~status: CouncilProposalSub.Status.t,
  ) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let openDepositors = () =>
      vetoProposal.id->ID.LegacyProposal.toInt->Depositors->OpenModal->dispatchModal
    let vote = () => Syncing->OpenModal->dispatchModal

    <Row marginTopSm=24>
      <Col col=Col.Twelve mb=8 style={CssHelper.flexBox()}>
        <Heading
          value="Reject Details" size=Heading.H4 weight=Heading.Semibold color={theme.neutral_600}
        />
        <HSpacing size=Spacing.xs />
        <CTooltip
          tooltipPlacement=CTooltip.Top
          tooltipText="A veto proposal can be opened to prevent a proposal from being approved. It requires a deposit of 1,000 BAND.  
A veto proposal will pass and the proposal being vetoed will be rejected if the veto proposal has a quorum of more than 50% and the yes threshold exceeds 40%.">
          <Icon name="fal fa-info-circle" size=16 color={theme.neutral_400} />
        </CTooltip>
        <HSpacing size=Spacing.xs />
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
      <Col col=Col.Twelve>
        <InfoContainer py=24 px=24>
          <Row>
            <Col col=Col.Six colSm=Col.Twelve>
              <Row marginBottom=16>
                <Col col=Col.Seven colSm=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <Heading
                      value="Turnout"
                      size=Heading.H4
                      weight=Heading.Regular
                      color={theme.neutral_900}
                      marginRight=8
                    />
                    <Text
                      // minimum yes vote to pass set in CouncilProposalSub.passedTheshold
                      value={`min ${CouncilProposalSub.VetoProposal.turnoutTheshold->Belt.Float.toString}%`}
                      size=Text.Body2
                      weight=Text.Regular
                      color={theme.neutral_600}
                    />
                  </div>
                </Col>
                <Col col=Col.Five colSm=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <img
                      src={switch vetoProposal.isTurnoutPassed {
                      | Pass => Images.yesRed
                      | Reject => Images.noGreen
                      }}
                      alt={vetoProposal.isTurnoutPassed->CouncilProposalSub.CurrentStatus.getStatusText}
                      className=Styles.yesnoImg
                    />
                    <Text
                      value={vetoProposal.turnout->Format.fVotePercent}
                      size=Text.Body1
                      weight=Text.Bold
                      color={theme.neutral_900}
                    />
                  </div>
                </Col>
              </Row>
              <Row marginBottom=16>
                <Col col=Col.Seven colSm=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <Heading
                      value="Yes Vote"
                      size=Heading.H4
                      weight=Heading.Regular
                      color={theme.neutral_900}
                      marginRight=8
                    />
                    <Text
                      // minimum yes vote to pass set in CouncilProposalSub.passedTheshold
                      value={`min ${CouncilProposalSub.VetoProposal.yesTheshold->Belt.Float.toString}%`}
                      size=Text.Body2
                      weight=Text.Regular
                      color={theme.neutral_600}
                    />
                  </div>
                </Col>
                <Col col=Col.Five colSm=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <img
                      src={switch vetoProposal.isYesPassed {
                      | Pass => Images.yesRed
                      | Reject => Images.noGreen
                      }}
                      alt={vetoProposal.isYesPassed->CouncilProposalSub.CurrentStatus.getStatusText}
                      className=Styles.yesnoImg
                    />
                    <Text
                      value={vetoProposal.yesVotePercent->Format.fVotePercent}
                      size=Text.Body1
                      weight=Text.Bold
                      color={theme.neutral_900}
                    />
                  </div>
                </Col>
              </Row>
              <Row>
                <Col col=Col.Seven colSm=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <Heading
                      value="Current Status"
                      size=Heading.H4
                      weight=Heading.Regular
                      color={theme.neutral_900}
                    />
                  </div>
                </Col>
                <Col col=Col.Five colSm=Col.Six>
                  <div className={CssHelper.flexBox()}>
                    <Text
                      value={vetoProposal.status->CouncilProposalSub.CurrentStatus.getStatusText}
                      size=Text.Body1
                      weight=Text.Semibold
                      color={vetoProposal.status->CouncilProposalSub.CurrentStatus.getStatusColorInverse(
                        theme,
                      )}
                      block=true
                    />
                  </div>
                </Col>
              </Row>
            </Col>
            {switch status {
            | VetoPeriod =>
              <Hidden variant={Mobile}>
                <Col col=Col.Six style={CssHelper.flexBox(~justify=#end_, ~align=#flexStart, ())}>
                  <Button
                    variant={Outline}
                    px=70
                    py=10
                    fsize=14
                    style={CssHelper.flexBox()}
                    onClick={_ => vote()}>
                    {"Vote"->React.string}
                  </Button>
                </Col>
              </Hidden>
            | _ => React.null
            }}
          </Row>
          <SeperatedLine mt=24 mb=24 color=theme.neutral_300 />
          <Row marginTop=16>
            <Col>
              <VoteProgress.Veto vetoProposal />
            </Col>
          </Row>
        </InfoContainer>
      </Col>
    </Row>
  }
}
