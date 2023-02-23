type content_inner_t =
  | PlainText(string)
  | Address(Address.t)
  | ValidatorAddress(Address.t)
  | Calldata(JsBuffer.t)
  | Coin(Belt.List.t<Coin.t>)
  | ID(React.element)

type content_t = {
  title: string,
  content: content_inner_t,
}

let renderValue = v => {
  switch v {
  | Address(address) => <AddressRender position=AddressRender.Subtitle address />
  | ValidatorAddress(address) => <AddressRender position=AddressRender.Subtitle address />
  | PlainText(content) => <Text value={content} />
  | Coin(amount) => <AmountRender coins={amount} />
  | ID(element) => element
  | _ => React.null
  }
}

module RenderContent = {
  @react.component
  let make = (~contents: array<content_t>) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    {
      contents
      ->Belt.Array.mapWithIndex((i, content) => {
        <Row key={i->Belt.Int.toString}>
          <Col col=Col.Four mb=24>
            <Heading
              value={content.title}
              size=Heading.H4
              weight=Heading.Regular
              marginBottom=8
              color=theme.neutral_600
            />
          </Col>
          <Col col=Col.Eight mb=24 key={i->Belt.Int.toString}> {renderValue(content.content)} </Col>
        </Row>
      })
      ->React.array
    }
  }
}

module CreateDataSourceMsg = {
  let getContentFail = (msg: Msg.CreateDataSource.t_base) => {
    [
      {title: "Owner", content: Address(msg.owner)},
      {title: "Treasury", content: Address(msg.treasury)},
      {
        title: "Fee",
        content: Coin(msg.fee),
      },
    ]
  }

  let getContentSuccess = (msg: Msg.CreateDataSource.t_success) => {
    [
      {title: "Owner", content: Address(msg.owner)},
      {title: "Treasury", content: Address(msg.treasury)},
      {
        title: "Fee",
        content: Coin(msg.fee),
      },
      {
        title: "Name",
        content: ID(
          <div className={CssHelper.flexBox()}>
            <TypeID.DataSource position=TypeID.Subtitle id={msg.id} />
            <HSpacing size=Spacing.sm />
            <Text value={msg.name} size=Text.Body1 />
          </div>,
        ),
      },
    ]
  }

  @react.component
  let make = (~msg: Msg.CreateDataSource.msg_t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

    let contents = switch msg {
    | Msg.CreateDataSource.Success(innerData) => getContentSuccess(innerData)
    | Msg.CreateDataSource.Failure(innerData) => getContentFail(innerData)
    }

    <RenderContent contents />
  }
}
