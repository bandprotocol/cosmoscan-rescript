@module("axios") external get: string => promise<'a> = "get"
@module("axios") external post: (string, Js.t<'a>) => promise<'b> = "post"
