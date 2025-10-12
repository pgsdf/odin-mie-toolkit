package main
import "core:fmt"
import "../mie"
main :: proc() {
    m_ice := mie.ice_m(9.65, -10.0)
    fmt.println("m(ice, 9.65 GHz, -10C) =", m_ice)
}
