//Top level module

module top
  (clk_input,
   rst_in,
   bus_pcie_wr,
   bus_pcie_req,

   clk_output,
   pcie_bus_rd
   );
   
`include "params.svh"
`include "structs.svh"

   input               clk_input;
   input               rst_in;
   
   input  pcie_wr_s    bus_pcie_wr;
   input  pcie_req_s   bus_pcie_req;

   output              clk_output;
   output pcie_rd_s    pcie_bus_rd;
   
   sum_pick_s  sum_pick;
   
   pcie_wr_s   pcie_coef_wr;
   pcie_req_s  pcie_coef_req;
   pcie_rd_s   coef_pcie_rd;

   pcie_wr_s   pcie_ctrl_wr;

   pcie_wr_s   pcie_rnd_wr;    

   pcie_req_s  pcie_pick_req;
   pcie_rd_s   pick_pcie_rd;
   
   ctrl_rnd_s  ctrl_rnd;
   ctrl_coef_s ctrl_coef;
   ctrl_pick_s ctrl_pick;
   
   rnd_coef_s  rnd_coef;
   coef_sum_s  coef_sum;

   pick_rnd_s  pick_rnd;
   
   sys_s       sys;

   
   clk_gen clk_gen_0
     (
      .clk_input(clk_input),
      .rst_in(rst_in),
      .sys(sys)
      );

   assign clk_output = sys.clk;
   
   pcie pcie_0
     (
      .sys(sys),	          

      .bus_pcie_wr(bus_pcie_wr),
      .bus_pcie_req(bus_pcie_req),
      .pcie_bus_rd(pcie_bus_rd),

      .pcie_coef_wr(pcie_coef_wr),
      .pcie_coef_req(pcie_coef_req),
      .coef_pcie_rd(coef_pcie_rd),
                                
      .pcie_ctrl_wr(pcie_ctrl_wr),
      
      .pcie_rnd_wr(pcie_rnd_wr),

      .pcie_pick_req(pcie_pick_req),
      .pick_pcie_rd(pick_pcie_rd)
      );   
   
   ctrl ctrl_0
     (
      .sys(sys),
      .pcie_ctrl_wr(pcie_ctrl_wr),

      .ctrl_rnd(ctrl_rnd),
      .ctrl_coef(ctrl_coef),
      .ctrl_pick(ctrl_pick)
      );

   rnd rnd_0
     (
      .sys(sys),      
      .pcie_rnd_wr(pcie_rnd_wr),
      .ctrl_rnd(ctrl_rnd),
      .pick_rnd(pick_rnd),

      .rnd_coef(rnd_coef)
      );

   coef coef_0
    ( 
     .sys(sys),
     .rnd_coef(rnd_coef),
     .pcie_coef_wr(pcie_coef_wr),
     .pcie_coef_req(pcie_coef_req),
     .ctrl_coef(ctrl_coef),

     .coef_pcie_rd(coef_pcie_rd),
     .coef_sum(coef_sum)
     );

   sum sum_0
     (
      .sys(sys),      
      .coef_sum(coef_sum),

      .sum_pick(sum_pick)
      );

   pick pick_0
     (
      .sys(sys),
      .ctrl_pick(ctrl_pick),
      .sum_pick(sum_pick),
      .pcie_pick_req(pcie_pick_req),

      .pick_rnd(pick_rnd),
      .pick_pcie_rd(pick_pcie_rd)
      );
   

endmodule // coef

 
