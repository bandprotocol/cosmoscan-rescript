@module("axios") external get: string => Promise.t<'a> = "get"
@module("axios") external post: (string, Js.t<'a>) => Promise.t<'b> = "post"
