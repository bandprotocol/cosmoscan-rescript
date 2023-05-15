@deriving(abstract)
type t = {
  executable: string,
  calldata: string,
  timeout: int,
}

let execute = (data: t) => Axios.post(Env.lambda, data)
