# -------------------------------------------------
# Technology
# -------------------------------------------------
read_lef /mnt/pdk/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
read_lef /mnt/pdk/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef
read_liberty /mnt/pdk/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# -------------------------------------------------
# Design
# -------------------------------------------------
read_verilog /project/physical/beta_core_synth.v
link_design beta_core

puts "Design loaded successfully."
report_design_area

# -------------------------------------------------
# Floorplan
# -------------------------------------------------

initialize_floorplan \
    -site unithd \
    -utilization 50 \
    -aspect_ratio 1.0 \
    -core_space 10

make_tracks

write_def /project/physical/openroad/floorplan.def

puts "Floorplan completed."