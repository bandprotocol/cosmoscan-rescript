@react.component
let make = () => {

  // this is used for debug graphql
  // will remove later
  let responeTime = OracleScriptSub.getResponseTimeList()
  let os = OracleScriptSub.get(3 -> ID.OracleScript.fromInt)
  let mostRequestedOracleScriptSub =
    OracleScriptSub.getList(~pageSize=6, ~page=1, ~searchTerm="", ());
  <Section>
    <div className=CssHelper.container id="proposalsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          {
            switch mostRequestedOracleScriptSub {
              | Data(data) => <Text value={data -> Belt.Array.length -> Belt.Int.toString} size=Text.Lg />
              | Loading => <Text value="Loading" size=Text.Lg />
              | NoData => <Text value="NoData" size=Text.Lg />
              | Error(err) => <Text value=err.message size=Text.Lg />
            }
          }
        </Col>
        <SeperatedLine/>
        {
          switch responeTime {
            | Data(res) => res -> Belt.Array.map(
              ({id,responseTime}) =>
              <>
                <Col col=Col.Twelve>
                  <Text value={id ->ID.OracleScript.toString} size=Text.Lg />
                </Col>
                <Col col=Col.Twelve>
                  <Text value={responseTime -> Belt.Float.toString} size=Text.Lg />
                </Col>
                <SeperatedLine/>
              </>
            ) -> React.array
            | Loading => <Text value="Loading" size=Text.Lg />
            | NoData => <Text value="NoData" size=Text.Lg />
            | Error(err) => <Text value=err.message size=Text.Lg />
          }
        }
      </Row>
    </div>
  </Section>;
}
