@react.component
let make = (~reserveIndex,  ~proposalSub: Sub.variant<ProposalSub.t>) => {
    let isMobile = Media.isMobile();
    let ({ThemeContext.theme}, _) = React.useContext(ThemeContext.context);

    <Col key={reserveIndex -> Belt.Int.toString} mb=24 mbSm=16>
      <InfoContainer>
        <Row marginBottom=18>
          <Col col=Col.Eleven colSm=Col.Ten>
            <div>
              {switch (proposalSub) {
               | Data({id, name}) =>
                 <>
                   <TypeID.Proposal id position=TypeID.Title />
                   <Heading
                     size=Heading.H3
                     value=name
                     color={theme.textSecondary}
                     weight=Heading.Thin
                   />
                 </>
               | _ =>
                 isMobile
                   ? <>
                       <LoadingCensorBar width=50 height=15 mbSm=16 />
                       <LoadingCensorBar width=100 height=15 mbSm=16 />
                     </>
                   : <LoadingCensorBar width=270 height=15 />
               }}
              <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
                {switch (proposalSub) {
                 | Data({status}) => <ProposalBadge status />
                 | _ =>
                   <>
                     {isMobile ? React.null : <HSpacing size={#px(10)} />}
                     <LoadingCensorBar width=100 height=15 radius=50 />
                   </>
                 }}
              </div>
            </div>
          </Col>
          <Col col=Col.One colSm=Col.Two>
            <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
              // {switch (proposalSub) {
              //  | Data({id}) =>
              //    <TypeID.ProposalLink id>
              //      <div
              //        className={Css.merge([
              //          Styles.proposalLink(theme),
              //          CssHelper.flexBox(~justify=#center, ()),
              //        ])}>
              //        <Icon name="far fa-arrow-right" color={theme.white} />
              //      </div>
              //    </TypeID.ProposalLink>
              //  | _ => <LoadingCensorBar width=32 height=32 radius=8 />
              //  }}
            </div>
          </Col>
        </Row>
        <Row marginBottom=24>
          <Col>
            <></>
            // {switch (proposalSub) {
            //  | Data({description}) => <Markdown value=description />
            //  | _ => <LoadingCensorBar width=270 height=15 />
            //  }}
          </Col>
        </Row>
        <SeperatedLine />
      </InfoContainer>
    </Col>;
};
