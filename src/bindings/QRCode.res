@module("qrcode.react") @react.component
external make: (~value: string, ~size: int) => React.element = "QRCodeCanvas"
