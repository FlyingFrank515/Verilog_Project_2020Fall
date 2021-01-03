// this module will pass the value of T, V, F in smithwaterman algorithm

module BUFFER_S(
    input clk,
    input rst,
    input valid,
    input [11:0] count,
    input [1:0] data_s_i,
    output reg [1:0] data_s_o
);

    parameter IDLE               = 2'b00;
    parameter GIVE_IN            = 2'b01;
    parameter WRITE_BUF          = 2'b10;
    parameter GIVE_BUF           = 2'b11;
    
    reg [1:0]  buffer_S [127:0];

    reg [1:0] state, next_state;
    reg [1:0] next_data_s_o;
    
    // sequential part
    integer i;
    always@( posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
            data_s_o <= 0;
        end
        else begin
            state <= next_state;
            data_s_o <= next_data_s_o;

            for(i=0; i < 127; i=i+1) begin
                buffer_S[i] <= buffer_S[i+1];
            end
            buffer_S[127] <= data_s_i;
        end
    end
    
    // combinational part
    always@(*) begin
        next_state = state;
        next_data_s_o = data_s_o;
        case(state)
            IDLE: begin
                if(valid) begin
                    next_state = GIVE_IN;
                    next_data_s_o = data_s_i;
                end
                else begin
                    next_state = IDLE;
                    next_data_s_o = 0;
                end
            end
            
            GIVE_IN: begin
                next_data_s_o = data_s_i;
                
                if(count == 128) begin
                    next_state = WRITE_BUF;
                end
            end

            WRITE_BUF: begin
                if(count == 256) begin
                    next_state = GIVE_BUF;
                    next_data_s_o = buffer_S[0];
                end
            end
            
            GIVE_BUF: begin
                next_data_s_o = buffer_S[0];
                if(count == 384) begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = state;
            end

        endcase
    end
endmodule