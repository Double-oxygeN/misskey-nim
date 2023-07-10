discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../src/misskey/clients
import ../../../src/misskey/apis/invite
import ../../../src/misskey/models/utils/invitationcodes
import std/[unittest, json, httpclient, uri]

const
  testMisskeyHost = "https://misskey.example.com"
  testInvitationCode = "ABCD1234"

type MockedHttpClient = ref object

proc postJson(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  check uri.path == "/api/invite"
  result.code = Http200
  result.headers = @[("Content-Type", "application/json")]
  result.body = %* { "code": testInvitationCode }


proc postMultipart(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard


let
  client = newMisskeyClient(testMisskeyHost, new MockedHttpClient)
  invitationCode = client.invite()

check $invitationCode == testInvitationCode
