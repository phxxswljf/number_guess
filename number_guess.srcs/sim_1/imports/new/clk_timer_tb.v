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

 // �ź�����
    reg clk;
    reg rst;
    reg [15:0] time_limit;
    reg [1:0]  current_state;
    wire timeout;
    wire [7:0] clk_out;

    // ʱ�����ڲ���
    parameter CLK_PERIOD = 10; // 100MHz ʱ��

    // ʵ���� clk_timer
    clk_timer uut (
        .clk(clk),
        .rst(rst),
        .time_limit(time_limit),
        .current_state(current_state),
        .timeout(timeout),
        .clk_out(clk_out)
    );

    // ����ʱ��
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk; // 100MHz ʱ��
    end

    // ���Լ���
    initial begin
        rst = 1;
        time_limit = 8'd10;  // ��ʱʱ������Ϊ10��
        current_state = 2'b01; // �ȴ�����״̬

        #50 rst = 0;  // �ͷŸ�λ

        
        // ģ��״̬�仯
        #500 current_state = 2'b10; // �����״̬
        #1000 current_state = 2'b11; // ��Ϸ����״̬
        #5000;

        $finish; // ��������
    end

    // ������
    initial begin
        $monitor("Time=%0dns, rst=%b, time_limit=%d, clk_out=%d, timeout=%b", 
                 $time, rst, time_limit, clk_out, timeout);
    end

endmodule
