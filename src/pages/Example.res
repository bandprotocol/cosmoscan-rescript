module Styles = {
  open CssJs

  let root = style(. [
    backgroundColor(black),
    color(white),
    padding2(~v=px(10), ~h=px(20)),
    marginTop(Spacing.lg),
    Media.mobile([backgroundColor(pink)]),
  ])

  let padding = style(. [padding(px(20))])
}

@react.component
let make = () => {
  let ({ThemeContext.isDarkMode: isDarkMode, theme}, toggle) = React.useContext(
    ThemeContext.context,
  )
  let (_, dispatchModal) = React.useContext(ModalContext.context)

  let currentTime =
    React.useContext(TimeContext.context) |> MomentRe.Moment.format(Config.timestampUseFormat)

  Js.log(currentTime)

  let send = () => {
    None->SubmitMsg.Send->SubmitTx->OpenModal->dispatchModal
  }

  // let pageSize = 5
  // let (value, setValue) = React.useState(_ => 0.)
  // let (preValue, setPreValue) = React.useState(_ => 0.)
  // let blockSub = BlockSub.get(~height=10030000, ())

  // let markDown = "### Hello Word ``` code ``` **strong**"

  // let update = () => setValue(prev => prev +. 20.)

  // let capitalizedName = "hello world" |> ChangeCase.pascalCase

  // let keyword = "testing"

  // let client = BandChainJS.createClient("https://api-gm-lb.bandchain.org")
  // let _ =
  //   client
  //   ->BandChainJS.getReferenceData(["BAND/USD", "BAND/BTC"])
  //   ->Promise.then(result => {
  //     Js.log(result)
  //     Promise.resolve()
  //   })

  // Js.log(capitalizedName)
  // Js.log(Theme.get(Theme.Day))
  // let identity = "94C57647B928FAF1"
  // let useTest = AxiosHooks.use(j`https://keybase.io/_/api/1.0/user/lookup.json?key_suffix=$identity&fields=pictures`)
  // Js.log2("use", useTest)

  // let (
  //   data,
  //   reload,
  // ) = AxiosHooks.useWithReload(j`https://keybase.io/_/api/1.0/user/lookup.json?key_suffix=$identity&fields=pictures`)

  // Js.log2("useWithReloadData", data)

  // React.useEffect1(() => {
  //   let handleKey = event =>
  //     if ReactEvent.Keyboard.keyCode(event) == 27 {
  //       Js.log("trigger")
  //     }
  //   Document.addKeyboardEventListener("keydown", handleKey)
  //   Some(() => Document.removeKeyboardEventListener("keydown", handleKey))
  // }, [])
  // LocalStorage.setItem(keyword, "Hello World")
  // Js.log(Semver.gte("5.2.3", "3.2.1"))

  // // address
  // let mnemonic = "absurd exhibit garbage gun flush gown basic chicken east image chimney stand skill own bracket"
  // let bandChain = CosmosJS.network("rpcUrl", "chainID")
  // bandChain->CosmosJS.setPath("m/44'/494'/0'/0/0")
  // bandChain->CosmosJS.setBech32MainPrefix("band")
  // Js.log2(
  //   "private",
  //   bandChain |> CosmosJS.getECPairPriv(_, mnemonic) |> JsBuffer.toHex(~with0x=false),
  // )
  // Js.log2("address", bandChain |> CosmosJS.getAddress(_, mnemonic))

  // let countUp = CountUp.context(
  //   CountUp.props(
  //     ~start=preValue,
  //     ~end=value,
  //     ~delay=0,
  //     ~decimals=6,
  //     ~duration=4,
  //     ~useEasing=false,
  //     ~separator=",",
  //     ~ref="counter",
  //   ),
  // )

  Js.log(Env.rpc)

  let chainID = "band-laozi-testnet2"

  let (accountOpt, dispatchAccount) = React.useContext(AccountContext.context)

  let connectMnemonic = () => {
    let wallet = Wallet.createFromMnemonic("s")
    let _ =
      wallet
      ->Wallet.getAddressAndPubKey
      ->Promise.then(((address, pubKey)) => {
        dispatchAccount(Connect(wallet, address, pubKey, chainID))
        Js.log(accountOpt)
        Promise.resolve()
      })
      ->Promise.catch(err => {
        Js.Console.log(err)
        Promise.resolve()
      })
  }

  let connectLedger = () => {
    let wallet = Wallet.createFromMnemonic("s")
    let _ =
      wallet
      ->Wallet.getAddressAndPubKey
      ->Promise.then(((address, pubKey)) => {
        dispatchAccount(Connect(wallet, address, pubKey, chainID))
        Js.log(accountOpt)
        Promise.resolve()
      })
      ->Promise.catch(err => {
        Js.Console.log(err)
        Promise.resolve()
      })
  }

  let connectLedger = () => {
    let _ =
      Wallet.createFromLedger(Ledger.Cosmos, 0)
      ->Promise.then(wallet => {
        wallet
        ->Wallet.getAddressAndPubKey
        ->Promise.then(((address, pubKey)) => {
          dispatchAccount(Connect(wallet, address, pubKey, chainID))
          Promise.resolve()
        })
      })
      ->Promise.catch(err => {
        Js.Console.log(err)
        Promise.resolve()
      })
  }

  let disconnect = () => {
    dispatchAccount(Disconnect)
  }

  <>
    <button
      onClick={_ => {
        toggle()
        Js.log(isDarkMode)
      }}>
      {"Change Theme" |> React.string}
    </button>
    <button onClick={_ => send()}> {"Send modal" |> React.string} </button>
    <button onClick={_ => connectMnemonic()}> {"Connect Wallets Mnemonic" |> React.string} </button>
    <button onClick={_ => connectLedger()}> {"Connect Wallets Ledger" |> React.string} </button>
    <button onClick={_ => disconnect()}> {"Disconnected" |> React.string} </button>
    {switch accountOpt {
    | Some({address}) => address |> Address.toBech32 |> React.string
    | None => "not connected" |> React.string
    }}
  </>

  // React.useEffect1(_ => {
  //   countUp.update(value)
  //   let timeoutId = Js.Global.setTimeout(() => setPreValue(_ => value), 800)
  //   Some(() => Js.Global.clearTimeout(timeoutId))
  // }, [value])

  // Js.log(LocalStorage.getItem(keyword))

  // <>
  //   <Tooltip
  //     title={"hello world" |> React.string}
  //     placement="bottom"
  //     arrow=true
  //     leaveDelay=0
  //     leaveTouchDelay=3000
  //     enterTouchDelay=0>
  //     <span> {React.string("Hello World")} </span>
  //   </Tooltip>
  //   <ReactSelectCustom />
  //   <MarkDown value=markDown />
  //   <div
  //     onClick={_ => {
  //       Copy.copy("Hello World")
  //     }}>
  //     {"Copy" |> React.string}
  //   </div>
  //   <QRCode value={"Wow QR Code"} size=200 />
  //   <span id="counter" />
  //   <button onClick={_ => update()}> {"update" |> React.string} </button>
  //   <ReactHighlight className=Styles.padding>
  //     {"let x = hello world; console.log(x);" |> React.string}
  //   </ReactHighlight>
  //   <div className=Styles.root>
  //     {switch blockSub {
  //     | {data: Some({blocks_by_pk}), loading: false} => {
  //         Js.log2("Data is ", blocks_by_pk)
  //         React.null
  //       }
  //     | {loading: true, data: Some(x)} => {
  //         Js.log2("Loading with Some", x)
  //         <div> {"Loading with Some" |> React.string} </div>
  //       }
  //     | {loading: true, data: None} => {
  //         Js.log("Loading with None")
  //         <div> {"Loading with None" |> React.string} </div>
  //       }
  //     | {error: Some(error)} => {
  //         Js.log(error)
  //         React.null
  //       }
  //     | {loading: false, data: None, error: None} => {
  //         Js.log("No data")
  //         <div> {"No data" |> React.string} </div>
  //       }
  //     }}
  //   </div>
  //   {
  //     let dict = Js.Dict.empty()
  //     Js.Dict.set(dict, "name", Js.Json.string("John Doe"))
  //     let src = Js.Json.object_(dict)

  //     <JsonViewer src />
  //   }
  // </>
}
