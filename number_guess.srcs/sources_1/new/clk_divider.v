`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 21:51:36
// Design Name: 
// Module Name: clk_divider
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


module clk_timer# (
    parameter TIME_LIMIT=16'd200  // 超时阈值
    )(
    input wire clk,               // 输入时钟（100 MHz）
    input wire rst,               // 复位信号
    input wire [2:0] current_state, // 当前状态
    output reg timeout,           // 超时信号
    output reg [7:0] clk_out      // 每秒计数值（直接作为 timeout_counter）
);

   reg [26:0] clk_counter= 27'd99999999;       // 分频计数器
   reg clk_enable;               // 1Hz 时钟使能信号

    // 1Hz 时钟生成
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_counter <= 0;
            clk_enable <= 0;
       end else if (clk_counter == 27'd99999999) begin
            clk_counter <= 0;
            clk_enable  <= 1;      // 每秒触发一次
        end else begin
            clk_counter <= clk_counter + 1;
            clk_enable <= 0;
        end
    end

    // 超时检测与计数
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_out <=30;         // 重置计时器
            timeout <= 0;
        end else if (clk_enable) begin
            if ((current_state == 3'b001 || current_state == 3'b010)&&!timeout) begin // 等待输入或检查结果
                if (clk_out >0) begin
                    clk_out <= clk_out - 1; // 每秒递增
                    timeout <= 0;           // 未超时
                end else begin
                    timeout <= 1;           // 超时信号
                end
            end 
            else if(current_state!=3'b001&&current_state!=3'b010) begin
                clk_out <= 30;               // 非等待状态，重置计时器
                timeout <= 0;
            end
        end
    end

endmodule


