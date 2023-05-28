discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../src/misskey/clients
import std/[unittest, json, uri, httpclient]

const
  testMisskeyHost = "https://misskey.example.com"
  testEndpoint = "admin/meta"

let
  testBody = %* { "foo": "bar" }
  testHeaders = @[(key: "Accept", val: "application/json")]

# `request` should request Misskey API in a correct manner.

type
  MockedHttpClient = ref object

proc postJson(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  check $uri == testMisskeyHost & "/api/" & testEndpoint
  check body == testBody
  check headers.contains(("Accept", "application/json"))


proc postMultipart(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard


let client = newMisskeyClient(testMisskeyHost, new MockedHttpClient)

discard client.request(testEndpoint, testBody, testHeaders)
