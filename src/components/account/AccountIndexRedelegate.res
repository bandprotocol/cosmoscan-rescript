module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
}

module RenderBody = {
  @react.component
  let make = (~redelegateListSub: Sub.variant<RedelegateSub.redelegate_list_t>) =>
    <TBody>
      <Row alignItems=Row.Center>
        <Col col=Col.Three>
          {switch redelegateListSub {
          | Data({
              srcValidator: {
                operatorAddress: srcAddress,
                moniker: srcMoniker,
                identity: srcIdentity,
              },
            }) =>
            <ValidatorMonikerLink
              validatorAddress=srcAddress
              moniker=srcMoniker
              identity=srcIdentity
              width=#px(200)
              avatarWidth=30
              size=Text.Body1
            />
          | _ => <LoadingCensorBar width=200 height=20 />
          }}
        </Col>
        <Col col=Col.Three>
          <div className={CssHelper.flexBox()}>
            {switch redelegateListSub {
            | Data({
                dstValidator: {
                  operatorAddress: dstAddress,
                  moniker: dstMoniker,
                  identity: dstIdentity,
                },
              }) =>
              <ValidatorMonikerLink
                validatorAddress=dstAddress moniker=dstMoniker identity=dstIdentity width=#px(200)
              />

            | _ => <LoadingCensorBar width=200 height=20 />
            }}
          </div>
        </Col>
        <Col col=Col.Three>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            {switch redelegateListSub {
            | Data({amount}) => <Text value={amount->Coin.getBandAmountFromCoin->Format.fPretty} />
            | _ => <LoadingCensorBar width=145 height=20 />
            }}
          </div>
        </Col>
        <Col col=Col.Three>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            {switch redelegateListSub {
            | Data({completionTime}) =>
              <Timestamp.Grid
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
  let make = (~reserveIndex, ~redelegateListSub: Sub.variant<RedelegateSub.redelegate_list_t>) =>
    switch redelegateListSub {
    | Data({
        srcValidator: {operatorAddress: srcAddress, moniker: srcMoniker, identity: srcIdentity},
        dstValidator: {operatorAddress: dstAddress, moniker: dstMoniker, identity: dstIdentity},
        completionTime,
        amount,
      }) =>
      let key_ =
        srcAddress->Address.toBech32 ++
          (dstAddress->Address.toBech32 ++
          (completionTime->MomentRe.Moment.toISOString ++
            (amount->Coin.getBandAmountFromCoin->Js.Float.toString ++
            reserveIndex->Belt.Int.toString)))
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Source\nValidator", Validator(srcAddress, srcMoniker, srcIdentity)),
            ("Destination\nValidator", Validator(dstAddress, dstMoniker, dstIdentity)),
            ("Amount\n(BAND)", Coin({value: list{amount}, hasDenom: false})),
            ("Redelegate\nComplete At", Timestamp(completionTime)),
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
            ("Source\nValidator", Loading(230)),
            ("Destination\nValidator", Loading(100)),
            ("Amount\n(BAND)", Loading(100)),
            ("Redelegate\nComplete At", Loading(230)),
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

  let redelegateCountSub = RedelegateSub.getRedelegateCountByDelegator(address, currentTime)
  let redelegateListSub = RedelegateSub.getRedelegationByDelegator(
    address,
    currentTime,
    ~pageSize,
    ~page,
    (),
  )

  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  <div className=Styles.tableWrapper>
    {isMobile
      ? <Row marginBottom=16>
          <Col>
            {switch redelegateCountSub {
            | Data(redelegateCount) =>
              <div className={CssHelper.flexBox()}>
                <Text
                  block=true
                  value={redelegateCount->Belt.Int.toString}
                  weight=Text.Semibold
                  size=Text.Caption
                  transform=Text.Uppercase
                />
                <HSpacing size=Spacing.xs />
                <Text
                  block=true
                  value="Redelegate Entries"
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
            <Col col=Col.Three>
              {switch redelegateCountSub {
              | Data(redelegateCount) =>
                <div className={CssHelper.flexBox()}>
                  <Text
                    block=true
                    value={redelegateCount->Belt.Int.toString}
                    weight=Text.Semibold
                    size=Text.Caption
                    transform=Text.Uppercase
                  />
                  <HSpacing size=Spacing.xs />
                  <Text
                    block=true
                    value="Redelegate Entries"
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
                value="Desination Validator"
                weight=Text.Semibold
                size=Text.Caption
                transform=Text.Uppercase
              />
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
                value="Redelegate Complete At"
                weight=Text.Semibold
                size=Text.Caption
                transform=Text.Uppercase
                align=Text.Right
              />
            </Col>
          </Row>
        </THead>}
    {switch redelegateListSub {
    | Data(redelegateList) =>
      redelegateList->Belt.Array.size > 0
        ? redelegateList
          ->Belt.Array.mapWithIndex((i, e) => {
            let componentKey =
              e.srcValidator.operatorAddress->Address.toBech32 ++
                (e.dstValidator.operatorAddress->Address.toBech32 ++
                (e.amount->Coin.getBandAmountFromCoin->Js.Float.toString ++
                  (e.completionTime->MomentRe.Moment.format(Config.timestampDisplayFormat, _) ++
                  i->Belt.Int.toString)))
            isMobile
              ? <RenderBodyMobile
                  redelegateListSub={Sub.resolve(e)} reserveIndex=i key=componentKey
                />
              : <RenderBody redelegateListSub={Sub.resolve(e)} key=componentKey />
          })
          ->React.array
        : <EmptyContainer>
            <img
              src={isDarkMode ? Images.noDataDark : Images.noDataLight}
              alt="No Data"
              className=Styles.noDataImage
            />
            <Heading
              size=Heading.H4
              value="No redelegation"
              align=Heading.Center
              weight=Heading.Regular
              color=theme.neutral_600
            />
          </EmptyContainer>
    | _ =>
      Belt.Array.make(pageSize, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile redelegateListSub=noData reserveIndex=i key={i->Belt.Int.toString} />
          : <RenderBody redelegateListSub=noData key={i->Belt.Int.toString} />
      )
      ->React.array
    }}
    {switch redelegateCountSub {
    | Data(redelegateCount) =>
      let pageCount = Page.getPageCount(redelegateCount, pageSize)
      <Pagination currentPage=page pageCount onPageChange={newPage => setPage(_ => newPage)} />
    | _ => React.null
    }}
  </div>
}
