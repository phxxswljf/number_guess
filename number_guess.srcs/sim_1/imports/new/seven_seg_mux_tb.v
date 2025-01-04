`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/17 12:30:18
// Design Name: 
// Module Name: seven_srg_mux_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Testbench for 7-segment display multiplexer
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module seven_srg_mux_tb();
  // 信号声明
  reg [7:0] final_input;     // 输入值，用于控制7段数码管显示
  reg [7:0] clk_out;         // 时钟输出（假设用于时钟切换）
  reg clk;                   // 时钟信号
  reg rst;                   // 复位信号
  wire [6:0] seg_display;    // 7段数码管显示输出
  
  // 时钟周期参数
  parameter CLK_PERIOD = 10;

  // 实例化 seven_seg_mux 模块
  seven_seg_mux uut (
      .final_input(final_input),
      .clk_out(clk_out),
      .clk(clk),
      .rst(rst),
      .seg_display(seg_display)
  );

  // 生成时钟信号
  initial begin
      clk = 0;
      forever #(CLK_PERIOD / 2) clk = ~clk; // 100MHz 时钟（10ns周期）
  end

  // 测试激励
  initial begin
      // 初始值设置
      rst = 1;                   // 复位信号激活
      final_input = 8'd123;      // 设置 final_input 为 123
      clk_out = 8'd45;           // 设置 clk_out 为 45
      #50 rst = 0;               // 释放复位信号

      // 改变输入值
      #200 final_input = 8'd200; // 更新 final_input 为 200
      clk_out = 8'd30;           // 更新 clk_out 为 30
      #200 final_input = 8'd99;  // 更新 final_input 为 99
      clk_out = 8'd15;           // 更新 clk_out 为 15

      #500;                      // 延时500ns
      $finish;                   // 结束仿真
  end

  // 监控输出
  initial begin
      $monitor("Time=%0dns, final_input=%d, clk_out=%d, seg_display=%b", 
               $time, final_input, clk_out, seg_display);
  end
endmodule
