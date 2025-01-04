`timescale 1ns / 1ps

module ps2_keyboard_tb;

    // 信号声明
    reg clk;                     // FPGA 系统时钟
    reg ps2_clk;                 // PS/2 时钟信号
    reg ps2_data;                // PS/2 数据信号
    reg [2:0] current_state;     // 当前状态
    wire [7:0] final_input;      // 最终输入值
    wire input_confirmed;        // 输入确认信号

    // 时钟周期参数
    parameter CLK_PERIOD = 10;   // 系统时钟周期 10ns (100MHz)
    parameter PS2_CLK_PERIOD = 50_000; // PS/2 时钟周期约 20us (50kHz)

    // 实例化待测试模块
    ps2_keyboard uut (
        .clk(clk),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .current_state(current_state),
        .final_input(final_input),
        .input_confirmed(input_confirmed)
    );

    // 系统时钟生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk; // 100MHz 时钟
    end

    // PS/2 时钟生成任务
    task ps2_send_byte(input [7:0] data_byte);
        integer i;
        begin
            ps2_data = 0; // 起始位
            #(PS2_CLK_PERIOD);
            for (i = 0; i < 8; i = i + 1) begin
                ps2_clk = 0;
                ps2_data = data_byte[i]; // 发送数据位（低位先发送）
                #(PS2_CLK_PERIOD / 2);
                ps2_clk = 1;
                #(PS2_CLK_PERIOD / 2);
            end
            ps2_clk = 0;
            ps2_data = ~(^data_byte); // 奇偶校验位
            #(PS2_CLK_PERIOD / 2);
            ps2_clk = 1;
            #(PS2_CLK_PERIOD / 2);

            ps2_clk = 0;
            ps2_data = 1; // 停止位
            #(PS2_CLK_PERIOD / 2);
            ps2_clk = 1;
            #(PS2_CLK_PERIOD / 2);
        end
    endtask

    // 测试过程
    initial begin
        // 初始化信号
        ps2_clk = 1;
        ps2_data = 1;
        current_state = 3'b010; // 设置为 WAIT_INPUT 状态

        // 等待复位结束
        #(10 * CLK_PERIOD);

        // 发送数字 "1" 的扫描码 (假设扫描码为 0x45)
        $display("Sending digit 1 (0x45)...");
        ps2_send_byte(8'h45);
        #(10 * PS2_CLK_PERIOD);

        // 发送数字 "2" 的扫描码 (假设扫描码为 0x46)
        $display("Sending digit 2 (0x46)...");
        ps2_send_byte(8'h46);
        #(10 * PS2_CLK_PERIOD);

        // 发送回车键的扫描码 (假设扫描码为 0x5A)
        $display("Sending ENTER key (0x5A)...");
        ps2_send_byte(8'h5A);
        #(10 * PS2_CLK_PERIOD);

        // 等待一段时间，查看结果
        #(50 * PS2_CLK_PERIOD);

        $finish; // 结束仿真
    end

    // 监控信号
    initial begin
        $monitor("Time=%0dns, ps2_clk=%b, ps2_data=%b, final_input=%d, input_confirmed=%b",
                 $time, ps2_clk, ps2_data, final_input, input_confirmed);
    end

endmodule
