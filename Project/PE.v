// module: PE(processing element)
// function of this module:
// finish one calculation of one node in Smith-Waterman Algorithm and going down 

`include "LUT.v"
`include "MAX.v"

module PE(clk,  rst, changeS_in,  S_in,   T_in,   MAX_in,     V_in,   F_in,   init_in,
                     changeS_out,         T_out,  MAX_out,    V_out,  F_out,  init_out);
    // declartion of input and output
    input           clk;            // clk signal
    input           rst;            // reset signal
    input           changeS_in;     // control whether S in PE should be changed
                                    // change when this PE change its column
    input [1:0]     S_in;           // input data of S(not need to be used)
    input [1:0]     T_in;           // input data of T
    input [11:0]    MAX_in;         // MAX of previous PE
    input [11:0]    V_in;           // input data of V
    input [11:0]    F_in;           // input data of F
    input           init_in;        // determine whether this PE is working
    
    output reg          changeS_out;// transmit changeS to next PE
    output reg [1:0]    T_out;      // transmit T to next PR
    output reg [11:0]   MAX_out;    // transmit MAX in this PE to next PE
    output reg [11:0]   V_out;      // transmit V in this PE to next PE
    output reg [11:0]   F_out;      // transmit F in this PE to next PE
    output reg          init_out;   // transmit init in this PE to next PE
    
    // declartion of reg and wire
    wire [1:0]  S_signal;
    wire [11:0] LUT;
    wire [11:0] MO1;
    wire [11:0] MO2;
    wire [11:0] MO3;
    wire [11:0] MO4;
    wire [11:0] MO5;
    wire [11:0] MO6;
    wire [11:0] E_out_minus_beta;
    wire [11:0] V_out_minus_alpha;
    wire [11:0] V_in_minus_alpha;
    wire [11:0] F_in_minus_beta;
    wire [11:0] V_diag_plus_LUT;
    wire [11:0] V_signal;
    reg  [11:0] V_diag;
    reg  [11:0] E_out;
    reg  [1:0] S_out;

    parameter alpha = -12'sd7;
    parameter beta  = -12'sd3;

    // connection
    assign S_signal             = changeS_in ? S_in : S_out;
    assign E_out_minus_beta     = (E_out + beta);
    assign V_out_minus_alpha    = (V_out + alpha);
    assign V_in_minus_alpha     = (V_in + alpha);
    assign F_in_minus_beta      = (F_in + beta);
    assign V_diag_plus_LUT      = V_diag + LUT;
    assign V_signal             = MO6[11] ? 12'd0 : MO6;
    
    // --- combinational part ---
    LUT L1(
        .OUTPUT (LUT),
        .Si     (S_signal),
        .Tj     (T_in)
    );
    MAX M1(
        .OUTPUT (MO1), 
        .A      (MAX_in),
        .B      (V_out)
    );
    MAX M2(
        .OUTPUT (MO2), 
        .A      (MO1),
        .B      (MAX_out)
    );
    MAX M3(
        .OUTPUT (MO3), 
        .A      (E_out_minus_beta),
        .B      (V_out_minus_alpha)
    );
    MAX M4(
        .OUTPUT (MO4), 
        .A      (V_in_minus_alpha),
        .B      (F_in_minus_beta)
    );
    MAX M5(
        .OUTPUT (MO5), 
        .A      (MO3),
        .B      (MO4)
    );
    MAX M6(
        .OUTPUT (MO6), 
        .A      (V_diag_plus_LUT),
        .B      (MO5)
    );
    

    // --- sequential part ---
    always@(posedge clk or posedge rst) begin
        if(rst) begin 
            V_diag  <= 0;
            S_out   <= 0;
            T_out   <= 0;
            MAX_out <= 0;
            E_out   <= 0;
            V_out   <= 0;
            F_out   <= 0;
            init_out<= 0;
            changeS_out <= 0;
        end
        else begin
            if(init_in) begin
                V_diag  <= V_in;
                S_out   <= S_signal;
                T_out   <= T_in;
                MAX_out <= MO2;
                E_out   <= MO3;
                F_out   <= MO4;
                V_out   <= V_signal;
                init_out<= init_in;
                changeS_out <= changeS_in;
            end
            else begin
                V_diag  <= 0;
                S_out   <= S_signal;
                T_out   <= T_in;
                MAX_out <= 0;
                E_out   <= 12'b100100000000; // aproxiamately -INF
                F_out   <= 12'b100100000000; // aproxiamately -INF
                V_out   <= 0;
                init_out<= init_in;
                changeS_out <= changeS_in;
            end
        end
    end     
endmodule