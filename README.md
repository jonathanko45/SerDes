# SerDes
8b/10b SerDes system designed to simulate at 1000MHz, but can go higher (fabric at 20 MHz). Asynchronous FIFO and gray codes are used to ensure transceivers properly receive serial data. Testbench currently sends 32 bits of parallel data to be serialized according to 8b/10b to then be sent over a ‘channel’ to then be deserialized back into the parallel 32 bits of input data.
## Output
Example transmission of first 8b:
<br /> <br />
![Sending](https://github.com/user-attachments/assets/16419839-b774-4489-9aeb-c03c2390790d)

Comparing expected data and received data at FIFO:
<br /> <br />
![receiving data](https://github.com/user-attachments/assets/1da479d0-8f26-4caa-a4fb-3ecbad81b68c)
