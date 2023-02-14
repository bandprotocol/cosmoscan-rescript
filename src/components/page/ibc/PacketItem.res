module Styles = {
  open CssJs

  let paperStyle = (theme: Theme.t, isDarkMode) =>
    style(. [
      backgroundColor(isDarkMode ? theme.white : theme.white),
      borderRadius(#px(10)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), rgba(16, 18, 20, #num(0.15)))),
      padding(#px(16)),
      border(#px(1), #solid, isDarkMode ? hex("F3F4F6") : hex("F3F4F6")), // TODO: will change to theme color
      //   border(#px(1), #solid, isDarkMode ? theme.secondaryBg : theme.textSecondary),
      //   padding2(~v=#px(8), ~h=#px(10)),
      //   minWidth(#px(153)),
      //   justifyContent(#spaceBetween),
      //   alignItems(#center),
      //   position(#relative),
      //   cursor(#pointer),
      //   zIndex(5),
      //   Media.mobile([padding2(~v=#px(5), ~h=#px(10))]),
      //   Media.smallMobile([minWidth(#px(90))]),
    ])

  let cardContainer = style(. [position(#relative), selector(" > div + div", [marginTop(#px(12))])])

  let infoContainer = style(. [height(#percent(100.))])

  let badgeContainer = style(. [selector(" > div", [margin(#zero)])])

  let failText = style(. [cursor(#pointer), selector("> span", [marginRight(#px(8))])])
  let portChannelWrapper = style(. [
    display(#flex),
    flexDirection(#row),
    justifyContent(#spaceBetween),
    alignItems(#center),
    selector(" > div", [marginRight(#px(8))]),
  ])

  let channelSource = style(. [textAlign(#left), marginRight(#px(8))])
  let channelDest = style(. [textAlign(#right), marginLeft(#px(8))])
  let packetInnerColumn = style(. [
    // minWidth(#calc((#sub, #percent(16.), #px(8)))),
    minWidth(#px(120)),
    marginLeft(#px(8)),
    marginRight(#px(8)),
    textAlign(#center),
  ])

  let largeColumn = style(. [minWidth(#px(245))])
  let smallColumn = style(. [minWidth(#px(80))])
  let leftAlign = style(. [textAlign(#left)])
}

@react.component
let make = (~packetSub: Sub.variant<IBCQuery.t>) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  // let errorMsg = reason => reason->IBCPacketError->OpenModal->dispatchModal

  <div className={Styles.paperStyle(theme, isDarkMode)}>
    <div className={Css.merge(list{CssHelper.flexBox(~align=#center, ~justify=#spaceBetween, ())})}>
      <div className={Css.merge(list{Styles.packetInnerColumn, Styles.leftAlign})}>
        {switch packetSub {
        | Data({txHash}) =>
          <TxLink txHash={txHash->Belt.Option.getExn} width=100 size=Text.Sm fullHash=false />
        | _ => <LoadingCensorBar width=110 height=20 radius=50 />
        }}
      </div>
      <div className=Styles.packetInnerColumn>
        {switch packetSub {
        | Data({counterPartyChainID}) => <Text value={counterPartyChainID} />
        | _ => <LoadingCensorBar width=110 height=20 radius=50 />
        }}
      </div>
      <div className={Css.merge(list{Styles.packetInnerColumn, Styles.largeColumn})}>
        {switch packetSub {
        | Data({srcPort, srcChannel, dstPort, dstChannel}) =>
          <div className={Css.merge(list{Styles.portChannelWrapper, Styles.packetInnerColumn})}>
            <div className=Styles.channelSource>
              <Text value={srcPort} />
              <br />
              <Text value={srcChannel} color={theme.baseBlue} weight={Text.Semibold} />
            </div>
            <div>
              <img alt="arrow" src={isDarkMode ? Images.longArrowDark : Images.longArrowLight} />
            </div>
            <div className=Styles.channelDest>
              <Text value={dstPort} />
              <br />
              <Text value={dstChannel} color={theme.baseBlue} weight={Text.Semibold} />
            </div>
          </div>

        | _ => <LoadingCensorBar width=110 height=20 radius=50 />
        }}
      </div>
      <div className=Styles.packetInnerColumn>
        {switch packetSub {
        | Data({sequence}) => <Text value={sequence->Belt.Int.toString} />
        | _ => <LoadingCensorBar width=110 height=20 radius=50 />
        }}
      </div>
      <div className=Styles.packetInnerColumn>
        <div className=Styles.badgeContainer>
          {switch packetSub {
          | Data({packetType}) => <MsgBadge name={packetType->IBCQuery.getPacketTypeText} />
          | _ => <LoadingCensorBar width=110 height=20 radius=50 />
          }}
        </div>
      </div>
      <div className=Styles.packetInnerColumn>
        {switch packetSub {
        | Data({
            srcChannel,
            dstChannel,
            srcPort,
            dstPort,
            sequence,
            blockHeight,
            counterPartyChainID,
            packetType,
            txHash,
            acknowledgement: acknowledgementOpt,
            data,
          }) =>
          <>
            {switch packetType {
            | OracleRequest =>
              {
                let acknowledgement = acknowledgementOpt->Belt.Option.getExn

                switch acknowledgement.data {
                | Request({requestID: requestIDOpt}) =>
                  let requestID = requestIDOpt->Belt.Option.getExn
                  Some(<TypeID.Request id={requestID->ID.Request.fromInt} position=TypeID.Text />)
                | _ => None
                }
              }->Belt.Option.getWithDefault(React.null)
            | OracleResponse =>
              switch data {
              | Response(response) =>
                <>
                  <TypeID.Request
                    id={response.requestID->ID.Request.fromInt} position=TypeID.Text block=false
                  />
                  // <PacketDetail.ResolveStatus status={response.resolveStatus} />
                </>
              | _ => React.null
              }
            | FungibleToken
            | _ => React.null
            }}
          </>
        | _ => <LoadingCensorBar width=110 height=20 radius=50 />
        }}
      </div>
      <div className={Css.merge(list{Styles.packetInnerColumn, Styles.smallColumn})}>
        {switch packetSub {
        | Data({acknowledgement}) =>
          switch acknowledgement {
          | Some({status, reason}) =>
            switch status {
            | Success => <img alt="Success Icon" src=Images.success />
            | Pending => <img alt="Pending Icon" src=Images.pending />
            | Fail =>
              <div
                className={Css.merge(list{CssHelper.flexBox(), Styles.failText})}
                // onClick={_ => errorMsg(reason->Belt.Option.getExn)}>
                onClick={_ => Js.log("Show Error")}>
                <Text value="View Error Message" color=Theme.failColor />
                <img alt="Fail Icon" src=Images.fail />
              </div>
            }
          | _ => React.null
          }
        | _ => React.null
        }}
      </div>
    </div>
  </div>
}
