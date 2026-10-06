package tests

import "core:testing"
import "../tcc"

make_testcard :: proc() -> tcc.TCard {
    make_day :: proc(times: ..string) -> []string {
        day := make([]string, len(times))
        for t, i in times do day[i] = t
        return day
    }
    return tcc.TCard{
         {
            make_day("08:14", "15:54"),
            {},
            {},
            {},
            {},
            make_day("16:07", "21:06"),
            make_day("07:43", "14:24", "15:13", "17:10", "17:28", "21:33"),
        },
        {
            make_day("07:45", "12:57"),
            make_day("14:56", "20:50"),
            {},
            {},
            make_day("10:17", "16:09"),
            make_day("14:59", "20:44"),
            make_day("08:08", "12:56", "15:10", "21:33"),
        },
    }
}

delete_timecard :: proc(tc: tcc.TCard) {
    for week in tc {
        for day in week {
            delete(day)
        }
    }
}

@(test)
test_tcard_struct :: proc(t: ^testing.T) {
    testcard := make_testcard()
    defer delete_timecard(testcard)
    expected := [2][7][]string{{{"08:14","15:54"},{},{},{},{},{"16:07","21:06"},{"07:43","14:24","15:13","17:10","17:28","21:33"}},{{"07:45","12:57"},{"14:56","20:50"},{},{},{"10:17","16:09"},{"14:59","20:44"},{"08:08","12:56","15:10","21:33"}}}
    ok := typeid_of(type_of(testcard)) == typeid_of([2][7][]string)
    testing.expect(t, ok)
}

//make_testsheet :: proc() -> tcc.Sheet {
//    return
//}
