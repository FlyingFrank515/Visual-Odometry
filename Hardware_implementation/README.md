Top module: CHIP_all.sv
testbench: CHIP_alltb.sv

RTL simulation:

```
ncverilog CHIP_alltb.sv +incdir+/opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver/ -y /opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver +libext+.v+notimingchecks +define+RTL +access+r 
```


sram generate list

| usage                 | # of sram | sram words | sram bits |
| --------------------- | --------- | ---------- | --------- |
| line buffer for FAST  | 6         | 640        | 8         |
| line buffer for BRIEF | 30        | 640        | 8         |
| FIFO for NMS          | 1         | 640        | 10        |
| FIFO for sin, cos     | 2         | 640        | 12        |