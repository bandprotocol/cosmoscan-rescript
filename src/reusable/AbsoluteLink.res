module Styles = {
  open CssJs

  let a = (theme: Theme.t) =>
    style(. [textDecoration(#none), color(theme.neutral_900), hover([color(theme.primary_600)])]);
};

@react.component
let make = (~href, ~className="", ~noNewTab=false, ~children) => {
  let ({ThemeContext.theme}, _) = React.useContext(ThemeContext.context);
  switch(href){
    | "" => children
    | _ =>  <a 
        href 
        className={Css.merge(list{Styles.a(theme), className})} 
        target={noNewTab ? "_self" : "_blank" }
        rel="noopener"
      >
        children
      </a>
  }
};
