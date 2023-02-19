@react.component
let make = () => {
  // this is used for debug graphql
  // will remove later
  // let requestsByTxHash = RequestSub.Mini.getListByTxHash("45b9e63e8c5fab1085d1361a6f723c04ba40f2be770968012685f35d8292a49b" -> Hash.fromHex);
  // let requestsByDs = RequestSub.Mini.getListByDataSource(1 -> ID.DataSource.fromInt, ~page=1, ~pageSize=5);

  <Section>
    <div className=CssHelper.container id="proposalsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        // <Col col=Col.Twelve>
        //   {
        //     switch requestsByDs {
        //       | Data(data) => <Text value={data[0].txHash -> Belt.Option.getExn -> Hash.toHex} size=Text.Body1 />
        //       | Loading => <Text value="Loading" size=Text.Body1 />
        //       | NoData => <Text value="NoData" size=Text.Body1 />
        //       | Error(err) => <Text value=err.message size=Text.Body1 />
        //     }
        //   }
        // </Col>
        // <Col col=Col.Twelve>
        //   {
        //     switch requestsByTxHash {
        //       | Data(data) => <Text value={data[0].txHash -> Belt.Option.getExn -> Hash.toHex} size=Text.Body1 />
        //       | Loading => <Text value="Loading" size=Text.Body1 />
        //       | NoData => <Text value="NoData" size=Text.Body1 />
        //       | Error(err) => <Text value=err.message size=Text.Body1 />
        //     }
        //   }
        // </Col>
        <SeperatedLine />
        // {
        //   switch requestsByTxHashSub {
        //     | Data(res) => res -> Belt.Array.map(
        //       ({id,responseTime}) =>
        //       <>
        //         <Col col=Col.Twelve>
        //           <Text value={id ->ID.OracleScript.toString} size=Text.Body1 />
        //         </Col>
        //         <Col col=Col.Twelve>
        //           <Text value={responseTime -> Belt.Float.toString} size=Text.Body1 />
        //         </Col>
        //         <SeperatedLine/>
        //       </>
        //     ) -> React.array
        //     | Loading => <Text value="Loading" size=Text.Body1 />
        //     | NoData => <Text value="NoData" size=Text.Body1 />
        //     | Error(err) => <Text value=err.message size=Text.Body1 />
        //   }
        // }
      </Row>
    </div>
  </Section>
}
