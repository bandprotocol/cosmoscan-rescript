module Styles = {
  open CssJs
  let card = style(. [height(#percent(100.)), padding2(~v=#px(24), ~h=#px(32))])

  let link = style(. [fontSize(#px(14))])

  let bondedTokenContainer = style(. [height(#percent(100.))])
  let avatarContainer = style(. [
    position(#relative),
    marginRight(#px(24)),
    Media.mobile([marginRight(#zero), marginBottom(#px(16))]),
  ])
  let rankContainer = style(. [
    backgroundColor(Theme.baseBlue),
    borderRadius(#percent(50.)),
    position(#absolute),
    right(#zero),
    bottom(#zero),
    width(#px(26)),
    height(#px(26)),
  ])

  // Oracle Status
  let oracleStatusBox = (isActive, theme: Theme.t) => {
    style(. [
      backgroundColor(isActive ? theme.successColor : theme.failColor),
      borderRadius(#px(50)),
      padding2(~v=#px(2), ~h=#px(10)),
    ])
  }

  let customContainer = style(. [height(#percent(100.))])

  let chartWrapper = style(. [minHeight(px(220)), selector("> div", [width(#percent(100.))])])
}

@react.component
let make = (~address, ~hashtag: Route.validator_tab_t) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  let validatorSub = ValidatorSub.get(address)
  let bondedTokenCountSub = ValidatorSub.getTotalBondedAmount()
  // let oracleReportsCountSub = ReportSub.ValidatorReport.count(address)
  // for finding validator rank
  let validatorsSub = ValidatorSub.getList(~isActive=true, ())

  let isMobile = Media.isMobile()

  let allSub = Sub.all3(validatorSub, validatorSub, bondedTokenCountSub)

  <Section>
    <div className=CssHelper.container>
      <Heading value="Validator Details" size=Heading.H2 marginBottom=40 marginBottomSm=24 />
      <Row marginBottom=40 marginBottomSm=16 alignItems=Row.Center>
        <Col col=Col.Nine>
          <div
            className={Css.merge(list{
              CssHelper.flexBox(),
              CssHelper.flexBoxSm(~direction=#column, ()),
            })}>
            <div className=Styles.avatarContainer>
              {switch allSub {
              | Data(({identity, moniker}, validators, _)) =>
                let rankOpt =
                  validators
                  ->Belt.Array.keepMap(({moniker: m, rank}) => moniker === m ? Some(rank) : None)
                  ->Belt.Array.get(0)
                <>
                  <Avatar moniker identity width=100 widthSm=80 />
                  {switch rankOpt {
                  | Some(rank) =>
                    <div
                      className={Css.merge(. [
                        Styles.rankContainer,
                        CssHelper.flexBox(~justify=#center, ()),
                      ])}>
                      <Text value={rank->Belt.Int.toString} color={theme.white} />
                    </div>
                  | None => React.null
                  }}
                </>
              | _ => <LoadingCensorBar width=100 height=100 radius=100 />
              }}
            </div>
            {switch allSub {
            | Data(({moniker}, _, _)) =>
              <Heading
                size=Heading.H3
                value=moniker
                marginBottomSm=8
                align={isMobile ? Heading.Center : Heading.Left}
              />
            | _ => <LoadingCensorBar width=270 height=20 />
            }}
          </div>
        </Col>
        <Col col=Col.Three>
          <div
            className={Css.merge(. [
              CssHelper.flexBox(~justify=#flexEnd, ()),
              CssHelper.flexBoxSm(~justify=#center, ()),
            ])}>
            {switch allSub {
            | Data(({isActive}, _)) =>
              <div className={CssHelper.flexBox()}>
                <div className={CssHelper.flexBox(~justify=#center, ())}>
                  <img
                    alt={isActive ? "Active Validator Icon" : "Inactive Validator Icon"}
                    src={isActive ? Images.activeValidatorLogo : Images.inactiveValidatorLogo}
                  />
                </div>
                <HSpacing size=Spacing.sm />
                <Text value={isActive ? "Active" : "Inactive"} color={theme.textSecondary} />
              </div>
            | _ => <LoadingCensorBar width=60 height=20 />
            }}
            <HSpacing size=Spacing.md />
            {switch allSub {
            | Data(({oracleStatus}, _)) =>
              <div
                className={Css.merge(. [
                  CssHelper.flexBox(~justify=#center, ()),
                  Styles.oracleStatusBox(oracleStatus, theme),
                ])}>
                <Text value="Oracle" color={theme.white} />
                <HSpacing size=Spacing.sm />
                <Icon
                  name={oracleStatus ? "fas fa-check" : "fal fa-times"} color={theme.white} size=10
                />
              </div>
            | _ => <LoadingCensorBar width=75 height=20 />
            }}
          </div>
        </Col>
      </Row>
    </div>
  </Section>
}
