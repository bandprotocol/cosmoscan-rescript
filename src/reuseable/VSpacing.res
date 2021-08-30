open CssJs

@react.component
let make = (~size) => <div className={style(. [paddingTop(size)])} />
