module SET (clk , rst, en, central, radius, busy, valid, candidate );
// --- Input/Output declartion ---
input clk, rst;
input en;
input [7:0] central;
input [3:0] radius;
output busy;
output valid;
output [7:0] candidate;

reg busy, next_busy;
reg valid, next_valid;
reg [7:0] candidate, next_candidate;

// --- MARCRO declartion for FSM ---
parameter IDLE          = 2'b00;
parameter CACULATING    = 2'b10;
parameter OUTPUT        = 2'b11;

// --- Wire/Reg declartion ---
reg [1:0] state, next_state;
reg signed [3:0] i, next_i, x_c, next_x_c;
reg signed [3:0] j, next_j, y_c, next_y_c; 
reg [8:0] r_square, next_r_square;
reg [8:0] distance, next_distance;
reg signed [3:0] LEFT, RIGHT, TOP, BOTTOM;
reg signed [3:0] next_LEFT, next_RIGHT, next_TOP, next_BOTTOM;

reg [7:0] dx_square;
reg [7:0] dy_square;
reg [4:0] r;
reg signed [5:0] x1, x2, y1, y2;


// -------------------------------------
//             Sequential Part
// -------------------------------------
always@(posedge clk or posedge rst) begin
    if(rst) begin
        state <= IDLE;
        busy <= 1'd0;
        valid <= 1'd0;
        candidate <= 8'd0;
        i <= 4'd0;
        j <= 4'd0;
        x_c <= 4'd0;
        y_c <= 4'd0;
        r_square <= 9'd0;
        dx_square <= 8'd0;
        dy_square <= 8'd0;
        distance <= 9'd0;
        
        LEFT <= 4'd0;
        RIGHT <= 4'd0;
        TOP <= 4'd0;
        BOTTOM <= 4'd0;

    end
    else begin
        state <= next_state;
        busy <= next_busy;
        valid <= next_valid;
        candidate <= next_candidate;
        i <= next_i;
        j <= next_j;
        x_c <= next_x_c;
        y_c <= next_y_c;
        r_square <= next_r_square;
        distance <= next_distance;
        
        LEFT <= next_LEFT;
        RIGHT <= next_RIGHT;
        TOP <= next_TOP;
        BOTTOM <= next_BOTTOM;
    end
end
// -------------------------------------
//           Combinational Part
// -------------------------------------
always@(*) begin
    next_state = state;
    next_busy = busy;
    next_valid = valid;
    next_candidate = candidate;
    next_i = i;
    next_j = j;
    next_x_c = x_c;
    next_y_c = y_c;
    next_r_square = r_square;
    next_distance = distance;

    next_LEFT = LEFT;
    next_RIGHT = RIGHT;
    next_TOP = TOP;
    next_BOTTOM = BOTTOM;
    
    case(state)
        IDLE: begin
            if(en && !busy) begin
                next_state = CACULATING;
                next_busy = 1'd1;
                next_r_square = radius * radius;
                next_x_c = central[7:4];
                next_y_c = central[3:0];
                next_candidate = 8'd0;
                
                r = radius;
                x1 = next_x_c - $signed(r);
                next_LEFT = (x1 < -6'sd7) ? (-4'sd7) : x1;
                x2 = next_x_c + $signed(r);
                next_RIGHT = (x2 > 6'sd7) ? (4'sd7) : x2;
                y1 = next_y_c + $signed(r);
                next_TOP = (y1 > 6'sd7) ? (4'sd7) : y1;
                y2 = next_y_c - $signed(r);
                next_BOTTOM = (y2 < -6'sd7) ? (-4'sd7) : y2;
                
                next_i = next_LEFT;
                next_j = next_BOTTOM;
                
            end
            else begin
                next_state = IDLE;
                next_busy = 1'd0;
                next_valid = 1'd0;
            end
        end
        
        CACULATING:begin
            dx_square = (x_c - i)**2;
            dy_square = (y_c - j)**2;
            distance = dx_square + dy_square;
            next_candidate = (distance < r_square) ? (candidate+1) : candidate;
            
            if(j == TOP && i == RIGHT) begin
                next_state = OUTPUT;
            end
            else begin
                next_j = (j != TOP) ? (j+1) : BOTTOM;
                next_i = (j == TOP) ? (i+1) : i;
            end
        end

        OUTPUT:begin
            next_state = IDLE;
            next_valid = 1'd1;
        end
        default:begin
            next_state = state;
        end
    endcase
end

endmodule


