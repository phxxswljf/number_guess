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
  // �ź�����
  reg [7:0] final_input;     // ����ֵ�����ڿ���7���������ʾ
  reg [7:0] clk_out;         // ʱ���������������ʱ���л���
  reg clk;                   // ʱ���ź�
  reg rst;                   // ��λ�ź�
  wire [6:0] seg_display;    // 7���������ʾ���
  
  // ʱ�����ڲ���
  parameter CLK_PERIOD = 10;

  // ʵ���� seven_seg_mux ģ��
  seven_seg_mux uut (
      .final_input(final_input),
      .clk_out(clk_out),
      .clk(clk),
      .rst(rst),
      .seg_display(seg_display)
  );

  // ����ʱ���ź�
  initial begin
      clk = 0;
      forever #(CLK_PERIOD / 2) clk = ~clk; // 100MHz ʱ�ӣ�10ns���ڣ�
  end

  // ���Լ���
  initial begin
      // ��ʼֵ����
      rst = 1;                   // ��λ�źż���
      final_input = 8'd123;      // ���� final_input Ϊ 123
      clk_out = 8'd45;           // ���� clk_out Ϊ 45
      #50 rst = 0;               // �ͷŸ�λ�ź�

      // �ı�����ֵ
      #200 final_input = 8'd200; // ���� final_input Ϊ 200
      clk_out = 8'd30;           // ���� clk_out Ϊ 30
      #200 final_input = 8'd99;  // ���� final_input Ϊ 99
      clk_out = 8'd15;           // ���� clk_out Ϊ 15

      #500;                      // ��ʱ500ns
      $finish;                   // ��������
  end

  // ������
  initial begin
      $monitor("Time=%0dns, final_input=%d, clk_out=%d, seg_display=%b", 
               $time, final_input, clk_out, seg_display);
  end
endmodule
