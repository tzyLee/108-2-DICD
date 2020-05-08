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

reg         request, imgproc_ready, finish;
reg  [13:0] imgproc_addr, orig_addr;
reg  [7:0]  imgproc_data;

localparam MAX_ADDR = 14'd16383;

wire [7:0]  channel[0:2];

wire        nxt_finish;
wire [14:0] nxt_addr;

reg  [14:0] addr;
reg  [7:0]  min;

assign channel[0] = orig_data[23:16];
assign channel[1] = orig_data[15:8];
assign channel[2] = orig_data[7:0];

always @(*) begin
    // a<b b<c a<c
    if(channel[0] < channel[1]) begin
        if(channel[0] < channel[2]) begin
            // 1 0 1 (1, 5, 3) -> a
            // 1 1 1 (1, 3, 5) -> a
            min = channel[0];
        end
        else begin
            // 1 0 0 (3, 5, 1) -> c
            min = channel[2];
        end
    end
    else begin
        if (channel[1] < channel[2]) begin
            // 0 1 0 (5, 1, 3) -> b
            // 0 1 1 (3, 1, 5) -> b
            min = channel[1];
        end
        else begin
            // 0 0 0 (5, 3, 1) -> c
            min = channel[2];
        end
    end
end

assign nxt_addr = addr + 1;
assign nxt_finish = nxt_addr[14];

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
        orig_addr     <= nxt_addr[13:0];
        imgproc_ready <= orig_ready;
        imgproc_addr  <= addr[13:0];
        imgproc_data  <= min;
        addr          <= nxt_addr;
        request       <= !nxt_finish;
        finish        <= nxt_finish;
    end
end


endmodule

