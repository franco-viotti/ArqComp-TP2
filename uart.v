module uart
    #( //Default setting:
       // 19200 baud, 8 data bits, 1 stop bit, 2 2 FIFO
    parameter   DBIT        = 8,    // data bits
                SB_TICK     = 16,   // ticks for stop bits
                                    // 16/24/32 for 1/1.5/2 stop bits
                DVSR        = 163,  // baud rate divisor
                                    // DVSR = 50M/(16* baud rate)
                DVSR_BITS   = 9,    // number of bits in divisor
                FIFO_W      = 2    // FIFO width
                                    // words in FIFO = 2^FIFO_W
    )            
    (
        input wire clk, reset,
        input wire rd_uart, wr_uart, rx,
        input wire [DBIT-1:0] w_data,
        output wire [DBIT-1:0] r_data,
        output wire tx_full, rx_empty, tx
    );

    //signal declaration
    wire tick, rx_done_tick, tx_done_tick;
    wire tx_empty, tx_fifo_not_empty;
    wire [DBIT-1:0] tx_fifo_out, rx_data_out;

    //body
    //baud rate generator
    baud_rate_gen #(.NB(DVSR_BITS), .M(DVSR)) baud_rate_gen_unit
    (
        .clk(clk), .reset(reset),
        .max_tick(tick), .q()
    );
    uart_rx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_rx_unit
    (
        .clk(clk), .reset(reset),
        .rx(rx), .s_tick(tick),
        .rx_done_tick(rx_done_tick),
        .dout(rx_data_out)
    );
    fifo #(.W(FIFO_W), .B(DBIT)) rx_fifo_unit
    (
        .clk(clk), .reset(reset),
        .rd(rd_uart), .wr(rx_done_tick),
        .w_data(rx_data_out),
        .r_data(r_data),
        .full(), .empty(rx_empty)
    );
    uart_tx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_tx_unit
    (
        .clk(clk), .reset(reset),
        .tx_start(tx_fifo_not_empty), .s_tick(tick),
        .din(tx_fifo_out),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );
    fifo #(.W(FIFO_W), .B(DBIT)) tx_fifo_unit
    (
        .clk(clk), .reset(reset),
        .rd(tx_done_tick), .wr(wr_uart),
        .w_data(w_data),
        .r_data(tx_fifo_out),
        .full(tx_full), .empty(tx_empty)
    );
    assign tx_fifo_not_empty = ~tx_empty;

endmodule