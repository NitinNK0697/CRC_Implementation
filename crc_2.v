
module crc2(input [31:0] data_in,
input data_in_valid,
input poly_in_valid,
output reg poly_in_ready,
output reg data_in_ready,
output reg outvalid,
input outready,
input reset,
input [5:0] poly,
input clk,
output [4:0] out);
wire t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20,t21,t22,t23;
reg [31:0] dbuf;
reg [5:0] gbuf;
reg [4:0] obuf,temp;
reg dreset;
reg din0,din1;
D x0(.clk(clk),.in(t2),.out(t3),.reset(dreset));
D x1(.clk(clk),.in(t4),.out(t5),.reset(dreset));
D x2(.clk(clk),.in(t6),.out(t7),.reset(dreset));
D x3(.clk(clk),.in(t8),.out(t9),.reset(dreset));
D x4(.clk(clk),.in(t10),.out(t11),.reset(dreset));
reg data_flag,poly_flag;
reg[1:0] state,next;
parameter S0=2'd0,S1=2'd1,S2=2'd2,S3=2'd3;

//upper half of polynomial multiplication
assign t12=(t1 & gbuf[1]);
assign t13=(t1 & gbuf[2]);
assign t14=(t1 & gbuf[3]);
assign t15=(t1 & gbuf[4]);

//lower half of polynomial multiplication
assign t16=(t2 & gbuf[1]);
assign t17=(t2 & gbuf[2]);
assign t18=(t2 & gbuf[3]);
assign t19=(t2 & gbuf[4]);

assign t20=t3^t12;
assign t21=t5^t13;
assign t22=t7^t14;
assign t23=t9^t15;
assign t1=t11^din0;

assign t4=t1^t16;
assign t6=t20^t17;
assign t8=t21^t18;
assign t10=t22^t19;
assign t2=t23^din1;

reg [5:0] i;//variable to store count values

//combinational block to calculate next state of system
always@(*)
begin
    case(state)
    
    S0://reset state where inready and outvalid signals are initialized and valid 
    //input message data and polynomial is copied into variable.
    begin
        dreset=1'b1;
        outvalid=1'b0;
        obuf=5'bxxxxx;
        data_in_ready=1'b1;
        poly_in_ready=1'b1;
        dbuf=(data_in_ready & data_in_valid)?data_in:32'hxxxx;
        data_flag=(data_in_ready & data_in_valid)?1'b1:1'b0;//data_flag high when both data_valid and data_ready high
        gbuf=(poly_in_ready & poly_in_valid)?poly:6'bxxxxxx;
        poly_flag=(poly_in_ready & poly_in_valid)?1'b1:1'b0;//poly_flag high when both poly_valid and poly_ready high
        next=(data_flag & poly_flag)?S1:S0;//state changes when both data_flag and poly_flag are high
    end
    
    S1:
    begin
        data_flag=1'b0;
        poly_flag=1'b0;
        data_in_ready=1'b0;
        poly_in_ready=1'b0;
        next=S2;
    end
    
    S2://state in which complete computation of crc is done
    begin
        dreset=1'b0;
        next=(i==6'd16)?S3:S2;
    end
    
    S3://output crc is copied to a variable 
    begin
        temp={t11,t9,t7,t5,t3};
        outvalid=1'b1;
        obuf=(outready & outvalid)?temp:obuf;
        next=(outready & outvalid)?S0:S3;
    end

    // S4://   asserting outvalid signal high and wait for outready signal from the slave block 
    // begin
    //     outvalid=1'b1;
    //     next=(outready & outvalid)?S5:S4;
    // end
    
    // S4://data is put onto the output data bus
    // begin
    //     obuf=temp;
    //     next=S0;
    // end
    default:state=S0;
    endcase
end

//sequential block to change state at clock edge
always@(posedge clk)
begin
    
    if(reset==0)
    state<=S0;
    else
    begin
        if(next==S1)
        i<=0;
        else if(next==S2)
        i<=i+1;
        din0<=dbuf[31-(2*i)];
        din1<=dbuf[31-(2*i+1)];
        state<=next;
    end
end
assign out=(outvalid & outready)?obuf:5'bxxxxx ;

endmodule

//D flop module
module D(input clk,
input reset,
input in,
output out);
reg out;
always@(posedge clk)
begin
    
    if(reset==1)
    out<=1'b0;
    else
    out<=in;
end
endmodule