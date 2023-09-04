module YesNo = {
  type t = Yes | No | Unknown

  let getColor = (vote, theme: Theme.t) =>
    switch vote {
    | Yes => theme.success_600
    | No => theme.error_600
    | Unknown => theme.neutral_900
    }

  let getColorInvert = (vote, theme: Theme.t) =>
    switch vote {
    | Yes => theme.error_600
    | No => theme.success_600
    | Unknown => theme.neutral_900
    }

  let toString = vote =>
    switch vote {
    | Yes => "Yes"
    | No => "No"
    | Unknown => "Unknown"
    }

  module Parser = {
    let parse = json =>
      switch json->Js.Json.decodeString {
      | Some(str) =>
        switch str {
        | "Yes" => Yes
        | "No" => No
        | _ => Unknown
        }
      | None => Unknown
      }

    let serialize = vote => vote->toString->Js.Json.string
  }
}

module Full = {
  type t = Yes | No | NoWithVeto | Abstain | Unknown

  let getColor = (vote, theme: Theme.t) =>
    switch vote {
    | Yes => theme.success_600
    | No => theme.error_600
    | NoWithVeto => theme.error_700
    | Abstain => theme.warning_600
    | Unknown => theme.neutral_900
    }

  let getColorInvert = (vote, theme: Theme.t) =>
    switch vote {
    | Yes => theme.error_600
    | No => theme.success_600
    | NoWithVeto => theme.success_800
    | Abstain => theme.neutral_500
    | Unknown => theme.neutral_900
    }

  let toString = vote =>
    switch vote {
    | Yes => "Yes"
    | No => "No"
    | NoWithVeto => "Veto"
    | Abstain => "Abstain"
    | Unknown => "Unknown"
    }
}
