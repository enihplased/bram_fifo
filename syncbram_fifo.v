
`timescale 1ns / 100ps

`define BUF_WIDTH 3                                                                                       // BUF_SIZE = 16 -> BUF_WIDTH = 4, no. of bits to be used in pointer
`define BUF_SIZE ( 1 << `BUF_WIDTH )

module syncbram_fifo ( clk, rst, buf_in, buf_out, wr_en, rd_en, buf_empty, buf_full );

// system clock, reset
input                     clk;
input                     rst;
// write enable, read enable
input                     wr_en;
input                     rd_en;
// buffer data in
input           [ 7 : 0 ] buf_in;
// buffer data out
output          [ 7 : 0 ] buf_out;
// full and empty flags
output                    buf_empty;                       // buffer empty flag
output                    buf_full;                        // buffer full flag

reg             [ 7 : 0 ] buf_out;                         // read data from buffer

reg    [ `BUF_WIDTH : 0 ] rd_ptr;                          // pointer to read address
reg    [ `BUF_WIDTH : 0 ] wr_ptr;                          // pointer to write address
reg             [ 7 : 0 ] buf_mem[ `BUF_SIZE - 1 : 0 ];    // buffer memory

// generation of full and empty signals
assign buf_full = (( rd_ptr[`BUF_WIDTH] != wr_ptr[`BUF_WIDTH]) && ( rd_ptr[`BUF_WIDTH-1 : 0] == wr_ptr[`BUF_WIDTH-1 : 0] ));
assign buf_empty = ( rd_ptr == wr_ptr );

always @( posedge clk )
begin
   if ( rst )
      buf_out <= 8'b0;                                     //On reset output of buffer is all 0.
   else if ( rd_en && !buf_empty )
      buf_out <= buf_mem[rd_ptr[`BUF_WIDTH-1 : 0]];        //Reading the 8 bit data from buffer location indicated by read pointer
end

always@( posedge clk )
begin
   if ( wr_en && !buf_full )
      buf_mem[wr_ptr[`BUF_WIDTH-1 : 0]] <= buf_in;         // wrting data to the buffer memory 
end

always@( posedge clk )
begin
   if ( rst )                                              // reset condition
      begin
         wr_ptr <= `BUF_WIDTH'd0;                          // Initializing write pointer
         rd_ptr <= `BUF_WIDTH'd0;                          // Initializing read pointer
      end
   else
   begin
      if ( !buf_full && wr_en )                            // check whether fifo is not full and write enable high condition
         wr_ptr <= wr_ptr + `BUF_WIDTH'd1;                 // increment write pointer

      if ( !buf_empty && rd_en )                           // check whether fifo is not full, and read enable high condition
         rd_ptr <= rd_ptr + `BUF_WIDTH'd1;                 // increment read pointer
   end
end
endmodule
