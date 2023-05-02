@deriving(abstract)
type cookie_attributes = {expires: option<int>}

@module("js-cookie") external get: string => bool = "get"
@module("js-cookie") external set: (string, string, option<cookie_attributes>) => unit = "set"
