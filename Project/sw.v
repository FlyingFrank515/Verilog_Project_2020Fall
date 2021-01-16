`include "BUFFER_TVF.v"
`include "PE.v"
`include "BUFFER_S.v"
`include "MAX.v"

module sw(clk, reset, valid, data_s, data_t, finish, max);
    
    // declartion of input and output
    input               clk;
    input               reset;
    input               valid;
    input [1:0]         data_s;
    input [1:0]         data_t;
    output              finish;
    output [11:0]       max;
    
    // --- MARCRO declartion for FSM ---
    parameter IDLE          = 2'b00;
    parameter CACULATING    = 2'b01;
    parameter OUTPUT        = 2'b11;

    //------------------------------------------------------------------
    // reg & wire
    
    // --- reg of this module(should be pushed) ---
    reg             finish,    next_finish;
    reg [1:0]       state,     next_state;
    reg [11:0]      count,     next_count;
    reg             init,      next_init;
    reg             changeS,   next_changeS;

    wire [11:0]     next_max_recursive;
    reg  [11:0]     max_recursive;

    // --- input for first PE ---
    wire [1:0]      S_in;
    wire [1:0]      T_in;
    wire [11:0]     V_in;
    wire [11:0]     F_in;
    
    // --- inner wire of PE ---
    wire  [1:0]     T_bus       [127:0];
    wire [11:0]     MAX_bus     [127:0];
    wire [11:0]     V_bus       [127:0];
    wire [11:0]     F_bus       [127:0];
    wire            changeS_bus [127:0];
    wire            init_bus    [127:0];

    //------------------------------------------------------------------
    // combinational part

    BUFFER BUF(
        // inputs
        .clk(clk),
        .rst(reset),
        .valid(valid),
        .count(count),
        .data_t_i(data_t),
        .data_t_last(T_bus[127]),
        .data_V_last(V_bus[127]),
        .data_F_last(F_bus[127]),

        // outputs
        .data_t_o(T_in),
        .V_o(V_in),
        .F_o(F_in)
    );

    BUFFER_S BUF_S(
        // inputs
        .clk(clk),
        .rst(reset),
        .valid(valid),
        .count(count),
        .data_s_i(data_s),
        
        // outputs
        .data_s_o(S_in)
    );
    
    genvar i;
    generate
        for(i = 0; i < 128 ; i = i+1) begin
            if(i == 0) begin
                PE P0(
                    // inputs
                    .clk(clk),
                    .rst(reset),
                    .changeS_in(changeS),
                    .S_in(S_in),
                    .T_in(T_in),
                    .MAX_in(12'd0),
                    .V_in(V_in),
                    .F_in(F_in),
                    .init_in(init),
                    
                    // outputs
                    .changeS_out(changeS_bus[i]),
                    .T_out(T_bus[i]),
                    .MAX_out(MAX_bus[i]),
                    .V_out(V_bus[i]),
                    .F_out(F_bus[i]),
                    .init_out(init_bus[i])
                );
            end
            else begin
                PE Pi(
                    // inputs
                    .clk(clk),
                    .rst(reset),
                    .changeS_in(changeS_bus[i-1]),
                    .S_in(S_in),
                    .T_in(T_bus[i-1]),
                    .MAX_in(MAX_bus[i-1]),
                    .V_in(V_bus[i-1]),
                    .F_in(F_bus[i-1]),
                    .init_in(init_bus[i-1]),
                    
                    //outputs
                    .changeS_out(changeS_bus[i]),
                    .T_out(T_bus[i]),
                    .MAX_out(MAX_bus[i]),
                    .V_out(V_bus[i]),
                    .F_out(F_bus[i]),
                    .init_out(init_bus[i])
                );      
            end
        end
    endgenerate
    
    // Outer MAX module
    // Use only 5 MAX in the PE, so need a outer MAX
    MAX M_recursive(next_max_recursive, MAX_bus[127], max_recursive);
    
    // The last MAX_bus and V_bus need to be compared at the end
    // because in the serial PE, the work above will be done in next stage of PE
    // However, last PE doesnt have PE in its next stage, so we should do it manually
    MAX M_final(max, max_recursive, V_bus[127]);

    always@(*) begin
        next_state = state;
        next_count = count;
        next_finish = finish;
        next_init = init;
        next_changeS = changeS;
        
        case(state)
            IDLE: begin
                if(valid) begin
                    next_state = CACULATING;
                    next_count = count + 1;
                    next_changeS = 1;
                    next_init = 1;
                end
                else begin
                    next_state = IDLE;
                end
            end
            
            CACULATING: begin
                next_count = count + 1;
                next_changeS = 0;
                if(count == 256) next_changeS = 1;
                if(count == 513) next_init = 0;
                if(count == 640) begin
                    next_state = OUTPUT;
                    next_finish = 1;
                end
                else next_state = CACULATING;
            end
            
            OUTPUT:begin
                next_state = IDLE;
                next_finish = 0;
                next_count = 0;
            end
            
            default:begin
                next_state = state;
            end
        endcase
    end

    //------------------------------------------------------------------
    // sequential part
    always@( posedge clk or posedge reset) begin
        if(reset) begin
            state <= IDLE;
            finish <= 0;
            count <= 0;
            init <= 0;
            changeS <= 0;
            max_recursive <= 0;
        end
        else begin
            state <= next_state;
            finish <= next_finish;
            count <= next_count;
            init <= next_init;
            changeS <= next_changeS;
            max_recursive <= next_max_recursive;         
        end
    end

endmodule



