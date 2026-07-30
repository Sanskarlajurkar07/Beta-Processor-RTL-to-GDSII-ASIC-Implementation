import klayout.db as db
pdk_base = "/mnt/pdk/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A"
tech_lef = f"{pdk_base}/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
cell_lef = f"{pdk_base}/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
cell_gds = f"{pdk_base}/libs.ref/sky130_fd_sc_hd/gds/sky130_fd_sc_hd.gds"
layer_map = f"{pdk_base}/libs.tech/klayout/tech/sky130A.map"
def_file = "/project/physical/beta_core_routed.def"
out_gds  = "/project/physical/beta_core.gds"

layout = db.Layout()
opts = db.LoadLayoutOptions()
opts.lefdef_config.lef_files = [tech_lef, cell_lef]
opts.lefdef_config.macro_resolution_mode = 2
opts.lefdef_config.read_lef_with_def = True
print("Reading DEF + LEF...")
layout.read(def_file, opts)
print("Reading standard cell GDS for merging...")
cell_layout = db.Layout()
cell_layout.read(cell_gds)
# Merge cell shapes into main layout as needed
# (KLayout's DEF reader typically creates placeholder cells
#  we merge the actual GDS cell library so shapes resolve)
layout.read(cell_gds)
print(f"Writing GDS to {out_gds} ...")
layout.write(out_gds)
print("Done.")
