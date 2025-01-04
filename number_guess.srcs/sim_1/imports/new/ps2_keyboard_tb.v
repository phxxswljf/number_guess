`timescale 1ns / 1ps

module ps2_keyboard_tb;

    // �ź�����
    reg clk;                     // FPGA ϵͳʱ��
    reg ps2_clk;                 // PS/2 ʱ���ź�
    reg ps2_data;                // PS/2 �����ź�
    reg [2:0] current_state;     // ��ǰ״̬
    wire [7:0] final_input;      // ��������ֵ
    wire input_confirmed;        // ����ȷ���ź�

    // ʱ�����ڲ���
    parameter CLK_PERIOD = 10;   // ϵͳʱ������ 10ns (100MHz)
    parameter PS2_CLK_PERIOD = 50_000; // PS/2 ʱ������Լ 20us (50kHz)

    // ʵ����������ģ��
    ps2_keyboard uut (
        .clk(clk),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .current_state(current_state),
        .final_input(final_input),
        .input_confirmed(input_confirmed)
    );

    // ϵͳʱ������
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk; // 100MHz ʱ��
    end

    // PS/2 ʱ����������
    task ps2_send_byte(input [7:0] data_byte);
        integer i;
        begin
            ps2_data = 0; // ��ʼλ
            #(PS2_CLK_PERIOD);
            for (i = 0; i < 8; i = i + 1) begin
                ps2_clk = 0;
                ps2_data = data_byte[i]; // ��������λ����λ�ȷ��ͣ�
                #(PS2_CLK_PERIOD / 2);
                ps2_clk = 1;
                #(PS2_CLK_PERIOD / 2);
            end
            ps2_clk = 0;
            ps2_data = ~(^data_byte); // ��żУ��λ
            #(PS2_CLK_PERIOD / 2);
            ps2_clk = 1;
            #(PS2_CLK_PERIOD / 2);

            ps2_clk = 0;
            ps2_data = 1; // ֹͣλ
            #(PS2_CLK_PERIOD / 2);
            ps2_clk = 1;
            #(PS2_CLK_PERIOD / 2);
        end
    endtask

    // ���Թ���
    initial begin
        // ��ʼ���ź�
        ps2_clk = 1;
        ps2_data = 1;
        current_state = 3'b010; // ����Ϊ WAIT_INPUT ״̬

        // �ȴ���λ����
        #(10 * CLK_PERIOD);

        // �������� "1" ��ɨ���� (����ɨ����Ϊ 0x45)
        $display("Sending digit 1 (0x45)...");
        ps2_send_byte(8'h45);
        #(10 * PS2_CLK_PERIOD);

        // �������� "2" ��ɨ���� (����ɨ����Ϊ 0x46)
        $display("Sending digit 2 (0x46)...");
        ps2_send_byte(8'h46);
        #(10 * PS2_CLK_PERIOD);

        // ���ͻس�����ɨ���� (����ɨ����Ϊ 0x5A)
        $display("Sending ENTER key (0x5A)...");
        ps2_send_byte(8'h5A);
        #(10 * PS2_CLK_PERIOD);

        // �ȴ�һ��ʱ�䣬�鿴���
        #(50 * PS2_CLK_PERIOD);

        $finish; // ��������
    end

    // ����ź�
    initial begin
        $monitor("Time=%0dns, ps2_clk=%b, ps2_data=%b, final_input=%d, input_confirmed=%b",
                 $time, ps2_clk, ps2_data, final_input, input_confirmed);
    end

endmodule
