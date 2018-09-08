
`timescale 1ns / 1ps

`define BUF_WIDTH 3                                                                                       // BUF_SIZE = 16 -> BUF_WIDTH = 4, no. of bits to be used in pointer
`define BUF_SIZE ( 1 << `BUF_WIDTH )

module syncbram_fifo ( clk, rst, buf_in, buf_out, wr_en, rd_en, buf_empty, buf_full, fifo_counter );

input                     rst, clk;
// write enable, read enable
input                     wr_en;
input                     rd_en;
// reset, system clock, write enable and read enable
input           [ 7 : 0 ] buf_in;
// data input to be pushed to buffer
output          [ 7 : 0 ] buf_out;
// port to output the data using pop
output                    buf_empty;
output                    buf_full;
// buffer empty and full indication
output [ `BUF_WIDTH : 0 ] fifo_counter;
// number of data pushed in to buffer

reg             [ 7 : 0 ] buf_out;
reg                       buf_empty;
reg                       buf_full;

reg    [ `BUF_WIDTH : 0 ] fifo_counter;
reg   [`BUF_WIDTH -1 : 0] rd_ptr, wr_ptr;         // pointer to read and write addresses
reg             [ 7 : 0 ] uf_mem[ `BUF_SIZE - 1 : 0 ];  //

always @(*)
begin
   buf_empty = (fifo_counter == 0);   // Checking for whether buffer is empty or not
   buf_full = (fifo_counter == `BUF_SIZE);  //Checking for whether buffer is full or not
end

//Setting FIFO counter value for different situations of read and write operations.
always @(posedge clk or posedge rst)
begin
   if ( rst )
       fifo_counter <= `BUF_WIDTH'h0;                      // Reset the counter of FIFO
   else if ( !buf_full && wr_en )                          // When doing only write operation
       fifo_counter <= fifo_counter + 1;
   else if ( !buf_empty && rd_en )                         //When doing only read operation
       fifo_counter <= fifo_counter - 1;
end

always @( posedge clk or posedge rst )
begin
   if ( rst )
      buf_out <= 7'b0;                                     //On reset output of buffer is all 0.
   else if( rd_en && !buf_empty )
      buf_out <= buf_mem[rd_ptr];                          //Reading the 8 bit data from buffer location indicated by read pointer
end

always @(posedge clk)
begin
   if ( wr_en && !buf_full )
      buf_mem[ wr_ptr ] <= buf_in;                         // wrting data to the buffer memory 
end

always@(posedge clk or posedge rst)
begin
   if ( rst )                                               // reset condition
      begin
         wr_ptr <= `BUF_WIDTH-1'h0;                      // Initializing write pointer
         rd_ptr <= `BUF_WIDTH-1'h0;                      // Initializing read pointer
      end
   else
   begin
      if ( !buf_full && wr_en )                             // check whether fifo is not full and write enable high condition
         wr_ptr <= wr_ptr + 1;                             // increment write pointer

      if ( !buf_empty && rd_en )                            // check whether fifo is not full, and read enable high condition
         rd_ptr <= rd_ptr + 1;                             // increment read pointer
   end
end
endmodule
