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
    input wire clk,                   // ʱ���ź�
    input wire rst,                  // ��λ�ź�
    input wire [7:0] max_value,      // ���ֵ����Χ��
    output reg [7:0] random_number   // ��������
);

    // ����ͬ���������Ĳ��������Ը�����Ҫ������
    localparam A = 32'd1664525;   // ����
    localparam C = 32'd1013904223; // ����
    localparam M = 64'd4294967296; // ģ����2^32����32λ��ʾ
    
    // �������״̬�Ĵ���
    reg [31:0] seed;  // ��������ɵ�����

    // ÿ��ʱ�����ڲ����µ������
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seed <= 32'hDEADBEEF;  // ��λʱ����������Ϊһ������ֵ
            random_number <= 8'b0; // ��ʼ�����Ϊ0
        end else begin
            // ��������ͬ����������ʽ����α�����
            seed <= (A * seed + C) % M;  // ��������
            random_number <= seed[7:0] % (max_value + 1); // �����������ΧΪ 0 �� max_value
        end
    end

endmodule
