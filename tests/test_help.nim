# confutils
# Copyright (c) 2018-2025 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.

import unittest2, ../confutils

template helpOut(hout: var string): untyped =
  proc (s: string) {.gcsafe, raises: [].} =
    hout.add s

type
  OuterCmd = enum
    noCommand
    outerCmd1

  InnerCmd = enum
    innerCmd1 = "Inner cmd 1"
    innerCmd2 = "Inner cmd 2"

  TestConf = object
    case cmd {.
      command
      defaultValue: OuterCmd.noCommand }: OuterCmd
    of OuterCmd.noCommand:
      outerArg {.
        defaultValue: "outerArg default"
        desc: "outerArg desc"
        name: "outer-arg" }: string
    of OuterCmd.outerCmd1:
      outerArg1 {.
        defaultValue: "outerArg1 default"
        desc: "outerArg1 desc"
        name: "outer-arg1" }: string
      case innerCmd {.command.}: InnerCmd
      of InnerCmd.innerCmd1:
        innerArg1 {.
          defaultValue: "innerArg1 default"
          desc: "innerArg1 desc"
          name: "inner-arg1" }: string
      of InnerCmd.innerCmd2:
        innerArg2 {.
          defaultValue: "innerArg2 default"
          desc: "innerArg2 desc"
          name: "inner-arg2" }: string

suite "test nested cmd":
  test "no command":
    var hout = ""
    let cmdLine = @[
      "--help"
    ]
    let conf = TestConf.load(cmdLine = cmdLine, ignoreUnknown = true, sout = helpOut(hout))
    echo hout.len > 0
    echo "ok?"
