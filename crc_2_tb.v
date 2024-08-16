`timescale 1ns/1ns
`include "crc_2.v"
module crc_tb();
reg [31:0] data_in;
reg data_in_valid;
wire data_in_ready;
reg [5:0] poly;
wire poly_in_ready;
reg poly_in_valid;
reg reset;
//reg inready;
reg clk=0;;
reg outready;
wire [4:0] out;
wire outvalid;
crc2 seq(.clk(clk),.reset(reset),.data_in(data_in),.poly(poly),.data_in_valid(data_in_valid),.data_in_ready(data_in_ready),.poly_in_ready(poly_in_ready),
.poly_in_valid(poly_in_valid),.out(out),.outvalid(outvalid),.outready(outready));

//according to number of input test cases in input file [3:0] should be changed suitably in data12 poly12 outdata
reg [31:0] data12 [3:0];
reg [5:0] poly12 [3:0];
reg [4:0] outdata [3:0];
reg [2:0] i;

initial
begin
    forever
    begin
        #5 clk=~(clk);
    end
end

initial
begin
    $readmemh("data_input.txt",data12);//please enter data_in in this file in hex format
    $readmemb("poly_input.txt",poly12);//enter polynomial_data in this file in binary format
end

initial
begin
    $dumpfile("crcnew2.vcd");
$dumpvars(0,crc_tb);
for(i=0;i<4;i++)
begin
reset=1'b0; data_in=data12[i]; poly=poly12[i]; outready=1'b0;//change i also suitably according to number of input test cases
#12 reset=1'b1;
//#10 inready=1'b1;
#10 data_in_valid=1'b1;
#10 poly_in_valid=1'b1;
outready=1'b1;
if(i==0)begin
#196 
outdata[i]=out;end
else
begin
    #178 outdata[i]=out;end
end
$writememb("data_out.txt",outdata);
#10 $finish;
end
endmodule