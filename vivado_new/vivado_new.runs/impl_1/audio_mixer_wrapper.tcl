proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  debug::add_scope template.lib 1
  create_project -in_memory -part xc7z020clg484-1
  set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado_new/vivado_new.cache/wt [current_project]
  set_property parent.project_path /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado_new/vivado_new.xpr [current_project]
  set_property ip_repo_paths {
  /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado_new/vivado_new.cache/ip
  /home/INTRA/raogbe/workspace/soc-audio-mixer/ip_repo/axi_to_audio/axi_to_audio_1.0
  /home/INTRA/raogbe/workspace/soc-audio-mixer/ip_repo/audio_to_axi/audio_to_axi_1.0
  /home/INTRA/raogbe/workspace/soc-audio-mixer/ip_repo/zedboard_audio
} [current_project]
  set_property ip_output_repo /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado_new/vivado_new.cache/ip [current_project]
  add_files -quiet /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado_new/vivado_new.runs/synth_1/audio_mixer_wrapper.dcp
  read_xdc -ref audio_mixer_processing_system7_0_0 -cells inst /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado_new/vivado_new.srcs/sources_1/bd/audio_mixer/ip/audio_mixer_processing_system7_0_0/audio_mixer_processing_system7_0_0.xdc
  set_property processing_order EARLY [get_files /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado_new/vivado_new.srcs/sources_1/bd/audio_mixer/ip/audio_mixer_processing_system7_0_0/audio_mixer_processing_system7_0_0.xdc]
  read_xdc -prop_thru_buffers -ref audio_mixer_rst_processing_system7_0_100M_0 /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado_new/vivado_new.srcs/sources_1/bd/audio_mixer/ip/audio_mixer_rst_processing_system7_0_100M_0/audio_mixer_rst_processing_system7_0_100M_0_board.xdc
  set_property processing_order EARLY [get_files /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado_new/vivado_new.srcs/sources_1/bd/audio_mixer/ip/audio_mixer_rst_processing_system7_0_100M_0/audio_mixer_rst_processing_system7_0_100M_0_board.xdc]
  read_xdc -ref audio_mixer_rst_processing_system7_0_100M_0 /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado_new/vivado_new.srcs/sources_1/bd/audio_mixer/ip/audio_mixer_rst_processing_system7_0_100M_0/audio_mixer_rst_processing_system7_0_100M_0.xdc
  set_property processing_order EARLY [get_files /home/INTRA/raogbe/workspace/soc-audio-mixer/vivado_new/vivado_new.srcs/sources_1/bd/audio_mixer/ip/audio_mixer_rst_processing_system7_0_100M_0/audio_mixer_rst_processing_system7_0_100M_0.xdc]
  read_xdc /home/INTRA/raogbe/workspace/soc-audio-mixer/ip_repo/zedboard_audio/constraints/zed_audio.xdc
  link_design -top audio_mixer_wrapper -part xc7z020clg484-1
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  catch {write_debug_probes -quiet -force debug_nets}
  opt_design 
  write_checkpoint -force audio_mixer_wrapper_opt.dcp
  catch {report_drc -file audio_mixer_wrapper_drc_opted.rpt}
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  catch {write_hwdef -file audio_mixer_wrapper.hwdef}
  place_design 
  write_checkpoint -force audio_mixer_wrapper_placed.dcp
  catch { report_io -file audio_mixer_wrapper_io_placed.rpt }
  catch { report_utilization -file audio_mixer_wrapper_utilization_placed.rpt -pb audio_mixer_wrapper_utilization_placed.pb }
  catch { report_control_sets -verbose -file audio_mixer_wrapper_control_sets_placed.rpt }
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force audio_mixer_wrapper_routed.dcp
  catch { report_drc -file audio_mixer_wrapper_drc_routed.rpt -pb audio_mixer_wrapper_drc_routed.pb }
  catch { report_timing_summary -warn_on_violation -max_paths 10 -file audio_mixer_wrapper_timing_summary_routed.rpt -rpx audio_mixer_wrapper_timing_summary_routed.rpx }
  catch { report_power -file audio_mixer_wrapper_power_routed.rpt -pb audio_mixer_wrapper_power_summary_routed.pb }
  catch { report_route_status -file audio_mixer_wrapper_route_status.rpt -pb audio_mixer_wrapper_route_status.pb }
  catch { report_clock_utilization -file audio_mixer_wrapper_clock_utilization_routed.rpt }
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  write_bitstream -force audio_mixer_wrapper.bit 
  catch { write_sysdef -hwdef audio_mixer_wrapper.hwdef -bitfile audio_mixer_wrapper.bit -meminfo audio_mixer_wrapper.mmi -ltxfile debug_nets.ltx -file audio_mixer_wrapper.sysdef }
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

