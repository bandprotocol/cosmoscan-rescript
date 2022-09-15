type t = {
  usdPrice: float,
  usdMarketCap: float,
  usd24HrChange: float,
  btcPrice: float,
  btcMarketCap: float,
  circulatingSupply: float,
}

let getBandUsd24Change = () => {
  open! JsonUtils.Decode
  Axios.get(
    "https://api.coingecko.com/api/v3/simple/price?ids=band-protocol&vs_currencies=usd&include_market_cap=true&include_24hr_change=true",
  )
  ->Promise.then(result =>
    Promise.resolve(result["data"] |> at(list{"band-protocol", "usd_24h_change"}, float))
  )
  ->Promise.catch(_ => {
    Js.Console.log("swapped to use cryptocompare api")
    Axios.get(
      "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BAND&tsyms=USD",
    )->Promise.then(result =>
      Promise.resolve(result["data"] |> at(list{"RAW", "BAND", "USD", "CHANGEPCT24HOUR"}, float))
    )
  })
}

let getCirculatingSupply = () => {
  open! JsonUtils.Decode

  Axios.get("https://supply.bandchain.org/circulating")
  ->Promise.then(result => Promise.resolve(result["data"] |> float))
  ->Promise.catch(_ => {
    Js.Console.log("swapped to use coingekco api")
    Axios.get(
      "https://api.coingecko.com/api/v3/coins/band-protocol?tickers=false&community_data=false&developer_data=false&sparkline=false",
    )->Promise.then(result =>
      Promise.resolve(result["data"] |> at(list{"market_data", "circulating_supply"}, float))
    )
  })
}

module Price = {
  type t = {
    multiplier: float,
    px: float,
  }

  let decode = json => {
    open JsonUtils.Decode
    {
      multiplier: json |> at(list{"multiplier"}, string) |> float_of_string,
      px: json |> at(list{"px"}, string) |> float_of_string,
    }
  }
}

let getPrices = () =>
  Axios.get(
    "https://lcd-lp.bandchain.org/oracle/v1/request_prices?ask_count=4&min_count=3&symbols=BAND&symbols=BTC",
  )->Promise.then(result =>
    Promise.resolve({
      let prices = result["data"]["price_results"] |> Belt.Array.map(_, Price.decode)
      prices->Belt.Array.get(0)
        -> Belt.Option.flatMap( bandPrice => {
          prices->Belt.Array.get(1)
            -> Belt.Option.flatMap( btcPrice => {
              let bandUsdPrice = bandPrice.px /. bandPrice.multiplier
              let btcUsdPrice = btcPrice.px /. btcPrice.multiplier
              let bandBtcPrice = bandUsdPrice /. btcUsdPrice

              Some((bandUsdPrice, bandBtcPrice))
            })
        })
    })
  )

let getBandInfo = client => {
  //TODO: Will uncomment after, we have bandchainjs
  // let ratesPromise = client->BandChainJS.getReferenceData([|"BAND/USD", "BAND/BTC"|]);
  let ratesPromise = getPrices()
  let supplyPromise = getCirculatingSupply()
  let usd24HrChangePromise = getBandUsd24Change()

  Promise.all3((ratesPromise, usd24HrChangePromise, supplyPromise))->Promise.then(result => {
    Promise.resolve({
      let (rates, usd24HrChange, supply) = result
      rates |> Belt.Option.flatMap(_, prices => {
        let (bandUsd, bandBtc) = prices
        Some({
          usdPrice: bandUsd,
          usdMarketCap: bandUsd *. supply,
          usd24HrChange: usd24HrChange,
          btcPrice: bandBtc,
          btcMarketCap: bandBtc *. supply,
          circulatingSupply: supply,
        })
      })
    })
  })
}
