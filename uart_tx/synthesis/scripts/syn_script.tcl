
################################################################################
#                         DESIGN COMPILER SCRIPT
################################################################################
#
# Design Flow:
#   1. Define Top Module
#   2. Define Working Library
#   3. Setup Search Paths and Technology Libraries
#   4. Read RTL Files
#   5. Set and Link Top-Level Design
#   6. Check Design Consistency
#   7. Define Path Groups
#   8. Apply Design Constraints
#   9. Compile and Optimize Design
#  10. Write Synthesized Design Files
#  11. Generate Reports
#  12. Launch GUI (Optional)
#
################################################################################


################################################################################
# 1. TOP-LEVEL DESIGN
################################################################################
#
# Define the top-level module of the design.
#
################################################################################

set top_module UART_Tx


################################################################################
# 2. WORKING LIBRARY
################################################################################
#
# Create the Design Compiler working library where compiled design data
# will be stored.
#
################################################################################

define_design_lib work -path ./work


################################################################################
# 3. LIBRARY AND SEARCH PATH SETUP
################################################################################
#
# Add the directories containing:
#   - Standard-cell libraries
#   - RTL source files
#
################################################################################

lappend search_path /home/ICer/Labs/Ass_Syn_2.0/std_cells
lappend search_path /home/ICer/Labs/Ass_Syn_2.0/rtl


# Technology library files for different PVT corners
set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"


# Standard-cell libraries used during synthesis
set target_library [list $SSLIB $TTLIB $FFLIB]


# Libraries used for resolving references during linking
set link_library [list * $SSLIB $TTLIB $FFLIB]


################################################################################
# 4. READ RTL SOURCE FILES
################################################################################
#
# Read all Verilog/SystemVerilog source files that make up the design.
#
################################################################################

set file_format verilog

read_file -format $file_format uart_tx.v
read_file -format $file_format serializer.v
read_file -format $file_format parity_calc.v

read_file -format sverilog Tx_FSM.sv


################################################################################
# 5. SET TOP-LEVEL DESIGN
################################################################################
#
# Select the top-level module for synthesis.
#
################################################################################

current_design $top_module


################################################################################
# 6. LINK DESIGN
################################################################################
#
# Resolve all module references and connect the different RTL blocks
# into a complete design hierarchy.
#
################################################################################

puts "###############################################"
puts "######## Linking All Design Parts ############"
puts "###############################################"

link


################################################################################
# 7. CHECK DESIGN CONSISTENCY
################################################################################
#
# Check the design for common structural and connectivity issues
# before applying constraints and performing synthesis.
#
################################################################################

puts "###############################################"
puts "######## Checking Design Consistency #########"
puts "###############################################"

check_design


################################################################################
# 8. DEFINE PATH GROUPS
################################################################################
#
# Divide timing paths into logical groups to make timing analysis
# and optimization reports easier to interpret.
#
# INREG  : Input ports to registers
# REGOUT : Registers to output ports
# INOUT  : Input ports to output ports
#
################################################################################

puts "###############################################"
puts "################ Path Groups ##################"
puts "###############################################"

group_path -name INREG  -from [all_inputs]
group_path -name REGOUT -to   [all_outputs]
group_path -name INOUT  -from [all_inputs] -to [all_outputs]


################################################################################
# 9. APPLY DESIGN CONSTRAINTS
################################################################################
#
# Load the SDC constraint file containing:
#   - Clock definitions
#   - Input/output delays
#   - Clock uncertainty
#   - Driving cells
#   - Output loads
#   - Operating conditions
#   - Wire-load model
#   - Other timing constraints
#
################################################################################

puts "###############################################"
puts "############ Design Constraints ##############"
puts "###############################################"

source -echo ./cons.tcl


################################################################################
# 10. SYNTHESIS, MAPPING AND OPTIMIZATION
################################################################################
#
# Compile the RTL design and map it to the target standard-cell libraries.
#
# High mapping effort is used to improve the quality of the synthesized
# implementation.
#
################################################################################

puts "###############################################"
puts "########## Mapping & Optimization ############"
puts "###############################################"

compile -map_effort high


################################################################################
# 11. WRITE SYNTHESIZED DESIGN FILES
################################################################################
#
# Save the synthesized design in different formats for further use.
#
# Verilog : Gate-level synthesized netlist
# DDC     : Design Compiler database
# SDC     : Applied timing constraints
# SDF     : Timing annotation information
#
################################################################################

puts "###############################################"
puts "########## Writing Output Files ##############"
puts "###############################################"

write_file -format verilog -hierarchy -output UART_TX_Netlist.v
write_file -format ddc     -hierarchy -output UART_TX_Netlist.ddc

write_sdc -nosplit UART_TX.sdc
write_sdf           UART_TX.sdf


################################################################################
# 12. GENERATE REPORTS
################################################################################
#
# Generate reports for:
#   - Area
#   - Power
#   - Hold timing
#   - Setup timing
#   - Clock information
#   - Constraint violations
#
################################################################################

puts "###############################################"
puts "############### Generating Reports ###########"
puts "###############################################"

# Area report
report_area -hierarchy > Area.rpt

# Power report
report_power -hierarchy > power.rpt

# Hold timing report
report_timing \
    -max_paths 100 \
    -delay_type min > hold.rpt

# Setup timing report
report_timing \
    -max_paths 100 \
    -delay_type max > setup.rpt

# Clock report
report_clock -attributes > clocks.rpt

# Constraint violation report
report_constraint -all_violators > constraints.rpt


################################################################################
# 13. GRAPHICAL USER INTERFACE
################################################################################
#
# Uncomment the following command to launch the Design Compiler GUI
# after synthesis and reporting are complete.
#
################################################################################

# gui_start