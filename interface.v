module interface_alu_uart
    #( //default settings
    parameter DBIT = 8,     // data bits
    parameter NB_OP = 6,    // operation bits
    parameter NB_AB = 8     // operand bits

    )
    (
        input  clk, reset,
        input  [DBIT-1:0] r_data,
        input  rx_empty, tx_done_tick,
        input  [NB_AB-1:0] result,
        output [DBIT-1:0] w_data,
        output rd_uart, wr_uart,
        output [NB_OP-1:0] op_code,
        output [NB_AB-1:0] data_a, data_b
    );

    localparam [2:0]
        waiting_s     = 3'b000,
        op_code_s     = 3'b001,
        data_a_s      = 3'b010,
        data_b_s      = 3'b011,
        send_result_s = 3'b100;

    //signal declaration
    reg [2:0] state_reg, state_next;
    reg [NB_OP-1:0] op_code_reg;
    reg [NB_AB-1:0] data_a_reg, data_b_reg;
    reg [NB_AB-1:0] result_reg;
    reg rd_uart_reg, wr_uart_reg;
    reg tx_empty;

    always @(posedge clk, posedge reset) begin
        if(reset)
            begin
                state_reg <= waiting_s;
            end
        else
            begin
                state_reg <= state_next;
            end
    end

    always @(posedge clk) begin
        if (reset) begin    // Que pasa si se quiere resetear y cuando se evalua el
                            //if el reset esta en cero porque se solto el boton?
            rd_uart_reg <= 1'b0;
            wr_uart_reg <= 1'b0;
            data_a_reg <= 0;
            data_b_reg <= 0;
            op_code_reg <= 0;
            state_next <= waiting_s;
        end

        case (state_reg)
            waiting_s:
                begin
                    if(~rx_empty)
                        begin
                            state_next <= op_code_s;
                        end
                end
            op_code_s:
                begin
                    if(~rx_empty)
                        begin
                            op_code_reg <= r_data[NB_OP-1 : 0];
                            state_next <= data_a_s;
                            rd_uart_reg    <= 1'b1;
                        end
                end
            data_a_s:
                begin
                    rd_uart_reg <= 1'b0;
                    if(~rx_empty)
                        begin
                            data_a_reg <= r_data[NB_AB-1 : 0];
                            state_next <= data_b_s;
                            rd_uart_reg    <= 1'b1;
                        end
                end
            data_b_s:
                begin
                    rd_uart_reg    <= 1'b0;
                    if(~rx_empty)
                        begin
                            data_b_reg <= r_data[NB_OP-1 : 0];
                            state_next <= send_result_s;
                            rd_uart_reg    <= 1'b1;
                            tx_empty <= 1'b1;
                        end
                end
            send_result_s:
                begin
                    rd_uart_reg <= 1'b0;
                    if(tx_empty)
                        begin
                            result_reg <= result;
                            wr_uart_reg    <= 1'b1;
                            tx_empty <= 1'b0;
                        end
                    else begin
                        wr_uart_reg <= 1'b0;
                    end
                    if(tx_done_tick)
                        begin
                            state_next <= waiting_s;
                            wr_uart_reg    <= 1'b0;
                        end
                end
        endcase

    end

    assign op_code = op_code_reg;
    assign data_a  = data_a_reg;
    assign data_b  = data_b_reg;
    assign w_data  = result_reg;
    assign rd_uart = rd_uart_reg;
    assign wr_uart = wr_uart_reg;

endmodule
