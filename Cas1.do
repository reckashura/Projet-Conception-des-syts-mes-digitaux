vsim -voptargs="+acc" work.logique_cfg
view wave
view signals
add wave *

force s_clk 0 0, 1 {10 ns} -r 20 ns
force s_interrupteurs(3) 0 0
force s_interrupteurs(2) 1 0
force s_interrupteurs(1) 0 0
force s_interrupteurs(0) 0 0
force s_echo1 0 0, 1 1us, 0 1ms -r 20ms
force s_boutoninitial 0 0
force s_boutonfinal 0 0
force s_presenceIR 0 0
force s_contact_barriere 0 0


run 250ms

noforce s_echo1
force s_echo1 1 0, 0 470us -r 20ms

run 350ms

wave zoom full