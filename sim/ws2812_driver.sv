module ws2812_driver # (
    parameter V_0_HIGH    =   8'd3 ,
    parameter V_0_LOW     =   8'd3 ,
    parameter V_1_HIGH    =   8'd3 ,
    parameter V_1_LOW     =   8'd3 ,
    parameter COUNTER_W   =   8'd10
)(
    input  logic  clk_in       ,
    input  logic  rst_n_in     ,

    input  logic  code_in      ,
    input  logic  code_in_valid,

    output logic  ws2812_out   ,
    output logic  ready_out  
);

logic [COUNTER_W-1:0] counter;

typedef enum {  
    S_OUT_IDLE ,
    S_OUT_HIGH ,
    S_OUT_LOW
} ws2812_e;

ws2812_e curr_state;
ws2812_e next_state;

logic    code_in_reg      ;
always_ff@(posedge clk_in or negedge rst_n_in) begin
    if( !rst_n_in ) begin
        code_in_reg <= 1'b0;
    end else if(code_in_valid && ready_out ) begin 
        code_in_reg <= code_in;
    end else begin
        code_in_reg <= code_in_reg;
    end
end

// the first segment of fsm
always_ff @(posedge clk_in or negedge rst_n_in ) begin
    if( !rst_n_in ) begin
        curr_state <= S_OUT_IDLE;
    end else begin
        curr_state <= next_state;
    end
end

// the second segment of fsm
always_comb begin
    if( !rst_n_in ) begin
        next_state = S_OUT_IDLE;
    end else begin
        case(curr_state) 
        S_OUT_IDLE : begin  
            if( code_in_valid == 1'b1 && ready_out == 1'b1) begin
                next_state = S_OUT_HIGH;
            end else begin
                next_state = S_OUT_IDLE;
            end
        end
        S_OUT_HIGH : begin
            if( ( (code_in_reg == 1'b0)&& (counter == V_0_HIGH -1'b1) ) || ( (code_in_reg == 1'b1)&& (counter == V_1_HIGH -1'b1) ) ) begin
                next_state = S_OUT_LOW;
            end else begin
                next_state = S_OUT_HIGH;
            end
        end
        S_OUT_LOW  : begin
            if( ( (code_in_reg == 1'b0)&& (counter == V_0_LOW -1'b1) ) || ( (code_in_reg == 1'b1)&& (counter == V_1_LOW -1'b1) ) ) begin
                next_state = S_OUT_IDLE;
            end else begin
                next_state = S_OUT_LOW;
            end
        end
        default: begin
            next_state = S_OUT_IDLE;
        end
        endcase
    end
end

assign ready_out = (curr_state == S_OUT_IDLE )? 1'b1 : 1'b0;
// the third segment of fsm
always_ff @(posedge clk_in or negedge rst_n_in) begin
    if( !rst_n_in ) begin
        ws2812_out <= 1'b0;
        counter    <= 'b0 ;
    end else begin
        case( curr_state )
        S_OUT_IDLE : begin
            ws2812_out <= 1'b0;
            counter    <= 'b0;
        end
        S_OUT_HIGH : begin
            ws2812_out <= 1'b1;
            if( (code_in_reg == 1'b0) && (counter == V_0_HIGH-1'b1 ) ) begin
                counter <= 'b0;
            end else if( (code_in_reg == 1'b1) && (counter == V_1_HIGH-1'b1 ) ) begin
                counter <= 'b0;
            end else begin
                counter <= counter + 1'b1;
            end
        end
        S_OUT_LOW  : begin
            ws2812_out <= 1'b0;
            if( (code_in_reg == 1'b0) && (counter == V_0_LOW-1'b1 ) ) begin
                counter <= 'b0;
            end else if( (code_in_reg == 1'b1) && (counter == V_1_LOW-1'b1 ) ) begin
                counter <= 'b0;
            end else begin
                counter <= counter + 1'b1;
            end
        end
        default: begin
            ws2812_out <= 1'b0;
            counter    <= 'b0 ;
        end
        endcase
    end
end

endmodule