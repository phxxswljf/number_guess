`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/03 17:03:21
// Design Name: 
// Module Name: top
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


module mp3_player (
    input wire clk,                // ϵͳʱ��
    input wire rst,                // ��λ�ź�
    input wire start_play,         // ��ʼ�����ź�
    input wire spi_miso,           // SPI ��������
    output reg spi_clk,            // SPI ʱ���ź�
    output reg spi_cs,             // SPI Ƭѡ�ź�
    output reg spi_mosi,           // SPI �������
    output reg audio_data,         // ��Ƶ�������
    output reg mp3_playing,        // MP3 ����״̬
    output reg audio_ready         // ��Ƶ����׼���ź�
);

    // ״̬����
    localparam IDLE         = 3'b000;
    localparam PLAY_MP3     = 3'b001;
    localparam WAIT_LRC     = 3'b010;
    localparam END_PLAY     = 3'b100;

    reg [2:0] state, next_state;
    reg [23:0] flash_addr;        // SPI Flash ��ַ
    reg [7:0] mp3_data;           // �洢��ȡ�� MP3 ����

    // ״̬��
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // ״̬ת�ƺ��߼�����
    always @(*) begin
        case (state)
            IDLE: begin
                if (start_play) begin
                    next_state = PLAY_MP3;
                end else begin
                    next_state = IDLE;
                end
            end

            PLAY_MP3: begin
                if (audio_ready) begin
                    next_state = WAIT_LRC;  // ��Ƶ������Ϻ󣬴��� LRC
                end else begin
                    next_state = PLAY_MP3;
                end
            end

            WAIT_LRC: begin
                // �������ʹ�� LRC �ļ��е�ʱ���ͬ�����
                // �����ǲ���Ҫ��ʾ��ʣ�ֻ��Ҫͬ���ͺ�
                next_state = END_PLAY;
            end

            END_PLAY: begin
                next_state = IDLE; // ������Ϻ�ص�����״̬
            end

            default: next_state = IDLE;
        endcase
    end

    // SPI Flash ��ȡ�߼����� Flash �ж�ȡ MP3 ����
    always @(posedge clk) begin
        if (state == PLAY_MP3) begin
            // ��ȡ MP3 ���ݿ�
            // �������ͨ�� SPI �ӿڴ� SPI Flash �л�ȡ���ݲ����䵽 MP3 ����оƬ��VS1003B��
            spi_mosi <= mp3_data;
            spi_cs <= 0;    // ѡ�� SPI Flash
            spi_clk <= ~spi_clk;  // ���� SPI ʱ��

            // ���� Flash ��ַ
            flash_addr <= flash_addr + 1;
            mp3_data <= spi_miso; // �� SPI �ӿڶ�ȡ����
            audio_ready <= 1; // ������׼����
        end else begin
            spi_cs <= 1;   // ֹͣ SPI Flash ����
            audio_ready <= 0;  // û������׼��
        end
    end

    // ��Ƶ���ſ��ƣ�����ȡ����Ƶ���ݴ���� MP3 ����оƬ��VS1003B��
    always @(posedge clk) begin
        if (state == PLAY_MP3 && audio_ready) begin
            audio_data <= mp3_data;  // ����Ƶ���ݴ��䵽 VS1003B
            mp3_playing <= 1;        // ����״̬
        end else begin
            mp3_playing <= 0;        // ֹͣ����
        end
    end

endmodule
