type modal_t =
  | Connect(string)
  | SubmitTx(SubmitMsg.t)
  | ChainSelector(IBCConnectionQuery.target_chain_t)
  | QRCode(Address.t)
  | IBCPacketError(string)
  | Syncing
  | CouncilMembers(Council.council_t)
  | Depositors(int)
  | VetoVote(ID.LegacyProposal.t)

type t = {
  canExit: bool,
  closing: bool,
  modal: modal_t,
}

type a =
  | OpenModal(modal_t)
  | CloseModal
  | KillModal
  | EnableExit
  | DisableExit

let reducer = (state, x) =>
  switch x {
  | OpenModal(m) => Some({canExit: true, closing: false, modal: m})
  | CloseModal =>
    switch state {
    | Some({modal}) => Some({canExit: true, closing: true, modal})
    | None => None
    }
  | KillModal => None
  | EnableExit =>
    switch state {
    | Some({modal}) => Some({canExit: true, closing: false, modal})
    | None => None
    }
  | DisableExit =>
    switch state {
    | Some({modal}) => Some({canExit: false, closing: false, modal})
    | None => None
    }
  }

type props = {value: (option<t>, a => unit), children: React.element}
let context = React.createContext((None, _ => ()))

module Provider = {
  @react.component
  let make = (~children) => {
    let (state, dispatch) = React.useReducer(reducer, None)
    let isClosing = state->Belt.Option.mapWithDefault(false, ({closing}) => closing)
    React.useEffect1(() => {
      if isClosing {
        Js.Global.setTimeout(() => dispatch(KillModal), Config.modalFadingDutation)->ignore
      }
      None
    }, [isClosing])
    React.createElement(React.Context.provider(context), {value: (state, dispatch), children})
  }
}
