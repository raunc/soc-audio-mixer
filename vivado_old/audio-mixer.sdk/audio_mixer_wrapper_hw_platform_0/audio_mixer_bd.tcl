
################################################################
# This is a generated script based on design: audio_mixer
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source audio_mixer_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg484-1
#    set_property BOARD_PART em.avnet.com:zed:part0:1.3 [current_project]

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name audio_mixer

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]

  # Create ports
  set AC_ADR0 [ create_bd_port -dir O AC_ADR0 ]
  set AC_ADR1 [ create_bd_port -dir O AC_ADR1 ]
  set AC_GPIO0 [ create_bd_port -dir O AC_GPIO0 ]
  set AC_GPIO1 [ create_bd_port -dir I AC_GPIO1 ]
  set AC_GPIO2 [ create_bd_port -dir I AC_GPIO2 ]
  set AC_GPIO3 [ create_bd_port -dir I AC_GPIO3 ]
  set AC_MCLK [ create_bd_port -dir O AC_MCLK ]
  set AC_SCK [ create_bd_port -dir O AC_SCK ]
  set AC_SDA [ create_bd_port -dir IO AC_SDA ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list CONFIG.preset {ZedBoard}  ] $processing_system7_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

  # Create instance: zed_audio_0, and set properties
  set zed_audio_0 [ create_bd_cell -type ip -vlnv user.org:user:zed_audio:1.0 zed_audio_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]

  # Create port connections
  connect_bd_net -net AC_GPIO1_1 [get_bd_ports AC_GPIO1] [get_bd_pins zed_audio_0/AC_GPIO1]
  connect_bd_net -net AC_GPIO2_1 [get_bd_ports AC_GPIO2] [get_bd_pins zed_audio_0/AC_GPIO2]
  connect_bd_net -net AC_GPIO3_1 [get_bd_ports AC_GPIO3] [get_bd_pins zed_audio_0/AC_GPIO3]
  connect_bd_net -net Net [get_bd_ports AC_SDA] [get_bd_pins zed_audio_0/AC_SDA]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins zed_audio_0/clk_100]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins xlconstant_0/dout] [get_bd_pins zed_audio_0/hphone_l_valid] [get_bd_pins zed_audio_0/hphone_r_valid_dummy]
  connect_bd_net -net zed_audio_0_AC_ADR0 [get_bd_ports AC_ADR0] [get_bd_pins zed_audio_0/AC_ADR0]
  connect_bd_net -net zed_audio_0_AC_ADR1 [get_bd_ports AC_ADR1] [get_bd_pins zed_audio_0/AC_ADR1]
  connect_bd_net -net zed_audio_0_AC_GPIO0 [get_bd_ports AC_GPIO0] [get_bd_pins zed_audio_0/AC_GPIO0]
  connect_bd_net -net zed_audio_0_AC_MCLK [get_bd_ports AC_MCLK] [get_bd_pins zed_audio_0/AC_MCLK]
  connect_bd_net -net zed_audio_0_AC_SCK [get_bd_ports AC_SCK] [get_bd_pins zed_audio_0/AC_SCK]
  connect_bd_net -net zed_audio_0_line_in_l [get_bd_pins zed_audio_0/hphone_l] [get_bd_pins zed_audio_0/line_in_l]
  connect_bd_net -net zed_audio_0_line_in_r [get_bd_pins zed_audio_0/hphone_r] [get_bd_pins zed_audio_0/line_in_r]

  # Create address segments
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


