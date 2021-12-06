`include "defines.vh"
module regfile(
    input wire clk,
    input wire [4:0] raddr1,
    output wire [31:0] rdata1,
    input wire [4:0] raddr2,
    output wire [31:0] rdata2,
    
    input wire we,
    input wire [4:0] waddr,
    input wire [31:0] wdata,

    input wire hi_r,
    input wire hi_we,
    input wire [31:0] hi_data,
    input wire lo_r,
    input wire lo_we,
    input wire [31:0] lo_data,
    output wire [31:0] hilo_data
);
    //自己家的hilo寄存器
    reg  [31:0] hi_o;
    reg  [31:0] lo_o;
    // write
    always @ (posedge clk) begin
        if (hi_we) begin
            hi_o <=  hi_data;
        end
    end
    always @ (posedge clk) begin
        if (lo_we) begin
            lo_o <= lo_data;
        end
    end
    //read
    assign hilo_data = (hi_r) ? hi_o 
                      :(lo_r) ? lo_o
                      : (32'b0);


    reg [31:0] reg_array [31:0];
    // write
    always @ (posedge clk) begin
        if (we && waddr!=5'b0) begin
            reg_array[waddr] <= wdata;
        end
    end

    // read out 1
    assign rdata1 = (raddr1 == 5'b0) ? 32'b0 : reg_array[raddr1];

    // read out2
    assign rdata2 = (raddr2 == 5'b0) ? 32'b0 : reg_array[raddr2];
endmodule