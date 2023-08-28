type council_name_t = BandDaoCouncil | GrantCouncil | TechCouncil | Unknown

module CouncilNameParser = {
  let parse = str =>
    switch str {
    | "COUNCIL_TYPE_BAND_DAO" => BandDaoCouncil
    | "COUNCIL_TYPE_GRANT" => GrantCouncil
    | "COUNCIL_TYPE_TECH" => TechCouncil
    | _ => Unknown
    }

  let serialize = (councilName: council_name_t) => {
    switch councilName {
    | BandDaoCouncil => "COUNCIL_TYPE_BAND_DAO"
    | GrantCouncil => "COUNCIL_TYPE_GRANT"
    | TechCouncil => "COUNCIL_TYPE_TECH"
    | Unknown => "Unknown"
    }
  }
}

let getCouncilNameString = (councilName: council_name_t) =>
  switch councilName {
  | BandDaoCouncil => "Band DAO Council"
  | GrantCouncil => "Grant Council"
  | TechCouncil => "Tech Council"
  | Unknown => "Unknown"
  }
