module Price = {
  type t = {
    multiplier: float,
    px: float,
  }

  let decode = json => {
    multiplier: json
    |> JsonUtils.Decode.at(list{"multiplier"}, JsonUtils.Decode.string)
    |> float_of_string,
    px: json |> JsonUtils.Decode.at(list{"px"}, JsonUtils.Decode.string) |> float_of_string,
  }
}

let getPrices = () => {
  Axios.get(
    "https://lcd-lp.bandchain.org/oracle/v1/request_prices?ask_count=4&min_count=3&symbols=BAND&symbols=BTC",
  )->Promise.then(response => {
    let price = response["data"]["price_results"] |> Belt.Array.map(_, Price.decode)
    Js.log(price)
    Promise.resolve(price)
  })
}
