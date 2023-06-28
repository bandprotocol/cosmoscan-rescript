module Styles = {
  open CssJs

  let card = (theme: Theme.t, isDarkMode) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.neutral_000),
      padding(#px(24)),
      borderRadius(#px(8)),
      boxShadow(
        Shadow.box(
          ~x=#zero,
          ~y=#px(2),
          ~blur=#px(4),
          ~spread=#px(1),
          Css.rgba(16, 18, 20, #num(0.15)),
        ),
      ),
      height(#percent(100.)),
      display(#flex),
      alignItems(#flexStart),
      justifyContent(#center),
      flexDirection(#column),
    ])

  let channelInfo = style(. [
    display(#flex),
    flexDirection(#row),
    alignItems(#center),
    justifyContent(#spaceBetween),
    width(#percent(100.)),
  ])

  let chainLogo = style(. [width(#px(24)), height(#px(24))])

  let chainWrapper = style(. [marginBottom(#px(16))])

  let packetWrapper = style(. [marginBottom(#px(40))])
}

module ChainLogo = {
  @react.component
  let make = (~chain, ~channel, ()) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let chainlogo = VerifiedChain.parse(chain, channel)

    <div
      className={Css.merge(list{
        CssHelper.flexBox(~justify=#flexStart, ~align=#center, ~direction=#row, ()),
        Styles.chainWrapper,
      })}>
      <div className="chain-logo">
        {switch chainlogo {
        | (_, "Unknown") => <Avatar moniker={chain} identity={chain} width={24} />
        | (img, _) => <img alt="target chain" src=img className=Styles.chainLogo />
        }}
      </div>
      <HSpacing size=Spacing.sm />
      <Text
        value={chain}
        size=Text.Xl
        weight={Semibold}
        color={theme.neutral_900}
        transform={Capitalize}
      />
    </div>
  }
}

@react.component
let make = (~chainID, ~port, ~channel) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let channelInfo = ChannelSub.getChannelInfo(~port, ~channel, ())
  let inComingCount = IBCPacketQuery.incomingCount(~port, ~channel, ~packetType="%%", ())
  let outgoingCount = IBCPacketQuery.outgoingCount(~port, ~channel, ~packetType="%%", ())

  let allQuery = Query.all2(inComingCount, outgoingCount)

  <Section ptSm=32 pbSm=32>
    <div className=CssHelper.container id="section_relayer_details">
      <Row marginBottom=40 marginBottomSm=24>
        <Col col=Col.Six colSm=Col.Twelve mb={24} mbSm={16}>
          <div className={Styles.card(theme, isDarkMode)}>
            {switch channelInfo {
            | Data(info) =>
              switch info {
              | Data({counterpartyChannel, port, channel, counterpartyPort}) =>
                <div className={CssHelper.fullWidth}>
                  <div
                    className={CssHelper.flexBox(
                      ~justify=#spaceBetween,
                      ~align=#center,
                      ~direction=#row,
                      (),
                    )}>
                    <ChainLogo chain={"band"} channel={""} />
                    <ChainLogo chain={chainID} channel={counterpartyChannel} />
                  </div>
                  <Row alignItems=Row.Center>
                    <Col col=Col.Four colSm=Col.Five>
                      <div className="src-channel">
                        <Text value={port} size=Text.Body1 block=true color={theme.neutral_900} />
                        <VSpacing size=Spacing.xs />
                        <Text
                          size=Text.Xxl
                          value={channel}
                          code=true
                          color={theme.primary_600}
                          weight={Bold}
                        />
                      </div>
                    </Col>
                    <Col col=Col.Four colSm=Col.Two>
                      <div className="channel-arrow">
                        <div className={CssHelper.flexBox(~justify=#center, ())}>
                          <img
                            alt="arrow"
                            src={isDarkMode
                              ? Images.connectionArrowLight
                              : Images.connectionArrowDark}
                            className="img-fullWidth"
                          />
                        </div>
                      </div>
                    </Col>
                    <Col col=Col.Four colSm=Col.Five>
                      {
                        let port = Ellipsis.format(~text=counterpartyPort, ~limit=15, ())
                        <Text
                          value={port} size=Text.Body1 align={Right} color={theme.neutral_900}
                        />
                      }
                      <VSpacing size=Spacing.xs />
                      <Text
                        size=Text.Xxl
                        value={counterpartyChannel}
                        ellipsis=true
                        block=true
                        code=true
                        color={theme.primary_600}
                        weight={Bold}
                        align={Right}
                      />
                    </Col>
                  </Row>
                  <div className={Styles.channelInfo} />
                </div>
              | _ => React.null
              }
            | _ => <LoadingCensorBar width=100 height=20 />
            }}
          </div>
        </Col>
        <Col col=Col.Three colSm=Col.Six mb={24} mbSm={24}>
          <div className={Styles.card(theme, isDarkMode)}>
            <Text value="Transactions" size=Text.Xl />
            <VSpacing size=Spacing.sm />
            <div>
              {switch allQuery {
              | Data(inCount, outCount) =>
                <Text
                  size=Text.Xxxl
                  value={(inCount + outCount)->Format.iPretty}
                  code=true
                  color={theme.neutral_900}
                  weight={Bold}
                />
              | Error(_) =>
                <Text
                  value={"N/A"} code=true color={theme.neutral_900} weight={Bold} size=Text.Xxxl
                />
              | _ => <LoadingCensorBar width=100 height=20 />
              }}
            </div>
          </div>
        </Col>
        <Col col=Col.Three colSm=Col.Six mb={24} mbSm={24}>
          <div className={Styles.card(theme, isDarkMode)}>
            <Text value="Last Tx Update" size=Text.Xl />
            <VSpacing size=Spacing.sm />
            {switch channelInfo {
            | Data(info) =>
              switch info {
              | Data({lastUpdate}) =>
                lastUpdate->MomentRe.Moment.year === 1970
                  ? <Text
                      value={"N/A"} code=true color={theme.neutral_900} weight={Bold} size=Text.Xxxl
                    />
                  : <TimeAgos
                      time={lastUpdate}
                      size=Text.Xxxl
                      color={theme.neutral_900}
                      code=true
                      weight={Bold}
                    />
              | _ =>
                <Text
                  value={"N/A"} code=true color={theme.neutral_900} weight={Bold} size=Text.Xxxl
                />
              }

            | _ => <LoadingCensorBar width=100 height=20 />
            }}
          </div>
        </Col>
      </Row>
    </div>
    <div className={Css.merge(list{CssHelper.container})} id="section_incoming_packets">
      <div className={Styles.packetWrapper}>
        <IncomingSection chainID channel port />
      </div>
    </div>
    <div className={Css.merge(list{CssHelper.container})} id="section_outgoing_packets">
      <div className={Styles.packetWrapper}>
        <OutgoingSection chainID channel port />
      </div>
    </div>
  </Section>
}
