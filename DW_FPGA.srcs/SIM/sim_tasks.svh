// This is included, so does not need to be in module.

task automatic pcie_write
  (
   input reg [31:0] block_offset,
   input reg [31:0] addr,
   input reg [63:0] data,
   ref   reg        clk_in,
   
   ref pcie_wr_s    bus_pcie_wr
   );
   
   begin : bus_pcie_write
      @(negedge clk_in);
      bus_pcie_wr.data = data;
      bus_pcie_wr.addr = block_offset + addr;
      bus_pcie_wr.vld  = 1'b1;
      
      @(negedge clk_in);
      bus_pcie_wr.vld  = 1'b0;
   end
   
endtask //

task automatic pcie_read
  (
   input  reg [31:0] block_offset,
   input  reg [31:0] addr,
   output reg [63:0] data,
   ref    reg 	     clk_in,
   ref pcie_req_s    bus_pcie_req,
   ref pcie_rd_s     pcie_bus_rd
   );
   
   begin : bus_pcie_read
      @(negedge clk_in);
      bus_pcie_req.tag  = bus_pcie_req.tag + 1;
      bus_pcie_req.addr = block_offset + addr;
      bus_pcie_req.vld  = 1'b1;
      
      @(negedge clk_in);
      bus_pcie_req.vld  = 1'b0;
      while (pcie_bus_rd.vld == 'b0) begin
	 @(negedge clk_in);
      end
      data = pcie_bus_rd.data;
   end // block: bus_pcie_read
   
endtask //