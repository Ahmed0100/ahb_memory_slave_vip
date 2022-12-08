import definesPkg::*;
module monitor(AHBSlaveInterface ahb_slave_interface, input reset);

`define NUM_OF_SLAVES 2
int error_check_pass,error_check_fail;
int read_only_error_check_pass,read_only_error_check_fail;
int basic_write_error_check_pass,basic_error_check_fail;
int basic_read_error_check_pass,basic_error_check_fail;
int basic_burst_write_error_check_pass,basic_burst_write_error_check_fail;
int basic_burst_read_error_check_pass, basic_burst_read_error_check_fail;

int seq_check_pass,seq_check_fail;
int HREADY_check_pass,HREADY_check_fail;
int idle_check_pass,idle_check_fail;
int wait_check_pass,wait_check_fail;
int burst_count_4_check_pass,burst_count_4_check_fail;

int burst_count_8_check_pass,burst_count_8_check_fail;
int burst_count_16_check_pass,burst_count_16_check_fail;
int burst_count_single_check_pass,burst_count_single_check_fail;

int addr_change_4_check_pass,addr_change_4_check_fail;
int addr_change_8_check_pass,addr_change_8_check_fail;
int addr_change_16_check_pass,addr_change_16_check_fail;

property error_check;
@(posedge ahb_slave_interface.HCLK) disable iff(ahb_slave_interface.HTRANS == BUSY || ahb_slave_interface.HTRANS == IDLE)
(ahb_slave_interface.HADDR > ((2**10) * `NUM_OF_SLAVES)) |-> (ahb_slave_interface.HRESP == 1);
endproperty

