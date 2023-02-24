module CreateDataSourceMsg = {
  @react.component
  let make = (~dataSource: MsgDecoder.CreateDataSource.success_t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <Row>
      <Col col=Col.Six mb=24>
        <Heading
          value="Owner"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AddressRender position=AddressRender.Subtitle address=dataSource.owner />
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Name"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <div className={CssHelper.flexBox()}>
          <TypeID.DataSource position=TypeID.Subtitle id=dataSource.id />
          <HSpacing size=Spacing.sm />
          <Text value=dataSource.name size=Text.Body1 />
        </div>
      </Col>
      <Col col=Col.Six mbSm=24>
        <Heading
          value="Treasury"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AddressRender position=AddressRender.Subtitle address=dataSource.treasury />
      </Col>
      <Col col=Col.Six>
        <Heading
          value="Fee"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AmountRender coins=dataSource.fee />
      </Col>
    </Row>
  }
}

module CreateDataSourceFailMsg = {
  @react.component
  let make = (~dataSource: MsgDecoder.CreateDataSource.fail_t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <Row>
      <Col col=Col.Six mb=24>
        <Heading
          value="Owner"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AddressRender position=AddressRender.Subtitle address=dataSource.owner />
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Name"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <Text value=dataSource.name size=Text.Body1 />
      </Col>
      <Col col=Col.Six mbSm=24>
        <Heading
          value="Treasury"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AddressRender position=AddressRender.Subtitle address=dataSource.treasury />
      </Col>
      <Col col=Col.Six>
        <Heading
          value="Fee"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AmountRender coins=dataSource.fee />
      </Col>
    </Row>
  }
}

module EditDataSourceMsg = {
  @react.component
  let make = (~dataSource: MsgDecoder.EditDataSource.t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <Row>
      <Col col=Col.Six mb=24>
        <Heading
          value="Owner"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AddressRender position=AddressRender.Subtitle address=dataSource.owner />
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Name"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <div className={CssHelper.flexBox()}>
          <TypeID.DataSource position=TypeID.Subtitle id=dataSource.id />
          {dataSource.name == Config.doNotModify
            ? React.null
            : <>
                <HSpacing size=Spacing.sm />
                <Text value=dataSource.name size=Text.Body1 />
              </>}
        </div>
      </Col>
      <Col col=Col.Six mbSm=24>
        <Heading
          value="Treasury"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AddressRender position=AddressRender.Subtitle address=dataSource.treasury />
      </Col>
      <Col col=Col.Six>
        <Heading
          value="Fee"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AmountRender coins=dataSource.fee />
      </Col>
    </Row>
  }
}

module CreateOracleScriptMsg = {
  @react.component
  let make = (~oracleScript: MsgDecoder.CreateOracleScript.success_t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <Row>
      <Col col=Col.Six mbSm=24>
        <Heading
          value="Owner"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AddressRender position=AddressRender.Subtitle address=oracleScript.owner />
      </Col>
      <Col col=Col.Six>
        <Heading
          value="Name"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <div className={CssHelper.flexBox()}>
          <TypeID.OracleScript position=TypeID.Subtitle id=oracleScript.id />
          <HSpacing size=Spacing.sm />
          <Text value=oracleScript.name />
        </div>
      </Col>
    </Row>
  }
}

module CreateOracleScriptFailMsg = {
  @react.component
  let make = (~oracleScript: MsgDecoder.CreateOracleScript.fail_t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <Row>
      <Col col=Col.Six mbSm=24>
        <Heading
          value="Owner"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AddressRender position=AddressRender.Subtitle address=oracleScript.owner />
      </Col>
      <Col col=Col.Six>
        <Heading
          value="Name"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <Text value=oracleScript.name size=Text.Body1 />
      </Col>
    </Row>
  }
}

module EditOracleScriptMsg = {
  @react.component
  let make = (~oracleScript: MsgDecoder.EditOracleScript.t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <Row>
      <Col col=Col.Six mbSm=24>
        <Heading
          value="Owner"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AddressRender position=AddressRender.Subtitle address=oracleScript.owner />
      </Col>
      <Col col=Col.Six>
        <Heading
          value="Name"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <div className={CssHelper.flexBox()}>
          <TypeID.OracleScript position=TypeID.Subtitle id=oracleScript.id />
          {oracleScript.name == Config.doNotModify
            ? React.null
            : <>
                <HSpacing size=Spacing.sm />
                <Text value=oracleScript.name size=Text.Body1 />
              </>}
        </div>
      </Col>
    </Row>
  }
}

