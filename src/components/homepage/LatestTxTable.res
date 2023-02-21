module Styles = {
  open CssJs

  let statusImg = style(. [width(#px(20)), marginTop(#px(-3))]);
  let textMRight = style(. [marginRight(#px(6))]);
  let headingContainer = style(. [marginTop(#px(40)), marginBottom(#px(16))]);
};

module RenderBody = {
  @react.component
  let make = (~txSub: Sub.variant<TxSub.t>) => {
    <TBody paddingV=#px(16)>
      <Row alignItems=Row.Center>
        <Col col=Col.Four>
          {switch (txSub) {
           | Data({txHash}) => <TxLink txHash width=110 size=Text.Body1 weight=Text.Regular />
           | _ => <LoadingCensorBar width=60 height=15 />
           }}
        </Col>
        <Col col=Col.Three>
          {switch (txSub) {
           | Data({blockHeight}) => <TypeID.Block id=blockHeight size=Text.Body1 />
           | _ => <LoadingCensorBar width=50 height=15 />
           }}
        </Col>
        <Col col=Col.Three>
          {switch (txSub) {
           | Data({messages, txHash, success, errMsg}) =>
             <MsgBadgeGroup txHash messages/>
           | _ => <LoadingCensorBar width=50 height=15 />
           }}
        </Col>
        <Col col=Col.Two>
          <div className={CssHelper.flexBox(~justify=#center, ~align=#center, ())}>
            {switch (txSub) {
             | Data({success}) =>
               <img
                 alt="Status Icon"
                 src={success ? Images.success : Images.fail}
                 className=Styles.statusImg
               />
             | _ => <LoadingCensorBar width=20 height=20 radius=20 />
             }}
          </div>
        </Col>
      </Row>
    </TBody>;
  };
};

module RenderBodyMobile = {
  @react.component
  let make = (~reserveIndex, ~txSub: Sub.variant<TxSub.t>) => {
    let isSmallMobile = Media.isSmallMobile();

    switch (txSub) {
    | Data({txHash, blockHeight, success, messages, errMsg}) =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Tx Hash", TxHash(txHash, isSmallMobile ? 170 : 200)),
            ("Block", Height(blockHeight)),
            ("Actions", MsgBadgeGroup(txHash, messages)),
            ("Status", Status(success)),
          ]}
        key={txHash -> Hash.toHex}
        idx={txHash -> Hash.toHex}
        status=success
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Tx Hash", Loading(isSmallMobile ? 170 : 200)),
            ("Block", Loading(70)),
            (
              "Actions",
              Loading(
                {
                  isSmallMobile ? 160 : 230;
                },
              ),
            ),
            ("Status", Loading(70)),
          ]}
        key={reserveIndex -> Belt.Int.toString}
        idx={reserveIndex -> Belt.Int.toString}
      />
    };
  };
};

@react.component
let make = () => {
  let isMobile = Media.isMobile();
  let txCount = 10;
  let txsSub = TxSub.getList(~page=1, ~pageSize=txCount);
  let ({ThemeContext.theme}, _) = React.useContext(ThemeContext.context);

  <>
    {isMobile ? <div className={Css.merge(list{CssHelper.flexBox(~justify=#spaceBetween, ()), Styles.headingContainer})}>
      <Text value="Latest Transactions" size=Text.Xl weight=Text.Semibold color=theme.neutral_900 />
      <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
        <Link className={CssHelper.flexBox(~align=#center, ())} route=Route.TxHomePage>
          <div className=Styles.textMRight>
            <Text 
              value="View All" 
              size=Text.Body2
              weight=Text.Semibold 
              underline=true 
              color=theme.neutral_900 
            />
          </div>
          <Icon name="far fa-arrow-right" color=theme.neutral_900 />
        </Link>
      </div>
    </div> : React.null }
    <Table>
      {isMobile
        ? React.null
        : <Row marginTop=30 marginBottom=25 marginTopSm=24 marginBottomSm=0>
          <Col col=Col.Six colSm=Col.Six>
            <Text value="Latest Transactions" size=Text.Xl weight=Text.Semibold color=theme.neutral_900 />
          </Col>
          <Col col=Col.Six colSm=Col.Six>
            <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
              <Link className={CssHelper.flexBox(~align=#center, ())} route=Route.TxHomePage>
                <div className=Styles.textMRight>
                  <Text 
                    value="All Transactions" 
                    size=Text.Body2
                    weight=Text.Semibold 
                    underline=true 
                    color=theme.neutral_900 
                  />
                </div>
                <Icon name="far fa-arrow-right" color=theme.neutral_900 />
              </Link>
            </div>
          </Col>
        </Row>}
      {isMobile
        ? React.null
        : <THead height=30>
            <Row alignItems=Row.Center>
              <Col col=Col.Four>
                  <Text value="Tx Hash" size=Text.Body2 weight=Text.Semibold />
              </Col>
              <Col col=Col.Three>
                  <Text value="Block" size=Text.Body2 weight=Text.Semibold />
              </Col>
              <Col col=Col.Three>
                  <Text value="Message" size=Text.Body2 weight=Text.Semibold />
              </Col>
              <Col col=Col.Two>
                  <Text value="Status" size=Text.Body2 weight=Text.Semibold />
              </Col>
            </Row>
          </THead>}
      {switch (txsSub) {
      | Data(txs) =>
        txs
        ->Belt.Array.mapWithIndex((i, e) =>
            isMobile
              ? <RenderBodyMobile
                  key={e.txHash -> Hash.toHex}
                  reserveIndex=i
                  txSub={Sub.resolve(e)}
                />
              : <RenderBody key={e.txHash -> Hash.toHex} txSub={Sub.resolve(e)} />
          )
        ->React.array
      | _ =>
        Belt.Array.make(txCount, Sub.NoData)
        ->Belt.Array.mapWithIndex((i, noData) =>
            isMobile
              ? <RenderBodyMobile key={i->Belt.Int.toString} reserveIndex=i txSub=noData />
              : <RenderBody key={i->Belt.Int.toString} txSub=noData />
          )
        ->React.array
      }}
    </Table>
  </>;
};
