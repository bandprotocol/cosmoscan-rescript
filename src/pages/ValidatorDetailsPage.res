module Styles = {
  open CssJs
  let card = style(. [height(#percent(100.)), padding2(~v=#px(24), ~h=#px(32))])

  let link = style(. [fontSize(#px(14))])

  let bondedTokenContainer = style(. [height(#percent(100.))])
  let avatarContainer = style(. [
    position(#relative),
    Media.mobile([
      marginRight(#zero),
      marginBottom(#px(8)),
      display(#flex),
      justifyContent(#center),
    ]),
  ])
  let rankContainer = (theme: Theme.t) =>
    style(. [
      backgroundColor(theme.primary_600),
      borderRadius(#percent(50.)),
      position(#absolute),
      left(#calc(#add, #percent(50.), #px(20))),
      bottom(#zero),
      width(#px(26)),
      height(#px(26)),
    ])

  let validatorStatus = (isActive, theme: Theme.t) => {
    style(. [
      backgroundColor(isActive ? theme.success_600 : theme.error_600),
      borderRadius(#px(50)),
      padding2(~v=#px(2), ~h=#px(12)),
    ])
  }

  let customContainer = style(. [height(#percent(100.))])

  let chartWrapper = style(. [minHeight(px(220)), selector("> div", [width(#percent(100.))])])
}

module ValidatorStatus = {
  @react.component
  let make = (~validatorSub: Sub.variant<Validator.t>) => {
    let ({ThemeContext.theme: theme}, _) = ThemeContext.use()

    <div
      className={Css.merge(list{
        CssHelper.flexBox(~align=#flexEnd, ~direction=#column, ~rGap=#px(8), ()),
        CssHelper.flexBoxSm(~justify=#center, ~direction=#column, ~rGap=#px(16), ()),
        CssHelper.mbSm(~size=24, ()),
      })}>
      {switch validatorSub {
      | Data({isActive}) =>
        <div className={Styles.validatorStatus(isActive, theme)}>
          <Text
            value={(isActive ? "Active" : "Inactive") ++ " Validator"}
            color={theme.white}
            weight=Semibold
          />
        </div>
      | _ => <LoadingCensorBar width=100 height=20 />
      }}
      {switch validatorSub {
      | Data({oracleStatus}) =>
        <div className={Css.merge(list{CssHelper.flexBox(~justify=#center, ())})}>
          <img alt="Status Icon" src={oracleStatus ? Images.success : Images.fail} />
          <HSpacing size=Spacing.sm />
          <Text
            value={(oracleStatus ? "Active" : "Inactive") ++ " Oracle Status"}
            color={theme.neutral_600}
            size=Body1
            weight=Semibold
          />
        </div>
      | _ => <LoadingCensorBar width=75 height=20 />
      }}
    </div>
  }
}

module OracleUptimePercent = {
  @react.component
  let make = (~oracleStatus, ~operatorAddress) => {
    let ({ThemeContext.theme: theme}, _) = ThemeContext.use()
    let (prevDate, setPrevDate) = React.useState(_ => OracleDataReportChart.getDayAgo(90))
    React.useEffect0(() => {
      let timeOutID = Js.Global.setInterval(
        () => {setPrevDate(_ => OracleDataReportChart.getDayAgo(90))},
        60_000,
      )
      Some(() => {Js.Global.clearInterval(timeOutID)})
    })
    let historicalOracleStatusSub = ValidatorSub.getHistoricalOracleStatus(
      operatorAddress,
      prevDate,
      oracleStatus,
    )

    <>
      {switch historicalOracleStatusSub {
      | Data({uptimeCount}) =>
        <Text
          value={(uptimeCount->Belt.Int.toFloat /. 90. *. 100.)->Format.fPercent(~digits=0)}
          code=true
          size=Xl
          weight=Bold
          color=theme.neutral_900
        />
      | _ => <LoadingCensorBar width=20 height=14 />
      }}
    </>
  }
}

module UptimePercent = {
  @react.component
  let make = (~consensusAddress) => {
    let ({ThemeContext.theme: theme}, _) = ThemeContext.use()
    let getUptimeSub = ValidatorSub.getBlockUptimeByValidator(consensusAddress)

    let uptime = switch getUptimeSub {
    | Data({signedCount, missedCount}) =>
      signedCount == 0 && missedCount == 0
        ? None
        : Some(
            signedCount->Belt.Int.toFloat /.
            (signedCount->Belt.Int.toFloat +. missedCount->Belt.Int.toFloat) *. 100.,
          )
    | _ => None
    }

    switch uptime {
    | Some(x) =>
      <Text
        value={x->Format.fPercent(~digits=0)} code=true size=Xl weight=Bold color=theme.neutral_900
      />

    | None => <Text value={"N/A"} code=true size=Xl weight=Bold color=theme.neutral_900 />
    }
  }
}

@react.component
let make = (~address, ~hashtag: Route.validator_tab_t) => {
  let ({ThemeContext.theme: theme}, _) = ThemeContext.use()

  let validatorSub = ValidatorSub.get(address)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()

  let oracleReportsCountSub = ReportSub.ValidatorReport.count(address)
  let reporterCountSub = ReporterSub.count(address)
  let delegatorCountSub = DelegationSub.getDelegatorCountByValidator(address)

  // for finding validator rank
  let validatorsSub = ValidatorSub.getList(~filter=Active, ())

  let isMobile = Media.isMobile()

  let allSub = Sub.all3(validatorSub, validatorsSub, bondedTokenCountSub)

  <Section ptSm=24>
    <div className=CssHelper.container>
      <Button variant=Button.Text({underline: false}) onClick={_ => Route.redirect(ValidatorsPage)}>
        <Icon name="fal fa-angle-left" mr=8 size=20 color=theme.neutral_600 />
        <Text value="Back to all Validators" size=Text.Xl weight=Text.Medium />
      </Button>
      <Row marginTop=40 marginBottom=40 marginBottomSm=24>
        <Col col=Col.One>
          <div className=Styles.avatarContainer>
            {switch allSub {
            | Data(({identity, moniker}, validators, _)) =>
              let rankOpt =
                validators
                ->Belt.Array.keepMap(({moniker: m, rank}) => moniker === m ? Some(rank) : None)
                ->Belt.Array.get(0)
              <>
                <Avatar moniker identity width=80 widthSm=80 />
                {switch rankOpt {
                | Some(rank) =>
                  <div
                    className={Css.merge(list{
                      Styles.rankContainer(theme),
                      CssHelper.flexBox(~justify=#center, ()),
                    })}>
                    <Text value={rank->Belt.Int.toString} color={theme.white} />
                  </div>
                | None => React.null
                }}
              </>
            | _ => <LoadingCensorBar width=80 height=80 />
            }}
          </div>
        </Col>
        <Col col=Col.Eight>
          <div className={CssHelper.flexBoxSm(~justify=#center, ())}>
            {switch validatorSub {
            | Data({moniker}) =>
              <Heading
                size=Heading.H1
                value=moniker
                marginBottom=8
                marginBottomSm=24
                align={isMobile ? Heading.Center : Heading.Left}
              />
            | _ => <LoadingCensorBar width=260 height=32 mb=8 mbSm=8 />
            }}
          </div>
          {isMobile ? <ValidatorStatus validatorSub /> : React.null}
          <Row marginBottom=8 alignItems=Row.Center>
            <Col col=Col.Four mbSm=8>
              <div className={CssHelper.flexBox(~wrap=#nowrap, ())}>
                <Heading
                  value="Operator Address"
                  size=Heading.H4
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
                <HSpacing size={#px(4)} />
                <CTooltip tooltipText="The address used to show the validator's entity status">
                  <Icon name="fal fa-info-circle" size=16 color={theme.neutral_600} />
                </CTooltip>
              </div>
            </Col>
            <Col col=Col.Eight>
              {switch allSub {
              | Data(({operatorAddress}, _, _)) =>
                <AddressRender
                  address=operatorAddress
                  position=AddressRender.Subtitle
                  accountType=#validator
                  clickable=false
                  wordBreak=true
                  copy=true
                />
              | _ => <LoadingCensorBar width=260 height=15 />
              }}
            </Col>
          </Row>
          <Row marginBottom=8 alignItems=Row.Center>
            <Col col=Col.Four mbSm=8>
              <Heading
                value="Band Address" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
              />
            </Col>
            <Col col=Col.Eight>
              {switch allSub {
              | Data(({operatorAddress}, _, _)) =>
                <AddressRender
                  address=operatorAddress
                  position=AddressRender.Subtitle
                  wordBreak=true
                  copy=true
                  qrCode=true
                />
              | _ => <LoadingCensorBar width=260 height=15 />
              }}
            </Col>
          </Row>
        </Col>
        {!isMobile
          ? <Col col=Col.Three>
              <ValidatorStatus validatorSub />
            </Col>
          : React.null}
      </Row>
      {isMobile
        ? React.null
        : <Row marginBottom=24>
            <Col>
              <ValidatorStakingInfo validatorAddress=address />
            </Col>
          </Row>}
      // Validator Information
      <Row marginBottom=40 marginBottomSm=24>
        <Col>
          <InfoContainer py=24>
            <Heading value="Validator Information" size=Heading.H4 />
            <SeperatedLine mt=8 mb=16 />
            <Row marginBottom=24 alignItems=Row.Center>
              <Col col=Col.Three mbSm=8>
                <div className={CssHelper.flexBox()}>
                  <Heading
                    value="Commission" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                  />
                  <HSpacing size=Spacing.xs />
                  <CTooltip
                    tooltipText="The maximum increment by which the validator can increase their commission rate">
                    <Icon name="fal fa-info-circle" size=10 color={theme.neutral_600} />
                  </CTooltip>
                </div>
              </Col>
              <Col col=Col.Nine>
                {switch allSub {
                | Data(({commission}, _, _)) =>
                  <div className={CssHelper.flexBox()}>
                    <Text
                      value={Format.fPercent(~digits=2, commission)}
                      size=Body1
                      color={theme.neutral_900}
                      code=true
                    />
                    <HSpacing size=Spacing.lg />
                    // TODO: wire up
                    <Text value="(possible range is 2-20%)" size=Body1 />
                    <HSpacing size=Spacing.xs />
                    <CTooltip tooltipText="Possible commission rate that the validator can set">
                      <Icon name="fal fa-info-circle" size=16 color={theme.neutral_600} />
                    </CTooltip>
                  </div>
                | _ => <LoadingCensorBar width=260 height=15 />
                }}
              </Col>
            </Row>
            <Row marginBottom=24 alignItems=Row.Center>
              <Col col=Col.Three mbSm=8>
                <div className={CssHelper.flexBox()}>
                  <Heading
                    value="Est. APR" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                  />
                  <HSpacing size=Spacing.xs />
                  <CTooltip
                    tooltipText="Estimated Annual Percentage Rate of staking rewards exclude validator's commission">
                    <Icon name="fal fa-info-circle" size=10 color={theme.neutral_600} />
                  </CTooltip>
                </div>
              </Col>
              <Col col=Col.Nine>
                /* TODO: implement APR */
                <Text value={Format.fPercent(~digits=2, 0.)} size=Text.Body1 code=true />
              </Col>
            </Row>
            <Row marginBottom=24 alignItems=Row.Center>
              <Col col=Col.Three mbSm=8>
                <Heading
                  value="Website" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                />
              </Col>
              <Col col=Col.Nine>
                {switch allSub {
                | Data(({website}, _, _)) =>
                  <AbsoluteLink href=website className=Styles.link>
                    {website->React.string}
                  </AbsoluteLink>
                | _ => <LoadingCensorBar width=260 height=15 />
                }}
              </Col>
            </Row>
            <Row>
              <Col col=Col.Three mbSm=8>
                <Heading
                  value="Description" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                />
              </Col>
              <Col col=Col.Nine>
                {switch allSub {
                | Data(({details}, _, _)) => <Text value=details size=Text.Body1 code=true />
                | _ => <LoadingCensorBar width=260 height=15 />
                }}
              </Col>
            </Row>
          </InfoContainer>
        </Col>
      </Row>
      // Bondded token & staking section
      <Row marginBottom=24>
        <Col col=Col.Four mbSm=24>
          <InfoContainer style=Styles.bondedTokenContainer py=24>
            <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
              <Heading value="Voting Power" size=Heading.H4 />
              <div className={CssHelper.flexBox()}>
                // voting power
                {switch allSub {
                | Data({tokens, votingPower}, _, bondedTokenCount) =>
                  <div className={CssHelper.flexBox()}>
                    <Text
                      value={tokens->Coin.getBandAmountFromCoin->Format.fPretty(~digits=0)}
                      code=true
                      size=Xl
                      weight=Bold
                      color=theme.neutral_900
                    />
                    <HSpacing size=Spacing.sm />
                    <Text
                      value={"(" ++
                      (votingPower /. bondedTokenCount.amount *. 100.)
                        ->Format.fPercent(~digits=2) ++ ")"}
                      size=Body1
                      code=true
                    />
                  </div>
                | _ =>
                  <div
                    className={CssHelper.flexBox(
                      ~justify=#center,
                      ~direction=#column,
                      ~align=#flexEnd,
                      (),
                    )}>
                    <LoadingCensorBar width=40 height=25 />
                    <HSpacing size=Spacing.sm />
                    <LoadingCensorBar width=80 height=15 />
                  </div>
                }}
              </div>
            </div>
            <VSpacing size=#px(48) />
            <div
              className={Css.merge(list{
                CssHelper.flexBox(~justify=#center, ()),
                Styles.chartWrapper,
              })}>
              {switch allSub {
              | Data(({operatorAddress}, _, _)) => <HistoricalBondedGraph operatorAddress />
              | _ => <LoadingCensorBar.CircleSpin height=180 />
              }}
            </div>
          </InfoContainer>
        </Col>
        <Col col=Col.Four mbSm=24>
          <InfoContainer style=Styles.customContainer py=24>
            <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
              <div className={CssHelper.flexBox(~direction=#column, ~align=#flexStart, ())}>
                <Heading value="Node Uptime" size=Heading.H4 />
                <Text value="(last 100 Blocks)" size=Body1 />
              </div>
              {switch allSub {
              | Data(({consensusAddress}, _, _)) => <UptimePercent consensusAddress />
              | _ => <LoadingCensorBar width=90 height=15 />
              }}
            </div>
            <VSpacing size=Spacing.lg />
            <div
              className={Css.merge(list{
                CssHelper.flexBox(~justify=#center, ()),
                Styles.chartWrapper,
              })}>
              {switch allSub {
              | Data(({consensusAddress}, _, _)) => <BlockUptimeChart consensusAddress />
              | _ => <LoadingCensorBar.CircleSpin height=90 />
              }}
            </div>
          </InfoContainer>
        </Col>
        <Col col=Col.Four>
          <InfoContainer style=Styles.customContainer py=24>
            <div className={CssHelper.flexBox(~justify=#spaceBetween, ())}>
              <div className={CssHelper.flexBox(~direction=#column, ~align=#flexStart, ())}>
                <Heading value="Oracle Data Report Uptime" size=Heading.H4 />
                <Text value="(last 90 Days)" size=Body1 />
              </div>
              {switch allSub {
              | Data(({oracleStatus}, _, _)) =>
                // TODO: change hard-coded data
                <OracleUptimePercent oracleStatus operatorAddress=address />
              | _ => <LoadingCensorBar.CircleSpin height=90 />
              }}
            </div>
            <VSpacing size=Spacing.lg />
            <div
              className={Css.merge(list{
                CssHelper.flexBox(~justify=#center, ()),
                Styles.chartWrapper,
              })}>
              {switch allSub {
              | Data(({oracleStatus}, _, _)) =>
                <OracleDataReportChart oracleStatus operatorAddress=address />
              | _ => <LoadingCensorBar.CircleSpin height=90 />
              }}
            </div>
          </InfoContainer>
        </Col>
      </Row>
      <InfoContainer pySm=24>
        <Table>
          <Tab.Route
            tabs=[
              {
                name: {
                  switch oracleReportsCountSub {
                  | Data(count) => "Oracle Reports (" ++ count->Format.iPretty ++ ")"
                  | _ => "Oracle Reports"
                  }
                },
                route: Route.ValidatorDetailsPage(address, Route.Reports),
              },
              {
                name: {
                  switch reporterCountSub {
                  | Data(count) => "Reporters (" ++ count->Format.iPretty ++ ")"
                  | _ => "Reporters"
                  }
                },
                route: Route.ValidatorDetailsPage(address, Route.Reporters),
              },
              {
                name: "Proposed Blocks",
                route: Route.ValidatorDetailsPage(address, Route.ProposedBlocks),
              },
              {
                name: {
                  switch delegatorCountSub {
                  | Data(count) => "Delegators (" ++ count->Format.iPretty ++ ")"
                  | _ => "Delegators"
                  }
                },
                route: Route.ValidatorDetailsPage(address, Route.Delegators),
              },
            ]
            currentRoute={Route.ValidatorDetailsPage(address, hashtag)}>
            {switch hashtag {
            | Reports => <ReportsTable address />
            | Reporters => <ReportersTable address />
            | ProposedBlocks =>
              switch validatorSub {
              | Data(validator) =>
                <ProposedBlocksTable consensusAddress={Some(validator.consensusAddress)} />
              | _ => <ProposedBlocksTable consensusAddress=None />
              }
            | Delegators => <DelegatorsTable address />
            }}
          </Tab.Route>
        </Table>
      </InfoContainer>
    </div>
  </Section>
}
