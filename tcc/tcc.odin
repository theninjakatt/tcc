package tcc

import "core:os"
import "core:flags"

// flags
Options :: struct {
    rate: f64 `args:"name=r,required" usage:"Hourly wage"`,
    mult: f64 `args:"name=m" usage:"Overtime wage multiplier (Default = 1.5)"`,
    disable_ot: bool `args:"name=not" usage:"Toggle overtime (Default = ON)"`,
    overflow: [dynamic]string `usage:"String path to file(s)"`,
}

main :: proc() {
    opt: Options
    style: flags.Parsing_Style = .Unix
    flags.parse_or_exit(&opt, os.args, style)

    scan_files(&opt)
}
