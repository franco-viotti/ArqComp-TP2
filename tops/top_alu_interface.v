module top_alu_interface
#(
    parameter DBIT = 8,
    parameter NB_OP = 6,
    parameter NB_AB = 8
)
(
    input clock,
    input i_reset,
    input wire_tx_full, 
    input wire_rx_empty, 
    input wire_tx_done_tick,
    input [DBIT-1:0] wire_r_data,
    output [DBIT-1:0] wire_w_data,
    output wire_rd_uart, 
    output wire_wr_uart
);

wire [NB_AB-1:0] wire_a;
wire [NB_AB-1:0] wire_b;
wire [NB_OP-1:0] wire_operation;
wire [NB_AB-1:0] wire_result; 


interface_alu_uart //! Instancia de interface
    #(
      .DBIT(DBIT),
      .NB_OP(NB_OP),
      .NB_AB(NB_AB)
    )
    u_interface
    (
      .clk(clock),
      .reset(i_reset),
      .r_data(wire_r_data),
      .tx_full(wire_tx_full),
      .rx_empty(wire_rx_empty),
      .tx_done_tick(wire_tx_done_tick),
      .result(wire_result),
      .w_data(wire_w_data),
      .rd_uart(wire_rd_uart),
      .wr_uart(wire_wr_uart),
      .op_code(wire_operation),
      .data_a(wire_a),
      .data_b(wire_b)
    );

    ALU //! Instancia de ALU
    #(
      .NB_AB(NB_AB),
      .NB_OP(NB_OP),
      .ADD(6'b100000),
      .SUB(6'b100010),
      .AND(6'b100100),
      .OR (6'b100101),
      .XOR(6'b100110),
      .SRA(6'b000011),
      .SRL(6'b000010),
      .NOR(6'b100111)
    )
    u_ALU
    (
      .i_opcode(wire_operation),
      .i_A(wire_a             ),
      .i_B(wire_b             ),
      .o_result(wire_result   )
    );
endmodule