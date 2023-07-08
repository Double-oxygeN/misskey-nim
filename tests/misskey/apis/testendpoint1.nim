discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../src/misskey/clients
import ../../../src/misskey/apis/endpoint
import std/unittest
import clientendpoint

const testMisskeyHost = "https://misskey.example.com"

let
  client = newMisskeyClient(testMisskeyHost, new MockedHttpClient)

check client.hasEndpoint("endpoint")
