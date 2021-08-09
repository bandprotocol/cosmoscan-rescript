@deriving(abstract)
type props = {
  ref: string,
  start: float,
  end: float,
  delay: int,
  decimals: int,
  duration: int,
  useEasing: bool,
  separator: string,
}

type t = {
  countUp: float,
  update: float => unit,
}

@module("react-countup") @val external context: props => t = "useCountUp"
