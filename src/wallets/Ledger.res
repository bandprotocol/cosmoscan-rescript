type t = {
  transport: LedgerJS.transport_t,
  app: LedgerJS.t,
  path: array<int>,
  prefix: string,
}

type ledger_app_t = Cosmos

let getPath = (ledgerApp, accountIndex) =>
  switch ledgerApp {
  | Cosmos => [44, 118, 0, 0, accountIndex]
  }

let getAppName = x =>
  switch x {
  | Cosmos => "Cosmos"
  }

// TODO: hard-coded minimum version
let getRequiredVersion = x =>
  switch x {
  | Cosmos => "1.5.0"
  }

let getAddressAndPubKey = x => {
  let prefix = "band"
  let responsePromise = LedgerJS.getAddressAndPubKey(x.app, x.path, prefix)

  responsePromise->Promise.then(response => {
    if response.return_code != 36864 {
      Js.Console.log(response.error_message)
      Promise.reject(Not_found)
    } else {
      Promise.resolve((
        response.bech32_address->Address.fromBech32,
        response.compressed_pk->JsBuffer.from->JsBuffer.toHex->PubKey.fromHex,
      ))
    }
  })
}

let create = (ledgerApp, accountIndex) => {
  open Promise
  // TODO: handle interaction timeout later
  let timeout = 10000
  let path = getPath(ledgerApp, accountIndex)
  let prefix = "band"

  let transportPromise = Os.isWindows()
    ? LedgerJS.createTransportWebHID(timeout)
    : LedgerJS.createTransportWebUSB(timeout)

  transportPromise->then(transport => {
    let app = LedgerJS.createApp(transport)

    LedgerJS.publicKey(app, path)->then(pubKeyInfo => {
      LedgerJS.appInfo(app)->then(
        appInfo => {
          LedgerJS.getVersion(app)->then(
            version => {
              let {major, minor, patch, test_mode, device_locked} = version
              let userVersion = j`$major.$minor.$patch`
              let requiredAppName = getAppName(ledgerApp)
              let requiredVersion = getRequiredVersion(ledgerApp)

              // 36864(0x9000) will return if there is no error.
              // TODO: improve handle error
              // Validatate step
              // 1. Check return code of pubKeyInfo
              // 2. If pass, then check app version
              // 3. If pass, then check test_mode
              if pubKeyInfo.return_code != 36864 {
                if appInfo.appName != requiredAppName {
                  let appName = appInfo.appName
                  Js.Console.log(j`App name is not $requiredAppName. (Current is $appName)`)
                  reject(Not_found)
                } else if device_locked {
                  Js.Console.log3("Device is locked", pubKeyInfo, version)
                  reject(Not_found)
                } else {
                  Js.Console.log(pubKeyInfo.error_message)
                  reject(Not_found)
                }
              } else if !Semver.gte(userVersion, requiredVersion) {
                Js.Console.log(j`Cosmos app version must >= $requiredVersion (Current is $userVersion)`)
                reject(Not_found)
              } else if test_mode {
                Js.Console.log3("test mode is not supported", pubKeyInfo, version)
                reject(Not_found)
              } else {
                resolve({transport, app, path, prefix})
              }
            },
          )
        },
      )
    })
  })
}

let sign = (x, message) => {
  let responsePromise = LedgerJS.sign(x.app, x.path, message)
  responsePromise->Promise.then(response => {
    response.signature->Secp256k1.signatureImport->JsBuffer.from->Promise.resolve
  })
}
