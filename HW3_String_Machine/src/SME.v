module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg [4:0] match_index;
output reg valid;
// reg match;
// reg [4:0] match_index;
// reg valid;

reg [7:0] string [31:0]; // string array length = 32
reg [7:0] pattern [7:0]; // patern array length = 8
reg [5:0] count_s; // from 0 to 32
reg [3:0] count_p;
reg [5:0] len_s;
reg [3:0] len_p;

reg flag_begin;
reg flag_end;

integer i;
integer j;

always @(posedge clk or negedge reset) begin
    if(reset) begin
        for(i = 0; i < 32; i = i + 1) begin
          string[i] = 0;
        end
        for(i = 0; i < 8; i = i + 1) begin
          pattern[i] = 0;
        end
        count_s <= 0;
        count_p <= 0;
        flag_begin <= 0;
        flag_end <= 0;

        match <= 0;
        match_index <= 0;
        valid <= 0;
    end

    // intake the string
    if(isstring) begin
        match = 0;
        string[count_s] = chardata;
        count_s = count_s + 1;
        len_s <= count_s; // record the length of string
    end
    else begin
        count_s = 0;
    end

    // intake pattern
    if(ispattern) begin
        match = 0;
        if(chardata == 8'h5E) begin flag_begin = 1; end
        else if(chardata == 8'h24) begin flag_end = 1; end
        else begin
            pattern[count_p] = chardata;
            count_p = count_p + 1;
            len_p <= count_p;
        end
    end
    else begin
        count_p = 0;
    end

    
    valid  = 0;
    // raise valid
    if(!isstring && !ispattern) begin 
        valid = 1;
        match = 0; 
        flag_begin <= 0;
        flag_end <= 0;
    end
end

always @(valid) begin: check
  
    if(valid == 1)begin
        match = 0;
        match_index = 0;
        for(i = 0; i <= len_s - len_p; i = i + 1) begin: pass_1

            for (j = 0; j < len_p; j = j + 1) begin: pass_2
                if(string[i+j] != pattern[j] && pattern[j] != 8'h2E) begin
                    disable pass_1; // continue
                end
            end

            if(j == len_p)begin
                match_index = i;
                match = 1;

                /** deal with the special mark**/
                if(flag_begin) begin
                    if(i != 0 && string[i-1] != 8'h20) begin 
                        match = 0;
                    end
                end
                if(flag_end) begin
                    if((i+(j-1) != len_s - 1) && string[i+(j-1)+1] != 8'h20) begin
                    match = 0;
                    end
                end
                /*******************************/
                
            
                if(match == 1) begin 
                    disable check; 
                end
            end
        end
    end
end

endmodule

// so far 93 
