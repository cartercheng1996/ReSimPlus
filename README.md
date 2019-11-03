# ReSimPlus
UNSW 4th Year Thesis project

   A field-programmable gate array (FPGA) is a type of integrated circuit which permits various user-defined reconfiguration after 
manufacturing.[1] Dynamically Reconfigurable Systems (DRS) is a special type of implementation using FPGA. It allows a certain part 
of hardware logic to be reconfigured partially while the rest of the hardware design is continually operating. As a result, multiple 
reconfigurable hardware modules that built different functional circuits can be mapped to the same region of FPGA. In other words, 
without increasing the usage of FPGA fabric area, such a DRS system allows time-multiplex these modules during run time in order to a
dapt to changing execution requirements. This further extends the flexibility and reusability of the FPGA design, but at the same time 
also introduce some significant challenges to functionally verify and debug the time-varying behaviour of the DRS system.
Besides using normal simulation tool like ModelSim to test the functionality of each reconfigurable modules statically and separately,
a new simulation approach is required to model and simulate when part of the DRS hardware design is reconfiguring [2]. 
Currently, Xilinx and Intel together occupy more than 87% of FPGA product market shares [3], but neither Vivado Simulator nor ModelSim, 
the two FPGA simulation tools using by Xilinx and Intel, support such kind of DRS simulation sufficiently. ReSim, an open-source library 
to support RTL simulation and functional verification of DRS designs [4], is one recent tool to solve this kind of DRS simulation 
problem. It was first built in 2013 but only support ModelSim and QuestaSim 6.5g/10.1b or above so far. In this thesis, ReSim library 
will be integrated into the latest Vivado design suite and support Virtex 7 FPGA to provide an easy user interface to simulate and 
implement a DRS design. Particularly, both ReSim and Vivado use open Tcl APIs and this thesis aims to integrate these two set of Tcl 
utilities together [5]. We also aim to simplify the ReSim’s workflow by removing the extra step of writing a Tcl script. Finally, some 
showcases would be provided to demonstrate the capability and usability of simulating the DRS design by ReSim integrated into Vivado. 
This document aims to report and reflect on current progress we made in Thesis A and B and revise the Thesis C planning.


#****************************************************************************************************
#Author    : Zihao Cheng z5108506
#Degree 	  : Bachelor of computer engineering
#Supovisor : LinKan (George) Gong
#Company	  : UNSW Sydney Australia
#****************************************************************************************************

# -------------------Important Notice-----------------------
#   1. We assume here each RM in a RR has same port interface
#   2. We assume here each RM's bitstream length in each RR
#      is same, since the area of each RR is fixed value when
#      doing the on-board RR planing.
#   3. We assume here each RR has "UNIQUE" black-box instance name.
#   4. The ReSimPlus Auto-Generated file will be output to the
#   same directory where you put the Tcl_Script folder
# ----------------------------------------------------------

