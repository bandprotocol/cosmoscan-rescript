module Styles = {
  open CssJs

  let root = style(. [position(#relative)])
  let content = style(. [position(#relative), zIndex(1)])
  let baseBg = style(. [position(#absolute), top(#px(40))])
  let left = style(. [left(#zero)])
  let right = style(. [right(#zero), transform(rotateZ(#deg(180.)))])
}

@react.component
let make = () => {
  // Subscribe for latest 5 blocks here so both "LatestBlocks" and "ChainInfoHighLights"
  // share the same infomation.
  let pageSize = 10
  let latestBlocksSub = BlockSub.getList(~pageSize, ~page=1)
  let latestBlockSub = latestBlocksSub->Sub.map(blocks => blocks->Belt.Array.getExn(0))
  let latestRequestsSub = RequestSub.getList(~pageSize, ~page=1)
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)
  let isMobile = Media.isMobile()

  <Section pt=80 pb=80 ptSm=0 pbSm=24 bg={theme.neutral_000} style=Styles.root>
    <Example />
    // {!isMobile
    //   ? <>
    //       <img
    //         alt="Homepage Background"
    //         src={isDarkMode ? Images.bgLeftDark : Images.bgLeftLight}
    //         className={Css.merge(list{Styles.baseBg, Styles.left})}
    //       />
    //       <img
    //         alt="Homepage Background"
    //         src={isDarkMode ? Images.bgLeftDark : Images.bgLeftLight}
    //         className={Css.merge(list{Styles.baseBg, Styles.right})}
    //       />
    //     </>
    //   : React.null}
    // <div className={Css.merge(list{CssHelper.container, Styles.content})} id="homePageContainer">
    //   <ChainInfoHighlights latestBlockSub />
    //   <Row marginTop=40>
    //     <Col col=Col.Six>
    //       <LatestTxTable />
    //     </Col>
    //     <Col col=Col.Six>
    //       <LatestRequests latestRequestsSub />
    //     </Col>
    //   </Row>
    // </div>
  </Section>
}
