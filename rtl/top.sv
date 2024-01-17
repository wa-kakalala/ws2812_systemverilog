/**************************************
@ filename    : top.v
@ author      : yyrwkk
@ create time : 2024/01/17 23:20:21
@ version     : v1.0.0
**************************************/
module top (
    input  logic clk_in    ,
    input  logic rst_n_in  ,

    output logic ws2812_out 
);

logic [23:0] grb_code            ;
logic        grb_code_valid      ;

logic        counter             ;

logic         code               ; 
logic         code_valid         ; 
       
logic         driver_ready       ;

logic         oneled_ready       ;

always_ff @ ( posedge clk_in or negedge rst_n_in)begin
    if( !rst_n_in ) begin
        grb_code <= 24'b0;
        grb_code_valid <= 1'b0;
        counter <= 1'b0;
    end else if( counter == 1'b0) begin
        grb_code <= {8'd255,8'd0,8'd0};
        grb_code_valid <=  1'b1;   
        counter <= 1'b1;
    end else begin
        grb_code <= grb_code;
        grb_code_valid <=  1'b0;   
        counter <= counter;
    end
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

    .grb_in         (grb_code      ),
    .grb_in_valid   (grb_code_valid),

    .driver_ready_in(driver_ready),

    .code_out       (code        ),
    .code_out_valid (code_valid  ),
    .ready_out      (oneled_ready)
);


endmodule