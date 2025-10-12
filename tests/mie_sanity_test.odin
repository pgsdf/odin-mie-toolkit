package main
import "core:fmt"
import "../mie"
main :: proc(){ res := mie.mie_sphere(mie.Complex{re=8.5, im=-2.2}, 1.0); fmt.println(res) }
