`include "lib/defines.vh"
module CTRL(
    input wire rst,
    input wire stallreq_from_ex,
    input wire stallreq_from_id,

    // output reg flush,
    // output reg [31:0] new_pc,
    output reg [`StallBus-1:0] stall
);  

    //stall[0]为1表示没有暂停
    //stall[1]为1 if段暂停
    //stall[2]为1 id段暂停
    //stall[3]为1 ex段暂停
    //stall[4]为1 mem段暂停
    //stall[5]为1 wb段暂停
    always @ (*) begin
        if (rst) begin
            stall <= `StallBus'b0;
        end
        else if(stallreq_from_ex == 1'b1) begin
            stall <= 6'b001111;
        end
        else if(stallreq_from_id == 1'b1) begin
            stall <= 6'b000111;
        end else begin 
            stall <= 6'b000000;
        end
    end
    
endmodule