module imgproc(clk, rst, orig_data, orig_ready, request, orig_addr, imgproc_ready, imgproc_addr, imgproc_data, finish);

input           clk, rst;

input  [23:0]   orig_data;
input           orig_ready;

output          request;
output [13:0]   orig_addr;

output          imgproc_ready;
output [13:0]   imgproc_addr;
output [7:0]    imgproc_data;
output          finish;
// Please DO NOT modified the I/O signal

localparam MAX_ADDR = 14'd16383;

wire [7:0]  channel[0:2], min01, min;
wire [14:0] nxt_addr;
reg         request, imgproc_ready, finish;
reg         nxt_request, nxt_finish;
reg  [13:0] imgproc_addr, orig_addr;
reg  [7:0]  imgproc_data;
reg  [14:0] addr;

assign channel[0] = orig_data[23:16];
assign channel[1] = orig_data[15:8];
assign channel[2] = orig_data[7:0];

// TODO use more comparator for faster comparison
assign min01    = channel[0] < channel[1] ? channel[0] : channel[1];
assign min      = min01      < channel[2] ? min01 : channel[2];
assign nxt_addr = addr + 1;

always @(*) begin
    if (nxt_addr[14] == 1'b1) begin
        nxt_finish  = 1;
        nxt_request = 0;
    end
    else begin
        nxt_finish  = 0;
        nxt_request = 1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        imgproc_ready <= 0;
        imgproc_addr  <= 14'b0;
        imgproc_data  <= 8'b0;
        addr          <= {1'b1, MAX_ADDR}; // 0x7fff + 1 == 0
        request       <= 0;
        finish        <= 0;
    end
    else begin
        orig_addr    <= nxt_addr[13:0];
        imgproc_addr <= addr[13:0];
        addr         <= nxt_addr;
        request      <= nxt_request;
        finish       <= nxt_finish;
        if(orig_ready) begin
            imgproc_ready <= 1;
            imgproc_data  <= min;
        end
        else begin
            imgproc_ready <= 0;
            imgproc_data  <= 8'b0;
        end
    end
end


endmodule

