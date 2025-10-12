package main
import "core:fmt"
import "core:math"
import "../mie"
main :: proc(){ R:=[]f64{1,2,5,10}; G:=make([]f64,len(R)); for i in 0..len(R)-1{ G[i]=mie.gamma_from_Mie_GammaDSD(9.65,20,8000,2.0,4.1, true);} fmt.println(G) }
