package tcc

import "core:fmt"

DEFAULT_OT_MULTIPLIER :: 1.5
DEFAULT_OT_LIMIT :: 40

Day   :: struct {
    Times:  []string,
    Hours:  f64,
}
Week  :: struct {
    Days:  [7]Day,
    Hours: f64,
    Overtime: f64,
    Total_Hours: f64,
}
Tcard :: struct {
    Weeks: [2]Week,
    Hours: f64,
    Overtime: f64,
    Total_Hours: f64,
    Rate: f64,
    Mult: f64,
    Filename: string
}

Raw_Tcard :: [2][7][]string

check_overtime :: proc(timecard: ^Tcard) {
    for _, w in timecard.Weeks { 
        timecard.Weeks[w].Total_Hours = timecard.Weeks[w].Hours 
        if timecard.Weeks[w].Hours > DEFAULT_OT_LIMIT {
            timecard.Weeks[w].Overtime = timecard.Weeks[w].Hours - DEFAULT_OT_LIMIT
            timecard.Weeks[w].Hours = DEFAULT_OT_LIMIT
            timecard.Overtime += timecard.Weeks[w].Overtime
            timecard.Hours += timecard.Weeks[w].Hours
        } else do timecard.Hours += timecard.Weeks[w].Hours
    }
}

count_hours :: proc(floats: []f64) -> (hours: f64) {
    x, y: int
    y += 1
    for y <= len(floats) {
        start := floats[x]
        end := floats[y]
        if ( end < start ) do end += 24 // add 24hours to end time if smaller than beginning time (as in overnight hours)
        hours += end - start
        x += 2
        y += 2
    }
    return hours
}

extract_times :: proc(data: Raw_Tcard, timecard: ^Tcard) {
    for week, w in data {
        for day, d in week {
            flts := parse_strtimes(day)
            //fmt.assertf(len(flts)%2 == 0, "Missing time in Week %d, Day %d", w+1, d+1)
            timecard.Weeks[w].Days[d].Hours = count_hours(flts)
            timecard.Weeks[w].Days[d].Times = day
            timecard.Weeks[w].Hours += timecard.Weeks[w].Days[d].Hours
        }
        timecard.Total_Hours += timecard.Weeks[w].Hours
    }
}

parse_strtimes :: proc(data: []string) -> (times: []f64) {
    darr := make([dynamic]f64)
    defer clear(&darr)
    for d in data {
        res, err := strtime_to_f64(d)
        assert(err == .None)
        append(&darr, res)
    }
    times = darr[:]
    return 
}
