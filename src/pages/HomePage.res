@react.component
let make = () => {
  // this is used for debug graphql
  // will remove later
  let proposalSub = ProposalSub.get(2 -> ID.Proposal.fromInt)

  <Section>
    <div className=CssHelper.container id="proposalsSection">
      <Row alignItems=Row.Center marginBottom=40 marginBottomSm=24>
        <Col col=Col.Twelve>
          {
            switch proposalSub {
              | Data({content}) => {
                switch content {
                | Some({changes}) => {
                    switch changes {
                      | Some(data) => data -> Belt.Array.map(({subspace, key, value}) => <div className={CssHelper.flexBox(~direction=#column, ())}> 
                        <Text value=j`subspace : $subspace` size=Text.Body1 />
                        <Text value=j`key : $key` size=Text.Body1 />
                        <Text value=j`value : $value` size=Text.Body1 />
                        <Text value="" size=Text.Body1 />
                      </div> ) -> React.array
                      | None => <Text value="no changes" size=Text.Body1 />
                    }
                    
                  }
                | None => <Text value="inside GGWP" size=Text.Body1 />
                }
              }
              | _ => <Text value="GGWP" size=Text.Body1 />
            }
          }
        </Col>
        
        <SeperatedLine />
        <Col col=Col.Twelve>
          {
            switch proposalSub {
              | Data({content}) => {
                switch content {
                | Some({plan}) => {
                    switch plan {
                      | Some({name, time, height}) => <div className={CssHelper.flexBox(~direction=#column, ())}> 
                        <Text value=j`name : $name` size=Text.Body1 />
                        <Text value=j`time : $time` size=Text.Body1 />
                        <Text value=j`height : $height` size=Text.Body1 />
                        <Text value="" size=Text.Body1 />
                      </div>
                      | None => <Text value="no plan" size=Text.Body1 />
                    }
                    
                  }
                | None => <Text value="inside GGWP" size=Text.Body1 />
                }
              }
              | _ => <Text value="GGWP" size=Text.Body1 />
            }
          }
        </Col>
      </Row>
    </div>
  </Section>
}
