package tcc

import "core:strconv"
import "core:strings"
import "core:math"

Error :: enum {
    None,
    MissingSeparator,
    TooManySeparators,
    OutOfBoundsMinute,
    OutOfBoundsHour,
    InvalidMinuteType,
    InvalidHourType,
}

f64_to_strtime :: proc(float: f64) -> (strtime: string) {
    // sep fraction from whole
    whole, fraction : f64 = math.modf(float)
    // convert fraction to minutes
    minutes : f64 = fraction * 60
    // build string 
    sb := strings.builder_make()
    strings.write_float(&sb, whole, 'f', 0, 64)
    strings.write_byte(&sb, ':')
    strings.write_float(&sb, minutes, 'f', 0, 64)
    strtime = strings.to_string(sb)
    return strtime
}

strtime_to_f64 :: proc(data: string) -> (dtime: f64, err: Error) {
    ok: bool
    minute, hour, sep_pos, sep_count: int
    fraction: f64
    // check if separator exists
    for ch, i in data {
        if ch == ':' {
            sep_pos = i
            sep_count += 1
            //err = .None
        }
}
    // return if it doesn't
    switch {
        case sep_count == 0:
            err = .MissingSeparator
            return 
        case sep_count > 1:
            err = .TooManySeparators
            return
    }
    // convert minute to decimal repr
    minute, ok = strconv.parse_int(data[sep_pos+1:len(data)])
    if !ok {
        err = .InvalidMinuteType
        return
    }
    if (0 > minute || minute > 60) {
        err = .OutOfBoundsMinute
        return
    }
    fraction = cast(f64)minute / 60
    // convert hour to int
    hour, ok = strconv.parse_int(data[0:sep_pos])
    if !ok {
        err = .InvalidHourType
        return
    }
    if (0 > hour || hour > 23) {
        err = .OutOfBoundsHour
        return
    }
    dtime = cast(f64)hour + fraction
    return dtime, err
}
