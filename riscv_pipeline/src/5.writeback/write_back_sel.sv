`timescale 1ns/1ps

import defines::*;

module write_back_sel (
  input wb_sel_e WBSel_WB,
  input logic [DATA_WIDTH-1:0] alu_result_WB,
  input logic [DATA_WIDTH-1:0] rd_data_WB,
  input logic [DATA_WIDTH-1:0] pc_plus4_WB,

  output logic [DATA_WIDTH-1:0] write_back_WB
  );

  always_comb begin
    case (WBSel_WB)
      WB_ALU: write_back_WB = alu_result_WB;
      WB_MEM: write_back_WB = rd_data_WB;
      WB_PC4: write_back_WB = pc_plus4_WB;
      WB_NONE: write_back_WB = '0;
    endcase
  end

endmodule
