module Styles = {
  open CssJs

  let paperStyle = (theme: Theme.t, isDarkMode) =>
    style(. [
      backgroundColor(isDarkMode ? theme.neutral_100 : theme.white),
      borderRadius(#px(10)),
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), rgba(16, 18, 20, #num(0.15)))),
      padding(#px(16)),
      border(#px(1), #solid, theme.neutral_100),
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
  let channelDest = style(. [
    textAlign(#right),
    marginLeft(#px(8)),
    Media.mobile([textAlign(#left)]),
  ])
  let packetInnerColumn = style(. [
    minWidth(#px(120)),
    marginLeft(#px(8)),
    marginRight(#px(8)),
    textAlign(#center),
  ])

  let largeColumn = style(. [minWidth(#px(245))])
  let smallColumn = style(. [minWidth(#px(80))])
  let leftAlign = style(. [textAlign(#left)])
  let packetMobileItem = style(. [
    selector("> div", [borderBottom(#px(1), #solid, hex("E5E7EB"))]), // TODO: change to theme color
    selector("> div:last-child", [borderBottom(#zero, solid, #transparent)]),
  ])
  let packetInnerMobile = style(. [
    width(#percent(100.)),
    paddingTop(#px(16)),
    paddingBottom(#px(16)),
    display(#flex),
    flexDirection(#row),
    alignItems(#center),
    selector(" > div:first-child", [width(#px(90)), marginRight(#px(16))]),
  ])
}

module MobilePacketItem = {
  // Module contents
  @react.component
  let make = (~packetSub: Sub.variant<IBCQuery.t>) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    <div className={Css.merge(list{Styles.paperStyle(theme, isDarkMode), Styles.packetMobileItem})}>
      <div className={Css.merge(list{Styles.packetInnerMobile})}>
        <div>
          {switch packetSub {
          | Data({packetType}) =>
            switch packetType {
            | OracleRequest
            | InterchainAccount
            | FungibleToken =>
              <Text value="Tx Hash" size=Text.Body1 weight=Text.Semibold />
            | OracleResponse => <Text value="Block ID" size=Text.Body1 weight=Text.Semibold />
            | _ => React.null
            }
          | _ => React.null
          }}
        </div>
        <div>
          {switch packetSub {
          | Data({packetType, txHash, blockHeight}) =>
            switch packetType {
            | OracleRequest
            | InterchainAccount
            | FungibleToken =>
              <TxLink
                txHash={txHash->Belt.Option.getExn} width=100 size=Text.Body2 fullHash=false
              />
            | OracleResponse => <TypeID.Block id=blockHeight position=TypeID.Text />
            | _ => React.null
            }
          | _ => <LoadingCensorBar width=110 height=20 radius=50 />
          }}
        </div>
      </div>
      <div className={Css.merge(list{Styles.packetInnerMobile})}>
        <div>
          <Text value="Counterparty Chain ID" size=Text.Body1 weight=Text.Semibold />
        </div>
        <div>
          {switch packetSub {
          | Data({counterPartyChainID}) => <Text value={counterPartyChainID} />
          | _ => <LoadingCensorBar width=110 height=20 radius=50 />
          }}
        </div>
      </div>
      <div className={Css.merge(list{Styles.packetInnerMobile})}>
        <div>
          <Text value="Port & Channel" size=Text.Body1 weight=Text.Semibold />
        </div>
        <div>
          {switch packetSub {
          | Data({srcPort, srcChannel, dstPort, dstChannel}) =>
            <div className={Css.merge(list{Styles.portChannelWrapper})}>
              <div
                className={
                  open CssJs
                  Css.merge(list{Styles.channelSource, style(. [width(#px(80))])})
                }>
                <Text value={srcPort} />
                <br />
                <Text value={srcChannel} color={theme.primary_600} weight={Text.Semibold} />
              </div>
              <div
                className={
                  open CssJs
                  Css.merge(list{style(. [marginLeft(#px(8))])})
                }>
                <Icon name="far fa-arrow-right" color={theme.neutral_600} />
              </div>
              <div
                className={
                  open CssJs
                  Css.merge(list{Styles.channelDest, style(. [width(#px(80))])})
                }>
                <Text value={dstPort} />
                <br />
                <Text value={dstChannel} color={theme.primary_600} weight={Text.Semibold} />
              </div>
            </div>

          | _ => <LoadingCensorBar width=110 height=20 radius=50 />
          }}
        </div>
      </div>
      <div className={Css.merge(list{Styles.packetInnerMobile})}>
        <div>
          <Text value="Sequence" size=Text.Body1 weight=Text.Semibold />
        </div>
        <div>
          {switch packetSub {
          | Data({sequence}) => <Text value={sequence->Belt.Int.toString} />
          | _ => <LoadingCensorBar width=110 height=20 radius=50 />
          }}
        </div>
      </div>
      <div className={Css.merge(list{Styles.packetInnerMobile})}>
        <div>
          <Text value="Packet Type" size=Text.Body1 weight=Text.Semibold />
        </div>
        <div>
          {switch packetSub {
          | Data({packetType}) => <MsgBadge name={packetType->IBCQuery.getPacketTypeText} />
          | _ => <LoadingCensorBar width=110 height=20 radius=50 />
          }}
        </div>
      </div>
      <div className={Css.merge(list{Styles.packetInnerMobile})}>
        {switch packetSub {
        | Data({packetType, acknowledgement: acknowledgementOpt, data}) =>
          <>
            {switch packetType {
            | OracleRequest =>
              <>
                <div>
                  <Text value="Request ID" size=Text.Body1 weight=Text.Semibold />
                </div>
                <div>
                  {{
                    let acknowledgement = acknowledgementOpt->Belt.Option.getExn

                    switch acknowledgement.data {
                    | Request({requestID: requestIDOpt}) =>
                      let requestID = requestIDOpt->Belt.Option.getExn
                      Some(
                        <TypeID.Request id={requestID->ID.Request.fromInt} position=TypeID.Text />,
                      )
                    | _ => None
                    }
                  }->Belt.Option.getWithDefault(React.null)}
                </div>
              </>
            | OracleResponse =>
              switch data {
              | Response(response) =>
                <>
                  <div>
                    <Text value="Request ID" size=Text.Body1 weight=Text.Semibold />
                  </div>
                  <div>
                    <TypeID.Request
                      id={response.requestID->ID.Request.fromInt} position=TypeID.Text block=false
                    />
                  </div>
                </>
              | _ => React.null
              }
            | _ => React.null
            }}
          </>
        | _ => <LoadingCensorBar width=110 height=20 radius=50 />
        }}
      </div>
      <div className={Css.merge(list{Styles.packetInnerMobile})}>
        <div>
          <Text value="Status" size=Text.Body1 weight=Text.Semibold />
        </div>
        <div>
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
                  <Text value="View Error Message" color=theme.error_600 />
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
}

module DesktopPacketItem = {
  // Module contents

  @react.component
  let make = (~packetSub: Sub.variant<IBCQuery.t>) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
    let isTablet = Media.isTablet()
    <div className={Styles.paperStyle(theme, isDarkMode)}>
      <div
        className={Css.merge(list{CssHelper.flexBox(~align=#center, ~justify=#spaceBetween, ())})}>
        <div className={Css.merge(list{Styles.packetInnerColumn, Styles.leftAlign})}>
          {switch packetSub {
          | Data({packetType, txHash, blockHeight}) =>
            switch packetType {
            | OracleRequest
            | InterchainAccount
            | FungibleToken =>
              <TxLink
                txHash={txHash->Belt.Option.getExn} width=100 size=Text.Body2 fullHash=false
              />
            | OracleResponse => <TypeID.Block id=blockHeight position=TypeID.Text />
            | _ => React.null
            }
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
                <Text value={srcChannel} color={theme.primary_600} weight={Text.Semibold} />
              </div>
              <div>
                <img alt="arrow" src={isDarkMode ? Images.longArrowDark : Images.longArrowLight} />
              </div>
              <div className=Styles.channelDest>
                <Text value={dstPort} />
                <br />
                <Text value={dstChannel} color={theme.primary_600} weight={Text.Semibold} />
              </div>
            </div>

          | _ => <LoadingCensorBar width=110 height=20 radius=50 />
          }}
        </div>
        {switch isTablet {
        | true => React.null
        | false =>
          <div className=Styles.packetInnerColumn>
            {switch packetSub {
            | Data({sequence}) => <Text value={sequence->Belt.Int.toString} />
            | _ => <LoadingCensorBar width=110 height=20 radius=50 />
            }}
          </div>
        }}
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
          | Data({packetType, acknowledgement: acknowledgementOpt, data}) =>
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
                  </>
                | _ => React.null
                }
              | _ => React.null
              }}
            </>
          | _ => <LoadingCensorBar width=110 height=20 radius=50 />
          }}
        </div>
        <div className={Css.merge(list{Styles.packetInnerColumn, Styles.smallColumn})}>
          {switch packetSub {
          | Data({acknowledgement, packetType, data}) =>
            switch packetType {
            | OracleResponse =>
              switch data {
              | Response(response) =>
                switch response.resolveStatus {
                | IBCQuery.OracleResponseData.Success =>
                  <img alt="Success Icon" src=Images.success />
                | Fail => <img alt="Fail Icon" src=Images.fail />
                | _ => React.null
                }
              | _ => React.null
              }

            | OracleRequest
            | FungibleToken
            | _ =>
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
                    <Text value="View Error Message" color=theme.error_600 />
                    <img alt="Fail Icon" src=Images.fail />
                  </div>
                }
              | _ => React.null
              }
            }
          | _ => <LoadingCensorBar width=110 height=20 radius=50 />
          }}
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (~packetSub: Sub.variant<IBCQuery.t>) => {
  let isTablet = Media.isTablet()
  <div>
    {switch isTablet {
    | true => <MobilePacketItem packetSub />
    | false => <DesktopPacketItem packetSub />
    }}
  </div>
}
