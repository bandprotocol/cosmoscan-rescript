open Jest
open ExecutableParser

open Expect

describe("Expect Parser to work correctly", () => {
  test("test pythonMatch function", () =>
    expect(
      `#!/usr/bin/env python3

import json
import urllib.request
import sys

COINS_URL = "https://api.coingecko.com/api/v3/coins/list"
PRICE_URL = "https://api.coingecko.com/api/v3/simple/price?ids={}&vs_currencies=usd"

def make_json_request(url):
    return json.loads(urllib.request.urlopen(url).read())

def main(symbol):
    coins = make_json_request(COINS_URL)
    for coin in coins:
        if coin["symbol"] == symbol.lower():
            slug = coin["id"]
            return make_json_request(PRICE_URL.format(slug))[slug]["usd"]
    raise ValueError("unknown CoinGecko symbol: {}".format(symbol))


if __name__ == "__main__":
    try:
        print(main(*sys.argv[1:]))
    except Exception as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)
`
      ->pythonMatch
      ->Belt.Option.getExn,
    )->toEqual(["symbol"])
  )

  test("test get 1 variable in python script", () =>
    expect(
      `#!/usr/bin/env python3

import json
import urllib.request
import sys

COINS_URL = "https://api.coingecko.com/api/v3/coins/list"
PRICE_URL = "https://api.coingecko.com/api/v3/simple/price?ids={}&vs_currencies=usd"

def make_json_request(url):
    return json.loads(urllib.request.urlopen(url).read())

def main(symbol):
    coins = make_json_request(COINS_URL)
    for coin in coins:
        if coin["symbol"] == symbol.lower():
            slug = coin["id"]
            return make_json_request(PRICE_URL.format(slug))[slug]["usd"]
    raise ValueError("unknown CoinGecko symbol: {}".format(symbol))


if __name__ == "__main__":
    try:
        print(main(*sys.argv[1:]))
    except Exception as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)
`
      ->getVariables
      ->Belt.Option.getExn,
    )->toEqual(["symbol"])
  )
  test("test get multiple variable in python script", () =>
    expect(
      `#!/usr/bin/env python3

import json

def main(symbol, main, temp):
    return "111"

if __name__ == "__main__":
    try:
        print(main(*sys.argv[1:]))
    except Exception as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)
`
      ->getVariables
      ->Belt.Option.getExn,
    )->toEqual(["symbol", "main", "temp"])
  )

  test("test main function's name closely in python script", () =>
    expect(
      `#!/usr/bin/env python3

import json

def mains(aaa, bbb, ccc):
    return "2222"

def main(symbol):
    coins = make_json_request(COINS_URL)
    for coin in coins:
        if coin["symbol"] == symbol.lower():
            slug = coin["id"]
            return make_json_request(PRICE_URL.format(slug))[slug]["usd"]
    raise ValueError("unknown CoinGecko symbol: {}".format(symbol))

if __name__ == "__main__":
    try:
        print(main(*sys.argv[1:]))
    except Exception as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)
`
      ->getVariables
      ->Belt.Option.getExn,
    )->toEqual(["symbol"])
  )

  test("test get no variable in python script", () =>
    expect(
      `#!/usr/bin/env python3

  import json

  def main():
      return "111"

  if __name__ == "__main__":
      try:
          print(main(*sys.argv[1:]))
      except Exception as e:
          print(str(e), file=sys.stderr)
          sys.exit(1)
  `->getVariables,
    )->toEqual(Some([]))
  )

  test("test no main function in python script", () =>
    expect(
      `#!/usr/bin/env python3

import json
import urllib.request
import sys

if __name__ == "__main__":
    try:
        print(main(*sys.argv[1:]))
    except Exception as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)
`->getVariables,
    )->toEqual(None)
  )

  test("test parseExecutableScript(python script)", () =>
    expect(
      "IyEvdXNyL2Jpbi9lbnYgcHl0aG9uMwoKaW1wb3J0IGpzb24KaW1wb3J0IHVybGxpYi5yZXF1ZXN0CmltcG9ydCBzeXMKCkNPSU5TX1VSTCA9ICJodHRwczovL2FwaS5jb2luZ2Vja28uY29tL2FwaS92My9jb2lucy9saXN0IgpQUklDRV9VUkwgPSAiaHR0cHM6Ly9hcGkuY29pbmdlY2tvLmNvbS9hcGkvdjMvc2ltcGxlL3ByaWNlP2lkcz17fSZ2c19jdXJyZW5jaWVzPXVzZCIKCgpkZWYgbWFrZV9qc29uX3JlcXVlc3QodXJsKToKICAgIHJldHVybiBqc29uLmxvYWRzKHVybGxpYi5yZXF1ZXN0LnVybG9wZW4odXJsKS5yZWFkKCkpCgoKZGVmIG1haW4oc3ltYm9sKToKICAgIGNvaW5zID0gbWFrZV9qc29uX3JlcXVlc3QoQ09JTlNfVVJMKQogICAgZm9yIGNvaW4gaW4gY29pbnM6CiAgICAgICAgaWYgY29pblsic3ltYm9sIl0gPT0gc3ltYm9sLmxvd2VyKCk6CiAgICAgICAgICAgIHNsdWcgPSBjb2luWyJpZCJdCiAgICAgICAgICAgIHJldHVybiBtYWtlX2pzb25fcmVxdWVzdChQUklDRV9VUkwuZm9ybWF0KHNsdWcpKVtzbHVnXVsidXNkIl0KICAgIHJhaXNlIFZhbHVlRXJyb3IoInVua25vd24gQ29pbkdlY2tvIHN5bWJvbDoge30iLmZvcm1hdChzeW1ib2wpKQoKCmlmIF9fbmFtZV9fID09ICJfX21haW5fXyI6CiAgICB0cnk6CiAgICAgICAgcHJpbnQobWFpbigqc3lzLmFyZ3ZbMTpdKSkKICAgIGV4Y2VwdCBFeGNlcHRpb24gYXMgZToKICAgICAgICBwcmludChzdHIoZSksIGZpbGU9c3lzLnN0ZGVycikKICAgICAgICBzeXMuZXhpdCgxKQo="
      ->JsBuffer.fromBase64
      ->parseExecutableScript
      ->Belt.Option.getExn,
    )->toEqual(["symbol"])
  )

  test("test parseExecutableScript return None", () =>
    expect(
      "IyEvYmluL3NoCgpzeW1ib2w9JDEyCgojIENyeXB0b2N1cnJlbmN5IHByaWNlIGVuZHBvaW50OiBodHRwczovL3d3dy5jb2luZ2Vja28uY29tL2FwaS9kb2N1bWVudGF0aW9ucy92Mwp1cmw9Imh0dHBzOi8vYXBpLmNvaW5nZWNrby5jb20vYXBpL3YzL3NpbXBsZS9wcmljZT9pZHM9JHN5bWJvbCZ2c19jdXJyZW5jaWVzPXVzZCIKCiMgUGVyZm9ybXMgZGF0YSBmZXRjaGluZyBhbmQgcGFyc2VzIHRoZSByZXN1bHQKY3VybCAtcyAtWCBHRVQgJHVybCAtSCAiYWNjZXB0OiBhcHBsaWNhdGlvbi9qc29uIiB8IGpxIC1lciAiLltcIiRzeW1ib2xcIl0udXNkIgo="
      ->JsBuffer.fromBase64
      ->parseExecutableScript,
    )->toEqual(None)
  )
})
