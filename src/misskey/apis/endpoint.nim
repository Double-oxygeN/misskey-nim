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

import std/[json, httpcore]
import ../clients
import errors

type
  RequestParam* = tuple
    name, `type`: string


proc hasEndpoint*[T](client: MisskeyClient[T]; path: string): bool =
  ## Checks if the client has the endpoint.
  let response = client.request("endpoint", %* { "endpoint": path })

  case response.code
  of Http200:
    return true

  of Http204:
    return false

  else:
    raise newMisskeyResponseError(response.code, response.body)


proc availableParams*[T](client: MisskeyClient[T]; path: string): seq[RequestParam] =
  ## Returns the available parameters of the endpoint.
  ## If the endpoint does not exist, an empty sequence is returned.
  let response = client.request("endpoint", %* { "endpoint": path })

  case response.code
  of Http200:
    for paramNode in response.body["params"].getElems:
      result.add (paramNode["name"].getStr(), paramNode["type"].getStr())

  of Http204:
    return @[]

  else:
    raise newMisskeyResponseError(response.code, response.body)
