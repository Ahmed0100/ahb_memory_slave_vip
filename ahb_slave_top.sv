`define NUM_OF_SLAVES 2

module ahb_slave_top(AHBSlaveInterface ahb_slave_interface, input wait_slave_to_master);

parameter ADDR_BUS_WIDTH 32;
parameter ADDR_SPACE = 10;

logic [`NUM_OF_SLAVES-1:0] HSEL;
logic [`NUM_OF_SLAVES-1:0][31:0] HRDATA_BUS;
logic [`NUM_OF_SLAVES-1:0] HRESP_BUS;
logic [`NUM_OF_SLAVES-1:0] HREADY_BUS;
logic [`NUM_OF_SLAVES-1:0] encoded_addr;
assign encoded_addr ahb_slave_interface.HADDR[ADDR_SPACE + $clog2(`NUM_OF_SLAVES)-1:ADDR_SPACE];
decoder ahb_decoder_inst (.addr(encoded_addr),.decoded_addr(HSEL));

genvar i;
generate
	for(i =0; i<NUM_OF_SLAVES; i=i+1)
	begin
		ahb_slave_mem ahb_slave_mem_inst
		(
			.HCLK(ahb_slave_interface.HCLK),
			.HRESETn(ahb_slave_interface.HRESETn),
			.HADDR(ahb_slave_interface.HADDR),
			.HWDATA(ahb_slave_interface.HWDATA),
			.HTRANS(ahb_slave_interface.HTRANS),
			.HWRITE(ahb_slave_interface.HWRITE),
			.HSEL(HSEL[i]),
			.wait_slave_to_master(wait_slave_to_master),
			.HRDATA(HRDATA_BUS[i]),
			.HRESP(HRESP_BUS[i]),
			.HREADY(HREADY_BUS[i])

		);

	end
endgenerate
endmodule : ahb_slave_top


always_comb begin
	ahb_slave_interface.HRDATA = HRDATA_BUS[encoded_addr];
	if(ahb_slave_interface.HADDR > (`NUM_OF_SLAVES *(2**ADDR_SPACE)))
	begin
		if(ahb_slave_interface.HTRANS == 2'b10 || ahb_slave_interface.HTRANS == 2'b11)
		begin
			ahb_slave_interface.HRESP = 1;
			ahb_slave_interface.HREADY = 0;
		end
		else
		begin
			ahb_slave_interface.HRESP = 0;
			ahb_slave_interface.HREADY = 1;
		end
	end
	else
	begin
		ahb_slave_interface.HRESP = HRESP_BUS[encoded_addr];
		ahb_slave_interface.HREADY = HREADY_BUS[encoded_addr];
	end
end

module decoder(input [`clog2(`NUM_OF_SLAVES)-1:0] addr, output logic [`NUM_OF_SLAVES-1:0] HSEL);

assign HSEL = (`NUM_OF_SLAVES'b1) << addr;

endmodule	