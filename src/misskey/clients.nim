# Copyright 2023 Double-oxygeN
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import std/[json, uri, httpclient]

type
  HeaderField* = tuple
    ## A header field.
    ## See `RFC 9110 section 6.3 <https://tools.ietf.org/html/rfc9110.html#section-6.3>`_ for details.
    key, val: string

  JsonResponse* = tuple
    ## A response with JSON body.
    code: HttpCode
    headers: seq[HeaderField]
    body: JsonNode

  JsonPostable* = concept x
    ## The concept of HTTP client.
    ## This abstraction is useful for various HTTP client implementations.
    ##
    ## This library also provides `HttpClient` implementation as a default.
    x.postJson(Uri, JsonNode, openArray[HeaderField]) is JsonResponse
    x.postMultipart(Uri, MultipartData, openArray[HeaderField]) is JsonResponse

  MisskeyClient*[T: JsonPostable] = ref object
    ## A client for Misskey API.
    ## This is a thin wrapper of `JsonPostable` and provides some useful methods.
    httpClient: T
    host: Uri
    accessToken: string


proc postJson*(httpClient: HttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  ## Default implementation of `postJson` for `HttpClient`.
  ## See `JsonPostable`_ for details.
  var headersAppend = headers.newHttpHeaders()
  if not headersAppend.hasKey("Content-Type"):
    headersAppend.add("Content-Type", "application/json; charset=utf-8")

  let response = httpClient.request(uri, HttpPost, $body, headersAppend)
  result.code = response.code
  result.body = if response.body.len > 0: response.body.parseJson() else: nil
  for key, val in response.headers:
    result.headers.add (key, val)


proc postMultipart*(httpClient: HttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  ## Default implementation of `postMultipart` for `HttpClient`.
  ## See `JsonPostable`_ for details.
  var headersAppend = headers.newHttpHeaders()

  let response = httpClient.request(uri, HttpPost, $multipart, headersAppend)
  result.code = response.code
  result.body = response.body.parseJson()
  for key, val in response.headers:
    result.headers.add (key, val)


proc newMisskeyClient*[T: JsonPostable](host: Uri; httpClient: T): MisskeyClient[T] =
  ## Create a new `MisskeyClient`.
  result = MisskeyClient[T](httpClient: httpClient, host: host, accessToken: "")


proc newMisskeyClient*[T: JsonPostable](host: string; httpClient: T): MisskeyClient[T] =
  ## Create a new `MisskeyClient`.
  result = newMisskeyClient(host.parseUri(), httpClient)


template newMisskeyClient*(host: Uri | string): MisskeyClient[HttpClient] =
  ## Create a new `MisskeyClient`.
  ## This uses `std/httpclient` as a default HTTP client.
  newMisskeyClient[HttpClient](host, newHttpClient())


func isAuthorized*[T](client: MisskeyClient[T]): bool =
  ## Check if the client is authorized.
  result = client.accessToken.len > 0


proc authorize*[T](client: MisskeyClient[T]; accessToken: sink string) =
  ## Authorize the client.
  ## Ensure that the access token is valid.
  ## If the access token is empty, this raises `ValueError`.
  if accessToken.len == 0:
    raise ValueError.newException("The access token is empty.")

  client.accessToken = accessToken


proc unauthorize*[T](client: MisskeyClient[T]) =
  ## Unauthorize the client.
  client.accessToken = ""


proc request*[T](client: MisskeyClient[T]; endpoint: string; body: JsonNode; headers: openArray[HeaderField] = newSeq[HeaderField]()): JsonResponse =
  ## Send a request to Misskey API.
  mixin postJson

  let bodyAux = body.copy()
  if body.hasKey("i"):
    # TODO: Use logger instead of stderr.
    stderr.writeLine "[Misskey] Use `authorize` instead of `i` in `body`."
  elif isAuthorized(client):
    bodyAux["i"] = client.accessToken.newJString()

  result = client.httpClient.postJson(client.host / "api" / endpoint, bodyAux, headers)
