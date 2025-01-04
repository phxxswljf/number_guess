`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 17:03:21
// Design Name: 
// Module Name: ps2_keyboard
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


module ps2_keyboard (
    input wire clk,                 // FPGA系统时钟
    input wire ps2_clk,             // PS/2时钟信号
    input wire ps2_data,            // PS/2数据线
    input wire [2:0] current_state, // 当前状态
    output reg [9:0] final_input,   // 最终输入的数字，支持0到999的范围
    output reg input_confirmed      // 输入确认信号，当回车键按下时为1
);

    // 状态机状态
    localparam IDLE       = 2'b00; // 空闲状态
    localparam RECEIVE    = 2'b01; // 接收数据
    localparam PROCESS    = 2'b10; // 处理数据

    reg [1:0] state;              // 状态寄存器
    reg [7:0] shift_reg;          // 移位寄存器，用于接收8位数据
    reg [3:0] bit_count;          // 数据位计数
    reg [9:0] input_buffer;       // 输入缓冲区，最多支持3位数，宽度为10位
    reg [3:0] input_length;       // 输入长度计数器
    reg key_break;                // 断码标志位

    // 消抖信号
    reg ps2_clk_r0, ps2_clk_r1, ps2_clk_stable;  // 用于检测ps2_clk信号的消抖
    reg ps2_data_r0, ps2_data_r1, ps2_data_stable;  // 用于检测ps2_data信号的消抖
    wire ps2_clk_falling;
    wire ps2_data_stable_wire;

    // 时钟下降沿检测
    always @(posedge clk) begin
        ps2_clk_r0 <= ps2_clk;
        ps2_clk_r1 <= ps2_clk_r0;
        ps2_clk_stable <= (ps2_clk_r0 == ps2_clk_r1); // 判断ps2_clk是否稳定

        ps2_data_r0 <= ps2_data;
        ps2_data_r1 <= ps2_data_r0;
        ps2_data_stable <= (ps2_data_r0 == ps2_data_r1); // 判断ps2_data是否稳定
    end

    assign ps2_clk_falling = (ps2_clk_r1 == 1'b1) && (ps2_clk_r0 == 1'b0); // 检测下降沿
    assign ps2_data_stable_wire = ps2_data_stable;

    // 状态机和数据接收逻辑
    always @(posedge clk) begin
        if (current_state == 3'b010) begin // 等待输入状态
            case (state)
                IDLE: begin
                    input_confirmed <= 0; // 复位输入确认
                    key_break <= 0;       // 清除断码标志
                    bit_count <= 0;
                    input_length <= 0;    // 重置输入长度
                    if (ps2_clk_falling && ps2_data_stable_wire) begin
                        state <= RECEIVE; // 开始接收数据
                    end
                end

                RECEIVE: begin
                    if (ps2_clk_falling && ps2_data_stable_wire) begin
                        if (bit_count < 8) begin
                            shift_reg <= {ps2_data, shift_reg[7:1]}; // 接收数据位
                            bit_count <= bit_count + 1;
                        end else begin
                            state <= PROCESS; // 数据接收完成，处理数据
                        end
                    end
                end

                PROCESS: begin
                    if (shift_reg == 8'hF0) begin
                        key_break <= 1; // 断码标志置位
                    end else begin
                        key_break <= 0;  // 清除断码标志
                        // 检查通码对应的数字键
                        case (shift_reg)
                            8'h45: begin // 0
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 0;  // 累积数字0
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h16: begin // 1
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 1;  // 累积数字1
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h1E: begin // 2
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 2;  // 累积数字2
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h26: begin // 3
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 3;  // 累积数字3
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h25: begin // 4
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 4;  // 累积数字4
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h2E: begin // 5
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 5;  // 累积数字5
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h36: begin // 6
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 6;  // 累积数字6
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h3D: begin // 7
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 7;  // 累积数字7
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h3E: begin // 8
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 8;  // 累积数字8
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h46: begin // 9
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 9;  // 累积数字9
                                    input_length <= input_length + 1;
                                end
                            end

                            default: begin
                                // 不处理其他按键
                            end
                        endcase
                    end
                    
                    // 如果按下回车键
                    if (shift_reg == 8'h5A) begin  // 回车键
                        final_input <= input_buffer;  // 输入确认，赋值最终结果
                        input_confirmed <= 1;         // 输入确认信号置位
                        input_buffer <= 0;            // 清空输入缓冲区
                        input_length <= 0;            // 重置输入长度
                    end

                    state <= IDLE; // 返回空闲状态
                end

                default: state <= IDLE; // 默认状态
            endcase
        end else begin
            // 非 WAIT_INPUT 状态时，重置寄存器
            state <= IDLE;
            key_break <= 0;
            bit_count <= 0;
            input_buffer <= 0;
            input_length <= 0;
            final_input <= 0;
            input_confirmed <= 0;
        end
    end

endmodule
