`timescale 1ns / 100ps

module tb_alu_interface;

    reg clock, i_reset;
    reg [7:0] r_data_reg; 
    reg rx_empty_reg, tx_full_reg, tx_done_tick_reg;

    wire [7:0] wire_w_data;
    wire wire_rd_uart, wire_wr_uart;

    initial begin
        clock              = 0;
        i_reset            = 0;
        r_data_reg         = 0;
        tx_full_reg        = 0;
        rx_empty_reg       = 1;
        tx_done_tick_reg   = 0;
        

        #3  i_reset      = 1'b1;
        #3  i_reset      = 1'b0;
        #3  r_data_reg   = 8'b11111111;
        #1  rx_empty_reg = 0;

        #10 $finish;

    end

    always #1 clock = ~clock;

    top_alu_interface //! instancia top
        #(
            .DBIT(8),
            .NB_OP(6),
            .NB_AB(8)
        )
        u_top_alu_interface
        (
            .clock(clock),
            .i_reset(i_reset),
            .wire_tx_full(tx_full_reg),
            .wire_rx_empty(rx_empty_reg),
            .wire_tx_done_tick(tx_done_tick_reg),
            .wire_r_data(r_data_reg),
            .wire_w_data(wire_w_data),
            .wire_rd_uart(wire_rd_uart),
            .wire_wr_uart(wire_wr_uart)
        );

endmodule