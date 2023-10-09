module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
}

module RenderBody = {
  @react.component
  let make = (~blockSub: Sub.variant<BlockSub.t>, ~templateColumns) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <TBody>
      <TableGrid templateColumns>
        {switch blockSub {
        | Data({height}) => <TypeID.Block id=height />
        | _ => <LoadingCensorBar width=100 height=15 />
        }}
        {switch blockSub {
        | Data({hash}) =>
          <Text
            value={hash->Hash.toHex(~upper=true)}
            block=true
            code=true
            size=Text.Body1
            ellipsis=true
            color={theme.neutral_900}
          />
        | _ => <LoadingCensorBar width=500 height=15 />
        }}
        <div className={CssHelper.flexBox(~justify=#center, ())}>
          {switch blockSub {
          | Data({txn}) =>
            <Text
              value={txn->Format.iPretty}
              align=Text.Center
              color={theme.neutral_900}
              size=Text.Body1
            />
          | _ => <LoadingCensorBar width=20 height=15 />
          }}
        </div>
        <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
          {switch blockSub {
          | Data({timestamp}) => <Timestamp time=timestamp textAlign=Right size=Text.Body1 />
          | _ => <LoadingCensorBar width=80 height=15 />
          }}
        </div>
      </TableGrid>
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
            ("Time", Timestamp(timestamp)),
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

  let templateColumns = [#fr(0.5), #fr(2.25), #fr(0.5), #fr(0.75)]

  <div className=Styles.tableWrapper>
    {isMobile
      ? React.null
      : <THead height=36>
          <TableGrid templateColumns>
            <Text block=true value="Block" weight=Text.Semibold />
            <Text block=true value="Block Hash" weight=Text.Semibold />
            <Text block=true value="Txn" weight=Text.Semibold align=Text.Center />
            <Text block=true value="Time" weight=Text.Semibold align=Text.Right />
          </TableGrid>
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
            : <RenderBody
                key={e.height |> ID.Block.toString} blockSub={Sub.resolve(e)} templateColumns
              />
        )
        ->React.array}
      </>
    | _ =>
      Belt.Array.make(pageSize, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile key={Belt.Int.toString(i)} reserveIndex=i blockSub=noData />
          : <RenderBody key={Belt.Int.toString(i)} blockSub=noData templateColumns />
      )
      ->React.array
    }}
  </div>
}
