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
type valueContainer_t = {padding: string, flex: string, display: string, alignItems: string}

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
let make = (
  ~validatorOpt: option<Address.t>,
  ~filteredValidators: array<Validator.t>,
  ~setValidatorOpt,
) => {
  let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

  let validatorList = filteredValidators->Belt.Array.map(({operatorAddress, moniker}) => {
    open ReactSelect
    {value: operatorAddress->Address.toOperatorBech32, label: moniker}
  })
  let (selectedValidator, setSelectedValidator) = React.useState(_ => {
    open ReactSelect
    switch validatorOpt {
    | Some(val) =>
      switch Belt.Array.getBy(filteredValidators, v => v.operatorAddress == val) {
      | Some(v) => {value: v.operatorAddress->Address.toOperatorBech32, label: v.moniker}
      | None => {value: "N/A", label: "Select Validator"}
      }
    | None => {value: "N/A", label: "Select Validator"}
    }
  })

  // TODO: Hack styles for react-select
  <div
    className={CssHelper.flexBox(~align=#flexStart, ~direction=#column, ())}
    id="redelegateContainer">
    <ReactSelect
      options=validatorList
      onChange={newOption => {
        let newVal = newOption
        setSelectedValidator(_ => newVal)
        setValidatorOpt(_ => Some(newVal.value->Address.fromBech32))
      }}
      value=selectedValidator
      styles={
        ReactSelect.control: _ => {
          display: "flex",
          height: "37px",
          width: "100%",
          fontSize: "14px",
          color: theme.neutral_900->Theme.toString,
          backgroundColor: theme.neutral_000->Theme.toString,
          borderRadius: "8px",
          border: `1px solid ${theme.neutral_300->Theme.toString}`,
        },
        ReactSelect.option: _ => {
          fontSize: "14px",
          height: "37px",
          display: "flex",
          alignItems: "center",
          paddingLeft: "10px",
          cursor: "pointer",
          color: theme.neutral_900->Theme.toString,
          backgroundColor: theme.neutral_000->Theme.toString,
        },
        ReactSelect.container: _ => {
          width: "100%",
          position: "relative",
          boxSizing: "border-box",
        },
        ReactSelect.valueContainer: _ => {
          display: "grid",
          alignItems: "center",
          flex: "1",
          padding: "0px 16px",
        },
        ReactSelect.singleValue: _ => {
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
        ReactSelect.input: _ => {color: theme.neutral_900->Theme.toString},
        ReactSelect.menuList: _ => {
          backgroundColor: theme.neutral_000->Theme.toString,
          overflowY: "scroll",
          maxHeight: "230px",
        },
      }
    />
    <VSpacing size=Spacing.sm />
    <Text value={"(" ++ selectedValidator.value ++ ")"} />
  </div>
}
