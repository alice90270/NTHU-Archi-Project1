`timescale 1ns / 1ps
//Subject:     Architecture Project1 - Simulator
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Simulator(
        clk_i,
		rst_i
		);

//Parameter
`define INSTR_NUM 256
`define ADD 6'h20

//I/O ports
input clk_i;
input rst_i;  

//DO NOT CHANGE SIZE, NAME
reg [32-1:0] Instr_Mem [0:`INSTR_NUM-1];
reg signed [32-1:0] Reg_File [0:32-1];

//Register
reg [32-1:0] instr;
reg [32-1:0] pc_addr;
reg [6-1:0]op;
reg [5-1:0]rs;
reg [5-1:0]rt;
reg [5-1:0]rd;
reg [5-1:0]shamt;
reg [6-1:0]func;
integer i;

//Task
task decode;
	begin
		op = instr[31:26];
		rs = instr[25:21];
		rt = instr[20:16];
		rd = instr[15:11];
		shamt = instr[10:6];
		func = instr[5:0];
	end
endtask

//Main function
always @(posedge clk_i or negedge rst_i) begin
	if(rst_i == 0) begin
		for(i=0; i<32; i=i+1)
			Reg_File[i] = 32'd0;	
		pc_addr = 32'd0;
	end
	else begin
		instr = Instr_Mem[pc_addr/4];
		decode;
		if(op == 6'd0)begin //R-type
			case(func)
				`ADD: begin
					Reg_File[rd] = Reg_File[rs] + Reg_File[rt];
				end
			endcase
		end
		else begin //I-type
			
		end
		pc_addr = pc_addr + 32'd4;
	end
end
endmodule