module interface_alu_uart
    #( //default settings
    parameter DBIT = 8, // data bits
    parameter NB_OP = 6,
    parameter NB_AB = 8

    )
    (
        input wire clk, reset,
        input wire [DBIT-1:0] r_data,
        input wire tx_full, rx_empty, tx_done_tick,
        input wire [NB_AB-1:0] result,
        output wire [DBIT-1:0] w_data,
        output wire rd_uart, wr_uart,
        output wire [NB_OP-1:0] op_code,
        output wire [NB_AB-1:0] data_a, data_b
    );

    localparam [2:0]
        waiting_s     = 3'b000,
        op_code_s     = 3'b001,
        data_a_s      = 3'b010,
        data_b_s      = 3'b011,
        send_result_s = 3'b100;

    //signal declaration
    reg [1:0] state_reg, state_next;
    reg [NB_OP-1:0] op_code_reg;
    reg [NB_AB-1:0] data_a_reg, data_b_reg;
    reg [NB_AB-1:0] result_reg;
    reg [DBIT -1:0] r_data_reg;
    reg rd_uart_reg, wr_uart_reg;

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
        if (reset) begin
            rd_uart_reg <= 1'b0;
            wr_uart_reg <= 1'b0;
            data_a_reg <= 0;
            data_b_reg <= 0;
            op_code_reg <= 0;
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
                    op_code_reg <= r_data_reg[NB_OP-1 : 0];
                    if(~rx_empty)
                        begin
                            state_next <= data_a_s;
                            rd_uart_reg    <= 1'b1;
                        end
                end
            data_a_s:
                begin
                    rd_uart_reg <= 1'b0;
                    data_a_reg <= r_data_reg[NB_AB-1 : 0];
                    if(~rx_empty)
                        begin
                            state_next <= data_b_s;
                            rd_uart_reg    <= 1'b1;
                        end
                end
            data_b_s: 
                begin
                    rd_uart_reg    <= 1'b0;
                    data_b_reg <= r_data_reg[NB_OP-1 : 0];
                    if(~rx_empty)
                        begin
                            state_next <= send_result_s;
                            rd_uart_reg    <= 1'b1;
                        end
                end
            send_result_s: 
                begin
                    rd_uart_reg <= 1'b0;
                    if(~tx_full)
                        begin
                            result_reg <= result;    
                            wr_uart_reg    <= 1'b1;
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
