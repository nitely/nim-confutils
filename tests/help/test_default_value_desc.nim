
import ../../confutils

const defaultEth2TcpPort = 9000

type
  TestConf = object
    opt1 {.
      defaultValue: defaultEth2TcpPort
      defaultValueDesc: $defaultEth2TcpPort
      desc: "tcp port"
      name: "opt1" }: int

let c = TestConf.load(termWidth = int.high)
