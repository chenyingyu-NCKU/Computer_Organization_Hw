module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output reg R,
    output reg G,
    output reg Y
);

//write your code here
reg [10:0] cycle; // there are 1536 cycle in total (< 2^11)
reg initial_green;

always@(posedge clk or  negedge rst)begin
  // reset
  if(rst)begin 
    cycle = 0;
    initial_green = 1;
    R = 0;
    G = 1;
    Y = 0;
  end 
  
  else begin
    // pass
    if(pass && !initial_green)begin
      cycle = 0;
      initial_green = 1;
      R = 0;
      G = 1;
      Y = 0;
    end
    
    
    // initial_green
    if(cycle == 0)begin
      initial_green = 1;
      R = 0;
      G = 1;
      Y = 0;
    end
    // None
    else if(cycle == 512 || cycle == 640)begin
      initial_green = 0;
      R = 0;
      G = 0;
      Y = 0;
    end
    // Green (Not initial)
    else if(cycle == 576 || cycle == 704)begin
      initial_green = 0;
      R = 0;
      G = 1;
      Y = 0;
    end
    // Yellow
    else if(cycle == 768)begin
      initial_green = 0;
      R = 0;
      G = 0;
      Y = 1;
    end
    // Red
    else if(cycle == 1024)begin
      initial_green = 0;
      R = 1;
      G = 0;
      Y = 0;
    end
    // Cycle END
    if(cycle == 1536)begin
      initial_green = 1;
      cycle = 0;
      R = 0;
      G = 1;
      Y = 0;
    end
    
    cycle = cycle + 1;
  end
end

endmodule

