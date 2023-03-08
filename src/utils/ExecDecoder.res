// TODO: confirm for unused modules from previous code in ReasonML, next plan?

// module RawDataReport = {
//   type t = {
//     externalDataID: int,
//     data: JsBuffer.t,
//   }

//   let decoder = {
//     open JsonUtils.Decode
//     buildObject(json => {
//       externalDataID: json.required(list{"external_id"}, intWithDefault(0)),
//       data: json.required(list{"data"}, bufferWithDefault),
//     })
//   }
// }

// module Report = {
//   type t = {
//     requestID: ID.Request.t,
//     rawReports: list<RawDataReport.t>,
//     validator: Address.t,
//   }

//   let decoder = {
//     open JsonUtils.Decode
//     buildObject(json => {
//       requestID: json.required(list{"msg", "request_id"}, ID.Request.decoder),
//       rawReports: json.required(list{"msg", "raw_reports"}, list(RawDataReport.decoder)),
//       validator: json.required(list{"msg", "validator"}, string)->Address.fromBech32,
//     })

// TODO: Ref from ReasonML code, need to confirm
//       buildObject(json => {
//         requestID: oneOf([
//           json.required(list{"msg", "request_id"}, ID.Request.decoder),
//           json.required(list{"request_id"}, ID.Request.decoder),
//         ]),
//         rawReports: oneOf([
//           json.required(list{"msg", "raw_reports"}, list(RawDataReport.decoder)),
//           json.required(list{"raw_reports"}, list(RawDataReport.decoder)),
//         ]),
//         validator: oneOf([
//           json.required(list{"msg", "validator"}, string),
//           json.required(list{"validator"}, string),
//         ])->Address.fromBech32,
//       })
//   }
// }

type t =
  | ReportMsg
  | UnknownMsg

let decoder = {
  open JsonUtils.Decode
  buildObject(json => {
    let msgType = json.required(list{"type"}, string)
    switch msgType {
    | "/oracle.v1.MsgReportData" => ReportMsg
    | _ => UnknownMsg
    }
  })
}

let getName = name =>
  switch name {
  | ReportMsg => "Report"
  | UnknownMsg => "Unknown"
  }
