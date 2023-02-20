module BodyDesktop = {
  @react.component
  let make = (~reserveIndex, ~blockSub: Sub.variant<BlockSub.t>) => {
    let ({ThemeContext.theme}, _) = React.useContext(ThemeContext.context)
    <TBody
      key={
        switch blockSub {
        | Data({height}) => height -> ID.Block.toString
        | Error(_) | Loading | NoData => reserveIndex -> string_of_int
        }
      }>
      <Row alignItems=Row.Center>
        <Col col=Col.Two>
          {switch blockSub {
          | Data({height}) => <TypeID.Block id=height />
          | Error(_) | Loading | NoData => <LoadingCensorBar width=65 height=15 />
          }}
        </Col>
        <Col col=Col.Four>
          {switch blockSub {
          | Data({hash}) =>
            <Text
              value={hash -> Hash.toHex(~upper=true)}
              weight=Text.Medium
              block=true
              code=true
              ellipsis=true
              color={theme.neutral_600}
            />
          | Error(_) | Loading | NoData => <LoadingCensorBar fullWidth=true height=15 />
          }}
        </Col>
        <Col col=Col.Three>
          {switch blockSub {
          | Data({validator}) =>
            <ValidatorMonikerLink
              validatorAddress={validator.operatorAddress}
              moniker={validator.moniker}
              identity={validator.identity}
            />
          | Error(_) | Loading | NoData => <LoadingCensorBar fullWidth=true height=15 />
          }}
        </Col>
        <Col col=Col.One>
          <div className={CssHelper.flexBox(~justify=#center, ())}>
            {switch blockSub {
            | Data({txn}) =>
              <Text
                value={txn -> Format.iPretty}
                code=true
                weight=Text.Medium
                color={theme.neutral_900}
              />
            | Error(_) | Loading | NoData => <LoadingCensorBar width=40 height=15 />
            }}
          </div>
        </Col>
        <Col col=Col.Two>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            {switch blockSub {
            | Data({timestamp}) =>
              <Timestamp time=timestamp size=Text.Body2 weight=Text.Regular textAlign=Text.Right />
            | Error(_) | Loading | NoData => <LoadingCensorBar width=130 height=15 />
            }}
          </div>
        </Col>
      </Row>
    </TBody>
  }
}

module BodyMobile = {
  @react.component
  let make = (~reserveIndex, ~blockSub: Sub.variant<BlockSub.t>) => {
    switch blockSub {
    | Data({height, timestamp, hash, validator, txn}) =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Block", Height(height)),
            ("Block Hash", BlockHash(hash)),
            (
              "Proposer",
              Validator(validator.operatorAddress, validator.moniker, validator.identity),
            ),
            ("Txn", Count(txn)),
            ("Timestamp", Timestamp(timestamp)),
          ]
        }
        key={height -> ID.Block.toString}
        idx={height -> ID.Block.toString}
      />
    | Error(_) | Loading | NoData =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Block", Loading(70)),
            ("Block Hash", Loading(100)),
            ("Timestamp", Loading(166)),
            ("Proposer", Loading(136)),
            ("Txn", Loading(20)),
          ]
        }
        key={reserveIndex -> string_of_int}
        idx={reserveIndex -> string_of_int}
      />
    }
  }
}

@react.component
let make = () => {
  let blocksSub = BlockSub.getList(~pageSize=10, ~page=1)
  let isMobile = Media.isMobile()

  let ({ThemeContext.theme}, _) = React.useContext(ThemeContext.context)

  <Section ptSm=32 pbSm=32>
    <div className=CssHelper.container id="blocksSection">
      <div className=CssHelper.mobileSpacing>
        <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
          <Col col=Col.Twelve>
            <Heading value="Blocks" size=Heading.H2 marginBottom=16 marginBottomSm=8 />
            {switch blocksSub {
            | Data(blocks) =>
              <Heading
                value={
                  blocks
                  ->Belt.Array.get(0)
                  ->Belt.Option.mapWithDefault(0, ({height}) => height -> ID.Block.toInt)
                  ->Format.iPretty
                  ++ " In total"
                }
                size=Heading.H3
                weight=Heading.Thin
                color={theme.neutral_600}
              />
            | Error(_) | Loading | NoData => <LoadingCensorBar width=65 height=21 />
            }}
          </Col>
        </Row>
        <Table>
          {isMobile
            ? React.null
            : <THead>
                <Row alignItems=Row.Center>
                  <Col col=Col.Two>
                    <Text
                      block=true
                      value="Block"
                      size=Text.Caption
                      weight=Text.Semibold
                      transform=Text.Uppercase
                    />
                  </Col>
                  <Col col=Col.Four>
                    <Text
                      block=true
                      value="Block Hash"
                      size=Text.Caption
                      weight=Text.Semibold
                      transform=Text.Uppercase
                    />
                  </Col>
                  <Col col=Col.Three>
                    <Text
                      block=true
                      value="Proposer"
                      size=Text.Caption
                      weight=Text.Semibold
                      transform=Text.Uppercase
                    />
                  </Col>
                  <Col col=Col.One>
                    <Text
                      block=true
                      value="Txn"
                      size=Text.Caption
                      weight=Text.Semibold
                      align=Text.Center
                      transform=Text.Uppercase
                    />
                  </Col>
                  <Col col=Col.Two>
                    <Text
                      block=true
                      value="Timestamp"
                      size=Text.Caption
                      weight=Text.Semibold
                      align=Text.Right
                      transform=Text.Uppercase
                    />
                  </Col>
                </Row>
              </THead>
            }
          {switch blocksSub {
           | Data(blocks) =>
              blocks
              ->Belt.Array.mapWithIndex((i, e) =>
                  isMobile ? <BodyMobile reserveIndex=i blockSub=Sub.resolve(e)/>
                  : <BodyDesktop reserveIndex=i blockSub=Sub.resolve(e)/>
                )
              ->React.array
           | Error(_) | Loading | NoData =>
              Belt.Array.make(10, React.null)
              ->Belt.Array.mapWithIndex((i, _) =>
                  isMobile ? <BodyMobile reserveIndex=i blockSub=Sub.NoData/>
                  : <BodyDesktop reserveIndex=i blockSub=Sub.NoData/>
                )
              ->React.array
           }}
        </Table>
      </div>
    </div>
  </Section>
}

