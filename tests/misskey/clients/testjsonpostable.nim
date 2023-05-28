discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
"""

import ../../../src/misskey/clients
import std/[unittest, httpclient, uri, json]

type
  MockedHttpClient = ref object


proc postJson(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  discard


proc postMultipart(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard


check HttpClient is JsonPostable
check MockedHttpClient is JsonPostable
