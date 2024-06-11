module Styles = {
  open CssJs

  let selectContainer = style(. [maxWidth(px(285))])
  let buttonContainer = style(. [height(#percent(100.))])
}

type control_t = {
  display: string,
  height: string,
  width: string,
  fontSize: string,
  backgroundColor: string,
  borderRadius: string,
  border: string,
  color: string,
}

type option_t = {
  display: string,
  alignItems: string,
  height: string,
  fontSize: string,
  paddingLeft: string,
  cursor: string,
  color: string,
  backgroundColor: string,
}

type input_t = {color: string}

type menu_t = {
  backgroundColor: string,
  overflowY: string,
  maxHeight: string,
}

type container_t = {
  width: string,
  position: string,
  boxSizing: string,
}

type singleValue_t = {
  margin: string,
  maxWidth: string,
  overflow: string,
  position: string,
  textOverflow: string,
  whiteSpace: string,
  top: string,
  transform: string,
  boxSizing: string,
  fontWeight: string,
  lineHeight: string,
}

type indicatorSeparator_t = {display: string}

@react.component
let make = () => {
  let (selectedChainID, setSelectedChainID) = React.useState(_ => {
    open ReactSelect
    {value: "N/A", label: "Select Counterparty Chain"}
  })
  let validatorList = {
    open ReactSelect
    [{value: "1", label: "1"}, {value: "2", label: "2"}, {value: "3", label: "3"}]
  }

  // TODO: Hack styles for react-select
  <div className={Styles.selectContainer}>
    <ReactSelect
      options=validatorList
      value=selectedChainID
      onChange={newOption => {
        let newVal = newOption
        setSelectedChainID(_ => newVal)
      }}
      styles={
        ReactSelect.control: _ => {
          display: "flex",
          height: "37px",
          width: "100%",
          fontSize: "14px",
          color: "#303030",
          backgroundColor: "#ffffff",
          borderRadius: "8px",
          border: "1px solid" ++ "#EDEDED",
        },
        ReactSelect.option: _ => {
          fontSize: "14px",
          height: "37px",
          display: "flex",
          alignItems: "center",
          paddingLeft: "10px",
          cursor: "pointer",
          color: "#303030",
          backgroundColor: "#ffffff",
        },
        ReactSelect.container: _ => {
          width: "100%",
          position: "relative",
          boxSizing: "border-box",
        },
        ReactSelect.singleValue: _ => {
          margin: "0px 2px",
          maxWidth: "calc(100% - 8px)",
          overflow: "hidden",
          position: "absolute",
          textOverflow: "ellipsis",
          whiteSpace: "nowrap",
          top: "50%",
          transform: "translateY(-50%)",
          boxSizing: "border-box",
          fontWeight: "300",
          lineHeight: "1.3em",
        },
        ReactSelect.indicatorSeparator: _ => {display: "none"},
        ReactSelect.input: _ => {color: "#303030"},
        ReactSelect.menuList: _ => {
          backgroundColor: "#ffffff",
          overflowY: "scroll",
          maxHeight: "230px",
        },
      }
    />
  </div>
}
