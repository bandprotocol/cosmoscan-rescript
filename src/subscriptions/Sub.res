open ApolloClient__React_Hooks_UseSubscription

type variant<'a> =
  | Data('a)
  | Error(ApolloError.t)
  | Loading
  | NoData

let resolve = data => Data(data)

let default = (result, value) =>
  switch result {
  | Data(data) => data
  | _ => value
  }

let fromData = result =>
  switch result {
  | {data: Some(data)} => Data(data)
  | {error: Some(error)} => Error(error)
  | {loading: true} => Loading
  | {data: None, error: None, loading: false} => NoData
  }

let fromData2 = (result1, result2, f) =>
  switch (result1, result2) {
  | (Data(data1), Data(data2)) => Data(f(data1, data2))
  | (Loading, _) => Loading
  | (_, Loading) => Loading
  | (Error(e), _) => Error(e)
  | (_, Error(e)) => Error(e)
  | (NoData, _) => NoData
  | (_, NoData) => NoData
  }

let flatMap = (result, f) =>
  switch result {
  | Data(data) => f(data)
  | Loading => Loading
  | Error(e) => Error(e)
  | NoData => NoData
  }

// 1. loading: true, data: None
// 2. loading: false, data: Some
// 3. loading: true, data: Some

let map = (result, f) =>
  switch result {
  | Data(data) => Data(data->f)
  | Loading => Loading
  | Error(e) => Error(e)
  | NoData => NoData
  }

let map2 = (result1, result2, f) =>
  switch (result1, result2) {
  | (Data(data1), Data(data2)) => Data(f(data1, data2))
  | (Loading, _) => Loading
  | (_, Loading) => Loading
  | (Error(e), _) => Error(e)
  | (_, Error(e)) => Error(e)
  | (NoData, _) => NoData
  | (_, NoData) => NoData
  }

let all2 = (s1, s2) => flatMap(s1, s1' => flatMap(s2, s2' => Data((s1', s2'))))

let all3 = (s1, s2, s3) =>
  flatMap(s1, s1' => flatMap(s2, s2' => flatMap(s3, s3' => Data((s1', s2', s3')))))

let all4 = (s1, s2, s3, s4) =>
  flatMap(s1, s1' =>
    flatMap(s2, s2' => flatMap(s3, s3' => flatMap(s4, s4' => Data((s1', s2', s3', s4')))))
  )

let all5 = (s1, s2, s3, s4, s5) =>
  flatMap(s1, s1' =>
    flatMap(s2, s2' =>
      flatMap(s3, s3' => flatMap(s4, s4' => flatMap(s5, s5' => Data((s1', s2', s3', s4', s5')))))
    )
  )
