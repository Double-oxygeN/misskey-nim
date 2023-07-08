discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../src/misskey/clients
import ../../../src/misskey/apis/endpoints
import std/[unittest, json, httpclient, uri]

const
  testMisskeyHost = "https://misskey.example.com"
  testEndpoints = @[
    "admin/meta",
    "endpoint",
    "endpoints",
    "meta",
    "ping"
  ]

type MockedHttpClient = ref object

proc postJson(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  check uri.path == "/api/endpoints"
  result.code = Http200
  result.headers = @[("Content-Type", "application/json")]
  result.body = %* testEndpoints


proc postMultipart(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard


let
  client = newMisskeyClient(testMisskeyHost, new MockedHttpClient)
  eps = client.endpoints()

check eps == testEndpoints
