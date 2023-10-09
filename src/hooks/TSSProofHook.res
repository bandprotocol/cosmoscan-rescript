module Response = {
  type t = {data: Js.Json.t}

  let decode = {
    open JsonUtils.Decode
    object(fields => {
      data: fields.required(. "data", id),
    })
  }
}

let get = (requestID: int) => {
  open! JsonUtils.Decode

  Axios.get(
    `https://laozi-hackathon.bandchain.org/api/tss/v1beta1/signings/${requestID->Belt.Int.toString}`,
  )->Promise.then(result => {
    Promise.resolve(
      result->Belt.Option.map(json => JsonUtils.Decode.mustDecode(json, Response.decode)),
    )
  })
  // ->Promise.catch(e => {
  //   Js.Console.log(e)
  //   Js.Promise.resolve(0.)
  // })
}
