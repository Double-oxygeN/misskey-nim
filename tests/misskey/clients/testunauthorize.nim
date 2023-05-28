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

# `unauthorize` should unset "i" field in the body of every request.

type
  MockedHttpClient = ref object

proc postJson(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  check not body.hasKey("i")


proc postMultipart(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard


let client = newMisskeyClient(testMisskeyHost, new MockedHttpClient)
client.authorize(testAccessToken)

client.unauthorize()

discard client.request(testEndpoint, newJObject())
