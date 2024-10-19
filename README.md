# Project Overview
This project is a SerDes (serializer/deserializer) designed using 8b/10b encoding and verified with a full UVM test bench
### Design
* The SerDes blocks operate at 20 MHz and transmit over a “channel” at a speed of 1 GHz. The design does not actually send data over a high-speed channel and thus speed is kept low for the sake of simulation
* An asynchronous FIFO is used at the input of the deserializer to manage crossing clock domains
* The serializer simply uses a 2 flip-flop synchronizer when sending serialized across clock domain

### Verification
A UVM testbench verifies the design by making use of constrained random stimulus generation, assertions, and functional/code coverage
* Random packets of parallel data are sent to the serializer and a reference model. The output of the serializer is compared to the reference model for errors with assertions in the scoreboard
* The serialized output is captured by a reactive slave agent, which creates a new transaction for the deserializer. A passive agent then collects the deserializer's output and compares it in the scoreboard with the original random packet, confirming data integrity

## UVM Block Diagram
![SerDes block diagram](https://github.com/user-attachments/assets/ee67f8d7-58f2-4142-95eb-ad2b3a389ddd)


## Getting Started
### Dependencies
* Xilinx Vivado™ 2024.1

### Installation
1. Download and extract serdes.zip file
2. Create a new Vivado RTL project (do not select `Do not specify sources at this time`) <br/>
![create project 1](https://github.com/user-attachments/assets/62ecf1ea-5ff8-40cf-93ce-bc35d9917e02)
3. Add the directories "Design" and "Verif" to the project by clicking on `Add Directories`. Specify that Verif should be simulation only <br/>
![create project 3](https://github.com/user-attachments/assets/51971b21-faf8-40b6-a6f9-26ae964d1217)
4. Select the desired part/board and finish <br/>
5. Open simulation settings and add `-testplusarg UVM_TESTNAME=serdes_base_test -testplusarg UVM_VERBOSITY=UVM_LOW` to xsim.more_options in the simulate tab <br/>
![create project x](https://github.com/user-attachments/assets/657bdca9-b6be-42be-a14e-e0e31eb99c02)
6. Ensure that `serdes_tb_top` is set as the top module <br/>
![create project 5](https://github.com/user-attachments/assets/83fb3955-09a8-4d59-b5b0-47efa5ca2adb)
7. Hit run simulation

