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
    input [9:0] final_input,     // 输入的数字，用于显示（0-200）
    input [7:0] clk_out,         // 输入的时钟计数值（0-30）
    input clk,                   // 系统时钟信号
    input rst,                   // 复位信号
    input input_confirmed,       // 回车信号，数字是否要更新
    output reg [6:0] seg_display, // 7段数码管显示的输出
    output reg [7:0] an          // 数码管使能信号
);

    reg [2:0] digit_sel;        // 当前选中的数码管
    reg [16:0] clk_div;         // 分频计数器

    // 时钟分频：降低时钟频率，用于切换数码管
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div <= 0;
        end else begin
            clk_div <= clk_div + 1;
        end
    end

    // 数码管切换控制：每次选择一个数码管
    always @(posedge clk_div[16] or posedge rst) begin
        if (rst) begin
            digit_sel <= 3'b000;
        end else begin
            digit_sel <= digit_sel + 1;
        end
    end

    // 数码管使能信号生成：激活 1-3 和 5-6 号数码管
    always @(*) begin
        an = 8'b11111111; // 默认关闭所有数码管
        case (digit_sel)
            3'b000: an = 8'b11111110; // 激活数码管1
            3'b001: an = 8'b11111101; // 激活数码管2
            3'b010: an = 8'b11111011; // 激活数码管3
            3'b011: an = 8'b11101111; // 激活数码管5
            3'b100: an = 8'b11011111; // 激活数码管6
            default: an = 8'b11111111; // 其他数码管关闭
        endcase
    end

    // 数码管显示内容选择
    always @(*) begin
        case (digit_sel)
            // 数码管1-3：显示 final_input 或 0
            3'b010: seg_display = input_confirmed ? digit_to_7seg(final_input / 100) : digit_to_7seg(0);      //百位  3
            3'b001: seg_display = input_confirmed ? digit_to_7seg((final_input / 10) % 10) : digit_to_7seg(0);//十位  2
            3'b000: seg_display = input_confirmed ? digit_to_7seg(final_input % 10) : digit_to_7seg(0);       //个位  1
            // 数码管5-6：显示 clk_out 的十位和个位
            3'b100: seg_display = digit_to_7seg(clk_out / 10);    //十位  6
            3'b011: seg_display = digit_to_7seg(clk_out % 10);    //个位  5
            default: seg_display = 7'b1111111; // 默认关闭
        endcase
    end

    // 数字到7段数码管的转换
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





