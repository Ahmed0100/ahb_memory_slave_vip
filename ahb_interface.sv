`include "definesPkg.sv"
import definesPkg::*;

interface AHBInterface(input HCLK,input HRESETn);

logic [ADDRESS_WIDTH-1:0] HADDR;
logic HWRITE;
logic [HSIZE_WIDTH-1:0] HSIZE;
logic [BURST_WIDTH-1:0] HBURST;
logic [TRANSFER_WIDTH-1:0] HTRANS;
logic [DATA_WIDTH-1:0] HWDATA;
logic [DATA_WIDTH-1:0] HRDATA;
logic HREADY;
logic HRESP;
bit [ADDRESS_WIDTH-1:0] ADDR;
int i,j,k,n;
int count=0;

task read(input bit [ADDRESS_WIDTH-1:0] addr, output logic [DATA_WIDTH-1:0] data);
	@(posedge HCLK);
	HADDR = addr;
	HWRITE = 0;
	HSIZE = 3'b010;
	HBURST = 3'b000;
	if(HRESP) $display("ERROR RESPONSE FROM SLAVE \n");
	while(~HREADY);
	@(posedge HCLK);
	@(posedge HCLK);
	data = HRDATA;
endtask

task burst_read(bit [ADDRESS_WIDTH-1:0] addr, input int BEATS,
input int busy, output bit[DATA_WIDTH-1:0] data_burst_4[31:0]);
	automatic int i,j=0;
	@(posedge HCLK);
	HADDR = addr;
	HTRANS = NON_SEQ;
	HWRITE = 0;
	@(HCLK);
	HADDR = addr + 1;
	repeat(busy)
	begin
		j++;
		HTRANS = BUSY;
		@(posedge HCLK);
		if(j == busy) HTRANS = SEQ;
	end
	
	i = 0;
	repeat(BEATS-2)
	begin
		@(posedge HCLK);
		HADDR = HADDR + 1;
		HTRANS = SEQ;
		data_burst_4[i] = HRDATA;
		i=i+1;
	end
	@(posedge HCLK);
	data_burst_4[i] = HRDATA;
	i=i+1;
	@(posedge HCLK);
	data_burst_4[i]= HRDATA;
endtask

task write(input bit[ADDRESS_WIDTH-1:0] addr, input logic [DATA_WIDTH-1:0] data);
	@(posedge HCLK);
	HADDR = addr;
	HWRITE = 1;
	HSIZE = 3'b010;
	HBURST = 0;
	while(!HREADY);
	@(posedge HCLK);
	HWDATA = data;
	@(posedge HCLK);
	if(HRESP) $display("ERROR - WRITING TO READ ONLY MEMORY\n");
endtask

task burst_write (bit[ADDRESS_WIDTH-1:0] addr,  input int BEATS, input int busy, input bit[DATA_WIDTH-1:0] data_4[31:0]);
	if(BEATS == 4) HBURST = 3'b011;
	if(BEATS == 8) HBURST = 3'b101;
  	if(BEATS == 16) HBURST = 3'b111;
	i=0;
	j=0;
	k=0;
	if(HRESP) $display("ERROR\n");
	fork
		begin
			if(i==0) HTRANS=NON_SEQ;
			HADDR= addr;
			HWRITE = 1;
			@(posedge HCLK);
			HADDR = addr;
			while(!HREADY);
			addr = addr + 1;
			i=i+1;
         	if(busy == 1)
			begin
				if(i==2)
				begin
					HTRANS = BUSY;
					@(posedge HCLK);
				end
			end

			if(busy == 2)
			begin
				if(i==3)
				begin
					HTRANS = BUSY;
					@(posedge HCLK);
					@(posedge HCLK);
				end
			end

			if ( (busy==32'd1)||(busy ==32'd2) )	
			begin
				if ((i!=2) || (i!=3))
					HTRANS = BUSY;
			end
			else
			begin
				HTRANS = SEQ; 
			end
		end
	
		begin
		repeat(BEATS)
		begin
			@(posedge HCLK);
			HWDATA = data_4[j];
			while(~HREADY);
			j=j+1;
			k=k+1;
			if(busy == 1)
			begin
				if(k==2)
				begin
					@(posedge HCLK);
				end
			end
			if(busy == 2)
			begin
				if(k==3)
				begin
					@(posedge HCLK);
					@(posedge HCLK);
				end
			end
		end
	end
	join
endtask

modport slave(
					output HREADY,
					output HRESP,
					output HRDATA,
					input HADDR,
					input HWRITE,
					input HSIZE,
					input HBURST,
					input HTRANS,
					input HWDATA,
					input HCLK,
					input HRESETn
					);
					
endinterface
