`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/17 12:30:18
// Design Name: 
// Module Name: clk_timer_tb
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


module clk_timer_tb();

 // 信号声明
    reg clk;
    reg rst;
    reg [15:0] time_limit;
    reg [1:0]  current_state;
    wire timeout;
    wire [7:0] clk_out;

    // 时钟周期参数
    parameter CLK_PERIOD = 10; // 100MHz 时钟

    // 实例化 clk_timer
    clk_timer uut (
        .clk(clk),
        .rst(rst),
        .time_limit(time_limit),
        .current_state(current_state),
        .timeout(timeout),
        .clk_out(clk_out)
    );

    // 生成时钟
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk; // 100MHz 时钟
    end

    // 测试激励
    initial begin
        rst = 1;
        time_limit = 8'd10;  // 超时时间设置为10秒
        current_state = 2'b01; // 等待输入状态

        #50 rst = 0;  // 释放复位

        
        // 模拟状态变化
        #500 current_state = 2'b10; // 检查结果状态
        #1000 current_state = 2'b11; // 游戏结束状态
        #5000;

        $finish; // 结束仿真
    end

    // 监控输出
    initial begin
        $monitor("Time=%0dns, rst=%b, time_limit=%d, clk_out=%d, timeout=%b", 
                 $time, rst, time_limit, clk_out, timeout);
    end

endmodule
