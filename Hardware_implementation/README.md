Top module: CHIP_all.sv
testbench: CHIP_tb_v2.sv

RTL simulation:

```
ncverilog CHIP_tb_v2.sv +incdir+/opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver/ -y /opt/CAD/synopsys/synthesis/2019.12/dw/sim_ver +libext+.v+notimingchecks +define+RTL +access+r 
```

or just...

```
./run_check
```



sram generate list

| usage                 | # of sram | sram words | sram bits |
| --------------------- | --------- | ---------- | --------- |
| line buffer for FAST  | 6         | 640        | 18        |
| line buffer for BRIEF | 30        | 640        | 8         |
| FIFO for NMS          | 1         | 640        | 20        |
| FIFO for sin, cos     | 2         | 640        | 12        |
| desc in MATCH         | 16        | 512        | 32        |
| point in MATCH        | 2         | 512        | 30        |