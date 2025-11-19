import ../../confutils

type
  Lvl1Cmd = enum
    lvl1Cmd1

  TestConf = object
    opt1 {.
      desc: "opt1 regular description"
      longDesc:
        "opt1 longdesc line one\n" &
        "longdesc line two\n" &
        "longdesc line three"
      defaultValue: "opt1 default"
      name: "opt1"
      abbr: "o" }: string

    case cmd {.command.}: Lvl1Cmd
    of Lvl1Cmd.lvl1Cmd1:
      opt2 {.
        desc: "opt2 regular description"
        longDesc:
          "opt2 longdesc line one\n" &
          "longdesc line two\n" &
          "longdesc line three"
        defaultValue: "opt2 default"
        name: "opt2" }: string
      opt3 {.
        defaultValue: "opt3 default"
        desc: "opt3 desc"
        name: "opt3" }: string

let c = TestConf.load(termWidth = int.high)