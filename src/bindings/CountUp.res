@deriving(abstract)
type props = {
  start: float,
  end: float,
  delay: int,
  decimals: int,
  duration: int,
  useEasing: bool,
  separator: string,
}

@deriving(abstract)
type t = {
  countUp: float,
  update: float => unit,
}

@val @module("react-countup") external context: props => t = "useCountUp"
