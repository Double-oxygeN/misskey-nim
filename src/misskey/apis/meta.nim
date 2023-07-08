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
import ../models/meta as modelMeta
import errors

proc meta*[T](client: MisskeyClient[T]; detail = true): Meta =
  ## Gets meta information of the instance.
  let response = client.request("meta", %* { "detail": detail })

  if response.code == Http200:
    result = response.body.toMeta()

  else:
    raise newMisskeyResponseError(response.code, response.body)
