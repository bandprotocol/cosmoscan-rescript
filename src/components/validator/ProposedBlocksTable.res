module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
}

module RenderBody = {
  @react.component
  let make = (~blockSub: Sub.variant<BlockSub.t>) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <TBody>
      <Row alignItems=Row.Center>
        <Col col=Col.Two>
          {switch blockSub {
          | Data({height}) => <TypeID.Block id=height />
          | _ => <LoadingCensorBar width=135 height=15 />
          }}
        </Col>
        <Col col=Col.Seven>
          {switch blockSub {
          | Data({hash}) =>
            <Text
              value={hash->Hash.toHex(~upper=true)}
              block=true
              code=true
              ellipsis=true
              color={theme.neutral_900}
            />
          | _ => <LoadingCensorBar width=522 height=15 />
          }}
        </Col>
        <Col col=Col.One>
          <div className={CssHelper.flexBox(~justify=#center, ())}>
            {switch blockSub {
            | Data({txn}) =>
              <Text value={txn->Format.iPretty} align=Text.Center color={theme.neutral_900} />
            | _ => <LoadingCensorBar width=20 height=15 />
            }}
          </div>
        </Col>
        <Col col=Col.Two>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            {switch blockSub {
            | Data({timestamp}) =>
              <Timestamp time=timestamp size=Text.Body2 weight=Text.Regular textAlign=Text.Right />
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
  let make = (~reserveIndex, ~blockSub: Sub.variant<BlockSub.t>) => {
    let isSmallMobile = Media.isSmallMobile()

    switch blockSub {
    | Data({height, timestamp, hash, txn}) =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Block", Height(height)),
            ("Block Hash", TxHash(hash, isSmallMobile ? 170 : 200)),
            ("Txn", Count(txn)),
            ("Timestamp", Timestamp(timestamp)),
          ]
        }
        key={height->ID.Block.toString}
        idx={height->ID.Block.toString}
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Block", Loading(isSmallMobile ? 170 : 200)),
            ("Block Hash", Loading(166)),
            ("Txn", Loading(20)),
            ("Timestamp", Loading(166)),
          ]
        }
        key={reserveIndex->Belt.Int.toString}
        idx={reserveIndex->Belt.Int.toString}
      />
    }
  }
}

@react.component
let make = (~consensusAddress) => {
  let pageSize = 10
  let isMobile = Media.isMobile()

  let blocksSub = {
    switch consensusAddress {
    | Some(address) => BlockSub.getListByConsensusAddress(~address, ~page=1, ~pageSize, ())
    | None => Sub.NoData
    }
  }

  Js.log(blocksSub)

  <div className=Styles.tableWrapper>
    {isMobile
      ? React.null
      : <THead>
          <Row alignItems=Row.Center>
            <Col col=Col.Two>
              <Text
                block=true
                value="Block"
                weight=Text.Semibold
                transform=Text.Uppercase
                size=Text.Caption
              />
            </Col>
            <Col col=Col.Seven>
              <Text
                block=true
                value="Block Hash"
                weight=Text.Semibold
                transform=Text.Uppercase
                size=Text.Caption
              />
            </Col>
            <Col col=Col.One>
              <Text
                block=true
                value="Txn"
                weight=Text.Semibold
                transform=Text.Uppercase
                size=Text.Caption
                align=Text.Center
              />
            </Col>
            <Col col=Col.Two>
              <Text
                block=true
                value="Timestamp"
                weight=Text.Semibold
                transform=Text.Uppercase
                size=Text.Caption
                align=Text.Right
              />
            </Col>
          </Row>
        </THead>}
    {switch blocksSub {
    | Data(blocks) =>
      <>
        {blocks
        ->Belt.Array.mapWithIndex((i, e) =>
          isMobile
            ? <RenderBodyMobile
                key={e.height |> ID.Block.toString} reserveIndex=i blockSub={Sub.resolve(e)}
              />
            : <RenderBody key={e.height |> ID.Block.toString} blockSub={Sub.resolve(e)} />
        )
        ->React.array}
      </>
    | _ =>
      Belt.Array.make(pageSize, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile key={Belt.Int.toString(i)} reserveIndex=i blockSub=noData />
          : <RenderBody key={Belt.Int.toString(i)} blockSub=noData />
      )
      ->React.array
    }}
  </div>
}
