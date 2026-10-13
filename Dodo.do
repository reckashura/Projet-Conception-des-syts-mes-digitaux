vsim -voptargs="+acc" work.logique_cfg
view wave
view signals
add wave *
force s_clk 0 0, 1 {10 ns} -r 20 ns
run 100 ms
wave zoom full