module SignalPrice = {
  type t = {
    priceStatus: int,
    signalId: string,
    price: option<float>,
  }

  let decode = {
    open JsonUtils.Decode
    object(fields => {
      priceStatus: fields.required(. "price_status", int),
      signalId: fields.required(. "signal_id", string),
      price: fields.optional(. "price", JsonUtils.Decode.float),
    })
  }
}

module Signal = {
  type t = {
    id: string,
    power: int,
  }
}
