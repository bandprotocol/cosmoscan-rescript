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
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
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

  <Section ptSm=32 pbSm=32>
    <div className=CssHelper.container id="validatorsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          <Heading value="All Validators" size=Heading.H2 marginBottom=16 marginBottomSm=8 />
          {switch topPartAllSub {
          | Data((validatorCount, _, _, _, _)) =>
            <Heading
              value={validatorCount->Belt.Int.toString ++ " In total"}
              size=Heading.H3
              weight=Heading.Thin
              color={theme.neutral_600}
            />
          | _ => <LoadingCensorBar width=65 height=21 />
          }}
        </Col>
      </Row>
      <Row marginBottom=24>
        <Col>
          <Row>
            <Col col=Col.Three colSm=Col.Six mbSm=24>
              <InfoContainer style=Styles.infoContainer>
                <Heading
                  value="Active Validators"
                  size=Heading.H4
                  marginBottom=28
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
                {switch topPartAllSub {
                | Data((_, isActiveValidatorCount, _, _, _)) =>
                  <Text
                    value={isActiveValidatorCount->Belt.Int.toString}
                    size=Text.Xxxl
                    block=true
                    weight=Text.Semibold
                    color={theme.neutral_900}
                  />
                | _ => <LoadingCensorBar width=100 height=24 />
                }}
              </InfoContainer>
            </Col>
            <Col col=Col.Three colSm=Col.Six mbSm=24>
              <InfoContainer style=Styles.infoContainer>
                <Heading
                  value="Bonded Tokens"
                  size=Heading.H4
                  marginBottom=28
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
                {switch topPartAllSub {
                | Data((_, _, bondedTokenCount, _, _)) =>
                  <Text
                    value={bondedTokenCount->Coin.getBandAmountFromCoin->Format.fCurrency}
                    size=Text.Xxxl
                    block=true
                    weight=Text.Semibold
                    color={theme.neutral_900}
                  />
                | _ => <LoadingCensorBar width=100 height=24 />
                }}
              </InfoContainer>
            </Col>
            <Col col=Col.Three colSm=Col.Six>
              <InfoContainer style=Styles.infoContainer>
                <Heading
                  value="Inflation Rate"
                  size=Heading.H4
                  marginBottom=28
                  weight=Heading.Thin
                  color={theme.neutral_600}
                />
                {switch topPartAllSub {
                | Data((_, _, _, _, {inflation})) =>
                  <Text
                    value={(inflation *. 100.)->Format.fPretty(~digits=2) ++ "%"}
                    size=Text.Xxxl
                    color={theme.neutral_900}
                    block=true
                    weight=Text.Semibold
                  />

                | _ => <LoadingCensorBar width=100 height=24 />
                }}
              </InfoContainer>
            </Col>
            <Col col=Col.Three colSm=Col.Six>
              <InfoContainer style=Styles.infoContainer>
                <Heading
                  value="24 Hour AVG Block Time"
                  size=Heading.H4
                  weight=Heading.Thin
                  color={theme.neutral_600}
                  marginBottom=28
                />
                {switch topPartAllSub {
                | Data((_, _, _, avgBlockTime, _)) =>
                  <Text
                    value={avgBlockTime->Format.fPretty(~digits=2) ++ " secs"}
                    size=Text.Xxxl
                    color={theme.neutral_900}
                    block=true
                    weight=Text.Semibold
                  />
                | _ => <LoadingCensorBar width=100 height=24 />
                }}
              </InfoContainer>
            </Col>
          </Row>
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
