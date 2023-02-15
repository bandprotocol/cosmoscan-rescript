module Styles = {
  open CssJs

  let statusImg = style(. [
    width(#px(20)),
    marginRight(#px(8))
  ]);
};

@react.component
  let make = (~status) => {
    let isMobile = Media.isMobile();
    let ({ThemeContext.theme}, _) = React.useContext(ThemeContext.context);
          
    <div className={CssHelper.flexBox( ~align=#center, ())}>
      <img
        alt="Status Icon"
        src={status ? Images.success : Images.fail}
        className=Styles.statusImg
      />
      {
        isMobile ? 
        <Text 
          value={status ? "Success" : "Fail"} 
          size={isMobile ? Text.Body1 : Text.Body2}
          color={status ? theme.success_600 : theme.error_600}
        /> 
        : React.null
      }
    </div>
  }

