package mie
type Pol :: enum { H, V }
gamma_MarshallPalmer_pol :: proc(freq_GHz, T_C, R:f64, pol:Pol, use_double:bool=true)->f64{ _=pol; return gamma_from_Mie_MarshallPalmer(freq_GHz, T_C, R, use_double); }
