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
    input wire clk,                // 系统时钟
    input wire rst,                // 复位信号
    input wire start_play,         // 开始播放信号
    input wire spi_miso,           // SPI 数据输入
    output reg spi_clk,            // SPI 时钟信号
    output reg spi_cs,             // SPI 片选信号
    output reg spi_mosi,           // SPI 数据输出
    output reg audio_data,         // 音频数据输出
    output reg mp3_playing,        // MP3 播放状态
    output reg audio_ready         // 音频数据准备信号
);

    // 状态定义
    localparam IDLE         = 3'b000;
    localparam PLAY_MP3     = 3'b001;
    localparam WAIT_LRC     = 3'b010;
    localparam END_PLAY     = 3'b100;

    reg [2:0] state, next_state;
    reg [23:0] flash_addr;        // SPI Flash 地址
    reg [7:0] mp3_data;           // 存储读取的 MP3 数据

    // 状态机
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // 状态转移和逻辑控制
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
                    next_state = WAIT_LRC;  // 音频播放完毕后，处理 LRC
                end else begin
                    next_state = PLAY_MP3;
                end
            end

            WAIT_LRC: begin
                // 这里可以使用 LRC 文件中的时间戳同步歌词
                // 但我们不需要显示歌词，只需要同步就好
                next_state = END_PLAY;
            end

            END_PLAY: begin
                next_state = IDLE; // 播放完毕后回到空闲状态
            end

            default: next_state = IDLE;
        endcase
    end

    // SPI Flash 读取逻辑：从 Flash 中读取 MP3 数据
    always @(posedge clk) begin
        if (state == PLAY_MP3) begin
            // 读取 MP3 数据块
            // 这里可以通过 SPI 接口从 SPI Flash 中获取数据并传输到 MP3 解码芯片（VS1003B）
            spi_mosi <= mp3_data;
            spi_cs <= 0;    // 选择 SPI Flash
            spi_clk <= ~spi_clk;  // 控制 SPI 时钟

            // 更新 Flash 地址
            flash_addr <= flash_addr + 1;
            mp3_data <= spi_miso; // 从 SPI 接口读取数据
            audio_ready <= 1; // 数据已准备好
        end else begin
            spi_cs <= 1;   // 停止 SPI Flash 访问
            audio_ready <= 0;  // 没有数据准备
        end
    end

    // 音频播放控制：将读取的音频数据传输给 MP3 解码芯片（VS1003B）
    always @(posedge clk) begin
        if (state == PLAY_MP3 && audio_ready) begin
            audio_data <= mp3_data;  // 将音频数据传输到 VS1003B
            mp3_playing <= 1;        // 播放状态
        end else begin
            mp3_playing <= 0;        // 停止播放
        end
    end

endmodule
