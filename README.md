# AMBA-ABP
The system is composed of one APB-Master which can send read/write transactions to two APB Slaves, a 64x16 ROM and a 128x8 RAM. The APB-Master coordinates the reading and writing transactions on the bus by handling the control signals of the communication interface. The APB Slaves reply to the master’s requests.


There was a misunderstanding about the spec and we implemented this by doing a read/write to address and address+1, so the testbench and description follow this spec.

Credits: Fabio Piras and Giacomo Volpi
