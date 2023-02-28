module Styles = {
  open CssJs;
  
  let badge = color => 
    style(. [backgroundColor(color), padding2(~v=#px(3), ~h=#px(10)), borderRadius(#px(50))]);
  
};

let getBadgeText = x =>
    switch(x){
        | ProposalSub.Deposit => "Deposit Period"
        | Voting => "Voting Period"
        | Passed => "Passed"
        | Rejected => "Rejected"
        | Inactive => "Inactive"
        | Failed => "Failed";
    }

let getBadgeColor = (theme: Theme.t, x) =>
    switch(x){
        | ProposalSub.Deposit
        | Voting => theme.primary_600
        | Passed => theme.success_600
        | Rejected
        | Inactive
        | Failed => theme.error_600;
    }

@react.component
let make = (~status) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)
  <div
    className={Css.merge(list{
      Styles.badge(getBadgeColor(theme, status)),
      CssHelper.flexBox(~justify=#center, ()),
    })}>
    <Text value={getBadgeText(status)} size=Text.Caption transform=Text.Uppercase color=theme.white />
  </div>;
};
