switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<Index />, root)
| None => ()
}
