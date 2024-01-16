module tb_ws2812_driver();

logic  clk_in       ;
logic  rst_n_in     ; 
logic  code_in      ; 
logic  code_in_valid; 
logic  ws2812_out   ; 
logic  ready_out    ;

ws2812_driver ws2812_driver_inst(
    .clk_in       (clk_in       ),
    .rst_n_in     (rst_n_in     ),

    .code_in      (code_in      ),
    .code_in_valid(code_in_valid),

    .ws2812_out   (ws2812_out   ),
    .ready_out    (ready_out    )
);
defparam ws2812_driver_inst.V_0_HIGH    =   3'd2 ;
defparam ws2812_driver_inst.V_0_LOW     =   3'd1 ;
defparam ws2812_driver_inst.V_1_HIGH    =   3'd4 ;
defparam ws2812_driver_inst.V_1_LOW     =   3'd5 ;
defparam ws2812_driver_inst.COUNTER_W   =   2'd3 ;

initial begin
    clk_in = 1'b0;
    forever #5 clk_in = ~clk_in;
end 

initial begin
    rst_n_in = 1'b0;
    code_in  = 1'b0;
    code_in_valid = 1'b0;
end 

initial begin
    @(posedge clk_in );
    rst_n_in = 1'b1;
    for( int i=0;i<10;i++) begin
        while (1) begin
            @(posedge clk_in );
            if( ready_out == 1'b1 ) begin
                break;
            end
        end
        code_in <= {$random()}&1'b1;
        code_in_valid <= 1'b1;
        @(posedge clk_in );
        code_in_valid <= 1'b0;
    end

    repeat(10) @(posedge clk_in );
    $finish;
end

endmodule