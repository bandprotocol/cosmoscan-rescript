module Styles = {
  open CssJs

  let container = (theme: Theme.t) =>
    style(. [
      selector(
        "a",
        [
          wordBreak(#breakAll),
          color(theme.primary_600),
          textDecoration(#none),
          transition(~duration=200, "all"),
          hover([color(theme.primary_600)]),
        ],
      ),
      selector("p, ul, ul > li, ol, ol > li", [color(theme.neutral_600), marginBottom(#em(1.))]),
      selector("p:last-child", [color(theme.neutral_600), marginBottom(#em(0.))]),
      selector(
        "h2,h3,h4,h5,h6",
        [color(theme.neutral_600), marginBottom(#px(10)), fontSize(#px(16)), fontWeight(#num(600))],
      ),
      selector("ul", [marginLeft(#em(1.2))]),
      selector("ol", [marginLeft(#em(2.0)), listStyleType(#decimal)]),
      selector(
        "ol > li",
        [fontSize(#px(14)), paddingLeft(#px(15)), position(#relative), lineHeight(#em(1.42))],
      ),
      selector(
        "ol > li::marker",
        [fontFamilies([#custom("Montserrat"), #custom("sans-serif")]), fontVariant(#inherit_)],
      ),
      selector("ul", [marginLeft(#em(1.2))]),
      selector("ol", [marginLeft(#em(2.0)), listStyleType(#decimal)]),
      selector(
        "ul > li",
        [
          fontSize(#px(14)),
          paddingLeft(#px(15)),
          position(#relative),
          lineHeight(#em(1.42)),
          before([
            contentRule(#text("\u23FA")),
            fontSize(#px(10)),
            color(theme.neutral_600),
            lineHeight(#zero),
            display(#inlineBlock),
            pointerEvents(#none),
            width(#em(1.5)),
            marginLeft(#em(-1.)),
          ]),
        ],
      ),
      selector(
        "ol > li",
        [fontSize(#px(14)), paddingLeft(#px(15)), position(#relative), lineHeight(#em(1.42))],
      ),
      selector(
        "ol > li::marker",
        [fontFamilies([#custom("Montserrat"), #custom("sans-serif")]), fontVariant(#inherit_)],
      ),
    ])
}

@react.component
let make = (~value) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <div className={Styles.container(theme)}> {value->MarkedJS.marked->MarkedJS.parse} </div>
}
