type t = {
  address: string,
  amount: int,
}

let request = (data: t) =>
  Axios.post(Env.faucet, data)->Promise.then(response => {
    Promise.resolve(response)
  })
