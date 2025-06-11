`include "Def.v"

module Hazard_Detection_Unit(
    input [4:0] ID_EX_rs1,       // RS1 from ID/EX pipeline register
    input [4:0] ID_EX_rs2,       // RS2 from ID/EX pipeline register
    input [4:0] EX_MEM_rd,       // RD from EX/MEM pipeline register
    input [4:0] MEM_WB_rd,       // RD from MEM/WB pipeline register
    input ID_EX_mem_read,        // Memory read signal from ID/EX
    input EX_MEM_mem_read,       // Memory read signal from EX/MEM
    input branch_taken,          // Branch is taken
    input jump,                  // Jump instruction
    output reg PC_write,         // Freeze PC if 0
    output reg IF_ID_write,      // Freeze IF/ID pipeline register if 0
    output reg control_mux_sel   // Insert bubbles if 1 (set controls to 0)
);

    // Detect load-use hazard (data hazard when load is followed by dependent instruction)
    wire load_use_hazard = ID_EX_mem_read && 
                          ((ID_EX_rs1 == EX_MEM_rd) || (ID_EX_rs2 == EX_MEM_rd));
    
    // Detect RAW (Read After Write) hazard
    wire raw_hazard = ((ID_EX_rs1 == MEM_WB_rd) || (ID_EX_rs2 == MEM_WB_rd)) && 
                     (MEM_WB_rd != 0);  // Register x0 is always 0
    
    // Detect control hazard (branch or jump)
    wire control_hazard = branch_taken || jump;

    always @(*) begin
        if (load_use_hazard || raw_hazard) begin
            // Stall the pipeline
            PC_write = 1'b0;
            IF_ID_write = 1'b0;
            control_mux_sel = 1'b1;
        end
        else if (control_hazard) begin
            // Flush the pipeline after branch/jump
            PC_write = 1'b1;
            IF_ID_write = 1'b1;
            control_mux_sel = 1'b1;
        end
        else begin
            // Normal operation
            PC_write = 1'b1;
            IF_ID_write = 1'b1;
            control_mux_sel = 1'b0;
        end
    end
endmodule
