module Styles = {
  open CssJs
  let container = (theme: Theme.t) =>
    style(. [
      backgroundColor(theme.neutral_000),
      width(#percent(100.)),
      maxWidth(#px(468)),
      minHeight(#px(360)),
      padding(#px(40)),
      Media.mobile([maxWidth(#px(300))]),
    ]);
  let qrCodeContainer = (theme: Theme.t) =>
    style(. [
      backgroundColor(theme.white),
      maxWidth(#px(220)),
      margin3(~top=#px(40), ~h=#auto, ~bottom=#zero),
      padding(#px(12)),
      borderRadius(#px(8)),
    ]);
};

@react.component
let make = (~address) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  <div className=Styles.container(theme)>
    <Heading size=Heading.H4 value="QR Code" marginBottom=24 marginBottomSm=24/>
    <AddressRender address position=AddressRender.Subtitle clickable=false />
    <div
      className={Css.merge(list{CssHelper.flexBox(~justify=#center, ()), Styles.qrCodeContainer(theme)})}>
      <QRCode value={address -> Address.toBech32} size=200 />
    </div>
  </div>;
};
