type mode_t =
  | Day
  | Dark


type t = {
  baseBlue: string,
  lightenBlue: string,
  lightBlue: string,
  darkBlue: string,
  darkenBlue: string,
  white: string,
  black: string,
  textPrimary: string,
  textSecondary: string,
  mainBg: string,
  contrastBg: string,
  headerBg: string,
  secondaryBg: string,
  successColor: string,
  pendingColor: string,
  failColor: string,
  inputColor: string,
  inputContrastColor: string,
  activeColor: string,
  dropdownHover: string,
  tableRowBorderColor: string,
  secondaryTableBg: string,
  loadingBaseColor: string,
  loadingSecondaryColor: string,
  footer: string,
}

// Default Colors

let baseBlue = "#4520E6"
let lightenBlue = "#B4A5F5"
let lightBlue = "#6A4CEB"
let darkBlue = "#3719B8"
let darkenBlue = "#29138A"
let black = "#000000"
let white = "#ffffff"
let gray = "#555555"

let successColor = "#5FD3C8"
let pendingColor = "#F4D23E"
let activeColor = "#5FD3C8"
let failColor = "#E84A4B"

let footer = "#1400A5"

let get = mode =>
  switch mode {
  | Day => {
      baseBlue: baseBlue,
      lightenBlue: lightenBlue,
      lightBlue: lightBlue,
      darkBlue: darkBlue,
      darkenBlue: darkenBlue,
      white: white,
      black: black,
      successColor: successColor,
      pendingColor: pendingColor,
      activeColor: activeColor,
      failColor: failColor,
      textPrimary: "#303030",
      textSecondary: "#7D7D7D",
      mainBg: "#ffffff",
      contrastBg: "#f5f5f5",
      headerBg: "#f5f5f5",
      secondaryBg: "#ffffff",
      inputColor: "#2C2C2C",
      inputContrastColor: "#ffffff",
      dropdownHover: "#EDEDED",
      tableRowBorderColor: "#EDEDED",
      secondaryTableBg: "#F5F5F5",
      loadingBaseColor: "#F5F5F5",
      loadingSecondaryColor: "#B2B2B2",
      footer: footer,
    }
  | Dark => {
      baseBlue: baseBlue,
      lightenBlue: lightenBlue,
      lightBlue: lightBlue,
      darkBlue: darkBlue,
      darkenBlue: darkenBlue,
      white: white,
      black: black,
      successColor: successColor,
      pendingColor: pendingColor,
      activeColor: activeColor,
      failColor: failColor,
      textPrimary: "#ffffff",
      textSecondary: "#9A9A9A",
      mainBg: "#000000",
      contrastBg: "#000000",
      headerBg: "#1B1B1B",
      secondaryBg: "#1B1B1B",
      inputColor: "#ffffff",
      inputContrastColor: "#2C2C2C",
      dropdownHover: "#0F0F0F",
      tableRowBorderColor: "#353535",
      secondaryTableBg: "#2C2C2C",
      loadingBaseColor: "#303030",
      loadingSecondaryColor: "#808080",
      footer: footer,
    }
  }
