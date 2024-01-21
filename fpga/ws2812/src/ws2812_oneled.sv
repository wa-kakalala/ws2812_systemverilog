/**************************************
@ filename    : ws2812_oneled.sv
@ author      : yyrwkk
@ create time : 2024/01/17 20:51:11
@ version     : v1.0.0
**************************************/
module ws2812_oneled (
    input  logic         clk_in         ,
    input  logic         rst_n_in       ,

    input  logic [23:0]  grb_in         ,
    input  logic         grb_in_valid   ,

    input  logic         driver_ready_in,

    output logic         code_out       ,
    output logic         code_out_valid ,
    output logic         ready_out     
);

typedef enum {
    s_idle   ,
    s_wait   ,
    s_start  ,
    s_iter   
} state_e;

state_e curr_state           ;
state_e next_state           ;

logic [23:0] grb_in_reg      ;
logic [4:0]  iter            ;

always_ff @(posedge clk_in or negedge rst_n_in ) begin
    if( !rst_n_in ) begin
        grb_in_reg <= 'b0;
    end else if( grb_in_valid ) begin
        grb_in_reg <= grb_in;
    end else begin
        grb_in_reg <= grb_in_reg;
    end
end

always_ff @( posedge clk_in or negedge rst_n_in ) begin
    if( !rst_n_in ) begin
        curr_state <= s_idle;
    end else begin
        curr_state <= next_state;
    end
end

always_comb begin
    if( !rst_n_in ) begin
        next_state = s_idle;
    end else begin
        case( curr_state ) 
        s_idle : begin
            if( grb_in_valid == 1'b1 && ready_out == 1'b1) begin
                next_state = s_wait;
            end  else begin
                next_state = s_idle;
            end
        end
        s_wait : begin
            if( driver_ready_in == 1'b1 ) begin
                next_state = s_start;
            end else begin
                next_state = s_wait;
            end
        end
        s_start: begin
            next_state = s_iter;
        end
        s_iter : begin
            if( iter > 5'd0 ) begin
                next_state = s_wait;
            end else if( iter == 5'd0 && driver_ready_in == 1'b1 ) begin
                next_state = s_idle;
            end else begin
                next_state = s_iter;
            end
        end
        default: begin
            next_state = s_idle;
        end
        endcase
    end
end

assign ready_out = (curr_state == s_idle) ? 1'b1:1'b0;
always_ff @( posedge clk_in or negedge rst_n_in ) begin
    if( !rst_n_in ) begin
        iter <= 5'd23;
    end else begin
        iter <= iter;
        case(curr_state) 
        s_idle : begin
            iter <= 5'd23;
        end
        s_wait : begin
        end
        s_start: begin
            
        end
        s_iter : begin
            if( iter > 5'd0 ) begin
                iter <= iter - 1'b1;
            end else if( iter == 5'd0 && driver_ready_in == 1'b1 ) begin
                iter <= 5'd23;
            end else begin
                iter <= iter;
            end
        end
        default: begin

        end
        endcase
    end
end

always_comb begin
    if( !rst_n_in ) begin
        code_out = 1'b0;
        code_out_valid = 1'b0;
    end else if( curr_state == s_start ) begin
        code_out = grb_in_reg[iter];
        code_out_valid = 1'b1;
    end else begin
        code_out = 1'b0;
        code_out_valid = 1'b0;
    end
end

endmodule