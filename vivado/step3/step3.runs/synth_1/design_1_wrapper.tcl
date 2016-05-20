# 
# Synthesis run script generated by Vivado
# 

debug::add_scope template.lib 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z020clg484-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/step3/step3.cache/wt [current_project]
set_property parent.project_path /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/step3/step3.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property ip_repo_paths {
  /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/ip_repo/AXI_to_Audio_1.0
  /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/ip_repo/Audio_to_AXI_1.0
  /home/INTRA/raogbe/workspace/soc-audio-mixer/git/zedboard_audio
  /home/INTRA/raogbe/workspace/soc-audio-mixer/git/SoC_Design/IPs/Audio_Mixer
  /home/INTRA/raogbe/workspace/soc-audio-mixer/git/ip_repo_vivado/adau1761_audio_1.0
} [current_project]
add_files /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/step3/step3.srcs/sources_1/bd/design_1/design_1.bd
set_property used_in_implementation false [get_files -all /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/step3/step3.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0/design_1_processing_system7_0_0.xdc]
set_property used_in_implementation false [get_files -all /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/step3/step3.srcs/sources_1/bd/design_1/ip/design_1_rst_processing_system7_0_100M_0/design_1_rst_processing_system7_0_100M_0_board.xdc]
set_property used_in_implementation false [get_files -all /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/step3/step3.srcs/sources_1/bd/design_1/ip/design_1_rst_processing_system7_0_100M_0/design_1_rst_processing_system7_0_100M_0.xdc]
set_property used_in_implementation false [get_files -all /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/step3/step3.srcs/sources_1/bd/design_1/ip/design_1_rst_processing_system7_0_100M_0/design_1_rst_processing_system7_0_100M_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/step3/step3.srcs/sources_1/bd/design_1/ip/design_1_xbar_0/design_1_xbar_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/step3/step3.srcs/sources_1/bd/design_1/ip/design_1_auto_pc_0/design_1_auto_pc_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/step3/step3.srcs/sources_1/bd/design_1/design_1_ooc.xdc]
set_property is_locked true [get_files /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/step3/step3.srcs/sources_1/bd/design_1/design_1.bd]

read_vhdl -library xil_defaultlib /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado/step3/step3.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.vhd
read_xdc /home/INTRA/raogbe/workspace/soc-audio-mixer/git/zedboard_audio/constraints/zed_audio.xdc
set_property used_in_implementation false [get_files /home/INTRA/raogbe/workspace/soc-audio-mixer/git/zedboard_audio/constraints/zed_audio.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
synth_design -top design_1_wrapper -part xc7z020clg484-1
write_checkpoint -noxdef design_1_wrapper.dcp
catch { report_utilization -file design_1_wrapper_utilization_synth.rpt -pb design_1_wrapper_utilization_synth.pb }
