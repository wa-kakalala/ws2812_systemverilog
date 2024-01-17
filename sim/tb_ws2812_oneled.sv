/**************************************
@ filename    : tb_ws2812_oneled.sv
@ author      : yyrwkk
@ create time : 2024/01/17 20:50:46
@ version     : v1.0.0
**************************************/
module tb_ws2812_oneled();
logic         clk_in             ;
logic         rst_n_in           ; 
       
logic         code               ; 
logic         code_valid         ; 
       
logic         ws2812_out         ; 
logic         driver_ready       ;
       
logic [23:0]  grb_in             ;
logic         grb_in_valid       ;
logic         oneled_ready       ;

initial begin
    clk_in = 1'b0;
    forever #5 clk_in = ~clk_in;
end 

initial begin
    grb_in = 24'b0;
    grb_in_valid = 1'b0;
    rst_n_in     = 1'b0;
end 

logic [23:0] grb_data[$] = {
    24'b1100_1100_1100_1111_0000_0000
};

initial begin
    @(posedge clk_in );
    rst_n_in = 1'b1;
    for( int idx = 0;idx < grb_data.size();idx++) begin
        wait( oneled_ready == 1'b1);
        grb_in <= grb_data[idx];
        grb_in_valid <= 1'b1;
        @(posedge clk_in );
        grb_in_valid <= 1'b0;
    end

    @(posedge clk_in);
    wait( oneled_ready == 1'b1);
    repeat(10) @(posedge clk_in);
    $finish;

end

ws2812_driver ws2812_driver_inst(
    .clk_in       (clk_in       ),
    .rst_n_in     (rst_n_in     ),

    .code_in      (code         ),
    .code_in_valid(code_valid   ),

    .ws2812_out   (ws2812_out   ),
    .ready_out    (driver_ready )
);

ws2812_oneled ws2812_oneled_inst (
    .clk_in         (clk_in      ),
    .rst_n_in       (rst_n_in    ),

    .grb_in         (grb_in      ),
    .grb_in_valid   (grb_in_valid),

    .driver_ready_in(driver_ready),

    .code_out       (code        ),
    .code_out_valid (code_valid  ),
    .ready_out      (oneled_ready)
);
endmodule