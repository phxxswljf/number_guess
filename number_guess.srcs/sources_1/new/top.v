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
    input wire clk,               // 时钟信号
    input wire rst,               // 复位信号
    input wire my_start,          // 游戏开始信号
    input wire diff,              //这一关选择的难度 
    
    //键盘
    input wire ps2_clk,           // PS/2时钟信号
    input wire ps2_data,          // PS/2数据线
    
    //7段数码管
    output wire [6:0] seg_display,  // 七段数码管显示信号
    output wire [7:0] an,           // 七段数码管使能信号
    
    // MP3
    output reg play_sound,        // 控制MP3播放声音
    output reg [1:0] sound_code   // MP3播放的声音类型
    
);

    wire [7:0] target_number; // 目标数字（1~100）
    // 状态定义
    localparam IDLE         = 3'b000; // 空闲状态--游戏还未开始
    localparam START_GAME   = 3'b001; // 启动游戏
    localparam WAIT_INPUT   = 3'b010; // 等待输入
    localparam CHECK_RESULT = 3'b011; // 检查输入结果
    localparam TIMEOUT      = 3'b100; // 超时状态
    localparam WIN          = 3'b101; // 游戏胜利

    // 游戏状态和下一个状态
    reg [2:0] current_state, next_state;

    // 随机数生成器
    reg [7:0] random_number; // 随机数生成器，范围 0-99
        
    parameter time_limit=30;  //设置我的游戏时间！！
  
     // MP3 控制信号连接
       wire mp3_start_play;           // 控制MP3开始播放
       wire mp3_spi_miso;             // SPI 数据输入
       wire mp3_spi_clk;              // SPI 时钟输出
       wire mp3_spi_cs;               // SPI 片选输出
       wire mp3_spi_mosi;             // SPI 数据输出
       wire mp3_audio_data;           // 音频数据输出
       wire mp3_audio_ready;          // 音频数据准备信号
       wire mp3_playing;              // MP3播放状态
       
    // 实例化mp3
     mp3_player mp3_inst (
            .clk(clk),                  // 系统时钟
            .rst(rst),                  // 复位信号
            .start_play(mp3_start_play), // MP3播放开始信号
            .spi_miso(mp3_spi_miso),     // SPI 数据输入
            .spi_clk(mp3_spi_clk),       // SPI 时钟信号
            .spi_cs(mp3_spi_cs),         // SPI 片选信号
            .spi_mosi(mp3_spi_mosi),     // SPI 数据输出
            .audio_data(mp3_audio_data), // 音频数据输出
            .mp3_playing(mp3_playing),   // MP3播放状态
            .audio_ready(mp3_audio_ready) // 音频数据准备信号
        );
     wire [9:0] final_input;

       // 实例化 ps2_keyboard 模块
    ps2_keyboard u_ps2_keyboard (
        .clk(clk),                   // 传入系统时钟
        .ps2_clk(ps2_clk),           // 传入PS/2时钟信号
        .ps2_data(ps2_data),         // 传入PS/2数据线信号
        .current_state(current_state), // 当前状态
        .final_input(final_input),   // 最终输入数字
        .input_confirmed(input_confirmed) // 输入确认信号
    );
    
      reg [7:0] max_value;  // 最大值（范围）

      wire timeout;  // 超时信号
      wire [7:0] clk_out;   //当前计时器的时间
      // 实例化 clk_timer 模块
           clk_timer #(
          .TIME_LIMIT(time_limit)
           )u_clk_timer (
               .clk(clk),
               .rst(rst),
               .current_state(current_state),
               .timeout(timeout),
               .clk_out(clk_out)
           );
           
     // 实例化 seven_seg_mux 模块
    seven_seg_mux u_seven_seg_mux (
         .final_input(final_input),
         .clk_out(clk_out),
         .clk(clk),
         .rst(rst),
         .input_confirmed(input_confirmed),
         .seg_display(seg_display),
         .an(an) // 使能信号输出，连接到数码管硬件引脚
     );

      // 通过输入信号选择不同的最大值
         always @(*) begin
             if (diff == 1) begin
                 max_value = 200;  // 如果diff为1，生成0~200的随机数
             end else begin
                 max_value = 100;  // 如果diff为0，生成0~100的随机数
             end
         end
     
         // 实例化随机数生成器，并传递max_value
         random_number_generator rng_inst (
             .clk(clk),
             .rst(rst),
             .max_value(max_value), // 将max_value传递给生成器
             .random_number(target_number) // 输出目标数字
         );


    // 状态机控制逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE; // 复位时进入IDLE状态
        end else begin
            current_state <= next_state;
        end
    end
    
 
    
    // 下一个状态逻辑
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (my_start) begin
                    next_state = START_GAME; // 如果my_start信号有效，则进入START_GAME状态
                end else begin
                    next_state = IDLE;
                end
            end

            START_GAME: begin
                next_state = WAIT_INPUT; // 启动游戏后，进入WAIT_INPUT状态
    
            end

            WAIT_INPUT: begin
                if (input_confirmed) begin
                    next_state = CHECK_RESULT; // 如果输入已准备好，进入CHECK_RESULT状态
                end else if (timeout) begin
                    next_state = TIMEOUT; // 如果超时，进入TIMEOUT状态
                end else begin
                    next_state = WAIT_INPUT; // 继续等待输入
                end
            end

            CHECK_RESULT: begin
                if (final_input == target_number) begin
                    next_state = WIN; // 如果猜测正确，进入游戏胜利状态
                end else begin
                    next_state = WAIT_INPUT; // 猜错了，继续等待输入
                end
            end

            TIMEOUT: begin
                next_state = IDLE; // 超时状态进入GAME_OVER，显示超时信息
            end

            WIN: begin
                next_state = IDLE; // 游戏结束后，回到IDLE状态
            end

            default: begin
                next_state = IDLE; // 默认进入IDLE状态
            end
        endcase
    end
    

    // 反馈逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
             play_sound=0;
        end else begin
            case (current_state)
       
                CHECK_RESULT: begin
                    if (final_input > target_number) begin
                        play_sound <= 1;           // 播放"猜大了"声音
                        sound_code <= 2'b00;       // 设定为"猜大了"声音
                    end else if (final_input < target_number) begin
               
                        play_sound <= 1;           // 播放"猜小了"声音
                        sound_code <= 2'b01;       // 设定为"猜小了"声音
                    end else begin
            
                        play_sound <= 1;           // 播放"猜对了"声音
                        sound_code <= 2'b10;       // 设定为"猜对了"声音  胜利的音效
                    end
                end

                TIMEOUT: begin
                    play_sound <= 1;         // 播放"超时"声音
                    sound_code <= 2'b11;     // 设定为"超时"声音
                end

                WIN: begin
                    play_sound <= 0;             // 停止播放声音
                end

                default: begin

                    play_sound <= 0;             // 默认停止播放声音
                end
            endcase
        end
    end



endmodule



