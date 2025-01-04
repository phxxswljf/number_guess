`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 21:27:16
// Design Name: 
// Module Name: random_number_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module random_number_generator (
    input wire clk,                   // 时钟信号
    input wire rst,                  // 复位信号
    input wire [7:0] max_value,      // 最大值（范围）
    output reg [7:0] random_number   // 随机数输出
);

    // 线性同余生成器的参数（可以根据需要调整）
    localparam A = 32'd1664525;   // 乘数
    localparam C = 32'd1013904223; // 增量
    localparam M = 64'd4294967296; // 模数，2^32，用32位表示
    
    // 随机数的状态寄存器
    reg [31:0] seed;  // 随机数生成的种子

    // 每个时钟周期产生新的随机数
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seed <= 32'hDEADBEEF;  // 复位时，设置种子为一个常量值
            random_number <= 8'b0; // 初始随机数为0
        end else begin
            // 根据线性同余生成器公式生成伪随机数
            seed <= (A * seed + C) % M;  // 更新种子
            random_number <= seed[7:0] % (max_value + 1); // 限制随机数范围为 0 到 max_value
        end
    end

endmodule
