let parse = (chainID, channel) =>
  switch (chainID, channel) {
  | ("consumer", "channel-25") => (Images.cosmosIBCIcon, "Consumer")
  | ("band", _) => (Images.bandLogo, "Band")
  | _ => (Images.unknownChain, "Unknown")
  }
