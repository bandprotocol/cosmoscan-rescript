module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (~unbondingListSub: Sub.variant<UnbondingSub.unbonding_list_t>) =>
    <TBody>
      <Row alignItems=Row.Center>
        <Col col=Col.Six>
          {switch unbondingListSub {
          | Data({validator: {operatorAddress, moniker, identity}}) =>
            <div className={CssHelper.flexBox()}>
              <ValidatorMonikerLink
                validatorAddress=operatorAddress
                moniker
                identity
                width=#px(300)
                avatarWidth=30
                size=Text.Body1
              />
            </div>
          | _ => <LoadingCensorBar width=200 height=20 />
          }}
        </Col>
        <Col col=Col.Three>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            {switch unbondingListSub {
            | Data({amount}) => <Text value={amount->Coin.getBandAmountFromCoin->Format.fPretty} />
            | _ => <LoadingCensorBar width=200 height=20 />
            }}
          </div>
        </Col>
        <Col col=Col.Three>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            {switch unbondingListSub {
            | Data({completionTime}) =>
              <Timestamp
                time=completionTime size=Text.Body2 weight=Text.Regular textAlign=Text.Right
              />
            | _ => <LoadingCensorBar width=200 height=20 />
            }}
          </div>
        </Col>
      </Row>
    </TBody>
}

module RenderBodyMobile = {
  @react.component
  let make = (~reserveIndex, ~unbondingListSub: Sub.variant<UnbondingSub.unbonding_list_t>) =>
    switch unbondingListSub {
    | Data({validator: {operatorAddress, moniker, identity}, amount, completionTime}) =>
      let key_ =
        operatorAddress->Address.toBech32 ++
          (completionTime->MomentRe.Moment.toISOString ++
          reserveIndex->Belt.Int.toString)
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Validator", Validator(operatorAddress, moniker, identity)),
            ("Amount\n(BAND)", Coin({value: list{amount}, hasDenom: false})),
            ("Unbonded At", Timestamp(completionTime)),
          ]
        }
        key=key_
        idx=key_
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Validator", Loading(230)),
            ("Amount\n(BAND)", Loading(230)),
            ("Unbonded At", Loading(230)),
          ]
        }
        key={reserveIndex->Belt.Int.toString}
        idx={reserveIndex->Belt.Int.toString}
      />
    }
}

@react.component
let make = (~address) => {
  let isMobile = Media.isMobile()
  let currentTime =
    React.useContext(TimeContext.context)->MomentRe.Moment.format(Config.timestampUseFormat, _)

  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 5

  let unbondingListSub = UnbondingSub.getUnbondingByDelegator(
    address,
    currentTime,
    ~pageSize,
    ~page,
    (),
  )
  let unbondingCountSub = UnbondingSub.getUnbondingCountByDelegator(address, currentTime)

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <div className=Styles.tableWrapper>
    {isMobile
      ? <Row marginBottom=16>
          <Col>
            {switch unbondingCountSub {
            | Data(unbondingCount) =>
              <div className={CssHelper.flexBox()}>
                <Text
                  block=true
                  value={unbondingCount->Belt.Int.toString}
                  weight=Text.Semibold
                  size=Text.Caption
                  transform=Text.Uppercase
                />
                <HSpacing size=Spacing.xs />
                <Text
                  block=true
                  value="Unbonding Entries"
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
            <Col col=Col.Six>
              {switch unbondingCountSub {
              | Data(unbondingCount) =>
                <div className={CssHelper.flexBox()}>
                  <Text
                    block=true
                    value={unbondingCount->Belt.Int.toString}
                    weight=Text.Semibold
                    size=Text.Caption
                    transform=Text.Uppercase
                  />
                  <HSpacing size=Spacing.xs />
                  <Text
                    block=true
                    value="Unbonding Entries"
                    weight=Text.Semibold
                    size=Text.Caption
                    transform=Text.Uppercase
                  />
                </div>
              | _ => <LoadingCensorBar width=100 height=15 />
              }}
            </Col>
            <Col col=Col.Three>
              <Text
                block=true
                value="Amount (BAND)"
                weight=Text.Semibold
                size=Text.Caption
                transform=Text.Uppercase
                align=Text.Right
              />
            </Col>
            <Col col=Col.Three>
              <Text
                block=true
                value="Unbonded At"
                weight=Text.Semibold
                size=Text.Caption
                transform=Text.Uppercase
                align=Text.Right
              />
            </Col>
          </Row>
        </THead>}
    {switch unbondingListSub {
    | Data(unbondingList) =>
      unbondingList->Belt.Array.length > 0
        ? unbondingList
          ->Belt.Array.mapWithIndex((i, e) =>
            isMobile
              ? <RenderBodyMobile
                  key={e.validator.operatorAddress->Address.toBech32 ++
                    (e.completionTime->MomentRe.Moment.toISOString ++
                    i->Belt.Int.toString)}
                  reserveIndex=i
                  unbondingListSub={Sub.resolve(e)}
                />
              : <RenderBody
                  key={e.validator.operatorAddress->Address.toBech32 ++
                    (e.completionTime->MomentRe.Moment.toISOString ++
                    i->Belt.Int.toString)}
                  unbondingListSub={Sub.resolve(e)}
                />
          )
          ->React.array
        : <EmptyContainer>
            <img
              src={isDarkMode ? Images.noDataDark : Images.noDataLight}
              alt="No Data"
              className=Styles.noDataImage
            />
            <Heading
              size=Heading.H4
              value="No Unbonding"
              align=Heading.Center
              weight=Heading.Regular
              color=theme.neutral_600
            />
          </EmptyContainer>
    | _ =>
      Belt.Array.make(pageSize, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile key={i->Belt.Int.toString} reserveIndex=i unbondingListSub=noData />
          : <RenderBody key={i->Belt.Int.toString} unbondingListSub=noData />
      )
      ->React.array
    }}
    {switch unbondingCountSub {
    | Data(unbondingCount) =>
      let pageCount = Page.getPageCount(unbondingCount, pageSize)
      <Pagination currentPage=page pageCount onPageChange={newPage => setPage(_ => newPage)} />
    | _ => React.null
    }}
  </div>
}
