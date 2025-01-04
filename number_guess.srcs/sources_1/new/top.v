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


module top (
    input wire clk,               // ʱ���ź�
    input wire rst,               // ��λ�ź�
    input wire my_start,          // ��Ϸ��ʼ�ź�
    input wire diff,              //��һ��ѡ����Ѷ� 
    
    //����
    input wire ps2_clk,           // PS/2ʱ���ź�
    input wire ps2_data,          // PS/2������
    
    //7�������
    output wire [6:0] seg_display,  // �߶��������ʾ�ź�
    output wire [7:0] an,           // �߶������ʹ���ź�
    
    // MP3
    output reg play_sound,        // ����MP3��������
    output reg [1:0] sound_code   // MP3���ŵ���������
    
);

    wire [7:0] target_number; // Ŀ�����֣�1~100��
    // ״̬����
    localparam IDLE         = 3'b000; // ����״̬--��Ϸ��δ��ʼ
    localparam START_GAME   = 3'b001; // ������Ϸ
    localparam WAIT_INPUT   = 3'b010; // �ȴ�����
    localparam CHECK_RESULT = 3'b011; // ���������
    localparam TIMEOUT      = 3'b100; // ��ʱ״̬
    localparam WIN          = 3'b101; // ��Ϸʤ��

    // ��Ϸ״̬����һ��״̬
    reg [2:0] current_state, next_state;

    // �����������
    reg [7:0] random_number; // ���������������Χ 0-99
        
    parameter time_limit=30;  //�����ҵ���Ϸʱ�䣡��
  
     // MP3 �����ź�����
       wire mp3_start_play;           // ����MP3��ʼ����
       wire mp3_spi_miso;             // SPI ��������
       wire mp3_spi_clk;              // SPI ʱ�����
       wire mp3_spi_cs;               // SPI Ƭѡ���
       wire mp3_spi_mosi;             // SPI �������
       wire mp3_audio_data;           // ��Ƶ�������
       wire mp3_audio_ready;          // ��Ƶ����׼���ź�
       wire mp3_playing;              // MP3����״̬
       
    // ʵ����mp3
     mp3_player mp3_inst (
            .clk(clk),                  // ϵͳʱ��
            .rst(rst),                  // ��λ�ź�
            .start_play(mp3_start_play), // MP3���ſ�ʼ�ź�
            .spi_miso(mp3_spi_miso),     // SPI ��������
            .spi_clk(mp3_spi_clk),       // SPI ʱ���ź�
            .spi_cs(mp3_spi_cs),         // SPI Ƭѡ�ź�
            .spi_mosi(mp3_spi_mosi),     // SPI �������
            .audio_data(mp3_audio_data), // ��Ƶ�������
            .mp3_playing(mp3_playing),   // MP3����״̬
            .audio_ready(mp3_audio_ready) // ��Ƶ����׼���ź�
        );
     wire [9:0] final_input;

       // ʵ���� ps2_keyboard ģ��
    ps2_keyboard u_ps2_keyboard (
        .clk(clk),                   // ����ϵͳʱ��
        .ps2_clk(ps2_clk),           // ����PS/2ʱ���ź�
        .ps2_data(ps2_data),         // ����PS/2�������ź�
        .current_state(current_state), // ��ǰ״̬
        .final_input(final_input),   // ������������
        .input_confirmed(input_confirmed) // ����ȷ���ź�
    );
    
      reg [7:0] max_value;  // ���ֵ����Χ��

      wire timeout;  // ��ʱ�ź�
      wire [7:0] clk_out;   //��ǰ��ʱ����ʱ��
      // ʵ���� clk_timer ģ��
           clk_timer #(
          .TIME_LIMIT(time_limit)
           )u_clk_timer (
               .clk(clk),
               .rst(rst),
               .current_state(current_state),
               .timeout(timeout),
               .clk_out(clk_out)
           );
           
     // ʵ���� seven_seg_mux ģ��
    seven_seg_mux u_seven_seg_mux (
         .final_input(final_input),
         .clk_out(clk_out),
         .clk(clk),
         .rst(rst),
         .input_confirmed(input_confirmed),
         .seg_display(seg_display),
         .an(an) // ʹ���ź���������ӵ������Ӳ������
     );

      // ͨ�������ź�ѡ��ͬ�����ֵ
         always @(*) begin
             if (diff == 1) begin
                 max_value = 200;  // ���diffΪ1������0~200�������
             end else begin
                 max_value = 100;  // ���diffΪ0������0~100�������
             end
         end
     
         // ʵ�����������������������max_value
         random_number_generator rng_inst (
             .clk(clk),
             .rst(rst),
             .max_value(max_value), // ��max_value���ݸ�������
             .random_number(target_number) // ���Ŀ������
         );


    // ״̬�������߼�
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE; // ��λʱ����IDLE״̬
        end else begin
            current_state <= next_state;
        end
    end
    
 
    
    // ��һ��״̬�߼�
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (my_start) begin
                    next_state = START_GAME; // ���my_start�ź���Ч�������START_GAME״̬
                end else begin
                    next_state = IDLE;
                end
            end

            START_GAME: begin
                next_state = WAIT_INPUT; // ������Ϸ�󣬽���WAIT_INPUT״̬
    
            end

            WAIT_INPUT: begin
                if (input_confirmed) begin
                    next_state = CHECK_RESULT; // ���������׼���ã�����CHECK_RESULT״̬
                end else if (timeout) begin
                    next_state = TIMEOUT; // �����ʱ������TIMEOUT״̬
                end else begin
                    next_state = WAIT_INPUT; // �����ȴ�����
                end
            end

            CHECK_RESULT: begin
                if (final_input == target_number) begin
                    next_state = WIN; // ����²���ȷ��������Ϸʤ��״̬
                end else begin
                    next_state = WAIT_INPUT; // �´��ˣ������ȴ�����
                end
            end

            TIMEOUT: begin
                next_state = IDLE; // ��ʱ״̬����GAME_OVER����ʾ��ʱ��Ϣ
            end

            WIN: begin
                next_state = IDLE; // ��Ϸ�����󣬻ص�IDLE״̬
            end

            default: begin
                next_state = IDLE; // Ĭ�Ͻ���IDLE״̬
            end
        endcase
    end
    

    // �����߼�
    always @(posedge clk or posedge rst) begin
        if (rst) begin
             play_sound=0;
        end else begin
            case (current_state)
       
                CHECK_RESULT: begin
                    if (final_input > target_number) begin
                        play_sound <= 1;           // ����"�´���"����
                        sound_code <= 2'b00;       // �趨Ϊ"�´���"����
                    end else if (final_input < target_number) begin
               
                        play_sound <= 1;           // ����"��С��"����
                        sound_code <= 2'b01;       // �趨Ϊ"��С��"����
                    end else begin
            
                        play_sound <= 1;           // ����"�¶���"����
                        sound_code <= 2'b10;       // �趨Ϊ"�¶���"����  ʤ������Ч
                    end
                end

                TIMEOUT: begin
                    play_sound <= 1;         // ����"��ʱ"����
                    sound_code <= 2'b11;     // �趨Ϊ"��ʱ"����
                end

                WIN: begin
                    play_sound <= 0;             // ֹͣ��������
                end

                default: begin

                    play_sound <= 0;             // Ĭ��ֹͣ��������
                end
            endcase
        end
    end



endmodule



