# confutils
# Copyright (c) 2018-2025 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.

import unittest2, ../confutils

type
  TopOptsConf = object
    opt1 {.
      desc: "top opt 1"
      defaultValue: "top_opt_1"
      name: "top-opt1" .}: string

    opt2 {.
      desc: "top opt 2"
      defaultValue: true
      name: "top-opt2" .}: bool

when false:
  suite "test TopOptsConf":
    test "top opts":
      let conf = TopOptsConf.load(cmdLine = @[
        "--top-opt1=foobar"
      ])
      check:
        conf.opt1 == "foobar"
        conf.opt2 == true

when true:
  type
    TestConfFlat = object
      topOpts {.flatten.}: TopOptsConf

  suite "test TestConfFlat":
    test "top opts":
      let conf = TestConfFlat.load(cmdLine = @[
        "--top-opt1=foobar",
        "--top-opt2=true"
      ])
      check:
        conf.topOpts.opt1 == "foobar"
        conf.topOpts.opt2 == true

