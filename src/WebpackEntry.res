switch ReactDOM.querySelector("#root") {
| Some(container) => ReactDOM.Client.createRoot(container)->ReactDOM.Client.Root.render(<Index />)
| None => ()
}
