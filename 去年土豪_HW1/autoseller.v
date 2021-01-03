module autoseller(clk, reset, enable_i, money_i, drinktype_i, ready_o, enable_o, change_o, drink_o);

input clk,reset,enable_i;
input [5:0] money_i; 
input [1:0] drinktype_i; 

output ready_o;
output enable_o;
output [5:0] change_o;
output [1:0] drink_o;

reg ready_o;
reg enable_o;
reg [5:0] change_o;
reg [1:0] drink_o;

parameter NOTHING = 2'b00;
parameter COKE    = 2'b01;
parameter TEA     = 2'b10;
parameter SODA    = 2'b11;

parameter NOTHING_c = 6'd0;
parameter COKE_c    = 6'd30;
parameter TEA_c     = 6'd20;
parameter SODA_c    = 6'd15;

parameter IDLE  = 2'b00;
parameter READY = 2'b01;
parameter DONE  = 2'b10;

reg [1:0] state, next_state;
reg [5:0] cost;

// Sequential part
always @(posedge clk or posedge reset) begin
    if(reset) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

//Combinational part
always @(*) begin
    case(state)
        IDLE:begin //!reset && !ready_o
            if(!reset) begin
                next_state = READY;
                cost = NOTHING_c;
                enable_o = 1'b0;
                change_o = NOTHING_c;
                drink_o = NOTHING;
            end
            else begin
                next_state = IDLE;
                cost = NOTHING_c;
                enable_o = 1'b0;
                change_o = NOTHING_c;
                drink_o = NOTHING;
            end
            ready_o = 1'b1;
        end
        READY:begin //!reset && ready_o
            ready_o = 1'b0;
            if(enable_i) begin
                next_state = DONE; 
                enable_o = 1'b1;
                case(drinktype_i)
                    NOTHING:begin
                        cost = NOTHING_c;
                    end
                    COKE:begin
                        cost = COKE_c;
                    end
                    TEA:begin
                        cost = TEA_c;
                    end
                    SODA:begin
                        cost = SODA_c;
                    end
                    default:begin
                        cost = NOTHING_c;
                    end
                endcase
                if(cost > money_i) begin
                    change_o = money_i;
                    drink_o = NOTHING;
                end
                else begin
                    change_o = money_i - cost;
                    drink_o = drinktype_i;
                end
            end
            else begin
                next_state = DONE;
                cost = NOTHING_c;
                enable_o = 1'b0;
                change_o = NOTHING_c;
                drink_o = NOTHING; 
            end
        end
        DONE:begin
            next_state = IDLE;
            cost = NOTHING_c;
            enable_o = 1'b0;
            change_o = NOTHING_c;
            drink_o = NOTHING;
            ready_o = 1'b0;
        end
        default:begin
            next_state = state;
            cost = NOTHING_c;
            enable_o = 1'b0;
            change_o = NOTHING_c;
            drink_o = NOTHING;
            ready_o = 1'b0;
        end
    endcase
end

endmodule
