
`timescale 1ns / 100ps

module tb_syncbram_fifo();

reg clk, rst, wr_en, rd_en;

reg   [ 7 : 0 ] buf_in;
reg   [ 7 : 0 ] tempdata;
wire  [ 7 : 0 ] buf_out;

   syncbram_fifo dut0 (
      .clk        (clk),
      .rst        (rst),
      .buf_in     (buf_in),
      .buf_out    (buf_out),
      .wr_en      (wr_en),
      .rd_en      (rd_en),
      .buf_empty  (buf_empty),
      .buf_full   (buf_full)
   );

initial
begin
   rst = 1;
   rd_en = 0;
   wr_en = 0;
   tempdata = 0;
   buf_in = 0;

   repeat(10) @(negedge clk);
   rst = 0;

   push(1);
   push(2);
   push(3);
   push(4);
   push(5);
   push(6);
   push(7);
   push(8);
   push(80);
   push(81);

   pop(tempdata);
   pop(tempdata);
   pop(tempdata);
   pop(tempdata);
   pop(tempdata);
   pop(tempdata);
   pop(tempdata);
   pop(tempdata);

   push(9);
   push(10);
   push(11);
   push(12);
   push(13);
   push(14);

   pop(tempdata);
   pop(tempdata);
   pop(tempdata);
   pop(tempdata);
   pop(tempdata);
   pop(tempdata);

   push(15);

   pop(tempdata);

   push(16);

   pop(tempdata);

   push(17);

   pop(tempdata);

   push(18);

   pop(tempdata);
   pop(tempdata);

   $finish();
end

initial begin clk = 0; forever #5 clk = ~clk; end

task push;
input[7:0] data;

   @(negedge clk)
   if ( buf_full )
      $display("----CANNOT PUSH %02d : BUFFER FULL----", data);
   else
      begin
         $display("%0t\tPUSHED %02d", $time, data );
         buf_in = data;
         wr_en = 1'b1;
         @(negedge clk);
         wr_en = 1'b0;
      end
endtask

task pop;
output [7:0] data;

   @(negedge clk)
   if ( buf_empty )
      $display("----CANNOT POP : BUFFER EMPTY----");
   else
      begin
         rd_en = 1'b1;
         @(negedge clk);
         rd_en = 1'b0;
         data = buf_out;
         $display("%0t\t-------------------------------POPED %02d ", $time, data);
      end
endtask

endmodule
