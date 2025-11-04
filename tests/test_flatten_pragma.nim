# confutils
# Copyright (c) 2018-2025 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.

import std/os, unittest2, toml_serialization, ../confutils

const flattenFilePath = "tests" / "config_files"

template loadFile(T, file): untyped =
  proc (
    config: T, sources: ref SecondarySources
  ) {.raises: [ConfigurationError].} =
    sources.addConfigFile(Toml, InputFile(flattenFilePath / file))

type
  TopOptsConf = object
    opt1 {.
      desc: "top opt 1"
      defaultValue: "top_opt_1"
      name: "top-opt1" .}: string

    opt2 {.
      desc: "top opt 2"
      defaultValue: false
      name: "top-opt2" .}: bool

suite "test TopOptsConf":
  test "top opts":
    let conf = TopOptsConf.load(cmdLine = @[
      "--top-opt1=foobar"
    ])
    check:
      conf.opt1 == "foobar"
      conf.opt2 == false

  test "top opts file":
    let conf = TopOptsConf.load(secondarySources = loadFile(TopOptsConf, "flatten.toml"))
    check:
      conf.opt1 == "foo"
      conf.opt2 == true

type
  TestConfFlat = object
    topOpts {.flatten.}: TopOptsConf

suite "test TestConfFlat":
  test "top opts flat":
    let conf = TestConfFlat.load(cmdLine = @[
      "--top-opt1=foobar",
      "--top-opt2=true"
    ])
    check:
      conf.topOpts.opt1 == "foobar"
      conf.topOpts.opt2 == true

  test "top opts flat defaults":
    let conf = TestConfFlat.load(cmdLine = newSeq[string]())
    check:
      conf.topOpts.opt1 == "top_opt_1"
      conf.topOpts.opt2 == false

  test "top opts flat file":
    let conf = TestConfFlat.load(secondarySources = loadFile(TestConfFlat, "flatten.toml"))
    check:
      conf.topOpts.opt1 == "foo"
      conf.topOpts.opt2 == true

type
  TestConfFlatArg = object
    topOpts {.flatten.}: TopOptsConf
    outerArg1 {.
      defaultValue: "outerArg1 default"
      desc: "outerArg1 desc"
      name: "outer-arg1" }: string

suite "test TestConfFlatArg":
  test "top opts arg":
    let conf = TestConfFlatArg.load(cmdLine = @[
      "--top-opt1=foobar",
      "--top-opt2=true",
      "--outer-arg1=bazquz"
    ])
    check:
      conf.topOpts.opt1 == "foobar"
      conf.topOpts.opt2 == true
      conf.outerArg1 == "bazquz"

  test "top opts arg defaults":
    let conf = TestConfFlatArg.load(cmdLine = newSeq[string]())
    check:
      conf.topOpts.opt1 == "top_opt_1"
      conf.topOpts.opt2 == false
      conf.outerArg1 == "outerArg1 default"

  test "top opts arg file":
    let conf = TestConfFlatArg.load(secondarySources = loadFile(TestConfFlatArg, "flatten.toml"))
    check:
      conf.topOpts.opt1 == "foo"
      conf.topOpts.opt2 == true
      conf.outerArg1 == "bar"

type
  OuterCmd = enum
    noCommand
    outerCmd1

  TestConfCmd = object
    case cmd {.
      command
      defaultValue: OuterCmd.noCommand }: OuterCmd
    of OuterCmd.noCommand:
      opts {.flatten.}: TopOptsConf
      outerArg {.
        defaultValue: "outerArg default"
        desc: "outerArg desc"
        name: "outer-arg" }: string
    of OuterCmd.outerCmd1:
      opts1 {.flatten.}: TopOptsConf
      outerArg1 {.
        defaultValue: "outerArg1 default"
        desc: "outerArg1 desc"
        name: "outer-arg1" }: string

suite "test TestConfCmd":
  test "top opts cmd":
    let conf = TestConfCmd.load(cmdLine = @[
      "--top-opt1=foobar",
      "--top-opt2=true",
      "--outer-arg=bazquz"
    ])
    check:
      conf.cmd == OuterCmd.noCommand
      conf.opts.opt1 == "foobar"
      conf.opts.opt2 == true
      conf.outerArg == "bazquz"

  test "top opts cmd 1":
    let conf = TestConfCmd.load(cmdLine = @[
      "outerCmd1",
      "--top-opt1=foobar",
      "--top-opt2=true",
      "--outer-arg1=bazquz"
    ])
    check:
      conf.cmd == OuterCmd.outerCmd1
      conf.opts1.opt1 == "foobar"
      conf.opts1.opt2 == true
      conf.outerArg1 == "bazquz"

  test "top opts cmd 1 defaults":
    let conf = TestConfCmd.load(cmdLine = @[
      "outerCmd1"
    ])
    check:
      conf.cmd == OuterCmd.outerCmd1
      conf.opts1.opt1 == "top_opt_1"
      conf.opts1.opt2 == false
      conf.outerArg1 == "outerArg1 default"

  test "top opts cmd file":
    let conf = TestConfCmd.load(
      secondarySources = loadFile(TestConfCmd, "flatten_cmd.toml")
    )
    check:
      conf.cmd == OuterCmd.noCommand
      conf.opts.opt1 == "foo"
      conf.opts.opt2 == true
      conf.outerArg == "bar"

  test "top opts cmd 1 file":
    let conf = TestConfCmd.load(
      cmdLine = @["outerCmd1"],
      secondarySources = loadFile(TestConfCmd, "flatten_cmd.toml")
    )
    check:
      conf.cmd == OuterCmd.outerCmd1
      conf.opts1.opt1 == "baz"
      conf.opts1.opt2 == true
      conf.outerArg1 == "quz"

type
  TopOptsConfFlat = object
    opts {.flatten.}: TopOptsConf
    opt3 {.
      desc: "top opt 3"
      defaultValue: "top_opt_3"
      name: "top-opt3" .}: string
  TestConfFlatNested = object
    topOpts {.flatten.}: TopOptsConfFlat
    outerArg1 {.
      defaultValue: "outerArg1 default"
      desc: "outerArg1 desc"
      name: "outer-arg1" }: string

suite "test TestConfFlatNested":
  test "top opts nested":
    let conf = TestConfFlatNested.load(cmdLine = @[
      "--top-opt1=foo",
      "--top-opt2=true",
      "--top-opt3=bar",
      "--outer-arg1=baz"
    ])
    check:
      conf.topOpts.opts.opt1 == "foo"
      conf.topOpts.opts.opt2 == true
      conf.topOpts.opt3 == "bar"
      conf.outerArg1 == "baz"

  test "top opts nested defaults":
    let conf = TestConfFlatNested.load(cmdLine = newSeq[string]())
    check:
      conf.topOpts.opts.opt1 == "top_opt_1"
      conf.topOpts.opts.opt2 == false
      conf.topOpts.opt3 == "top_opt_3"
      conf.outerArg1 == "outerArg1 default"

  test "top opts nested file":
    let conf = TestConfFlatNested.load(
      secondarySources = loadFile(TestConfFlatNested, "flatten.toml")
    )
    check:
      conf.topOpts.opts.opt1 == "foo"
      conf.topOpts.opts.opt2 == true
      conf.topOpts.opt3 == "baz"
      conf.outerArg1 == "bar"
