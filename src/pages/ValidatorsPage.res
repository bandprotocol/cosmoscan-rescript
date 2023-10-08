module Styles = {
  open CssJs
  let infoContainer = style(. [
    height(#percent(100.)),
    display(#flex),
    flexDirection(#column),
    justifyContent(#spaceBetween),
  ])
}

let getPrevDay = _ =>
  MomentRe.momentNow()
  ->MomentRe.Moment.defaultUtc
  ->MomentRe.Moment.subtract(~duration=MomentRe.duration(1->Belt.Int.toFloat, #days))
  ->MomentRe.Moment.format(Config.timestampUseFormat, _)

@react.component
let make = () => {
  let isMobile = Media.isMobile()
  let ({ThemeContext.theme: theme}, _) = ThemeContext.use()
  let currentTime =
    React.useContext(TimeContext.context)->MomentRe.Moment.format(Config.timestampUseFormat, _)

  let (prevDayTime, setPrevDayTime) = React.useState(getPrevDay)
  let (searchTerm, setSearchTerm) = React.useState(_ => "")
  let (sortedBy, setSortedBy) = React.useState(_ => ValidatorsTable.VotingPowerDesc)
  let (isActive, setIsActive) = React.useState(_ => true)

  React.useEffect0(() => {
    let timeOutID = Js.Global.setInterval(() => {setPrevDayTime(getPrevDay)}, 60_000)
    Some(() => {Js.Global.clearInterval(timeOutID)})
  })

  let infoSub = React.useContext(GlobalContext.context)

  let validatorsSub = ValidatorSub.getList(~isActive, ())
  let validatorsCountSub = ValidatorSub.count()
  let activeValidatorCountSub = ValidatorSub.countByActive(true)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()
  let avgBlockTimeSub = BlockSub.getAvgBlockTime(prevDayTime, currentTime)
  let latestBlock = BlockSub.getLatest()
  let votesBlockSub = ValidatorSub.getListVotesBlock()

  let topPartAllSub = Sub.all5(
    validatorsCountSub,
    activeValidatorCountSub,
    bondedTokenCountSub,
    avgBlockTimeSub,
    latestBlock,
  )

  let allSub = Sub.all3(topPartAllSub, validatorsSub, votesBlockSub)
  let infoBondSub = Sub.all2(infoSub, bondedTokenCountSub)

  <Section>
    <div className=CssHelper.container id="validatorsSection">
      // Heading
      <Row alignItems=Row.Center marginBottom=24 marginBottomSm=24>
        <Col col=Col.Twelve>
          <div className={CssHelper.flexBox()}>
            <Heading value="Validators" size=Heading.H1 weight=Heading.Semibold />
            <HSpacing size=Spacing.lg />
            {switch topPartAllSub {
            | Data((validatorCount, _, _, _, _)) =>
              <div className={CssHelper.mt(~size=4, ())}>
                <Text value={validatorCount->Belt.Int.toString ++ " In total"} size=Text.Xl />
              </div>
            | _ => <LoadingCensorBar width=65 height=20 />
            }}
          </div>
        </Col>
      </Row>
      // Infomation Cards
      <Row marginBottom=40>
        <Col col=Col.Three colSm=Col.Six mbSm=24>
          <InfoContainer style=Styles.infoContainer px=24 py=16 pxSm=16 pySm=16 radius=8>
            <Heading
              value="Active Validators"
              size=Heading.H4
              marginBottom=8
              weight=Regular
              color={theme.neutral_600}
            />
            {switch topPartAllSub {
            | Data((_, isActiveValidatorCount, _, _, _)) =>
              <Text
                value={isActiveValidatorCount->Belt.Int.toString}
                size=Text.Xxxl
                block=true
                weight=Text.Bold
                color={theme.neutral_900}
              />
            | _ => <LoadingCensorBar width=100 height=24 />
            }}
          </InfoContainer>
        </Col>
        <Col col=Col.Three colSm=Col.Six mbSm=24>
          <InfoContainer style=Styles.infoContainer px=24 py=16 pxSm=16 pySm=16 radius=8>
            <Heading
              value="BAND Bonded"
              size=Heading.H4
              marginBottom=8
              weight=Regular
              color={theme.neutral_600}
            />
            {switch infoBondSub {
            | Data({financial}, bondedTokenCount) =>
              <div className={CssHelper.flexBox()}>
                // TODO: update formatter
                <Text
                  value={bondedTokenCount->Coin.getBandAmountFromCoin->Format.fCurrency}
                  size=Text.Xxxl
                  block=true
                  weight=Text.Bold
                  color={theme.neutral_900}
                />
                // TODO: update formatter
                <Text
                  value={"/" ++ financial.totalSupply->Format.fCurrency}
                  size=Text.Xl
                  block=true
                  code=true
                />
                {isMobile
                  ? React.null
                  : <Text
                      value={"(" ++
                      (bondedTokenCount->Coin.getBandAmountFromCoin /.
                      financial.totalSupply *. 100.)->Format.fPretty(~digits=2) ++ "%)"}
                      size=Text.Xl
                      block=true
                      code=true
                    />}
              </div>
            | _ => <LoadingCensorBar width=100 height=24 />
            }}
          </InfoContainer>
        </Col>
        <Col col=Col.Three colSm=Col.Six>
          <InfoContainer style=Styles.infoContainer px=24 py=16 pxSm=16 pySm=16 radius=8>
            <Heading
              value="Est. APR"
              size=Heading.H4
              marginBottom=8
              weight=Regular
              color={theme.neutral_600}
            />
            // TODO: wire up Est. APR
            {switch topPartAllSub {
            | Data((_, _, _, _, {inflation})) =>
              <Text
                value={(inflation *. 100.)->Format.fPretty(~digits=2) ++ "%"}
                size=Text.Xxxl
                color={theme.neutral_900}
                block=true
                code=true
                weight=Text.Bold
              />
            | _ => <LoadingCensorBar width=100 height=24 />
            }}
          </InfoContainer>
        </Col>
        <Col col=Col.Three colSm=Col.Six>
          <InfoContainer style=Styles.infoContainer px=24 py=16 pxSm=16 pySm=16 radius=8>
            <Heading
              value="24h AVG Block Time"
              size=Heading.H4
              color={theme.neutral_600}
              weight=Regular
              marginBottom=8
            />
            {switch topPartAllSub {
            | Data((_, _, _, avgBlockTime, _)) =>
              <Text
                value={avgBlockTime->Format.fPretty(~digits=2) ++ " secs"}
                size=Text.Xxxl
                color={theme.neutral_900}
                block=true
                weight=Text.Bold
                code=true
              />
            | _ => <LoadingCensorBar width=100 height=24 />
            }}
          </InfoContainer>
        </Col>
      </Row>
      <Row marginTop=32 marginBottom=16>
        <Col col=Col.Six colSm=Col.Eight mbSm=16>
          <SearchInput placeholder="Search Validator" onChange=setSearchTerm />
        </Col>
        {isMobile
          ? <Col col=Col.Six colSm=Col.Four mbSm=16>
              <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
                // // TODO: modify this in new validator page UI
                // <SortableDropdown
                //   sortedBy
                //   setSortedBy
                //   sortList={
                //     open ValidatorsTable
                //     list{
                //       (NameAsc, getName(NameAsc)),
                //       (NameDesc, getName(NameDesc)),
                //       (VotingPowerAsc, getName(VotingPowerAsc)),
                //       (VotingPowerDesc, getName(VotingPowerDesc)),
                //       (CommissionAsc, getName(CommissionAsc)),
                //       (CommissionDesc, getName(CommissionDesc)),
                //       (UptimeAsc, getName(UptimeAsc)),
                //       (UptimeDesc, getName(UptimeDesc)),
                //     }
                //   }
                // />
              </div>
            </Col>
          : React.null}
        <Col col=Col.Six>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            <ToggleButton state=isActive setState=setIsActive nameArray=["Active", "Inactive"] />
          </div>
        </Col>
      </Row>
      <InfoContainer>
        <Table>
          <ValidatorsTable allSub searchTerm sortedBy setSortedBy />
        </Table>
      </InfoContainer>
    </div>
  </Section>
}
