`include "definesPkg.sv"
import definesPkg::*

module ahb_slave_tb;

logic HCLK;
logic HRESETn,wait_data;
bit [31:0] data_burst_read[31:0];
bit [DATA_WIDTH-1:0] data_burst[31:0] = '{32'd59, 32'd61, 32'd63, 32'd65,32'd1,32'd2,32'd3,32'd4,32'd5,32'd6,32'd7,32'd8,32'd9,32'd10,32'd11,32'd12,32'd13,32'd14,32'd15,32'd16,32'd17,32'd18,32'd19,32'd20,32'd21,32'd22,32'd23,32'd24,32'd25,32'd26,32'd27,32'd28 } ;

//initial block
initial HCLK=1'b1;
always #10 HCLK = ~HCLK;
class PacketClass;
	rand bit[31:0] addr_rand,data_rand;
	constrain c{
		addr_rand > 32'h0;
		addr_rand < 32'h400;
	}
endclass : PacketClass

program test(AHBInterface interfaceInstance)
	int rd_data,rd_data_wait;
	PacketClass pkt;
	initial
	begin
		pkt = new();
		assert(pk.randomize());
		interfaceInstance.write(32'h4,`1);
		#20
		interfaceInstance.read(32'h4,rd_data);

		interfaceInstance.write(32'h2,`1);
		#20
		interfaceInstance.read(32'h2,rd_data);
		#20
		//test case for 0 busy bursts 
		interfaceInstance.burst_write(32'd5,4,0,data_burst);
		#20;
		interfaceInstance.burst_read(32'd5,4,0,data_burst_read);
		#20;
		$display("DATA - 0 BUSY - BURST4 = %d, %d, %d, %d",data_burst_read[0],data_burst_read[1],data_burst_read[2],data_burst_read[3] );
		
		interfaceInstance.burst_write(32'd10,8,0,data_burst);
		#20;
		interfaceInstance.burst_read(32'd10,8,0,data_burst_read);
		#20;
		$display("DATA - 0 BUSY - BURST4 = %d, %d, %d, %d,%d, %d, %d, %d",data_burst_read[0],data_burst_read[1],data_burst_read[2],data_burst_read[3],
		data_burst_read[4],data_burst_read[5],data_burst_read[6],data_burst_read[7] );

		interfaceInstance.burst_write(32'd25,16,0,data_burst);
		#20;
		interfaceInstance.burst_read(32'd25,16,0,data_burst_read);
		#20;
		$display("DATA - 0 BUSY - BURST4 = %d, %d, %d, %d,%d, %d, %d, %d,%d, %d, %d, %d,%d, %d, %d, %d",
		data_burst_read[0],data_burst_read[1],data_burst_read[2],data_burst_read[3],
		data_burst_read[4],data_burst_read[5],data_burst_read[6],data_burst_read[7],
		data_burst_read[8],data_burst_read[9],data_burst_read[10],data_burst_read[11],
		data_burst_read[12],data_burst_read[13],data_burst_read[14],data_burst_read[15] );
//test case for 1 busy bursts 
		interfaceInstance.burst_write(32'd5,4,1,data_burst);
		#20;
		interfaceInstance.burst_read(32'd5,4,1,data_burst_read);
		#20;
		$display("DATA - 0 BUSY - BURST4 = %d, %d, %d, %d",data_burst_read[0],data_burst_read[1],data_burst_read[2],data_burst_read[3] );
		
		interfaceInstance.burst_write(32'd10,8,1,data_burst);
		#20;
		interfaceInstance.burst_read(32'd10,8,1,data_burst_read);
		#20;
		$display("DATA - 0 BUSY - BURST4 = %d, %d, %d, %d,%d, %d, %d, %d",data_burst_read[0],data_burst_read[1],data_burst_read[2],data_burst_read[3],
		data_burst_read[4],data_burst_read[5],data_burst_read[6],data_burst_read[7] );

		interfaceInstance.burst_write(32'd25,16,1,data_burst);
		#20;
		interfaceInstance.burst_read(32'd25,16,1,data_burst_read);
		#20;
		$display("DATA - 0 BUSY - BURST4 = %d, %d, %d, %d,%d, %d, %d, %d,%d, %d, %d, %d,%d, %d, %d, %d",
		data_burst_read[0],data_burst_read[1],data_burst_read[2],data_burst_read[3],
		data_burst_read[4],data_burst_read[5],data_burst_read[6],data_burst_read[7],
		data_burst_read[8],data_burst_read[9],data_burst_read[10],data_burst_read[11],
		data_burst_read[12],data_burst_read[13],data_burst_read[14],data_burst_read[15] );
//test case for 2 busy bursts 
		interfaceInstance.burst_write(32'd5,4,2,data_burst);
		#20;
		interfaceInstance.burst_read(32'd5,4,2,data_burst_read);
		#20;
		$display("DATA - 0 BUSY - BURST4 = %d, %d, %d, %d",data_burst_read[0],data_burst_read[1],data_burst_read[2],data_burst_read[3] );
		
		interfaceInstance.burst_write(32'd10,8,2,data_burst);
		#20;
		interfaceInstance.burst_read(32'd10,8,2,data_burst_read);
		#20;
		$display("DATA - 0 BUSY - BURST4 = %d, %d, %d, %d,%d, %d, %d, %d",data_burst_read[0],data_burst_read[1],data_burst_read[2],data_burst_read[3],
		data_burst_read[4],data_burst_read[5],data_burst_read[6],data_burst_read[7] );

		interfaceInstance.burst_write(32'd25,16,2,data_burst);
		#20;
		interfaceInstance.burst_read(32'd25,16,2,data_burst_read);
		#20;
		$display("DATA - 0 BUSY - BURST4 = %d, %d, %d, %d,%d, %d, %d, %d,%d, %d, %d, %d,%d, %d, %d, %d",
		data_burst_read[0],data_burst_read[1],data_burst_read[2],data_burst_read[3],
		data_burst_read[4],data_burst_read[5],data_burst_read[6],data_burst_read[7],
		data_burst_read[8],data_burst_read[9],data_burst_read[10],data_burst_read[11],
		data_burst_read[12],data_burst_read[13],data_burst_read[14],data_burst_read[15] );

		//wait state initiated by slave
		fork
			begin
				wait_data = 1;
				#60;
				wait_data = 0;
				#20;	
			end
			begin
				#20;
				#20;
				interfaceInstance.read(32'h4,rd_data_wait);
			end
		join

		$display ("DATA @ address 32'h00000004 with wait states installed by Slave = %h\n", rd_data_wait);

		$stop;
		//basic red
	end
endprogram

//instantiations
AHBInterface ahb_interface_inst(.HCLK(HCLK), HRESETn(1'b1));
ahb_slave_top ahb_slave_top_inst(.ahb_slave_interface(ahb_interface_inst.slave),.wait_slave(wait_data));
test t1(ahb_interface_inst);
monitor m1_inst(.bus(ahb_interface_inst),.reset());
endmodule : ahb_slave_tb