property read_only_check;
@(posedge ahb_slave_interface.HCLK) disable iff(ahb_slave_interface.HADDR[9:0] > 9'd3)
(ahb_slave_interface.HWRITE) |=> (ahb_slave_interface.HRESP == 1);
endproperty

property basic_write_check;
@(posedge ahb_slave_interface.HCLK) disable iff ((ahb_slave_interface.HTRANS == IDLE ||
	ahb_slave_interface.HTRANS == BUSY) && ahb_slave_interface.HBURST >0)
$rose(ahb_slave_interface.HWRITE) |=> ahb_slave_interface.HREADY==1;
endproperty

property basic_read_check;
@(posedge ahb_slave_interface.HCLK) disable iff ((ahb_slave_interface.HTRANS == IDLE ||
	ahb_slave_interface.HTRANS == BUSY) && ahb_slave_interface.HBURST >0 ||
	 ((ahb_slave_interface.HADDR) > ((2**10) * `NUM_OF_SLAVES)))
$fell(ahb_slave_interface.HWRITE) |=> ahb_slave_interface.HREADY==1;
endproperty

property basic_burst_write_check;
@(posedge ahb_slave_interface.HCLK) disable iff (ahb_slave_interface.HTRANS == BUSY)
(ahb_slave_interface.HWRITE==1)&&(ahb_slave_interface.HTRANS == NON_SEQ) |=> ahb_slave_interface.HREADY==1;
endproperty

property basic_burst_read_check;
@(posedge ahb_slave_interface.HCLK) disable iff ((ahb_slave_interface.HTRANS == BUSY) ||
	 ((ahb_slave_interface.HADDR) > ((2**10) * `NUM_OF_SLAVES)))
(ahb_slave_interface.HWRITE)&&(ahb_slave_interface.HTRANS == NON_SEQ) |=> ahb_slave_interface.HREADY==1;
endproperty

property seq_check;
@(posedge ahb_slave_interface.HCLK)
( (ahb_slave_interface.HWRITE == 1 || ahb_slave_interface.HWRITE == 0) &&
	(ahb_slave_interface.HTRANS == NON_SEQ)) |=> (ahb_slave_interface.HTRANS == SEQ);
endproperty

property HREADY_check;
@(posedge ahb_slave_interface.HCLK)
(ahb_slave_interface.HREADY == 0) |=> 
$stable(ahb_slave_interface.HADDR && ahb_slave_interface.HWRITE && ahb_slave_interface.HWDATA);
endproperty

property idle_check;
@(posedge ahb_slave_interface.HCLK)
(ahb_slave_interface.HTRANS == IDLE) |=> (ahb_slave_interface.HREADY == 1 && 
	ahb_slave_interface.HRESP == 0);
endproperty

property bursts_count_4_check;
@(posedge ahb_slave_interface.HCLK)
disable iff(ahb_slave_interface.HTRANS == BUSY || ahb_slave_interface.HBURST != 3'b011)
(ahb_slave_interface.HTRANS == NON_SEQ) |=> (ahb_slave_interface.HTRANS == SEQ)
|=> (ahb_slave_interface.HTRANS == SEQ)[*2];
endproperty

property bursts_count_8_check;
@(posedge ahb_slave_interface.HCLK)
disable iff(ahb_slave_interface.HTRANS == BUSY || ahb_slave_interface.HBURST != 3'b101)
(ahb_slave_interface.HTRANS == NON_SEQ) |=> (ahb_slave_interface.HTRANS == SEQ)
|=> (ahb_slave_interface.HTRANS == SEQ)[*6];
endproperty

property bursts_count_16_check;
@(posedge ahb_slave_interface.HCLK)
disable iff(ahb_slave_interface.HTRANS == BUSY || ahb_slave_interface.HBURST != 3'b111)
(ahb_slave_interface.HTRANS == NON_SEQ) |=> (ahb_slave_interface.HTRANS == SEQ)
|=> (ahb_slave_interface.HTRANS == SEQ)[*14];
endproperty

property addr_change_4_check;
@(posedge ahb_slave_interface.HCLK)
disable iff (ahb_slave_interface.HBURST != 3'b011)
(ahb_slave_interface.HTRANS == NON_SEQ) |=> not ($stable(ahb_slave_interface.HADR)[*3]);
endproperty

property addr_change_8_check;
@(posedge ahb_slave_interface.HCLK)
disable iff (ahb_slave_interface.HBURST != 3'b101)
(ahb_slave_interface.HTRANS == NON_SEQ) |=> not ($stable(ahb_slave_interface.HADR)[*7]);
endproperty

property addr_change_16_check;
@(posedge ahb_slave_interface.HCLK)
disable iff (ahb_slave_interface.HBURST != 3'b111)
(ahb_slave_interface.HTRANS == NON_SEQ) |=> not ($stable(ahb_slave_interface.HADR)[*15]);
endproperty

assert property(error_check)
error_check_pass ++;
else
error_check_fail ++;

assert property(read_only_check)
read_only_error_check_pass++;
else
read_only_error_check_fail++;

assert property(basic_write_check)
basic_write_error_check_pass++;
else
basic_write_error_check_fail++;

assert property(basic_read_check)
basic_write_error_check_pass++;
else
basic_write_error_check_fail++;

assert property(basic_burst_write) begin
basic_burst_write_check_pass++; 
end
else  begin
basic_burst_write_check_fail++;
end

assert property(basic_burst_read) begin
basic_burst_read_check_pass++; 
end
else  begin
basic_burst_read_check_fail++;
end

assert property(HREADY_check)
HREADY_check_pass++;
else
HREADY_check_fail++;

assert property(idle_check) 
idle_check_pass++;
else
idle_check_fail++;


assert property(bursts_count_4_check)
bursts_count_4_check_pass++;
else
bursts_count_4_check_fail++;

assert property(bursts_count_8_check)
bursts_count_8_check_pass++;
else
bursts_count_8_check_fail++;

assert property(bursts_count_16)check_
bursts_count_16_check_pass++;
else
bursts_count_16_check_fail++;

assert property(addr_change_4_check)
addr_change_4_check_pass++;
else
addr_change_4_check_fail++;

assert property(addr_change_8_check)
addr_change_8_check_pass++;
else
addr_change_8_check_fail++;

assert property(addr_change_16_check)
addr_change_16_check_pass++;
else
addr_change_16_check_fail++;



//SCorebard for Assertions.
final
begin
$display( "------------------------------------------------------------------------------------------------------");
$display( "----------------------------------------ASSERTION SCOREBOARD------------------------------------------");
$display("******************************************************************************************************");
$display(  "TYPE OF CHECK \t\t\t\tTOTAL COUNT\t\tPASS COUNT\t\t FAIL COUNT ");
$display( "------------------------------------------------------------------------------------------------------");
$display( " error_check            \t\t%d\t\t%d\t\t%d      ", (error_check_pass+error_check_fail),error_check_pass,error_check_fail);
$display( " read_only_error_check  \t\t%d\t\t%d\t\t%d      ", (read_only_error_check_pass+read_only_error_check_fail),read_only_error_check_pass,read_only_error_check_fail);
$display( " basic_write_error      \t\t%d\t\t%d\t\t%d      ", (basic_write_error_check_pass+basic_write_error_check_fail),basic_write_error_check_pass,basic_write_error_check_fail);
$display( " basic_read_error_check \t\t%d\t\t%d\t\t%d      ", (basic_read_error_check_pass+basic_read_error_check_fail),basic_read_error_check_pass,basic_read_error_check_fail);
$display( " basic_burst_write_check\t\t%d\t\t%d\t\t%d      ", (basic_burst_write_check_pass+basic_burst_write_check_fail),basic_burst_write_check_pass,basic_burst_write_check_fail);
$display( " basic_burst_read_check \t\t%d\t\t%d\t\t%d      ", (basic_burst_read_check_pass+basic_burst_read_check_fail),basic_burst_read_check_pass,basic_burst_read_check_fail);
$display( " HREADY_check           \t\t%d\t\t%d\t\t%d      ", (HREADY_check_pass+HREADY_check_fail),HREADY_check_pass,HREADY_check_fail);
$display( " bursts_count_4_check    \t\t%d\t\t%d\t\t%d      ", (bursts_count_4_check_pass+bursts_count_4_check_fail),bursts_count_4_check_pass,bursts_count_4_check_fail);
$display( " bursts_count_8_check    \t\t%d\t\t%d\t\t%d      ", (bursts_count_8_check_pass+bursts_count_8_check_fail),bursts_count_8_check_pass,bursts_count_8_check_fail);
$display( " bursts_count_16_check   \t\t%d\t\t%d\t\t%d      ", (bursts_count_16_check_pass+bursts_count_16_check_fail),bursts_count_16_check_pass,bursts_count_16_check_fail);
$display( " addr_change_2_check        \t\t%d\t\t%d\t\t%d      ",(addr_change_2_check_pass+addr_change_2_check_fail),addr_change_2_check_pass,addr_change_2_check_fail);
$display( " addr_8_check        \t\t%d\t\t%d\t\t%d      ",(addr_8_check_pass+addr_8_check_fail),addr_8_check_pass,addr_8_check_fail);
$display( " addr_16_check       \t\t%d\t\t%d\t\t%d      ",(addr_16_check_pass+addr_16_check_fail),addr_16_check_pass,addr_16_check_fail);

end

endmodule