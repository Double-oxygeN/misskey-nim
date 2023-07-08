discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../src/misskey/clients
import ../../../src/misskey/apis/ping
import std/[unittest, json, httpclient, uri, times]

const
  testMisskeyHost = "https://misskey.example.com"
  testTimeMillis = 2_147_483_648_012

let testTime = "20380119T031408.012Z".parseTime("yyyyMMdd'T'HHmmss'.'fff'Z'", utc())

type MockedHttpClient = ref object

proc postJson(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  check uri.path == "/api/ping"
  result.code = Http200
  result.headers = @[("Content-Type", "application/json")]
  result.body = %* { "pong": testTimeMillis }


proc postMultipart(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard


let
  client = newMisskeyClient(testMisskeyHost, new MockedHttpClient)
  pong = client.ping()

check pong == testTime
