@module("axios") external get: string => promise<'a> = "get"
@module("axios") external post: (string, 'a) => promise<'b> = "post"
