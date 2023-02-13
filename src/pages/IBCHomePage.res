module Styles = {
  open CssJs

  let selectContainer = style(. [minWidth(#px(245)), marginRight(#px(24))])
  let selectPortContainer = style(. [minWidth(#px(222))])
  let dropdownGroup = style(. [display(#flex), alignItems(#center)])
  let buttonContainer = style(. [height(#percent(100.))])
}

module CounterPartySelect = {
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
  let make = (~filterChainIDList: array<IBCFilterSub.filter_counterparty_t>, ~setChainID) => {
    let ({ThemeContext.isDarkMode: isDarkMode}, _) = React.useContext(ThemeContext.context)

    let (selectedChainID, setSelectedChainID) = React.useState(_ => {
      open ReactSelect
      {value: "N/A", label: "Select Counterparty Chain"}
    })

    let validatorList = filterChainIDList->Belt.Array.map(({chainID}) => {
      open ReactSelect
      {
        value: chainID,
        label: chainID,
      }
    })

    // TODO: Hack styles for react-select
    <div
      className={CssHelper.flexBox(~align=#flexStart, ~direction=#column, ())}
      id="counterPartySelection">
      <ReactSelect
        options=validatorList
        onChange={newOption => {
          let newVal = newOption
          setSelectedChainID(_ => newVal)
          setChainID(_ => newVal.value)
        }}
        value=selectedChainID
        styles={
          ReactSelect.control: _ => {
            display: "flex",
            height: "37px",
            width: "100%",
            fontSize: "14px",
            color: isDarkMode ? "#ffffff" : "#303030",
            backgroundColor: isDarkMode ? "#2C2C2C" : "#ffffff",
            borderRadius: "8px",
            border: "1px solid" ++ {
              isDarkMode ? "#353535" : "#EDEDED"
            },
          },
          ReactSelect.option: _ => {
            fontSize: "14px",
            height: "37px",
            display: "flex",
            alignItems: "center",
            paddingLeft: "10px",
            cursor: "pointer",
            color: isDarkMode ? "#ffffff" : "#303030",
            backgroundColor: isDarkMode ? "#2C2C2C" : "#ffffff",
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
          ReactSelect.input: _ => {color: isDarkMode ? "#ffffff" : "#303030"},
          ReactSelect.menuList: _ => {
            backgroundColor: isDarkMode ? "#2C2C2C" : "#ffffff",
            overflowY: "scroll",
            maxHeight: "230px",
          },
        }
      />
    </div>
  }
}

module CustomSelect = {
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

  type option_style_t = {
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
  let make = (~options: array<string>, ~setValue) => {
    let ({ThemeContext.isDarkMode: isDarkMode}, _) = React.useContext(ThemeContext.context)

    let (selectOption, setSelectOption) = React.useState(_ => {
      open ReactSelect
      {value: "N/A", label: "Select"}
    })

    let optionList = options->Belt.Array.map(option => {
      open ReactSelect
      {
        value: option,
        label: option,
      }
    })

    // TODO: Hack styles for react-select
    <div className={CssHelper.flexBox(~align=#flexStart, ~direction=#column, ())} id="customSelect">
      <ReactSelect
        options=optionList
        onChange={newOption => {
          let newVal = newOption
          setSelectOption(_ => newVal)
          setValue(_ => newVal.value)
        }}
        value=selectOption
        styles={
          ReactSelect.control: _ => {
            display: "flex",
            height: "37px",
            width: "100%",
            fontSize: "14px",
            color: isDarkMode ? "#ffffff" : "#303030",
            backgroundColor: isDarkMode ? "#2C2C2C" : "#ffffff",
            borderRadius: "8px",
            border: "1px solid" ++ {
              isDarkMode ? "#353535" : "#EDEDED"
            },
          },
          ReactSelect.option: _ => {
            fontSize: "14px",
            height: "37px",
            display: "flex",
            alignItems: "center",
            paddingLeft: "10px",
            cursor: "pointer",
            color: isDarkMode ? "#ffffff" : "#303030",
            backgroundColor: isDarkMode ? "#2C2C2C" : "#ffffff",
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
          ReactSelect.input: _ => {color: isDarkMode ? "#ffffff" : "#303030"},
          ReactSelect.menuList: _ => {
            backgroundColor: isDarkMode ? "#2C2C2C" : "#ffffff",
            overflowY: "scroll",
            maxHeight: "230px",
          },
        }
      />
    </div>
  }
}

@react.component
let make = () => {
  <Text value="IBC Homepage" size=Text.Body1 />
}
