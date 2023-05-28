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
  testAccessToken = "ABCDefgh1234"

# `authorize` should set "i" field in the body of every request.

type
  MockedHttpClient = ref object

proc postJson(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  check body["i"].getStr() == testAccessToken


proc postMultipart(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard


let client = newMisskeyClient(testMisskeyHost, new MockedHttpClient)

client.authorize(testAccessToken)

discard client.request(testEndpoint, newJObject())
