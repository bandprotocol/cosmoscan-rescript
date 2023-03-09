module Styles = {
  open CssJs

  let noDataImage =
    style(. [
      width(#auto),
      height(#px(40)),
      marginBottom(#px(16)),
      Media.mobile([marginBottom(#px(8))]),
    ]);
  let container =
    style(. [
      boxShadow(Shadow.box(~x=#zero, ~y=#px(2), ~blur=#px(4), Css.rgba(0, 0, 0, #num(0.2)))),
    ]);
  let textMRight = style(. [marginRight(#px(6))]);
  let headingContainer = style(. [marginTop(#px(40)), marginBottom(#px(16))]);
};

module RenderBody = {
  @react.component
  let make = (~requestSub: Sub.variant<RequestSub.t>) => {
    <TBody paddingV=#px(16)>
      <Row alignItems=Row.Center>
        <Col col=Col.Three>
          {switch (requestSub) {
           | Data({id}) => <TypeID.Request size=Text.Body1 id />
           | _ => <LoadingCensorBar width=60 height=15 />
           }}
        </Col>
        <Col col=Col.Six>
          {switch (requestSub) {
           | Data({oracleScript: {oracleScriptID, name}}) =>
             <div className={CssHelper.flexBox(~wrap=#nowrap, ())}>
               <TypeID.OracleScript id=oracleScriptID details=name size=Text.Body1 />
             </div>
           | _ => <LoadingCensorBar width=150 height=15 />
           }}
        </Col>
        <Col col=Col.Three>
          <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
            {switch (requestSub) {
             | Data({resolveStatus, requestedValidators, reports}) =>
               let reportedCount = reports->Array.length;
               let requestedCount = requestedValidators->Array.length;

               <div className={CssHelper.flexBox()}>
                 <Text value=j`$reportedCount of $requestedCount` size=Text.Body1  />
                 <HSpacing size=#px(16) />
                 <RequestStatus resolveStatus />
               </div>;
             | _ => <LoadingCensorBar width=70 height=15 />
             }}
          </div>
        </Col>
      </Row>
    </TBody>;
  };
};

module RenderBodyMobile = {
  @react.component
  let make = (~reserveIndex, ~requestSub: Sub.variant<RequestSub.t>) => {
    switch (requestSub) {
    | Data({
        id,
        oracleScript: {oracleScriptID, name},
        resolveStatus,
        requestedValidators,
        reports,
      }) =>
      let reportedCount = reports->Array.length;
      let requestedCount = requestedValidators->Array.length;
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Request ID", RequestID(id)),
            ("Oracle Script", OracleScript(oracleScriptID, name)),
            ("Report Status", RequestStatus(resolveStatus, {j`$reportedCount of $requestedCount`})),
          ]}
        key={id -> ID.Request.toString}
        idx={id -> ID.Request.toString}
        requestStatus=resolveStatus
      />;
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Request ID", Loading(60)),
            ("Oracle Script", Loading(150)),
            ("Report Status", Loading(60)),
          ]}
        key={reserveIndex -> Belt.Int.toString}
        idx={reserveIndex -> Belt.Int.toString}
      />
    };
  };
};

@react.component
let make = (~latestRequestsSub: Sub.variant<array<RequestSub.t>>) => {
  let isMobile = Media.isMobile();
  let ({ThemeContext.theme, isDarkMode}, _) = React.useContext(ThemeContext.context);

  <>
    {isMobile ? <div className={Css.merge(list{CssHelper.flexBox(~justify=#spaceBetween, ()), Styles.headingContainer})}>
      <Text value="Latest Request" size=Text.Xl weight=Text.Semibold color=theme.neutral_900  />
      <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
        <Link className={CssHelper.flexBox(~align=#center, ())} route=Route.RequestHomePage>
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
            <Text value="Latest Request" size=Text.Xl weight=Text.Semibold color=theme.neutral_900  />
          </Col>
          <Col col=Col.Six colSm=Col.Six>
            <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
              <Link className={CssHelper.flexBox(~align=#center, ())} route=Route.RequestHomePage>
                <div className=Styles.textMRight>
                  <Text 
                    value="All Requests" 
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
              <Col col=Col.Three>
                <Text
                  block=true
                  value="Request ID"
                  size=Text.Body2
                  weight=Text.Semibold
                />
              </Col>
              <Col col=Col.Six>
                <Text
                  block=true
                  value="Oracle Script"
                  size=Text.Body2
                  weight=Text.Semibold
                />
              </Col>
              <Col col=Col.Three>
                <Text
                  block=true
                  value="Report Status"
                  size=Text.Body2
                  weight=Text.Semibold
                  align=Text.Right
                />
              </Col>
            </Row>
          </THead>}
      {switch (latestRequestsSub) {
      | Data(requests) when requests->Belt.Array.length === 0 =>
        <EmptyContainer height={#calc((#sub, #percent(100.), #px(86)))} boxShadow=true>
          <img
            src={isDarkMode ? Images.noDataDark : Images.noDataLight}
            className=Styles.noDataImage
            alt="No Request"
          />
          <Heading size=Heading.H4 value="No Request" align=Heading.Center weight=Heading.Regular />
        </EmptyContainer>
      | Data(requests) =>
        requests
        ->Belt.Array.mapWithIndex((i, e) =>
            isMobile
              ? <RenderBodyMobile
                  key={e.id -> ID.Request.toString}
                  reserveIndex=i
                  requestSub={Sub.resolve(e)}
                />
              : <RenderBody key={e.id -> ID.Request.toString} requestSub={Sub.resolve(e)} />
          )
        ->React.array
      | _ =>
        Belt.Array.make(10, Sub.NoData)
        ->Belt.Array.mapWithIndex((i, noData) =>
            isMobile
              ? <RenderBodyMobile key={i->Belt.Int.toString} reserveIndex=i requestSub=noData />
              : <RenderBody key={i->Belt.Int.toString} requestSub=noData />
          )
        ->React.array
      }}
    </Table>
  </>;
};
