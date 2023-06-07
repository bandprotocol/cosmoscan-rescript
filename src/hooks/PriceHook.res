type t = {
  usdPrice: float,
  usdMarketCap: float,
  usd24HrChange: float,
  btcPrice: float,
  btcMarketCap: float,
  circulatingSupply: float,
  totalSupply: float,
}

let getBandUsd24Change = () => {
  open! JsonUtils.Decode
  Axios.get(
    "https://api.coingecko.com/api/v3/simple/price?ids=band-protocol&vs_currencies=usd&include_market_cap=true&include_24hr_change=true",
  )
  ->Promise.then(result =>
    Promise.resolve(result->mustAt(list{"data", "band-protocol", "usd_24h_change"}, float))
  )
  ->Promise.catch(_ => {
    Js.Console.log("swapped to use cryptocompare api")
    Axios.get(
      "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BAND&tsyms=USD",
    )->Promise.then(result =>
      Promise.resolve(result->mustAt(list{"data", "RAW", "BAND", "USD", "CHANGEPCT24HOUR"}, float))
    )
  })
}

let getCirculatingSupply = () => {
  open! JsonUtils.Decode

  Axios.get("https://api.bandchain.org/supply/circulating")
  ->Promise.then(result => Promise.resolve(result->mustGet("data", float)))
  ->Promise.catch(_ => {
    Js.Console.log("swapped to use coingekco api")
    Axios.get(
      "https://api.coingecko.com/api/v3/coins/band-protocol?tickers=false&community_data=false&developer_data=false&sparkline=false",
    )->Promise.then(result =>
      Promise.resolve(result->mustAt(list{"data", "market_data", "circulating_supply"}, float))
    )
  })
}

let getTotalSupply = () => {
  open! JsonUtils.Decode

  Axios.get("https://api.bandchain.org/supply/total")
  ->Promise.then(result => Promise.resolve(result->mustGet("data", float)))
  ->Promise.catch(e => {
    Js.Console.log("can't get totalsupply")
    Js.Console.log(e)
    Js.Promise.resolve(0.)
  })
}

module Price = {
  type t = {
    multiplier: float,
    px: float,
  }

  let decode = {
    open JsonUtils.Decode
    buildObject(json => {
      multiplier: json.required(list{"multiplier"}, floatstr),
      px: json.required(list{"px"}, floatstr),
    })
  }
}

let getPrices = () =>
  Axios.get(
    "https://laozi1.bandchain.org/api/oracle/v1/request_prices?ask_count=16&min_count=10&symbols=BAND&symbols=BTC",
  )->Promise.then(result =>
    Promise.resolve({
      let prices =
        result->JsonUtils.Decode.mustAt(
          list{"data", "price_results"},
          JsonUtils.Decode.array(Price.decode),
        )
      prices
      ->Belt.Array.get(0)
      ->Belt.Option.flatMap(bandPrice => {
        prices
        ->Belt.Array.get(1)
        ->Belt.Option.flatMap(
          btcPrice => {
            let bandUsdPrice = bandPrice.px /. bandPrice.multiplier
            let btcUsdPrice = btcPrice.px /. btcPrice.multiplier
            let bandBtcPrice = bandUsdPrice /. btcUsdPrice
            Some((bandUsdPrice, bandBtcPrice))
          },
        )
      })
    })
  )

let getBandInfo = client => {
  //TODO: Will uncomment after, we have bandchainjs
  // let ratesPromise = client->BandChainJS.Client.getReferenceData(["BAND/USD", "BAND/BTC"], 10, 16)
  let ratesPromise = getPrices()
  let supplyPromise = getCirculatingSupply()
  let usd24HrChangePromise = getBandUsd24Change()
  let totalPromise = getTotalSupply()

  Promise.all4((
    ratesPromise,
    usd24HrChangePromise,
    supplyPromise,
    totalPromise,
  ))->Promise.then(result => {
    Promise.resolve({
      let (rates, usd24HrChange, supply, totalSupply) = result
      rates->Belt.Option.flatMap(prices => {
        let (bandUsd, bandBtc) = prices
        Some({
          usdPrice: bandUsd,
          usdMarketCap: bandUsd *. supply,
          usd24HrChange,
          btcPrice: bandBtc,
          btcMarketCap: bandBtc *. supply,
          circulatingSupply: supply,
          totalSupply,
        })
      })
    })
  })
}
