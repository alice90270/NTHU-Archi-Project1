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
module Simulator( clk_i, rst_i );

//Parameter
`define INSTR_NUM 256
`define ADD 6'h20
`define SUB 6'h22
`define AND 6'h24
`define OR 6'h25
`define SLT 6'h2a
`define ADDI 6'h08
`define LW 6'h23
`define SW 6'h2b
`define SLTI 6'h0a
`define BEQ 6'h04

//I/O ports
input clk_i;
input rst_i;  
//DO NOT CHANGE SIZE, NAME
reg [32-1:0] Instr_Mem [0:`INSTR_NUM-1];
reg [32-1:0] Data_Mem [0:1024-1];
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
reg [16-1:0]immdt;
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
		immdt = instr[15:0];
	end
endtask
//Main function
always @(posedge clk_i or negedge rst_i) begin
	//initial
	if(rst_i == 0) begin
		for(i=0; i<32; i=i+1)
			Reg_File[i] = 32'd0;
		for(i=0; i<1024; i=i+1)
			Data_Mem[i] = 32'd0;		
		pc_addr = 32'd0;
	end
	else begin
		instr = Instr_Mem[pc_addr/4];
		decode;
		if(op == 6'd0 && rd!=0)begin //R-type
			case(func)
				`ADD: begin
					Reg_File[rd] = Reg_File[rs] + Reg_File[rt];
				end
				`SUB: begin
					Reg_File[rd] = Reg_File[rs] - Reg_File[rt];
				end
				`AND: begin
					Reg_File[rd] = Reg_File[rs] & Reg_File[rt];
				end
				`OR: begin
					Reg_File[rd] = Reg_File[rs] | Reg_File[rt];
				end
				`SLT: begin
					if(Reg_File[rs] < Reg_File[rt])	
						Reg_File[rd]= 1;
					else	
						Reg_File[rd]= 0;
				end
			endcase
		end
		else begin //I-type
			case(op)
				`ADDI: begin
					if(rt!=0)
						Reg_File[rt] = Reg_File[rs] + $signed(immdt);
				end
				`LW: begin
					if($signed(immdt)%4==0 && rt!=0)
						Reg_File[rt] = Data_Mem[(Reg_File[rs] + $signed(immdt))/4];
				end
				`SW: begin
					if({immdt[0],immdt[1]}==0)
						Data_Mem[(Reg_File[rs] + $signed(immdt))/4] = Reg_File[rt];
				end
				`SLTI: begin
					if(Reg_File[rs] < $signed(immdt))	Reg_File[rt]= 1;
					else 	Reg_File[rt]= 0;					
				end
				`BEQ: begin
					if(Reg_File[rt] == Reg_File[rs])	
						if(pc_addr + {{14{immdt[15]}},$signed(immdt)*4}<256*4) 
							if(pc_addr + {{14{immdt[15]}},$signed(immdt)*4}>=0) 
								pc_addr = pc_addr + {{14{immdt[15]}},$signed(immdt)*4};
					end
			endcase	
		end
		if((pc_addr + 32'd4)<256*4)
			if((pc_addr + 32'd4)>=0)
				pc_addr = pc_addr + 32'd4;
	end
end
endmodule