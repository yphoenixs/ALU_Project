
module Alu_f#(parameter WIDTH = 8, parameter C_WIDTH=4) (OPA,OPB,CIN,CLK,RST,IN_VALID,CMD,CE,MODE,COUT,OFLOW,RES,G,E,L,ERR,MUL_RES);


  input [WIDTH-1:0] OPA,OPB;
  input CLK,RST,CE,MODE,CIN;
  input [1:0]IN_VALID;
  input [C_WIDTH-1:0] CMD;
  output reg[WIDTH :0]RES = {WIDTH+1{1'b0}}; 
  output reg[(2*WIDTH-1) : 0]MUL_RES = {2*WIDTH{1'b0}};
  output reg COUT = 1'b0; 
  output reg OFLOW = 1'b0;
  output reg G = 1'b0;
  output reg E = 1'b0;
  output reg L = 1'b0;
  output reg ERR = 1'b0;
  
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
	IN_VALID_1 <= IN_VALID_T;
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
	   RES = {WIDTH+1{1'b0}};
	   ERR = 1;
	   end

 'b0101: 
           if(IN_VALID_T == 2'B01 ) begin
              OFLOW = (OPA_T == 0) ? 1:0;
               RES=OPA_T-1;end
           else begin
           RES = {WIDTH+1{1'b0}};
           ERR = 1;
           end

	  
           'b0110:
           if(IN_VALID_T == 2'B10 )
           begin
            RES=OPB_T+1;
            COUT = RES[WIDTH];
            end 
            else begin 
           RES = {WIDTH+1{1'b0}};
           ERR = 1;
           end 

           'b0111:
           if(IN_VALID_T == 2'B10) begin
              OFLOW = (OPB_T == 0) ? 1:0;
               RES=OPB_T-1;end
           else begin
           RES = {WIDTH+1{1'b0}};
           ERR = 1;
           end

           'b1000:
	   if(IN_VALID_T == 2'B11)
           begin
            RES={WIDTH+1{1'b0}};
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
	   RES = {WIDTH+1{1'b0}};
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
            RES = {WIDTH+1{1'b0}};
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
            RES = {WIDTH+1{1'b0}};
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