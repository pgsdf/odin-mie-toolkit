package main
import "core:fmt"
import "../mie"
main :: proc() {
    m := mie.ice_m_matzler(9.65, -15.0, "xband")
    fmt.println("ice_m_matzler:", m)
}
