# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [field: :*],
  export: [
    locals_without_parens: [field: :*]
  ]
]
