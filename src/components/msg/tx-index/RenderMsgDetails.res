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

module CreateDataSource = {
  let factory = (msg: Msg.CreateDataSource.t<'a>, firsts) =>
    firsts->Belt.Array.concat([
      {title: "Owner", content: Address(msg.owner)},
      {title: "Treasury", content: Address(msg.treasury)},
      {title: "Fee", content: Coin(msg.fee)},
    ])

  let success = (msg: Msg.CreateDataSource.success_t) =>
    msg->factory([
      {
        title: "ID",
        content: ID(
          <div className={CssHelper.flexBox()}>
            <TypeID.DataSource position=TypeID.Subtitle id={msg.id} />
            <HSpacing size=Spacing.sm />
            <Text value={msg.name} size=Text.Body1 />
          </div>,
        ),
      },
    ])

  let failed = (msg: Msg.CreateDataSource.failed_t) =>
    msg->factory([
      {
        title: "Name",
        content: PlainText(msg.name),
      },
    ])
}

let getContent = msg => {
  switch msg {
  | Msg.CreateDataSourceMsg(m) =>
    switch m {
    | Msg.CreateDataSource.Success(innerData) => CreateDataSource.success(innerData)
    | Msg.CreateDataSource.Failure(innerData) => CreateDataSource.failed(innerData)
    }
  | Msg.RequestMsg(m) => []
  | Msg.SendMsg(_) => []
  | Msg.UnknownMsg => []
  }
}

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
