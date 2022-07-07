transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/zabra/Workspace/ELEC5566M-Mini-Project-kamzaaa {C:/Users/zabra/Workspace/ELEC5566M-Mini-Project-kamzaaa/SevenSegment.v}
vlog -vlog01compat -work work +incdir+C:/Users/zabra/Workspace/ELEC5566M-Mini-Project-kamzaaa {C:/Users/zabra/Workspace/ELEC5566M-Mini-Project-kamzaaa/SevenSegManager.v}

vlog -vlog01compat -work work +incdir+C:/Users/zabra/Workspace/ELEC5566M-Mini-Project-kamzaaa/simulation {C:/Users/zabra/Workspace/ELEC5566M-Mini-Project-kamzaaa/simulation/SevenSegManager_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  SevenSegManager_tb

do C:/Users/zabra/Workspace/ELEC5566M-Mini-Project-kamzaaa/../ELEC5566M-Resources/simulation/load_sim.tcl
