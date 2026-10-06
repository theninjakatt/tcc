package tests

import "core:testing"
import "../tcc"

@(test)
test_valid_time :: proc(t: ^testing.T) {
    actual: f64
    err:    tcc.Error
    exprr:= tcc.Error.None //expected error
    actual, err = tcc.strtime_to_f64("10:30")
    testing.expect_value(t, actual, 10.5)
    testing.expect_value(t, err, exprr)
    actual, err = tcc.strtime_to_f64("22:00")
    testing.expect_value(t, actual, 22)
    testing.expect_value(t, err, exprr)
}

@(test)
test_invalid_hour :: proc(t: ^testing.T) {
    actual: f64
    err:    tcc.Error
    exprr:= tcc.Error.OutOfBoundsHour //expected error
    actual, err = tcc.strtime_to_f64("-10:00")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
    actual, err = tcc.strtime_to_f64("222:00")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
}

@(test)
test_invalid_minute :: proc(t: ^testing.T) {
    actual: f64
    err:    tcc.Error
    exprr:= tcc.Error.OutOfBoundsMinute //expected error
    actual, err = tcc.strtime_to_f64("10:-20")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
    actual, err = tcc.strtime_to_f64("22:80")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
}

@(test)
test_missing_sep :: proc(t: ^testing.T) {
    actual: f64
    err:    tcc.Error
    exprr:= tcc.Error.MissingSeparator //expected error
    actual, err = tcc.strtime_to_f64("1020")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
}

@(test)
test_too_many_seps :: proc(t: ^testing.T) {
    actual: f64
    err:    tcc.Error
    exprr:= tcc.Error.TooManySeparators //expected error
    actual, err = tcc.strtime_to_f64("1:02:0")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
    actual, err = tcc.strtime_to_f64("10::20")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
}

@(test)
test_hour_not_int :: proc(t: ^testing.T) {
    actual: f64
    err:    tcc.Error
    exprr:= tcc.Error.InvalidHourType //expected error
    actual, err = tcc.strtime_to_f64("w:50")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
    actual, err = tcc.strtime_to_f64("!23:24")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
    actual, err = tcc.strtime_to_f64("1.2:24")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
}

@(test)
test_minute_not_int :: proc(t: ^testing.T) {
    actual: f64
    err:    tcc.Error
    exprr:= tcc.Error.InvalidMinuteType //expected error
    actual, err = tcc.strtime_to_f64("10:w")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
    actual, err = tcc.strtime_to_f64("23:!24")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
    actual, err = tcc.strtime_to_f64("12:24.")
    testing.expect_value(t, actual, 0)
    testing.expect_value(t, err, exprr)
}
