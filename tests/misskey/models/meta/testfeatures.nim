discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../../src/misskey/models/meta/features
import std/[unittest, json]

let testJson = parseJson"""{"registration": false,"emailRequiredForSignup": true,"hcaptcha": false,"recaptcha": false,"turnstile": false,"objectStorage": false,"serviceWorker": false,"miauth": true}"""

let ftrs = testJson.toFeatures()

check ftrs == { Feature.emailRequiredForSignup, Feature.miauth }
