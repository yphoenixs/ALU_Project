module ALU_REF #(parameter WIDTH = 8,parameter C_WIDTH = 4)(

  input [WIDTH-1:0] OPA,OPB,
  input CLK,RST,CE,MODE,CIN,
  input [1:0]IN_VALID,
  input [C_WIDTH-1:0] CMD,
  output reg[WIDTH :0]RES = {WIDTH{1'b0}}, 
  output reg[(2*WIDTH-1) : 0]MUL_RES = {2*WIDTH{1'b0}},
  output reg COUT = 1'b0,
  output reg OFLOW = 1'b0,
  output reg G = 1'b0,
  output reg E = 1'b0,
  output reg L = 1'b0,
  output reg ERR = 1'b0);
  
  reg signed [WIDTH-1:0] sOPA = {WIDTH{1'b0}} , sOPB= {WIDTH{1'b0}};
  reg signed [WIDTH:0] sRES = {WIDTH+1{1'b0}};
  
  reg [WIDTH-1:0]OPA_T={WIDTH{1'b0}} ,OPB_T= {WIDTH{1'b0}};
  reg [C_WIDTH-1:0]CMD_T = {C_WIDTH{1'b0}};
  reg [1:0]IN_VALID_T = 2'b00;
  reg CIN_T = 1'b0;
  reg MODE_T = 1'b0;

  reg [WIDTH-1:0] OPA_1= {WIDTH{1'b0}}, OPB_1= {WIDTH{1'b0}};
  reg [C_WIDTH-1:0]CMD_1= {C_WIDTH{1'b0}};
  reg [1:0]IN_VALID_1 = 2'b00;
    

   function [WIDTH : 0] ROL(input [WIDTH-1:0] OPA_2,OPB_2);
	     integer j;
             reg [$clog2(WIDTH)-1 : 0] OPB_1;
             reg [WIDTH-1:0] temp ;
    	    begin
    	    OPB_1 = OPB_2;
    	    temp = OPA_2;
               for(j=0;j<OPB_2[$clog2(WIDTH)-1:0];j=j+1) begin   
               temp = {temp[WIDTH-2:0],temp[WIDTH-1]};
             end
		if(|OPB_2[(WIDTH-1) : ($clog2(WIDTH)+1)])begin
		     ROL[WIDTH] = 1'b1;end
		else
		     ROL[WIDTH] = 1'b0;
    	ROL[WIDTH-1:0] = temp;
             
             end
	    endfunction
	    
	    
	    function [WIDTH : 0] ROR(input [WIDTH-1:0] OPA_2,OPB_2);
	     integer j;
             reg [$clog2(WIDTH)-1 : 0] OPB_1;
             reg [WIDTH-1:0] temp ;
    	    begin
    	    OPB_1 = OPB_2;
    	    temp = OPA_2;
               for(j=0;j<OPB_2[$clog2(WIDTH)-1:0];j=j+1) begin   
               temp = {temp[0],temp[WIDTH-1:1]};
             end
		if(|OPB_2[(WIDTH-1) : ($clog2(WIDTH)+1)])begin
		     ROR[WIDTH] = 1'b1;end
		else
		     ROR[WIDTH] = 1'b0;
    	ROR[WIDTH-1:0] = temp;
             end
	    endfunction

  always @(posedge CLK) begin
        OPA_T<= OPA;
        OPB_T <= OPB;
        CMD_T <= CMD;
        IN_VALID_T <= IN_VALID;
        CIN_T <= CIN;
        MODE_T <= MODE;
    end

always@(posedge CLK) begin 

        case(CMD_T)
	 'b1001: begin
		  OPA_1 <=(OPA_T+1);
          OPB_1 <=(OPB_T+1);
		end  
     'b1010:begin
		 OPA_1 <= (OPA_T<<1);
		 OPB_1 <= OPB_T;
		 end
		 
	  default: begin
	           OPA_1 <= OPA_1;
	           OPB_1 <= OPB_1;
	           end
	           
	 endcase    
    end
	

      
	    
    always@(posedge CLK or posedge RST)
      begin
       if(!CE) begin
            ERR = 1'b1; RES = {WIDTH+1{1'b0}};
            end
       else 
        begin
         if(RST)
          begin
            RES={WIDTH+1{1'b0}};
            COUT=1'b0;
            OFLOW=1'b0;
            G=1'b0;
            E=1'b0;
            L=1'b0;
            ERR=1'b0;
	        MUL_RES = {2*WIDTH{1'b0}};
          end


         else if(MODE_T)
         begin
            RES={WIDTH+1{1'b0}};
            COUT=1'b0;
            OFLOW=1'b0;
            G=1'b0;
            E=1'b0;
            L=1'b0;
            ERR=1'b0;
            MUL_RES = {2*WIDTH{1'b0}};
            
          case(CMD_T) 
           'b0000:
	   if(IN_VALID_T == 2'B11)
            begin
              RES=OPA_T+OPB_T;
              COUT=RES[WIDTH]?1:0;
            end
           else
              ERR = 1;
	      
           'b0001: 
	   if(IN_VALID_T == 2'B11)
            begin
             OFLOW=(OPA_T<OPB_T)?1:0;
             RES=OPA_T-OPB_T;
            end
	     else
		ERR = 1;

           'b0010: 
	   if(IN_VALID == 2'B11)
            begin
             RES=OPA_T+OPB_T+CIN_T;
             COUT=RES[WIDTH]?1:0;
            end
	   else
		ERR = 1;

           'b0011: 
	   if(IN_VALID == 2'B11)
           begin
            OFLOW=(OPA_T<OPB_T)?1:0;
            RES=OPA_T-OPB_T-CIN_T;
           end
	   else 
     	    ERR = 1;

           'b0100:
	   if(IN_VALID_T == 2'B01 ) 
	   begin
	   RES=OPA_T+1;
	   COUT = RES[WIDTH];
	   end
	   else begin 
	   RES = {WIDTH{1'b0}};
	   ERR = 1;
	   end

 'b0101: 
           if(IN_VALID_T == 2'B01 ) begin
              OFLOW = (OPA_T == 0) ? 1:0;
               RES=OPA_T-1;end
           else begin
           RES = {WIDTH{1'b0}};
           ERR = 1;
           end

	  
           'b0110:
           if(IN_VALID_T == 2'B10 )
           begin
            RES=OPB_T+1;
            COUT = RES[WIDTH];
            end 
            else begin 
           RES = {WIDTH{1'b0}};
           ERR = 1;
           end 

           'b0111:
           if(IN_VALID_T == 2'B10) begin
              OFLOW = (OPB_T == 0) ? 1:0;
               RES=OPB_T-1;end
           else begin
           RES = {WIDTH{1'b0}};
           ERR = 1;
           end

           'b1000:
	   if(IN_VALID_T == 2'B11)
           begin
            RES={WIDTH{1'b0}};
            if(OPA_T==OPB_T)
             begin
               E=1'b1;
               G=1'b0;
               L=1'b0;
             end
            else if(OPA_T>OPB_T)
             begin
               E=1'b0;
               G=1'b1;
               L=1'b0;
             end
            else
             begin
               E=1'b0;
               G=1'b0;
               L=1'b1;
             end
           end
	   else begin 
	   RES = {WIDTH{1'b0}};
	   ERR = 1;
	  end
          
  	  'b1001:begin
  	     if(IN_VALID_T == 2'b11) begin
            MUL_RES = OPA_1 * OPB_1;
            end
         else begin
            MUL_RES = {2*WIDTH{1'b0}};
            ERR = 1;
          end
          end

	  'b1010: begin
	  if(IN_VALID_T == 2'b11) MUL_RES = OPA_1 * OPB_1;
	  else begin
            MUL_RES = {2*WIDTH{1'b0}};
            ERR = 1;
          end
	  
        end

	 'b1011: begin
          if(IN_VALID_T == 2'b11) begin
            sOPA = $signed(OPA_T);
            sOPB = $signed(OPB_T);
            sRES = sOPA + sOPB;
            RES = sRES;
            OFLOW = ((sOPA[WIDTH-1] == sOPB[WIDTH-1]) && (sRES[WIDTH-1] != sOPA[WIDTH-1]));
            G = (sOPA > sOPB);  
            E = (sOPA == sOPB);
            L = (sOPA < sOPB);
          end else begin
            RES = {WIDTH{1'b0}};
            ERR = 1;
          end
        end

	'b1100: begin
          if(IN_VALID_T == 2'b11) begin
            sOPA = $signed(OPA_T);
            sOPB = $signed(OPB_T);
            sRES = sOPA - sOPB;
            RES = sRES;
            OFLOW = ((sOPA[WIDTH-1] != sOPB[WIDTH-1]) && (sRES[WIDTH-1] != sOPA[WIDTH-1]));
            G = (sOPA > sOPB);
            E = (sOPA == sOPB);
            L = (sOPA < sOPB);
          end else begin
            RES = {WIDTH{1'b0}};
            ERR = 1;
          end
        end
    

           default:
            begin
            RES={WIDTH+1{1'b0}};
            COUT=1'b0;
            OFLOW=1'b0;
            G=1'b0;
            E=1'b0;
            L=1'b0;
            ERR=1'b1;
	    MUL_RES = {2*WIDTH{1'b0}};
           end
          endcase
         end

        else
        begin
            RES={WIDTH+1{1'b0}};
            COUT=1'b0;
            OFLOW=1'b0;
            G=1'b0;
            E=1'b0;
            L=1'b0;
            ERR=1'b0;
	        MUL_RES = {2*WIDTH{1'b0}};
           
	     
	    
	     case(CMD_T)
             'b0000:if(IN_VALID_T == 2'b11)RES={1'b0,OPA_T & OPB_T};
             else begin 
               RES = {WIDTH+1{1'b0}};
               ERR = 1;
               end
             'b0001:if(IN_VALID_T == 2'b11)RES={1'b0,~(OPA_T & OPB_T)};
             else begin 
               RES = {WIDTH+1{1'b0}};
               ERR = 1;
               end  
             
             'b0010:if(IN_VALID_T == 2'b11)RES={1'b0,OPA_T|OPB_T};
             else begin 
               RES = {WIDTH+1{1'b0}};
               ERR = 1;
               end
               
             'b0011:if(IN_VALID_T == 2'b11)RES={1'b0,~(OPA_T | OPB_T)};
             else begin 
               RES = {WIDTH+1{1'b0}};
               ERR = 1;
               end
               
             'b0100:if(IN_VALID_T == 2'b11)RES={1'b0,OPA_T ^ OPB_T};
             else begin 
               RES = {WIDTH+1{1'b0}};
               ERR = 1;
               end
               
             'b0101:if(IN_VALID_T == 2'b11)RES={1'b0,~(OPA_T ^ OPB_T)};
             else begin 
               RES = {WIDTH+1{1'b0}};
               ERR = 1;
               end

             'b0110:if(IN_VALID_T == 2'b01 )RES={1'b0,~OPA_T};
             else begin 
               RES = {WIDTH+1{1'b0}};
               ERR = 1;
               end
               
               'b0111:if(IN_VALID_T == 2'b10 )RES={1'b0,~OPB_T};
	              else begin 
               RES = {WIDTH+1{1'b0}};
               ERR = 1;
               end
             
             'b1000:if(IN_VALID_T == 2'b01)RES={1'b0,OPA_T>>1};
             else begin 
               RES = {WIDTH+1{1'b0}};
               ERR = 1;
               end
               
             'b1001:if(IN_VALID_T == 2'b01)RES={1'b0,OPA_T<<1};
             else begin 
               RES = {WIDTH+1{1'b0}};
               ERR = 1;
               end

             'b1010:if(IN_VALID_T == 2'b10)RES={1'b0,OPB_T>>1};
             else begin 
               RES = {WIDTH+1{1'b0}};
               ERR = 1;
                end
               
             'b1011:if(IN_VALID_T == 2'b10 )RES={1'b0,OPB_T<<1};
	         else begin 
               RES = {WIDTH+1{1'b0}};
               ERR = 1;
               end

             'b1100:begin 
	     if(IN_VALID_T == 2'b11)begin
 	            RES = ROL(OPA_T,OPB_T);
 	            ERR = RES[WIDTH];end
             else 
	           begin
                RES = {WIDTH+1{1'b0}};
                ERR = 1'b1;
	         end    
	     end

             'b1101:begin
              if(IN_VALID_T == 2'b11)begin
 	            RES = ROR(OPA_T,OPB_T);
 	            ERR = RES[WIDTH];end
             else 
	           begin
                RES = {WIDTH+1{1'b0}};
                ERR = 1'b1;
	         end         
             end
	   

             default:
               begin
            RES={WIDTH+1{1'b0}};
            COUT=1'b0;
            OFLOW=1'b0;
            G=1'b0;
            E=1'b0;
            L=1'b0;
            ERR=1'b1;
	        MUL_RES = {2*WIDTH{1'b0}};
               end
          endcase
     end
    end
   end
endmodule 


module ALU_testbench;
 parameter WIDTH = 8;parameter C_WIDTH = 4;
    reg [WIDTH -1 :0] OPA, OPB;
    reg CIN, CLK, RST, CE, MODE;
    reg [1:0] IN_VALID;
    reg [C_WIDTH-1:0] CMD;
    
    wire [WIDTH:0] RES;
    wire [2*WIDTH-1:0] MUL_RES;
    wire COUT, OFLOW, G, E, L, ERR;
    
    wire [WIDTH:0] RES_expected;
    wire [2*WIDTH-1:0] MUL_RES_expected;
    wire COUT_expected, OFLOW_expected;
    wire G_expected, E_expected, L_expected, ERR_expected;
    
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    Alu_f #(WIDTH,C_WIDTH) DUT (
        .OPA(OPA), .OPB(OPB), .CIN(CIN),
        .CLK(CLK), .RST(RST), .CMD(CMD),
        .CE(CE), .MODE(MODE), .IN_VALID(IN_VALID),
        .COUT(COUT), .OFLOW(OFLOW),
        .RES(RES),.MUL_RES(MUL_RES), .G(G), .E(E), .L(L), .ERR(ERR)
    );
    
    ALU_REF #(WIDTH,C_WIDTH) REF_MODEL (
        .OPA(OPA), .OPB(OPB), .CIN(CIN),
        .CLK(CLK), .RST(RST), .CMD(CMD),
        .CE(CE), .MODE(MODE), .IN_VALID(IN_VALID),
        .RES(RES_expected),
	.MUL_RES(MUL_RES_expected),
        .COUT(COUT_expected),
        .OFLOW(OFLOW_expected),
        .G(G_expected),
        .E(E_expected),
        .L(L_expected),
        .ERR(ERR_expected)
    );
    
    initial begin
        
        CE = 1;
        RST = 1;
        MODE = 1;
        CIN = 0;
        OPA = 'h00;
        OPB = 'h00;
        CMD = 'b1111;
        IN_VALID = 2'b11;
	

        @(negedge CLK);
        RST =0; 
       
	@(negedge CLK); 
        OPA = 'b00110111;
        OPB = 'b10111001;
	CMD = 'b0000;
	MODE = 1;
	IN_VALID = 2'b11;
        repeat(3)@(posedge CLK); 
          check_results("ADD");

	@(negedge CLK); 
        OPA = 'b01010111;
        OPB = 'b00100001;
	CMD = 'b0000;
	MODE = 1;
	IN_VALID = 2'b01;
        repeat(2)@(posedge CLK); 
          check_results("ADD");
          
        @(negedge CLK); 
        OPA = 'b01000110;
        OPB = 'b00101001;
	CMD = 'b0000;
	MODE = 1;
	IN_VALID = 2'b10;
        repeat(2)@(posedge CLK); 
          check_results("ADD");

	@(negedge CLK); 
        OPA = 'b01000111;
        OPB = 'b00110001;
	CMD = 'b0000;
	MODE = 1;
	IN_VALID = 2'b00;
        repeat(2)@(posedge CLK); 
          check_results("ADD");

	@(negedge CLK); 
        OPA = 'b01100111;
        OPB = 'b00011101;
	CMD = 'b0001;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SUB");

	@(negedge CLK); 
        OPA = 'b01100111;
        OPB = 'b00110101;
	CMD = 'b0001;
	MODE = 1;
	IN_VALID = 2'b11;
	CE = 0;
         repeat(2)@(posedge CLK); 
          check_results("SUB");

	@(negedge CLK);  
        OPA = 'b01000111;
        OPB = 'b00011101;
	CMD = 'b0001;
	MODE = 1;
	RST = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("RST");
 
	@(negedge CLK);   
        RST = 0;
	OPA = 'b01000111;
        OPB = 'b00011101;
	CMD = 'b0010;
	MODE = 1;
	CIN = 1;
	IN_VALID = 2'b11;
	CE=1;
         repeat(2)@(posedge CLK); 
          check_results("ADD_CIN");

	@(negedge CLK);   
        OPA = 'b01000111;
        OPB = 'b00011101;
	CMD = 'b1110;
	MODE = 1;
	CIN = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("Inv_CMD");

	@(negedge CLK);  
        OPA = 'b01000111;
        OPB = 'b00011101;
	CMD = 'b0011;
	MODE = 1;
	CIN = 0;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SUB_CIN");

	@(negedge CLK);   
        OPA = 'b01010111;
        OPB = 'b00011101;
	CMD = 'b0100;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("INC_A");

	@(negedge CLK);  
        OPA = 'b11111111;
        OPB = 'b011011101;
	CMD = 'b0100;
	MODE = 1;
	IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("INC_A");
          
@(negedge CLK);  
        OPA = 'b01111111;
        OPB = 'b011011101;
	CMD = 'b0100;
	MODE = 1;
	IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("INC_A");

	@(negedge CLK);  
        OPA = 'b010110111;
        OPB = 'b00011101;
	CMD = 'b0100;
	MODE = 1;
	IN_VALID = 2'b10;
         repeat(2)@(posedge CLK); 
          check_results("INC_A");

	@(negedge CLK);    
        OPA = 'b00000000;
        OPB = 'b00011101;
	CMD = 'b0101;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("DEC_A");

	@(negedge CLK);   
        OPA = 'b00000000;
        OPB = 'b011011101;
	CMD = 'b0101;
	MODE = 1;
	IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("DEC_A");
          
  	@(negedge CLK);   
        OPA = 'b00000000;
        OPB = 'b011011101;
	CMD = 'b0101;
	MODE = 1;
	IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("DEC_A");
          

	@(negedge CLK);  
        OPA = 'b010110111;
        OPB = 'b00011101;
	CMD = 'b0101;
	MODE = 1;
	IN_VALID = 2'b10;
         repeat(2)@(posedge CLK); 
          check_results("DEC_A");

	@(negedge CLK);    
        OPA = 'b01010111;
        OPB = 'b11111111;
	CMD = 'b0110;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("INC_B");

	@(negedge CLK);  
        OPA = 'b010101110;
        OPB = 'b11111111;
	CMD = 'b0110;
	MODE = 1;
	IN_VALID = 2'b10;
         repeat(2)@(posedge CLK); 
          check_results("INC_B");

	@(negedge CLK);   
        OPA = 'b11111111;
        OPB = 'b111111111;
	CMD = 'b0110;
	MODE = 1;
	IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("INC_B");

	@(negedge CLK);   
        OPA = 'b01010111;
        OPB = 'b00000000;
	CMD = 'b0111;
	MODE = 1;
	IN_VALID = 2'b10;
         repeat(2)@(posedge CLK); 
          check_results("DEC_B");

	@(negedge CLK);   
        OPA = 'b010101110;
        OPB = 'b00000000;
	CMD = 'b0111;
	MODE = 1;
	IN_VALID = 2'b10;
         repeat(2)@(posedge CLK); 
          check_results("DEC_B");

	@(negedge CLK);  
        OPA = 'b01011011;
        OPB = 'b000111010;
	CMD = 'b0111;
	MODE = 1;
	IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("DEC_B");

	@(negedge CLK);   
        OPA = 'b01011011;
        OPB = 'b00011101;
	CMD = 'b1000;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("CMP");

	@(negedge CLK);   
        OPA = 'b00011011;
        OPB = 'b00011011;
	CMD = 'b1000;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("CMP");

	@(negedge CLK);    
        OPA = 'b100011011;
        OPB = 'b00011011;
	CMD = 'b1000;
	MODE = 1;
	IN_VALID = 2'b10;
         repeat(2)@(posedge CLK); 
          check_results("CMP");

	@(negedge CLK);    
        OPA = 'b00110110;
        OPB = 'b01011101;
	CMD = 'b1000;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("CMP");

	@(negedge CLK);    
        OPA = 'b00110110;
        OPB = 'b01011101;
	CMD = 'b1001;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(3)@(posedge CLK); 
          check_results("MUL_1");

	@(negedge CLK);   
        OPA = 'b00110110;
        OPB = 'b01011101;
	CMD = 'b1010;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(3)@(posedge CLK); 
          check_results("MUL_2");

	@(negedge CLK);   
        OPA = 'b00110110;
        OPB = 'b01011101;
	CMD = 'b1011;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SIGN_ADD");

	@(negedge CLK);  
        OPA = 'b10001110;
        OPB = 'b00011101;
	CMD = 'b1011;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SIGN_ADD");

	@(negedge CLK);  
        OPA = 'b10001110;
        OPB = 'b11011101;
	CMD = 'b1011;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SIGN_ADD");

	@(negedge CLK);  
        OPA = 'b00001110;
        OPB = 'b11011101;
	CMD = 'b1011;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SIGN_ADD");

	@(negedge CLK);   
        OPA = 'b00110110;
        OPB = 'b01011101;
	CMD = 'b1100;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SIGN_SUB");

	@(negedge CLK);    
        OPA = 'b10001110;
        OPB = 'b00011101;
	CMD = 'b1100;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SIGN_SUB");

	@(negedge CLK);   
        OPA = 'b10001110;
        OPB = 'b11011101;
	CMD = 'b1011;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SIGN_SUB");

	@(negedge CLK);  
        OPA = 'b00001110;
        OPB = 'b11011101;
	CMD = 'b1100;
	MODE = 1;
	IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SIGN_SUB");

	
	
	

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0000;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("AND");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0001;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("NAND");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0001;
	MODE = 0;
        IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("NAND");

	
	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0010;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("OR");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0011;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("NOR");
	
	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0100;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("XOR");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0100;
	MODE = 0;
        IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("XOR");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0101;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("XONR");
	
	
	
	@(negedge CLK);
	CE = 0;
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0110;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("NOT_A");
	

	@(negedge CLK);
	CE=1;
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0110;
	MODE = 0;
        IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("NOT_A");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0110;
	MODE = 0;
        IN_VALID = 2'b10;
         repeat(2)@(posedge CLK); 
          check_results("NOT_A");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0111;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("NOT_B");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0111;
	MODE = 0;
        IN_VALID = 2'b10;
         repeat(2)@(posedge CLK); 
          check_results("NOT_B");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b0111;
	MODE = 0;
        IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("NOT_B");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b1000;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SHR1_A");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b1000;
	MODE = 0;
        IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("SHR1_A");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b1000;
	MODE = 0;
        IN_VALID = 2'b10;
         repeat(2)@(posedge CLK); 
          check_results("SHR1_A");
	
	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b1001;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SHL1_A");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b1001;
	MODE = 0;
        IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("SHL1_A");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b1001;
	MODE = 0;
        IN_VALID = 2'b10;
        IN_VALID = 2'b10;
         repeat(2)@(posedge CLK); 
          check_results("SHL1_A");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b1010;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SHR1_B");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b1010;
	MODE = 0;
        IN_VALID = 2'b10;
         repeat(2)@(posedge CLK); 
          check_results("SHR1_B");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b1010;
	MODE = 0;
        IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("SHR1_B");



	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b1011;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("SHL1_B");

	
	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b1011;
	MODE = 0;
        IN_VALID = 2'b10;
         repeat(2)@(posedge CLK); 
          check_results("SHL1_B");


	@(negedge CLK);
        OPA = 'b11110111;
        OPB = 'b11111110;
	CMD = 'b1011;
	MODE = 0;
        IN_VALID = 2'b01;
         repeat(2)@(posedge CLK); 
          check_results("SHL1_B");


	@(negedge CLK);
        OPA = 'b00000111;
        OPB = 'b00000110;
	CMD = 'b1100;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("ROL_A_B");


	@(negedge CLK);
        OPA = 'b00100111;
        OPB = 'b00100110;
	CMD = 'b1100;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("ROL_A_B");

	
	@(negedge CLK);
        OPA = 'b00000111;
        OPB = 'b00000110;
	CMD = 'b1101;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("ROR_A_B");

	
	@(negedge CLK);
        OPA = 'b00100111;
        OPB = 'b00100110;
	CMD = 'b1101;
	MODE = 0;
        IN_VALID = 2'b11;
         repeat(2)@(posedge CLK); 
          check_results("ROR_A_B");


	
	repeat(500) begin
	@(negedge CLK);
        OPA = $urandom;
        OPB = $urandom;
	CMD = $urandom;
	MODE = $urandom;
        IN_VALID = $urandom;
	CIN = $urandom;
	if((CMD == 'b1001 || CMD == 'b1010) && (MODE == 1)) begin
         repeat(3)@(posedge CLK); 
          check_results("RAND");
	end
	else begin
	repeat(2)@(posedge CLK); 
          check_results("RAND");
	end
	end
	

          #15;
            
           #60;
        $finish;

    end
    
    task check_results;
        input [8*10-1:0] operation;
        begin
            
            $strobe("\n%s Operation:", operation);
            $strobe("Inputs: OPA=%b, OPB=%b, CIN=%b, CMD=%b, MODE=%b, IN_VALID=%b", 
                     OPA, OPB, CIN, CMD, MODE,IN_VALID);

            if (RES === RES_expected)
                $strobe("RES: PASS - Got %b and expected is %b", RES,RES_expected);
            else
                $strobe("RES: FAIL - Got %b, Expected %b", RES, RES_expected);

	    if (MUL_RES === MUL_RES_expected)
                $strobe("MUL_RES: PASS - Got %b", MUL_RES);
            else
                $strobe("MUL_RES: FAIL - Got %b, Expected %b", MUL_RES, MUL_RES_expected);
                
            if (COUT === COUT_expected)
                $strobe("COUT: PASS - Got %b", COUT);
            else
                $strobe("COUT: FAIL - Got %b, Expected %b", COUT, COUT_expected);
                
            if (OFLOW === OFLOW_expected)
                $strobe("OFLOW: PASS - Got %b", OFLOW);
            else
                $strobe("OFLOW: FAIL - Got %b, Expected %b", OFLOW, OFLOW_expected);
                
            if (L === L_expected)
                $strobe("Comparison flags: PASS - L=%b",L);
            else
                $strobe("Comparison flags: FAIL - Got L=%b Expected L=%b", 
                          L, L_expected);

	    if (E === E_expected )
                $strobe("Comparison flags: PASS - E=%b ", E);
            else
                $strobe("Comparison flags: FAIL - Got E=%b Expected E=%b", 
                         E,E_expected);

	    if (G === G_expected )
                $strobe("Comparison flags: PASS - G=%b", G,);
            else
                $strobe("Comparison flags: FAIL - Got G=%b Expected G=%b", 
                         G, G_expected);
                
            if (ERR === ERR_expected)
                $strobe("ERR: PASS - Got %b", ERR);
            else
                $strobe("ERR: FAIL - Got %b, Expected %b", ERR, ERR_expected);
        end
    endtask
endmodule
