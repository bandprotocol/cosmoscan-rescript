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
  let (value, setValue) = React.useState(_ => 0.)
  let (preValue, setPreValue) = React.useState(_ => 0.)
  let blockSub = BlockSub.get(~height=10030000, ())

  let markDown = "### Hello Word ``` code ``` **strong**"

  let update = () => setValue(prev => prev +. 20.)

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
  let identity = "94C57647B928FAF1"
  let resOpt = AxiosHooks.use(j`https://keybase.io/_/api/1.0/user/lookup.json?key_suffix=$identity&fields=pictures`)
  Js.log2("avatar", resOpt)

  React.useEffect1(() => {
    let handleKey = event =>
      if ReactEvent.Keyboard.keyCode(event) == 27 {
        Js.log("trigger")
      }
    Document.addKeyboardEventListener("keydown", handleKey)
    Some(() => Document.removeKeyboardEventListener("keydown", handleKey))
  }, [])
  LocalStorage.setItem(keyword, "Hello World")

  let countUp = CountUp.context(
    CountUp.props(
      ~start=preValue,
      ~end=value,
      ~delay=0,
      ~decimals=6,
      ~duration=4,
      ~useEasing=false,
      ~separator=",",
      ~ref="counter",
    ),
  )

  React.useEffect1(_ => {
    countUp.update(value)
    let timeoutId = Js.Global.setTimeout(() => setPreValue(_ => value), 800)
    Some(() => Js.Global.clearTimeout(timeoutId))
  }, [value])

  Js.log(LocalStorage.getItem(keyword))

  <>
    <ReactSelectCustom />
    <MarkDown value=markDown />
    <div
      onClick={_ => {
        Copy.copy("Hello World")
      }}>
      {"Copy" |> React.string}
    </div>
    <QRCode value={"Wow QR Code"} size=200 />
    <span id="counter" />
    <button onClick={_ => update()}> {"update" |> React.string} </button>
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
