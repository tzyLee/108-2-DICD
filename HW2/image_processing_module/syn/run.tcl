read_verilog ../imgproc.v
source imgproc.sdc
compile

write_sdf -version 2.1 ./imgproc_syn.sdf
write -hierarchy -format verilog -output ../imgproc_syn.v
write -hierarchy -format ddc -output ./imgproc_syn.ddc                       
report_area -nosplit -hierarchy > ./imgproc_syn.area.rpt
report_timing > ./imgproc_syn.timing.rpt
