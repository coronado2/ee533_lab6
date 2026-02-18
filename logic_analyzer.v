`timescale 1ns/1ps

module logic_analyzer
   #(
      parameter ADDR_WIDTH = 10,
      parameter DATA_WIDTH = 72
   )
   (
      input                           clk,
      input                           reset,
      
      // Control regs
      input                           capture_enable,
      input                           capture_reset,
      input [ADDR_WIDTH-1:0]          read_addr,
      input [1:0]                     word_select,
      
      // Data captured
      input [DATA_WIDTH-1:0]          capture_data,
      input                           capture_trigger,
      
      // Outputs
      output [ADDR_WIDTH-1:0]         samples_captured,
      output [31:0]                   data_out
   );

   //------------------------- Internal Signals -----------------------
   
   reg [ADDR_WIDTH-1:0]   write_addr;
   reg [DATA_WIDTH-1:0]   memory [0:(1<<ADDR_WIDTH)-1];
   reg [DATA_WIDTH-1:0]   read_data;
   reg [31:0]             output_word;
   
   //------------------------- Write Address Counter ------------------
   
   always @(posedge clk) begin
      if (reset || capture_reset) begin
         write_addr <= {ADDR_WIDTH{1'b0}};
      end
      else if (capture_enable && capture_trigger) begin
         write_addr <= write_addr + 1'b1;
      end
   end
   
   //------------------------- Write to Memory ------------------------
   
   always @(posedge clk) begin
      if (capture_enable && capture_trigger) begin
         memory[write_addr] <= capture_data;
      end
   end
   
   //------------------------- Read from Memory -----------------------
   
   always @(posedge clk) begin
      read_data <= memory[read_addr];
   end
   
   //------------------------- Output Multiplexer ---------------------
   
   // Select which 32-bit chunk of the 72-bit sample to output
   always @(*) begin
      case (word_select)
         2'b00:   output_word = read_data[31:0];       
         2'b01:   output_word = read_data[63:32];         
         2'b10:   output_word = {24'b0, read_data[71:64]}; 
         2'b11:   output_word = 32'hDEADC0DE;             
         default: output_word = 32'hDEADC0DE;
      endcase
   end
   
   //------------------------- Outputs --------------------------------
   
   assign data_out = output_word;
   assign samples_captured = write_addr;

endmodule