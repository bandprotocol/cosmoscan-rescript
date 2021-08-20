@deriving(abstract)
type t = {
  executable: string,
  calldata: string,
  timeout: int,
}

/* TODO: FIX THIS MESS */
let convert: t => Js.t<'a> = %raw(`
function(data) {
  return {...data};
}
`)

let execute = (data: t) => Axios.postData(Env.lambda, convert(data))