module RequestMsg = {
  @react.component
  let make = (~request: MsgDecoder.Request.success_t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    let calldataKVsOpt = Obi.decode(request.schema, "input", request.calldata)
    <Row>
      <Col col=Col.Six mb=24>
        <Heading
          value="Owner"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AddressRender position=AddressRender.Subtitle address=request.sender />
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Request ID"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <TypeID.Request position=TypeID.Subtitle id=request.id />
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Oracle Script"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <div className={CssHelper.flexBox()}>
          <TypeID.OracleScript position=TypeID.Subtitle id=request.oracleScriptID />
          <HSpacing size=Spacing.sm />
          <Text value=request.oracleScriptName size=Text.Body1 />
        </div>
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Fee Limit"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color={theme.neutral_600}
        />
        <AmountRender coins={request.feeLimit} pos=AmountRender.TxIndex />
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Prepare Gas"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <Text value={request.prepareGas->Belt.Int.toString} size=Text.Body1 />
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Execute Gas"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <Text value={request.executeGas->Belt.Int.toString} size=Text.Body1 />
      </Col>
      <Col mb=24>
        <div
          className={Css.merge(list{
            CssHelper.flexBox(~justify=#spaceBetween, ()),
            CssHelper.mb(),
          })}>
          <Heading
            value="Calldata" size=Heading.H4 weight=Heading.Regular color=theme.neutral_600
          />
          <CopyButton
            data={request.calldata->JsBuffer.toHex(~with0x=false)} title="Copy as bytes" width=125
          />
        </div>
        {switch calldataKVsOpt {
        | Some(calldataKVs) =>
          <KVTable
            rows={calldataKVs->Belt.Array.map(({fieldName, fieldValue}) => [
              KVTable.Value(fieldName),
              KVTable.Value(fieldValue),
            ])}
          />
        | None =>
          <Text
            value="Could not decode calldata."
            spacing=Text.Em(0.02)
            nowrap=true
            ellipsis=true
            code=true
            block=true
            size=Text.Body1
          />
        }}
      </Col>
      <Col col=Col.Six mbSm=24>
        <Heading
          value="Request Validator Count"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <Text value={request.askCount->Belt.Int.toString} size=Text.Body1 />
      </Col>
      <Col col=Col.Six>
        <Heading
          value="Sufficient Validator Count"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <Text value={request.minCount->Belt.Int.toString} size=Text.Body1 />
      </Col>
    </Row>
  }
}

module RequestFailMsg = {
  @react.component
  let make = (~request: MsgDecoder.Request.fail_t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <Row>
      <Col col=Col.Six mb=24>
        <Heading
          value="Owner"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AddressRender position=AddressRender.Subtitle address=request.sender />
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Oracle Script"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <div className={CssHelper.flexBox()}>
          <TypeID.OracleScript position=TypeID.Subtitle id=request.oracleScriptID />
        </div>
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Fee Limit"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color={theme.neutral_600}
        />
        <AmountRender coins={request.feeLimit} pos=AmountRender.TxIndex />
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Prepare Gas"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <Text value={request.prepareGas->Belt.Int.toString} size=Text.Body1 />
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Execute Gas"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <Text value={request.executeGas->Belt.Int.toString} size=Text.Body1 />
      </Col>
      <Col mb=24>
        <Heading
          value="Calldata"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <div className={CssHelper.flexBox()}>
          <Text value={request.calldata->JsBuffer.toHex} size=Text.Body1 />
          <HSpacing size=Spacing.sm />
          <CopyRender width=14 message={request.calldata->JsBuffer.toHex} />
        </div>
      </Col>
      <Col col=Col.Six mbSm=24>
        <Heading
          value="Request Validator Count"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <Text value={request.askCount->Belt.Int.toString} size=Text.Body1 />
      </Col>
      <Col col=Col.Six>
        <Heading
          value="Sufficient Validator Count"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <Text value={request.minCount->Belt.Int.toString} size=Text.Body1 />
      </Col>
    </Row>
  }
}

module ReportMsg = {
  @react.component
  let make = (~report: MsgDecoder.Report.t) => {
    let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
    <Row>
      <Col col=Col.Six mb=24>
        <Heading
          value="Owner"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <AddressRender position=AddressRender.Subtitle address=report.reporter />
      </Col>
      <Col col=Col.Six mb=24>
        <Heading
          value="Request ID"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <TypeID.Request position=TypeID.Subtitle id=report.requestID />
      </Col>
      <Col>
        <Heading
          value="Raw Data Report"
          size=Heading.H4
          weight=Heading.Regular
          marginBottom=8
          color=theme.neutral_600
        />
        <KVTable
          headers=["External Id", "Exit Code", "Value"]
          rows={report.rawReports
          ->Belt.List.map(rawReport => [
            KVTable.Value(rawReport.externalDataID->Belt.Int.toString),
            KVTable.Value(rawReport.exitCode->Belt.Int.toString),
            KVTable.Value(rawReport.data->JsBuffer.toUTF8),
          ])
          ->Belt.List.toArray}
        />
      </Col>
    </Row>
  }
}