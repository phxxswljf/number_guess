`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/16 19:22:11
// Design Name: 
// Module Name: mux_7seg
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

module seven_seg_mux (
    input [9:0] final_input,     // ��������֣�������ʾ��0-200��
    input [7:0] clk_out,         // �����ʱ�Ӽ���ֵ��0-30��
    input clk,                   // ϵͳʱ���ź�
    input rst,                   // ��λ�ź�
    input input_confirmed,       // �س��źţ������Ƿ�Ҫ����
    output reg [6:0] seg_display, // 7���������ʾ�����
    output reg [7:0] an          // �����ʹ���ź�
);

    reg [2:0] digit_sel;        // ��ǰѡ�е������
    reg [16:0] clk_div;         // ��Ƶ������

    // ʱ�ӷ�Ƶ������ʱ��Ƶ�ʣ������л������
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div <= 0;
        end else begin
            clk_div <= clk_div + 1;
        end
    end

    // ������л����ƣ�ÿ��ѡ��һ�������
    always @(posedge clk_div[16] or posedge rst) begin
        if (rst) begin
            digit_sel <= 3'b000;
        end else begin
            digit_sel <= digit_sel + 1;
        end
    end

    // �����ʹ���ź����ɣ����� 1-3 �� 5-6 �������
    always @(*) begin
        an = 8'b11111111; // Ĭ�Ϲر����������
        case (digit_sel)
            3'b000: an = 8'b11111110; // ���������1
            3'b001: an = 8'b11111101; // ���������2
            3'b010: an = 8'b11111011; // ���������3
            3'b011: an = 8'b11101111; // ���������5
            3'b100: an = 8'b11011111; // ���������6
            default: an = 8'b11111111; // ��������ܹر�
        endcase
    end

    // �������ʾ����ѡ��
    always @(*) begin
        case (digit_sel)
            // �����1-3����ʾ final_input �� 0
            3'b010: seg_display = input_confirmed ? digit_to_7seg(final_input / 100) : digit_to_7seg(0);      //��λ  3
            3'b001: seg_display = input_confirmed ? digit_to_7seg((final_input / 10) % 10) : digit_to_7seg(0);//ʮλ  2
            3'b000: seg_display = input_confirmed ? digit_to_7seg(final_input % 10) : digit_to_7seg(0);       //��λ  1
            // �����5-6����ʾ clk_out ��ʮλ�͸�λ
            3'b100: seg_display = digit_to_7seg(clk_out / 10);    //ʮλ  6
            3'b011: seg_display = digit_to_7seg(clk_out % 10);    //��λ  5
            default: seg_display = 7'b1111111; // Ĭ�Ϲر�
        endcase
    end

    // ���ֵ�7������ܵ�ת��
    function [6:0] digit_to_7seg;
        input [3:0] digit;
        begin
            case (digit)
                 4'b0000:  digit_to_7seg=7'b1000000;  //0
                 4'b0001:  digit_to_7seg=7'b1111001;  //1
                 4'b0010:  digit_to_7seg=7'b0100100;  //2
                 4'b0011:  digit_to_7seg=7'b0110000;  //3
                 4'b0100:  digit_to_7seg=7'b0011001;  //4
                 4'b0101:  digit_to_7seg=7'b0010010;  //5
                 4'b0110:  digit_to_7seg=7'b0000010;  //6
                 4'b0111:  digit_to_7seg=7'b1111000;  //7
                 4'b1000:  digit_to_7seg=7'b0000000;  //8
                 4'b1001:  digit_to_7seg=7'b0010000;  //9
                 default:  digit_to_7seg=7'b1000000;  //0
            endcase
        end
    endfunction

endmodule





