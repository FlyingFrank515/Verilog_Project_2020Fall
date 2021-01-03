// this module will pass the value of T, V, F in smithwaterman algorithm

module BUFFER(
    input clk,
    input rst,
    input valid,
    input [11:0] count,
    input [1:0] data_t_i,
    input [1:0] data_t_last,
    input [11:0] data_V_last,
    input [11:0] data_F_last,
    
    output reg [1:0] data_t_o,
    output reg [11:0] V_o,
    output reg [11:0] F_o
);

    parameter IDLE               = 2'b00;
    parameter DIRECT_GIVE_IN     = 2'b01;
    parameter GIVE_IN_WRITE_BUF  = 2'b10;
    parameter GIVE_BUF_WRITE_BUF = 2'b11;
    
    reg [1:0]  buffer_T [127:0];
    reg [11:0] buffer_V [127:0];
    reg [11:0] buffer_F [127:0];

    reg [1:0] state, next_state;
    reg [1:0] next_data_t_o;
    reg [11:0] next_V_o;
    reg [11:0] next_F_o;
    
    // sequential part
    integer i;
    always@( posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
            data_t_o <= 0;
            V_o <= 0;
            F_o <= 0;

        end
        else begin
            state <= next_state;
            data_t_o <= next_data_t_o;
            V_o <= next_V_o;
            F_o <= next_F_o;
            
            for(i=0; i < 127; i=i+1) begin
                buffer_T[i] <= buffer_T[i+1];
                buffer_V[i] <= buffer_V[i+1];
                buffer_F[i] <= buffer_F[i+1];
            end
            
            buffer_T[127] <= data_t_last;
            buffer_V[127] <= data_V_last;
            buffer_F[127] <= data_F_last;
        end
    end
    
    // combinational part
    always@(*) begin
        next_state = state;
        next_data_t_o = data_t_o;
        next_V_o = V_o;
        next_F_o = F_o;
        
        case(state)
            IDLE: begin
                if(valid) begin
                    next_state = DIRECT_GIVE_IN ;
                    next_data_t_o = data_t_i;
                    next_V_o = 12'd0;
                    next_F_o = 12'd0;
                end
                else begin
                    next_state = IDLE;
                    next_data_t_o = 0;
                    next_V_o = 12'd0;
                    next_F_o = 12'd0;
                end
            end
            
            DIRECT_GIVE_IN: begin
                next_data_t_o = data_t_i;
                next_V_o = 12'd0;
                next_F_o = 12'd0;
                
                if(count == 128) begin
                    next_state = GIVE_IN_WRITE_BUF;
                end
            end

            GIVE_IN_WRITE_BUF: begin
                next_data_t_o = data_t_i;
                next_V_o = 12'd0;
                next_F_o = 12'd0;
                
                if(count == 256) begin
                    next_state = GIVE_BUF_WRITE_BUF;
                    next_data_t_o = buffer_T[0];
                    next_V_o = buffer_V[0];
                    next_F_o = buffer_F[0];
                end
            end
            
            GIVE_BUF_WRITE_BUF: begin
                next_data_t_o = buffer_T[0];
                next_V_o = buffer_V[0];
                next_F_o = buffer_F[0];

                if(count == 512) begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = state;
            end
        endcase
    end
endmodule