// type t<'a> = ApolloClient__React_Hooks_UseSubscription.useSubscription_result<'a, 'a>

// let map = (result, f) =>
//   switch (result) {
//   | ApolloClient__React_Hooks_UseSubscription.useSubscription_result<data, variables> => ApolloClient__React_Hooks_UseSubscription.useSubscription_result<data |> f>
//   | Loading => Loading
//   | Error(e) => Error(e)
//   | NoData => NoData
//   };

open ApolloClient__React_Hooks_UseSubscription

type variant<'a> =
  | Data('a)
  | Error(ApolloError.t)
  | Loading
  | NoData

let fromData = result =>
  switch result {
  | {data: Some(data)} => Data(data)
  | {error: Some(error)} => Error(error)
  | {loading: true} => Loading
  | {data: None, error: None, loading: false} => NoData
  }

// 1. loading: true, data: None
// 2. loading: false, data: Some
// 3. loading: true, data: Some

let map = (result, f) =>
  switch result {
  | Data(data) => Data(data |> f)
  | Loading => Loading
  | Error(e) => Error(e)
  | NoData => NoData
  }
