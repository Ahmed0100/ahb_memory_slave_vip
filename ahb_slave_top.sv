`define NUM_OF_SLAVES 2

module ahb_slave_top(AHBInterface ahb_slave_interface, input wait_slave_to_master);

parameter ADDR_BUS_WIDTH = 32;
parameter ADDR_SPACE = 10;

logic [`NUM_OF_SLAVES-1:0] HSEL;
logic [`NUM_OF_SLAVES-1:0][31:0] HRDATA_BUS;
logic [`NUM_OF_SLAVES-1:0] HRESP_BUS;
logic [`NUM_OF_SLAVES-1:0] HREADY_BUS;
logic [`NUM_OF_SLAVES-1:0] encoded_addr;
assign encoded_addr = ahb_slave_interface.HADDR[ADDR_SPACE + $clog2(`NUM_OF_SLAVES)-1:ADDR_SPACE];
decoder ahb_decoder_inst (.encoded_addr(encoded_addr),.decoded_addr(HSEL));

genvar i;
generate
	for(i =0; i<`NUM_OF_SLAVES; i=i+1)
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
always_comb begin
	ahb_slave_interface.HRDATA = HRDATA_BUS[encoded_addr];

		ahb_slave_interface.HRESP = HRESP_BUS[encoded_addr];
		ahb_slave_interface.HREADY = HREADY_BUS[encoded_addr];

end
endmodule : ahb_slave_top

module decoder(input [(`NUM_OF_SLAVES)-1:0] encoded_addr, output logic [`NUM_OF_SLAVES-1:0] decoded_addr);

assign decoded_addr = (`NUM_OF_SLAVES'b1) << encoded_addr;

endmodule	
