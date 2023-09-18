module Styles = {
  open CssJs

  let container = style(. [Media.mobile([margin2(~h=#px(-12), ~v=#zero)])])

  let header = (theme: Theme.t) =>
    style(. [
      borderBottom(#px(1), #solid, theme.neutral_100),
      selector("> div + div", [marginLeft(#px(32))]),
      Media.mobile([overflow(#auto), padding2(~v=#px(1), ~h=#px(15))]),
    ])

  let buttonContainer = (theme: Theme.t, active) =>
    style(. [
      display(#inlineFlex),
      justifyContent(#center),
      alignItems(#center),
      cursor(#pointer),
      padding3(~top=#zero, ~bottom=#px(16), ~h=#zero),
      borderBottom(#px(4), #solid, active ? theme.primary_600 : #transparent),
      Media.mobile([whiteSpace(#nowrap), padding2(~v=#px(24), ~h=#zero)]),
    ])

  let childrenContainer = style(. [Media.mobile([padding2(~h=#px(16), ~v=#zero)])])

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (~voteSub: Sub.variant<VoteSub.t>) => {
    <TBody>
      <Row alignItems=Row.Center>
        <Col col=Col.Five>
          {switch voteSub {
          | Data({voter, validator}) =>
            switch validator {
            | Some({moniker, operatorAddress, identity}) =>
              <ValidatorMonikerLink
                validatorAddress=operatorAddress
                moniker
                identity
                width={#percent(100.)}
                avatarWidth=20
              />
            | None => <AddressRender address=voter />
            }
          | _ => <LoadingCensorBar width=200 height=20 />
          }}
        </Col>
        <Col col=Col.Four>
          {switch voteSub {
          | Data({txHashOpt}) =>
            switch txHashOpt {
            | Some(txHash) => <TxLink txHash width=200 />
            | None => <Text value="Voted on Wenchang" />
            }
          | _ => <LoadingCensorBar width=200 height=20 />
          }}
        </Col>
        <Col col=Col.Three>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            {switch voteSub {
            | Data({timestampOpt}) =>
              switch timestampOpt {
              | Some(timestamp) =>
                <Timestamp
                  time=timestamp size=Text.Body2 weight=Text.Regular textAlign=Text.Right
                />
              | None => <Text value="Created on Wenchang" />
              }
            | _ => <LoadingCensorBar width=80 height=15 />
            }}
          </div>
        </Col>
      </Row>
    </TBody>
  }
}

module RenderBodyMobile = {
  @react.component
  let make = (~reserveIndex, ~voteSub: Sub.variant<VoteSub.t>) => {
    switch voteSub {
    | Data({voter, txHashOpt, timestampOpt, validator}) =>
      let key_ = voter->Address.toBech32

      <MobileCard
        values={
          open InfoMobileCard
          [
            (
              "Voter",
              {
                switch validator {
                | Some({operatorAddress, moniker, identity}) =>
                  Validator(operatorAddress, moniker, identity)
                | None => Address(voter, 200, #account)
                }
              },
            ),
            (
              "TX Hash",
              switch txHashOpt {
              | Some(txHash) => TxHash(txHash, 200)
              | None => Text("Voted on Wenchang")
              },
            ),
            (
              "Timestamp",
              switch timestampOpt {
              | Some(timestamp) => Timestamp(timestamp)
              | None => Text("Created on Wenchang")
              },
            ),
          ]
        }
        key=key_
        idx=key_
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [("Voter", Loading(230)), ("TX Hash", Loading(100)), ("Timestamp", Loading(100))]
        }
        key={reserveIndex->Belt.Int.toString}
        idx={reserveIndex->Belt.Int.toString}
      />
    }
  }
}

module TabButton = {
  @react.component
  let make = (~tab, ~active, ~setTab) => {
    let tabString = tab->VoteSub.toString(~withSpace=true)
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.buttonContainer(theme, active)} onClick={_ => setTab(_ => tab)}>
      <Text value=tabString weight={active ? Text.Semibold : Text.Regular} size=Text.Body1 />
    </div>
  }
}

@react.component
let make = (~proposalID) => {
  let isMobile = Media.isMobile()
  let (currentTab, setTab) = React.useState(_ => VoteSub.Yes)
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 5
  let votesSub = VoteSub.getList(proposalID, currentTab, ~pageSize, ~page, ())
  let voteCountSub = VoteSub.count(proposalID, currentTab)

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <Table>
    <div className=Styles.container>
      <div className={Css.merge(list{Styles.header(theme), CssHelper.flexBox(~wrap=#nowrap, ())})}>
        {[VoteSub.Yes, VoteSub.No, VoteSub.NoWithVeto, VoteSub.Abstain]
        ->Belt.Array.map(tab =>
          <TabButton key={tab->VoteSub.toString} tab setTab active={tab == currentTab} />
        )
        ->React.array}
      </div>
      <div className=Styles.childrenContainer>
        <div className=Styles.tableWrapper>
          {isMobile
            ? <Row marginBottom=16>
                <Col>
                  {switch voteCountSub {
                  | Data(voteCount) =>
                    <div className={CssHelper.flexBox()}>
                      <Text
                        block=true
                        value={voteCount->Belt.Int.toString}
                        weight=Text.Semibold
                        size=Text.Caption
                        transform=Text.Uppercase
                      />
                      <HSpacing size=Spacing.xs />
                      <Text
                        block=true
                        value="Voters"
                        weight=Text.Semibold
                        size=Text.Caption
                        transform=Text.Uppercase
                      />
                    </div>
                  | _ => <LoadingCensorBar width=100 height=15 />
                  }}
                </Col>
              </Row>
            : <THead>
                <Row alignItems=Row.Center>
                  <Col col=Col.Five>
                    {switch voteCountSub {
                    | Data(voteCount) =>
                      <div className={CssHelper.flexBox()}>
                        <Text
                          block=true
                          value={voteCount->Belt.Int.toString}
                          weight=Text.Semibold
                          size=Text.Caption
                          transform=Text.Uppercase
                        />
                        <HSpacing size=Spacing.xs />
                        <Text
                          block=true
                          value="Voters"
                          weight=Text.Semibold
                          size=Text.Caption
                          transform=Text.Uppercase
                        />
                      </div>
                    | _ => <LoadingCensorBar width=100 height=15 />
                    }}
                  </Col>
                  <Col col=Col.Four>
                    <Text
                      block=true
                      value="TX Hash"
                      weight=Text.Semibold
                      size=Text.Caption
                      transform=Text.Uppercase
                    />
                  </Col>
                  <Col col=Col.Three>
                    <Text
                      block=true
                      value="Timestamp"
                      weight=Text.Semibold
                      size=Text.Caption
                      transform=Text.Uppercase
                      align=Text.Right
                    />
                  </Col>
                </Row>
              </THead>}
          {switch votesSub {
          | Data(votes) =>
            votes->Belt.Array.length > 0
              ? votes
                ->Belt.Array.mapWithIndex((i, e) =>
                  isMobile
                    ? <RenderBodyMobile
                        reserveIndex=i key={e.voter->Address.toBech32} voteSub={Sub.resolve(e)}
                      />
                    : <RenderBody key={e.voter->Address.toBech32} voteSub={Sub.resolve(e)} />
                )
                ->React.array
              : <EmptyContainer height={#px(250)}>
                  <img
                    alt="No Voters"
                    src={isDarkMode ? Images.noDelegatorDark : Images.noDelegatorLight}
                    className=Styles.noDataImage
                  />
                  <Heading
                    size=Heading.H4
                    value="No Voters"
                    align=Heading.Center
                    weight=Heading.Regular
                    color={theme.neutral_600}
                  />
                </EmptyContainer>
          | _ =>
            Belt.Array.make(pageSize, Sub.NoData)
            ->Belt.Array.mapWithIndex((i, noData) =>
              isMobile
                ? <RenderBodyMobile reserveIndex=i key={i->Belt.Int.toString} voteSub=noData />
                : <RenderBody key={i->Belt.Int.toString} voteSub=noData />
            )
            ->React.array
          }}
          {switch voteCountSub {
          | Data(voteCount) =>
            <Pagination
              currentPage=page
              totalElement=voteCount
              pageSize
              onPageChange={newPage => setPage(_ => newPage)}
              onChangeCurrentPage={newPage => setPage(_ => newPage)}
            />
          | _ => React.null
          }}
        </div>
      </div>
    </div>
  </Table>
}
