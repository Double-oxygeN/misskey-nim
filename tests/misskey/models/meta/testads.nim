discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../../src/misskey/models/meta/ads
import std/[unittest, json, uri]

let testJson = parseJson"""{"id":"1234abcd","place":"square","url":"https://example.com/","imageUrl":"https://example.com/image.png","ratio":1.0}"""

let advertisement = testJson.toAdvertisement()

check advertisement.id == "1234abcd"
check advertisement.place == "square"
check advertisement.url == "https://example.com/".parseUri()
check advertisement.imageUrl == "https://example.com/image.png".parseUri()
check advertisement.ratio == 1.0
