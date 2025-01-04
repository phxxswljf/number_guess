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
    input wire clk,                 // FPGAϵͳʱ��
    input wire ps2_clk,             // PS/2ʱ���ź�
    input wire ps2_data,            // PS/2������
    input wire [2:0] current_state, // ��ǰ״̬
    output reg [9:0] final_input,   // ������������֣�֧��0��999�ķ�Χ
    output reg input_confirmed      // ����ȷ���źţ����س�������ʱΪ1
);

    // ״̬��״̬
    localparam IDLE       = 2'b00; // ����״̬
    localparam RECEIVE    = 2'b01; // ��������
    localparam PROCESS    = 2'b10; // ��������

    reg [1:0] state;              // ״̬�Ĵ���
    reg [7:0] shift_reg;          // ��λ�Ĵ��������ڽ���8λ����
    reg [3:0] bit_count;          // ����λ����
    reg [9:0] input_buffer;       // ���뻺���������֧��3λ�������Ϊ10λ
    reg [3:0] input_length;       // ���볤�ȼ�����
    reg key_break;                // �����־λ

    // �����ź�
    reg ps2_clk_r0, ps2_clk_r1, ps2_clk_stable;  // ���ڼ��ps2_clk�źŵ�����
    reg ps2_data_r0, ps2_data_r1, ps2_data_stable;  // ���ڼ��ps2_data�źŵ�����
    wire ps2_clk_falling;
    wire ps2_data_stable_wire;

    // ʱ���½��ؼ��
    always @(posedge clk) begin
        ps2_clk_r0 <= ps2_clk;
        ps2_clk_r1 <= ps2_clk_r0;
        ps2_clk_stable <= (ps2_clk_r0 == ps2_clk_r1); // �ж�ps2_clk�Ƿ��ȶ�

        ps2_data_r0 <= ps2_data;
        ps2_data_r1 <= ps2_data_r0;
        ps2_data_stable <= (ps2_data_r0 == ps2_data_r1); // �ж�ps2_data�Ƿ��ȶ�
    end

    assign ps2_clk_falling = (ps2_clk_r1 == 1'b1) && (ps2_clk_r0 == 1'b0); // ����½���
    assign ps2_data_stable_wire = ps2_data_stable;

    // ״̬�������ݽ����߼�
    always @(posedge clk) begin
        if (current_state == 3'b010) begin // �ȴ�����״̬
            case (state)
                IDLE: begin
                    input_confirmed <= 0; // ��λ����ȷ��
                    key_break <= 0;       // ��������־
                    bit_count <= 0;
                    input_length <= 0;    // �������볤��
                    if (ps2_clk_falling && ps2_data_stable_wire) begin
                        state <= RECEIVE; // ��ʼ��������
                    end
                end

                RECEIVE: begin
                    if (ps2_clk_falling && ps2_data_stable_wire) begin
                        if (bit_count < 8) begin
                            shift_reg <= {ps2_data, shift_reg[7:1]}; // ��������λ
                            bit_count <= bit_count + 1;
                        end else begin
                            state <= PROCESS; // ���ݽ�����ɣ���������
                        end
                    end
                end

                PROCESS: begin
                    if (shift_reg == 8'hF0) begin
                        key_break <= 1; // �����־��λ
                    end else begin
                        key_break <= 0;  // ��������־
                        // ���ͨ���Ӧ�����ּ�
                        case (shift_reg)
                            8'h45: begin // 0
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 0;  // �ۻ�����0
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h16: begin // 1
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 1;  // �ۻ�����1
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h1E: begin // 2
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 2;  // �ۻ�����2
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h26: begin // 3
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 3;  // �ۻ�����3
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h25: begin // 4
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 4;  // �ۻ�����4
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h2E: begin // 5
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 5;  // �ۻ�����5
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h36: begin // 6
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 6;  // �ۻ�����6
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h3D: begin // 7
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 7;  // �ۻ�����7
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h3E: begin // 8
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 8;  // �ۻ�����8
                                    input_length <= input_length + 1;
                                end
                            end

                            8'h46: begin // 9
                                if (input_length < 3) begin
                                    input_buffer <= (input_buffer * 10) + 9;  // �ۻ�����9
                                    input_length <= input_length + 1;
                                end
                            end

                            default: begin
                                // ��������������
                            end
                        endcase
                    end
                    
                    // ������»س���
                    if (shift_reg == 8'h5A) begin  // �س���
                        final_input <= input_buffer;  // ����ȷ�ϣ���ֵ���ս��
                        input_confirmed <= 1;         // ����ȷ���ź���λ
                        input_buffer <= 0;            // ������뻺����
                        input_length <= 0;            // �������볤��
                    end

                    state <= IDLE; // ���ؿ���״̬
                end

                default: state <= IDLE; // Ĭ��״̬
            endcase
        end else begin
            // �� WAIT_INPUT ״̬ʱ�����üĴ���
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
