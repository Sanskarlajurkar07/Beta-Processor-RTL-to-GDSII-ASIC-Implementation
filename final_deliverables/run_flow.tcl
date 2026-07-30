read_lef /mnt/pdk/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
read_lef /mnt/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef
read_liberty /mnt/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog /project/physical/beta_core_synth.v
link_design beta_core
initialize_floorplan -site unithd -utilization 50 -aspect_ratio 1.0 -core_space 10
make_tracks
place_pins -hor_layers met3 -ver_layers met2
global_placement -density 0.55
detailed_placement
insert_tiecells sky130_fd_sc_hd__conb_1/LO -prefix "TIE_ZERO_"
insert_tiecells sky130_fd_sc_hd__conb_1/HI -prefix "TIE_ONE_"
global_placement -density 0.55 -incremental
detailed_placement
check_placement

set_layer_rc -layer li1  -capacitance 1.499e-04  -resistance 6.81778E-02
set_layer_rc -layer met1 -capacitance 1.72375E-04 -resistance 1.20566E-03
set_layer_rc -layer met2 -capacitance 1.36233E-04 -resistance 1.22133E-03
set_layer_rc -layer met3 -capacitance 2.14962E-04 -resistance 1.66286E-04
set_layer_rc -layer met4 -capacitance 1.48128E-04 -resistance 1.68095E-04
set_layer_rc -layer met5 -capacitance 1.54087E-04 -resistance 1.83574E-05
set_layer_rc -via mcon -resistance 9.249146E-3
set_layer_rc -via via  -resistance 4.5E-3
set_layer_rc -via via2 -resistance 3.368786E-3
set_layer_rc -via via3 -resistance 0.376635E-3
set_layer_rc -via via4 -resistance 0.00580E-3
set_wire_rc -signal -layer met2
set_wire_rc -clock  -layer met5
create_clock -period 30 [get_ports clk]
set_propagated_clock [all_clocks]
configure_cts_characterization -slew_steps 4 -cap_steps 4
clock_tree_synthesis -root_buf sky130_fd_sc_hd__clkbuf_1 -buf_list sky130_fd_sc_hd__clkbuf_1
detailed_placement
check_placement
set_routing_layers -signal met1-met5 -clock met1-met5
global_route
write_db /project/physical/beta_core_pre_route.odb
write_def /project/physical/beta_core_pre_route.def
detailed_route \
 -output_drc /project/physical/reports/drc.rpt \
 -output_maze /project/physical/reports/maze.log
write_def /project/physical/beta_core_routed.def
write_db /project/physical/beta_core_routed.odb
puts "ROUTING DONE"
