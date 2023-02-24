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

module Request = {
  let factory = (msg: Msg.Request.t<'a, 'b, 'c>, firsts) =>
    firsts->Belt.Array.concat([{title: "Owner", content: Address(msg.sender)}])

  let success = (msg: Msg.Request.success_t) =>
    msg->factory([
      {
        title: "Request ID",
        content: ID(<TypeID.Request position=TypeID.Subtitle id={msg.id} />),
      },
      {
        title: "Oracle Script ID",
        content: ID(
          <div className={CssHelper.flexBox()}>
            <TypeID.OracleScript position=TypeID.Subtitle id={msg.oracleScriptID} />
            <HSpacing size=Spacing.sm />
            <Text value={msg.oracleScriptName} size=Text.Body1 />
          </div>,
        ),
      },
    ])

  let failed = (msg: Msg.Request.failed_t) => msg->factory([])
}

let getContent = msg => {
  switch msg {
  | Msg.CreateDataSourceMsg(m) =>
    switch m {
    | Msg.CreateDataSource.Success(innerData) => CreateDataSource.success(innerData)
    | Msg.CreateDataSource.Failure(innerData) => CreateDataSource.failed(innerData)
    }
  | Msg.RequestMsg(m) =>
    switch m {
    | Msg.Request.Success(innerData) => Request.success(innerData)
    | Msg.Request.Failure(innerData) => Request.failed(innerData)
    }
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
