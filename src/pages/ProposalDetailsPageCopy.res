module Styles = {
  open CssJs

  let statusLogo = style(. [width(#px(20))])
  let resultContainer = style(. [selector("> div + div", [marginTop(#px(24))])])

  let voteButton = status =>
    switch status {
    | ProposalSub.Voting => style(. [visibility(#visible)])
    | Deposit
    | Passed
    | Rejected
    | Inactive
    | Failed =>
      style(. [visibility(#hidden)])
    }

  let chartContainer = style(. [paddingRight(#px(20)), Media.mobile([paddingRight(#zero)])])

  let parameterChanges = (theme: Theme.t, isDarkMode) =>
    style(. [
      padding2(~v=#px(16), ~h=#px(24)),
      backgroundColor(isDarkMode ? theme.neutral_200 : theme.neutral_100),
    ])

  let proposalTypeBadge = (theme: Theme.t, isDarkMode) =>
    style(. [
      padding2(~v=#px(6), ~h=#px(12)),
      borderRadius(#px(20)),
      backgroundColor(isDarkMode ? theme.neutral_200 : theme.primary_100),
      display(#inlineBlock),
      selector(" > p", [color(theme.primary_600)]),
    ])
}

module ProposalTypeBadge = {
  @react.component
  let make = (~proposalType) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.proposalTypeBadge(theme, isDarkMode)}>
      <Text
        value={proposalType->ProposalSub.ProposalType.getBadgeText}
        size=Text.Body2
        block=true
        weight={Semibold}
      />
    </div>
  }
}

module VoteButton = {
  @react.component
  let make = (~proposalID, ~proposalName) => {
    let trackingSub = TrackingSub.use()

    let (accountOpt, _) = React.useContext(AccountContext.context)
    let (_, dispatchModal) = React.useContext(ModalContext.context)

    let connect = chainID => dispatchModal(OpenModal(Connect(chainID)))
    let vote = () => Vote(proposalID, proposalName)->SubmitTx->OpenModal->dispatchModal

    switch accountOpt {
    | Some(_) =>
      <Button px=40 py=10 fsize=14 style={CssHelper.flexBox()} onClick={_ => vote()}>
        {"Vote"->React.string}
      </Button>
    | None =>
      switch trackingSub {
      | Data({chainID}) =>
        <Button px=40 py=10 fsize=14 style={CssHelper.flexBox()} onClick={_ => connect(chainID)}>
          {"Vote"->React.string}
        </Button>
      | Error(err) =>
        // log for err details
        Js.Console.log(err)
        <Text value="chain id not found" />
      | _ => <LoadingCensorBar width=90 height=26 />
      }
    }
  }
}

@react.component
let make = (~proposalID) => {
  let isMobile = Media.isMobile()
  let proposalSub = ProposalSub.get(proposalID)
  let voteStatByProposalIDSub = VoteSub.getVoteStatByProposalID(proposalID)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()

  let allSub = Sub.all3(proposalSub, voteStatByProposalIDSub, bondedTokenCountSub)

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <Section>
    <div className=CssHelper.container>
      <Row>
        <Col>
          <Heading value="Proposal Details" size=Heading.H2 marginBottom=40 marginBottomSm=24 />
        </Col>
      </Row>
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=16>
        {switch allSub {
        | Data(({id, title, status}, _, _)) =>
          <>
            <Col col=Col.Eight mbSm=16>
              <div
                className={Css.merge(list{
                  CssHelper.flexBox(),
                  CssHelper.flexBoxSm(~direction=#column, ~align=#flexStart, ()),
                })}>
                <div className={CssHelper.flexBox()}>
                  <TypeID.Proposal id position=TypeID.Title />
                  <HSpacing size=Spacing.sm />
                  <Heading size=Heading.H3 value=title />
                  <HSpacing size={#px(16)} />
                </div>
                <div className={CssHelper.mtSm(~size=16, ())}>
                  <LegacyProposalBadge status />
                </div>
              </div>
            </Col>
            <Col col=Col.Four>
              {isMobile
                ? React.null
                : <div
                    className={Css.merge(list{
                      CssHelper.flexBox(~direction=#column, ~align=#flexEnd, ()),
                    })}>
                    <div className={Styles.voteButton(status)}>
                      <VoteButton proposalID proposalName=title />
                    </div>
                  </div>}
            </Col>
          </>
        | _ =>
          <Col col=Col.Eight mbSm=16>
            <div className={CssHelper.flexBox()}>
              <LoadingCensorBar width=270 height=15 />
              <HSpacing size={#px(16)} />
              <div className={CssHelper.mtSm(~size=16, ())}>
                <LoadingCensorBar width=100 height=15 radius=50 />
              </div>
            </div>
          </Col>
        }}
      </Row>
      <Row marginBottom=24>
        <Col>
          <InfoContainer>
            <Heading value="Proposal Details" size=Heading.H4 />
            <SeperatedLine mt=32 mb=24 />
            <Row marginBottom=24 alignItems=Row.Center>
              <Col col=Col.Four mbSm=8>
                <Heading
                  value="Proposer" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                />
              </Col>
              <Col col=Col.Eight>
                {switch allSub {
                | Data(({proposerAddressOpt}, _, _)) =>
                  switch proposerAddressOpt {
                  | Some(proposerAddress) =>
                    <AddressRender address=proposerAddress position=AddressRender.Subtitle />
                  | None => <Text value="Proposed on Wenchang" />
                  }
                | _ => <LoadingCensorBar width=270 height=15 />
                }}
              </Col>
            </Row>
            <Row marginBottom=24 alignItems=Row.Center>
              <Col col=Col.Four mbSm=8>
                <Heading
                  value="Submit Time" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                />
              </Col>
              <Col col=Col.Eight>
                {switch allSub {
                | Data(({submitTime}, _, _)) =>
                  <Timestamp size=Text.Body1 timeOpt=Some(submitTime) />
                | _ => <LoadingCensorBar width={isMobile ? 120 : 270} height=15 />
                }}
              </Col>
            </Row>
            <Row marginBottom=24 alignItems=Row.Center>
              <Col col=Col.Four mbSm=8>
                <Heading
                  value="Proposal Type"
                  size=Heading.H4
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
              </Col>
              <Col col=Col.Eight>
                {switch allSub {
                | Data(({proposalType}, _, _)) => <ProposalTypeBadge proposalType />
                | _ => <LoadingCensorBar width=90 height=15 />
                }}
              </Col>
            </Row>
            <Row marginBottom=24>
              <Col col=Col.Four mbSm=8>
                <Heading
                  value="Description" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                />
              </Col>
              <Col col=Col.Eight>
                {switch allSub {
                | Data(({description}, _, _)) => <MarkDown value=description />
                | _ => <LoadingCensorBar width=270 height=15 />
                }}
              </Col>
            </Row>
          </InfoContainer>
        </Col>
      </Row>
      {switch allSub {
      | Data(({content}, _, _)) =>
        <Row marginBottom=24>
          <Col>
            <InfoContainer>
              <Heading value="Messages" size=Heading.H4 />
              <SeperatedLine mt=32 mb=24 />
              {switch content {
              | CommunityPoolSpend({recipient, amount}) =>
                <>
                  <Row marginBottom=24>
                    <Col col=Col.Four mbSm=8>
                      <Heading
                        value="Recipient Address"
                        size=Heading.H4
                        weight=Heading.Thin
                        color={theme.neutral_600}
                      />
                    </Col>
                    <Col col=Col.Eight>
                      <AddressRender address=recipient position=AddressRender.Subtitle />
                    </Col>
                  </Row>
                  <Row marginBottom=24>
                    <Col col=Col.Four mbSm=8>
                      <Heading
                        value="Amount" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
                      />
                    </Col>
                    <Col col=Col.Eight>
                      <AmountRender coins=amount pos=AmountRender.TxIndex />
                    </Col>
                  </Row>
                </>
              | SoftwareUpgrade({name, height}) =>
                <>
                  <Row marginBottom=24>
                    <Col col=Col.Four mbSm=8>
                      <Heading
                        value="Upgrade Name"
                        size=Heading.H4
                        weight=Heading.Thin
                        color={theme.neutral_600}
                      />
                    </Col>
                    <Col col=Col.Eight>
                      <Text value={name} size=Text.Body1 block=true />
                    </Col>
                  </Row>
                  <Row marginBottom=24>
                    <Col col=Col.Four mbSm=8>
                      <Heading
                        value="Upgrade Height"
                        size=Heading.H4
                        weight=Heading.Thin
                        color={theme.neutral_600}
                      />
                    </Col>
                    <Col col=Col.Eight>
                      <Text value={height->Belt.Int.toString} size=Text.Body1 block=true />
                    </Col>
                  </Row>
                </>
              | ParameterChange(parameters) =>
                <>
                  <Row marginBottom=24>
                    <Col col=Col.Twelve>
                      <div className={Styles.parameterChanges(theme, isDarkMode)}>
                        {parameters
                        ->Belt.Array.mapWithIndex((i, value) =>
                          <div key={i->Belt.Int.toString}>
                            <Text
                              value={value.subspace ++ "." ++ value.key ++ ": " ++ value.value}
                              size=Text.Body1
                              block=true
                              code=true
                            />
                            {i < parameters->Belt.Array.length - 1
                              ? <VSpacing size=Spacing.md />
                              : React.null}
                          </div>
                        )
                        ->React.array}
                      </div>
                    </Col>
                  </Row>
                </>
              | _ => <Text value="Unable to show the proposal messages" />
              }}
            </InfoContainer>
          </Col>
        </Row>
      | _ => React.null
      }}
      {switch allSub {
      | Data((
          {
            status,
            votingStartTime,
            votingEndTime,
            endTotalYes,
            endTotalYesPercent,
            endTotalNo,
            endTotalNoPercent,
            endTotalNoWithVeto,
            endTotalNoWithVetoPercent,
            endTotalAbstain,
            endTotalAbstainPercent,
            endTotalVote,
            totalBondedTokens,
          },
          {
            total,
            totalYes,
            totalYesPercent,
            totalNo,
            totalNoPercent,
            totalNoWithVeto,
            totalNoWithVetoPercent,
            totalAbstain,
            totalAbstainPercent,
          },
          bondedToken,
        )) =>
        switch status {
        | Deposit => React.null
        | Voting
        | Passed
        | Rejected
        | Inactive
        | Failed =>
          <>
            <Row>
              <Col col=Col.Six mb=24 mbSm=16>
                <InfoContainer>
                  <Heading value="Voting Overview" size=Heading.H4 />
                  <SeperatedLine mt=32 mb=24 />
                  <Row marginTop=38 alignItems=Row.Center>
                    <Col col=Col.Seven>
                      <div
                        className={Css.merge(list{
                          CssHelper.flexBoxSm(~justify=#spaceAround, ()),
                          CssHelper.flexBox(~justify=#flexEnd, ()),
                        })}>
                        {
                          let turnoutPercent = switch totalBondedTokens {
                          | Some(totalBondedTokensExn) =>
                            endTotalVote /. totalBondedTokensExn *. 100.
                          | None => total /. bondedToken->Coin.getBandAmountFromCoin *. 100.
                          }
                          <div className=Styles.chartContainer>
                            <TurnoutChart percent=turnoutPercent />
                          </div>
                        }
                      </div>
                    </Col>
                    <Col col=Col.Five>
                      <Row justify=Row.Center marginTopSm=32>
                        <Col mb=24>
                          <Heading
                            value="Total Vote"
                            size=Heading.H5
                            color={theme.neutral_600}
                            marginBottom=4
                          />
                          {switch MomentRe.diff(
                            MomentRe.momentNow(),
                            votingEndTime->Belt.Option.getWithDefault(MomentRe.momentNow()),
                            #seconds,
                          ) < 0. {
                          | true =>
                            <Text
                              value={total->Format.fPretty(~digits=2) ++ " BAND"}
                              size=Text.Body1
                              block=true
                              color={theme.neutral_900}
                            />
                          | false =>
                            <Text
                              value={endTotalVote->Format.fPretty(~digits=2) ++ " BAND"}
                              size=Text.Body1
                              block=true
                              color={theme.neutral_900}
                            />
                          }}
                        </Col>
                        <Col mb=24 mbSm=0 colSm=Col.Six>
                          <Heading
                            value="Voting Start"
                            size=Heading.H5
                            color={theme.neutral_600}
                            marginBottom=4
                          />
                          <Timestamp.Grid
                            size=Text.Body1
                            time={votingStartTime->Belt.Option.getWithDefault(MomentRe.momentNow())}
                            color={theme.neutral_900}
                          />
                        </Col>
                        <Col mbSm=0 colSm=Col.Six>
                          <Heading
                            value="Voting End"
                            size=Heading.H5
                            color={theme.neutral_600}
                            marginBottom=4
                          />
                          <Timestamp.Grid
                            size=Text.Body1
                            time={votingEndTime->Belt.Option.getWithDefault(MomentRe.momentNow())}
                            color={theme.neutral_900}
                          />
                        </Col>
                      </Row>
                    </Col>
                  </Row>
                </InfoContainer>
              </Col>
              <Col col=Col.Six mb=24 mbSm=16>
                <InfoContainer>
                  <div className={Css.merge(list{CssHelper.flexBox(~justify=#spaceBetween, ())})}>
                    <Heading value="Results" size=Heading.H4 />
                  </div>
                  <SeperatedLine mt=24 mb=35 />
                  <div className=Styles.resultContainer>
                    {switch totalBondedTokens {
                    | Some(_) =>
                      <>
                        <ProgressBar.Voting
                          label=VoteSub.Yes amount=endTotalYes percent=endTotalYesPercent
                        />
                        <ProgressBar.Voting
                          label=VoteSub.No amount=endTotalNo percent=endTotalNoPercent
                        />
                        <ProgressBar.Voting
                          label=VoteSub.NoWithVeto
                          amount=endTotalNoWithVeto
                          percent=endTotalNoWithVetoPercent
                        />
                        <ProgressBar.Voting
                          label=VoteSub.Abstain
                          amount=endTotalAbstain
                          percent=endTotalAbstainPercent
                        />
                      </>
                    | None =>
                      <>
                        <ProgressBar.Voting
                          label=VoteSub.Yes amount=totalYes percent=totalYesPercent
                        />
                        <ProgressBar.Voting
                          label=VoteSub.No amount=totalNo percent=totalNoPercent
                        />
                        <ProgressBar.Voting
                          label=VoteSub.NoWithVeto
                          amount=totalNoWithVeto
                          percent=totalNoWithVetoPercent
                        />
                        <ProgressBar.Voting
                          label=VoteSub.Abstain amount=totalAbstain percent=totalAbstainPercent
                        />
                      </>
                    }}
                  </div>
                </InfoContainer>
              </Col>
            </Row>
            <Row marginBottom=24>
              <Col>
                <VoteBreakdownTableOld proposalID />
              </Col>
            </Row>
          </>
        }
      | _ => React.null
      }}
      <Row marginBottom=24>
        <Col>
          <InfoContainer>
            <Heading value="Deposit" size=Heading.H4 />
            <SeperatedLine mt=32 mb=24 />
            <Row marginBottom=24 alignItems=Row.Center>
              <Col col=Col.Four mbSm=8>
                <Heading
                  value="Deposit Status"
                  size=Heading.H4
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
              </Col>
              <Col col=Col.Eight>
                {switch proposalSub {
                | Data({totalDeposit, status}) =>
                  switch status {
                  | ProposalSub.Deposit => <ProgressBar.Deposit totalDeposit />
                  | _ =>
                    <div className={CssHelper.flexBox()}>
                      <img alt="Success Icon" src=Images.success className=Styles.statusLogo />
                      <HSpacing size=Spacing.sm />
                      // TODO: remove hard-coded later
                      <Text value="Completed Min Deposit 1,000 BAND" size=Text.Body1 />
                    </div>
                  }
                | _ => <LoadingCensorBar width={isMobile ? 120 : 270} height=15 />
                }}
              </Col>
            </Row>
            <Row alignItems=Row.Center>
              <Col col=Col.Four mbSm=8>
                <Heading
                  value="Deposit End Time"
                  size=Heading.H4
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
              </Col>
              <Col col=Col.Eight>
                {switch proposalSub {
                | Data({depositEndTime}) =>
                  <Timestamp size=Text.Body1 timeOpt=Some(depositEndTime) />
                | _ => <LoadingCensorBar width=90 height=15 />
                }}
              </Col>
            </Row>
          </InfoContainer>
        </Col>
      </Row>
      <Row>
        <Col>
          <Table>
            <Heading value="Depositors" size=Heading.H4 marginTop=32 marginTopSm=16 />
            <SeperatedLine mt=32 mb=0 />
            <DepositorTable proposalID />
          </Table>
        </Col>
      </Row>
    </div>
  </Section>
}
