/**
 * @Author:zht、szw
 * @Date: 2021-12-10
 */

`include "lib/defines.vh"

module mymul(
	input wire rst,							//复位
	input wire clk,							//时钟
	input wire signed_mul_i,				//是否为有符号乘法运算，1位有符号
	input wire[31:0] a_o,				//被乘数
	input wire[31:0] b_o,				//乘数
	input wire start_i,						//是否开始乘法运算
	output reg[63:0] result_o,				//乘法运算结果
	output reg ready_o						//乘法运算是否结束
);
reg [31:0] temp_opa,temp_opb;
reg [63:0] pv;
reg [63:0] ap;
reg [5:0] i;//进行到第几位
reg [1:0] state;// 00:空闲  10:开始   11:结束

always @ (posedge clk) begin
		if (rst) begin
			state <= `MulFree;
			result_o <= {`ZeroWord,`ZeroWord};
			ready_o <= `MulResultNotReady;
		end else begin
			case(state)			
				`MulFree: begin			//乘法器空闲
                    if (start_i== `MulStart) begin
                        state <= `MulOn;
                        i <= 6'b00_0000;
					    if(signed_mul_i == 1'b1 && a_o[31] == 1'b1) begin			//被乘数为负数
							temp_opa = ~a_o + 1;
						end else begin
							temp_opa = a_o;
						end
						if(signed_mul_i == 1'b1 && b_o[31] == 1'b1 ) begin			//乘数除数为负数
								temp_opb = ~b_o + 1;
						end else begin
							temp_opb = b_o;
						end
                        ap <= {32'b0,temp_opa};
						ready_o <= `MulResultNotReady;
						result_o <= {`ZeroWord, `ZeroWord};
                        pv <= 64'b0;
                    end
				end				
				
				`MulOn: begin				//乘法运算
                        if(i != 6'b100000) begin
                            if(temp_opb[0]==1'b1) begin
								pv <= pv + ap;
								ap <= {ap[62:0],1'b0};
								temp_opb <= {1'b0,temp_opb[31:1]};
							end
							else begin 
                                ap <= {ap[62:0],1'b0};
								temp_opb <= {1'b0,temp_opb[31:1]};
							end 	
                            i <= i + 1;
                        end
						else begin
							if ((signed_mul_i == 1'b1) && ((a_o[31] ^ b_o[31]) == 1'b1))begin
							    pv <= ~pv + 1;
							end
							state <= `MulEnd;
							i <= 6'b00_0000;
						end
					   
				end
				
				`MulEnd: begin			//乘法结束
					result_o <= pv;
					ready_o <= `MulResultReady;
					if (start_i == `MulStop) begin
						state <= `MulFree;
						ready_o <= `MulResultNotReady;
						result_o <= {`ZeroWord, `ZeroWord};
					end
				end
				
			endcase
		end
	end

endmodule
