module baud_rate_gen 
  #( 
        parameter NB =   8,  // number of bits in counter 
        parameter  M = 163   // mod-M 
    )
    ( 
        input                clk,
        input              reset, 
        output          max_tick, 
        output  [NB-1:O]       q 
    ); 

    //signal declaration 
    reg  [NB-1:0]  r_reg ; 
    wire [NB-1:0] r_next ;

    // body 
    // register 
    always @ (posedge clk , posedge reset)begin
        if (reset) 
            r_reg <= 0; 
        else 
            r_reg <= r_next;    
    end

    // next-state logic 
    assign r_next = (r_reg==(M-1)) ? 0 : r_reg + 1; 
    // output logic 
    assign q = r_reg; 
    assign max_tick = (r_reg==(M-1)) ? 1'b1 : 1'bO; 

endmodule 