################################################################################
#                         SDC CONSTRAINTS FILE
################################################################################
#
# Constraint Sections:
#   1. Clock Definitions
#   2. Input / Output Delays
#   3. Input Driving Cells
#   4. Output Load
#   5. Operating Conditions
#   6. Wire Load Model
#   7. Multicycle Paths
#
################################################################################


################################################################################
# 1. CLOCK DEFINITIONS
################################################################################
#
# Define the primary/master clock and its timing characteristics.
#
# CLK_PER         : Clock period
# CLK_HALF_PER    : Half of the clock period, used for a 50% duty cycle
# CLK_SETUP_SKEW  : Setup clock uncertainty
# CLK_HOLD_SKEW   : Hold clock uncertainty
# CLK_LAT         : Clock latency
# CLK_TRANS       : Maximum clock transition time
# CLK_RISE        : Clock rise transition
# CLK_FALL        : Clock fall transition
#
################################################################################

set CLK_NAME CLK
set CLK_PER 8680.56
set CLK_HALF_PER [expr $CLK_PER/2]

# Clock uncertainty
set CLK_SETUP_SKEW 0.25
set CLK_HOLD_SKEW  0.05

# Clock latency
set CLK_LAT 0

# Clock transition limits
set CLK_TRANS 0.1
set CLK_RISE  0.05
set CLK_FALL  0.05

# Create the master clock with a 50% duty cycle
create_clock \
    -period $CLK_PER \
    -name $CLK_NAME \
    -waveform "0 $CLK_HALF_PER" \
    [get_ports $CLK_NAME]

# Define setup and hold clock uncertainty
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $CLK_NAME]
set_clock_uncertainty -hold  $CLK_HOLD_SKEW  [get_clocks $CLK_NAME]

# Define the maximum clock transition
set_clock_transition $CLK_TRANS [get_clocks $CLK_NAME]

# Prevent optimization or modification of the clock port
set_dont_touch [get_ports $CLK_NAME]


################################################################################
# 2. INPUT / OUTPUT DELAYS
################################################################################
#
# Define the timing relationship between the external environment and
# the design's input/output ports.
#
# Input delay  : Time required for external logic to drive the input ports.
# Output delay : Time available for the design to drive the output ports.
#
# Both delays are defined as 30% of the clock period.
#
################################################################################

set in_delay  [expr 0.3*$CLK_PER]
set out_delay [expr 0.3*$CLK_PER]

# Input ports
set input_ports [list P_DATA DATA_VALID PAR_EN PAR_TYP]

# Apply input delay relative to the master clock
set_input_delay $in_delay \
    -clock $CLK_NAME \
    [get_ports $input_ports]

# Output ports
set output_ports [list Tx_out Busy]

# Apply output delay relative to the master clock
set_output_delay $out_delay \
    -clock $CLK_NAME \
    [get_ports $output_ports]


################################################################################
# 3. INPUT DRIVING CELLS
################################################################################
#
# Specify the external cells driving the design input ports.
#
# Different library corners are specified to model the input drivers
# under different PVT conditions.
#
################################################################################

# Fast corner
set_driving_cell \
    -lib_cell BUFX2M \
    -library scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c \
    -pin Y \
    [get_ports $input_ports]

# Slow corner
set_driving_cell \
    -lib_cell BUFX2M \
    -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c \
    -pin Y \
    [get_ports $input_ports]

# Typical corner
set_driving_cell \
    -lib_cell BUFX2M \
    -library scmetro_tsmc_cl013g_rvt_tt_1p2v_25c \
    -pin Y \
    [get_ports $input_ports]


################################################################################
# 4. OUTPUT LOAD
################################################################################
#
# Define the capacitive load seen by the design output ports.
#
# Load value = 0.5
#
################################################################################

set_load 0.5 [get_ports $output_ports]


################################################################################
# 5. OPERATING CONDITIONS
################################################################################
#
# Define the libraries used for timing analysis at different PVT corners.
#
# Min corner -> Hold analysis
#   Fast process, high voltage, low temperature
#
# Max corner -> Setup analysis
#   Slow process, low voltage, high temperature
#
################################################################################

set_operating_conditions \
    -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" \
    -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" \
    -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" \
    -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"


################################################################################
# 6. WIRE LOAD MODEL
################################################################################
#
# Specify the wire-load model used to estimate interconnect parasitics
# when physical layout information is not available.
#
################################################################################

set_wire_load_model \
    -name tsmc13_wl30 \
    -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c


################################################################################
# 7. MULTICYCLE PATHS
################################################################################
#
# Multicycle path constraints can be added here for paths that are
# intentionally allowed to take more than one clock cycle.
#
#
################################################################################
