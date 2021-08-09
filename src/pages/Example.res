module Styles = {
  open CssJs

  let root = style(. [
    backgroundColor(black),
    color(white),
    padding2(~v=px(10), ~h=px(20)),
    marginTop(Spacing.lg),
    Media.mobile([backgroundColor(pink)]),
  ])
}

@react.component
let make = () => {
  let pageSize = 5
  let (page, setPage) = React.useState(_ => 1)
  let blockSub = BlockSub.get(~height=10030000, ())

  let next = () => setPage(prev => prev + 1)
  let value = "### Hello Word ``` code ``` **strong**"

  let capitalizedName = "hello world" |> ChangeCase.pascalCase

  let keyword = "testing"

  let client = BandChainJS.createClient("https://api-gm-lb.bandchain.org")
  let _ =
    client
    ->BandChainJS.getReferenceData(["BAND/USD", "BAND/BTC"])
    ->Promise.then(result => {
      Js.log(result)
      Promise.resolve()
    })

  Js.log(capitalizedName)
  Js.log(Theme.get(Theme.Day))
  React.useEffect1(() => {
    let handleKey = event =>
      if ReactEvent.Keyboard.keyCode(event) == 27 {
        Js.log("trigger")
      }

    Document.addKeyboardEventListener("keydown", handleKey)
    Some(() => Document.removeKeyboardEventListener("keydown", handleKey))
  }, [])
  LocalStorage.setItem(keyword, "Hello World")

  Js.log(LocalStorage.getItem(keyword))
  <>
    <MarkDown value />
    <div
      onClick={_ => {
        Copy.copy("Hello World")
      }}>
      {"Copy" |> React.string}
    </div>
    <QRCode value={"Wow QR Code"} size=200 />
    <div className=Styles.root>
      {switch blockSub {
      | {data: Some({blocks_by_pk}), loading: false} => {
          Js.log2("Data is ", blocks_by_pk)
          React.null
        }
      | {loading: true, data: Some(x)} => {
          Js.log2("Loading with Some", x)
          <div> {"Loading with Some" |> React.string} </div>
        }
      | {loading: true, data: None} => {
          Js.log("Loading with None")
          <div> {"Loading with None" |> React.string} </div>
        }
      | {error: Some(error)} => {
          Js.log(error)
          React.null
        }
      | {loading: false, data: None, error: None} => {
          Js.log("No data")
          <div> {"No data" |> React.string} </div>
        }
      }}
    </div>
  </>
}
