import ../../confutils

type
  Lvl1Cmd = enum
    lvl1Cmd1

  TestConf = object
    opt1 {.
      separator: "Network Options:"
      defaultValue: "opt1 default"
      desc: "opt1 desc"
      name: "opt1" }: string
    opt2 {.
      defaultValue: "opt2 default"
      desc: "opt2 desc"
      name: "opt2" }: string
    opt3 {.
      separator: "\p----------------"
      defaultValue: "opt3 default"
      desc: "opt3 desc"
      name: "opt3" }: string

let c = TestConf.load(termWidth = int.high)
