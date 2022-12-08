module ahb_slave_memory
(
	input HCLK,
	input HRESETn,
	input [9:0] HADDR,
	input [31:0] HWDATA,
	input [1:0] HTRANS,
	input HWRITE,
	input HSEL,
	input wait_slave_to_master,
	output [31:0] HRDATA,
	output HRESP,
	output HREADY
);
localparam ADDR_SPACE=10;
localparam HSIZE_WIDTH = 3;
localparam READ_ONLY_START_ADDR = 10'h00;
localparam READ_ONLY_WRITE_ADDR = 10'h03;
reg [9:0] addr_next,addr_reg;

reg [31:0] mem [2**ADDR_SPACE - 1];

reg HREADY_next,HREADY_reg;
reg HRESP_next,HRESP_reg;
reg [31:0] HRDATA_next,HRDATA_reg;
reg [31:0] mem_wdata_reg,mem_wdata_next;

assign HRESP = HRESP_reg;
assign HRDATA = HRDATA_reg;
assign HREADY = HREADY_reg;

always @(posedge HCLK)
begin
	if(~HRESETn)
	begin
		HREADY_reg <= 1;
		HRESP_reg <= 0;
		HRDATA_reg <= 0;
		addr_reg <= 0;
		mem_wdata_reg<=0;
	end
	else
	begin
		HREADY_reg <= HREADY_next;
		HRESP_reg <= HRESP_next;
		HRDATA_reg <= HRESP_next;
		addr_reg<=addr_next;
		mem_wdata_reg<= mem_wdata_next;
	end
end
always @(*)
begin
	HREADY_next = HREADY_reg;
	HRESP_next = HRESP_reg;
	HRDATA_next = HRDATA_reg;
	addr_next = addr_reg;
	mem_wdata_next = mem_wdata_reg;
	mem[addr_reg] = mem_wdata_reg;
	if(HSEL)
	begin
		if(HTRANS == 2'b00 || HTRANS == 2'b01)
		begin
			HREADY_next = 1;
			HRESP_next = 0;
		end
		else 
		begin
			if(wait_slave_to_master)
			begin
				HREADY_next = 0;
				HRESP_next = 0;
			end
			else
			begin
				mem_wdata_next = HWDATA;
				if(HWRITE)
				begin
					if(HADDR >= 32'h0000_0000 && HADDR <= 32'h0000_0003)
					begin
						HREADY_next = 1;
						HRESP_next = 1;
					end
					else
					begin
						addr_next = HADDR;
						HREADY_next = 1;
						HRESP_next = 0;
					end
				end
				else
				begin
					addr_next = HADDR;
					HRDATA_next = mem[addr_reg];
					HREADY_next = 1;
					HRESP_next = 0;
				end
			end
		end
	end
end

endmodule