import klayout.db as db
import klayout.lay as lay
pdk = "/mnt/pdk/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A"
tech_lef = f"{pdk}/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
cell_lef = f"{pdk}/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
def_file = "/project/physical/beta_core_pre_route.def"
out_png  = "/project/physical/stage_placement.png"
opts = db.LoadLayoutOptions()

opts.lefdef_config.lef_files = [tech_lef, cell_lef]
opts.lefdef_config.read_lef_with_def = True
view = lay.LayoutView()
view.load_layout(def_file, opts)
view.max_hier()
view.zoom_fit()
view.save_image(out_png, 1600, 1600)
print("wrote", out_png)
