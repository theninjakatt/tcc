package tcc

import "core:fmt"
import "core:encoding/json"
import "core:os"
import "core:strings"
import "shared:afmt"

HEADER   :: "===================TCC==================="
BOLD_SEP :: "================================================" // len = 48
LINE_SEP :: "------------------------------------------------"

// sizeof table columns
COL0 :: 48 // total width of table
COL1 :: 8 
COL2 :: 20
COL3 :: 20

is_valid_tcard :: proc(data: ^Raw_Tcard) -> (ok: bool) {
    for week in data {
        for day in week {
            ok = validate_num_shifts(day); ok or_return
        }
        return ok
    }
    return ok
}

validate_num_shifts :: proc(data: []string) -> (bool) {
    return len(data)%2 == 0
}

scan_files :: proc(opt: ^Options) {
    fmt.println(BOLD_SEP)
    defer fmt.println(BOLD_SEP)
    // init OT multiplier
    if opt.mult < 1 do opt.mult = DEFAULT_OT_MULTIPLIER

    for path in opt.overflow {
        // print header and footer
        fmt.println(BOLD_SEP)
        defer fmt.println(BOLD_SEP)
        // load the file
        file, read_err := os.read_entire_file(path, context.allocator)
        defer delete(file)
        if read_err != nil {
            fmt.eprintfln("error reading %s: %s", path, read_err)
            continue
        }

        // init json_data
        json_data := new(Raw_Tcard)
        defer free(json_data)
        if unmarshal_err := json.unmarshal(file, json_data); unmarshal_err != nil {
            fmt.eprintfln("failed to unmarshal file %s: %s", path, unmarshal_err)
            continue
        }
        if !is_valid_tcard(json_data) {
            fmt.eprintfln("invalid data: %s", path)
            continue
        }


        // init timecard
        timecard := new(Tcard)
        defer free(timecard)
        timecard.Rate = opt.rate
        timecard.Mult = opt.mult
        _, long_fname := os.split_path(path)
        filename, _ := os.split_filename(long_fname)
        timecard.Filename = filename
        extract_times(json_data^, timecard)
        if !opt.disable_ot do check_overtime(timecard)

        print_json_data(json_data)
        fmt.println(build_sep('-', COL0))
        print_tc_table(timecard)
    }
}

build_sep :: proc(c: byte, n: int) -> (string) {
    sb := strings.builder_make()
    for i := 0; i < n; i += 1 do strings.write_byte(&sb, c)
    return strings.to_string(sb)
}

print_json_data :: proc(data: ^Raw_Tcard) {
  for week, w in data {
    fmt.printfln("Week %d:", w + 1)
    for day, d in week {
      fmt.printfln("\tDay %d:", d + 1)
      for time, t in day {
        switch {
        case t == 0 || t % 2 == 0:
          fmt.print("\t\t IN: ")
        case:
          fmt.print("\t\tOUT: ")
        }
        fmt.printfln("%s", time)
      }
    }
  }
}

print_tc_table :: proc(tc: ^Tcard) {
    tbl :: struct {
        header:    [1]afmt.Column(afmt.A24),
        ln_sep:    [1]afmt.Column(afmt.A24),
        col_label: [3]afmt.Column(afmt.A24),
        col_data:  [3]afmt.Column(afmt.A24),
    } {
        header = {{COL0, .CENTER, {at = {.bold}}}},
        ln_sep = {{COL0, .CENTER, {at = {}}}},
        col_label = {
            {COL1, .LEFT, {at = {.bold, .underline}}},
            {COL2, .RIGHT, {at = {.bold, .underline}}},
            {COL3, .RIGHT, {at = {.bold, .underline}}},
        },
        col_data = {
            {COL1, .LEFT, {at = {}}},
            {COL2, .RIGHT,  {at = {}}},
            {COL3, .RIGHT,  {at = {}}},
        },
    }
    afmt.printrow(tbl.header, tc.Filename)
    afmt.printrow(tbl.ln_sep, build_sep('-', COL0))
    afmt.printrow(tbl.header, "SUMMARY")
    afmt.printrow(tbl.ln_sep, build_sep('-', COL0))
    afmt.printrow(tbl.col_label, "", "TIME", "PAY $")
    for week, w in tc.Weeks {
        current := tc.Weeks[w]
        afmt.printrow(
            tbl.col_data, 
            fmt.tprintf("Week %d", w + 1),
            afmt.tprintf("%.3f", current.Hours), 
            afmt.tprintf("%.3f", current.Hours * tc.Rate), 
        )
        if current.Overtime > 0 do afmt.printrow(
            tbl.col_data, 
            "  OT",
            afmt.tprintf("%.3f", current.Overtime), 
            afmt.tprintf("%.3f", current.Overtime * tc.Rate * tc.Mult), 
        )
    }
    total_pay: f64
    switch {
    case tc.Overtime > 0:
        total_pay = (tc.Hours * tc.Rate) + (tc.Overtime * tc.Rate * tc.Mult)
    case tc.Overtime <= 0:
        total_pay = (tc.Total_Hours * tc.Rate)
    }
    afmt.printrow(
        tbl.col_data,
        "TOTAL", 
        fmt.tprintf("%.3f", tc.Total_Hours),
        fmt.tprintf("%.3f", total_pay),
    )
}
