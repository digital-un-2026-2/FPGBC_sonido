module top #(
    parameter CLK_HZ = 27_000_000   // ajusta a la frecuencia de tu oscilador
)(
    input  clk,
    input  rst_n,   // señal de reset (activa en bajo)
    output audio_l, // pin 56
    output audio_r  // pin 57
);
    localparam HALF = CLK_HZ / (440 * 2);
    
    reg [31:0] cnt = 0;
    reg tone = 0;

    always @(posedge clk) begin
        if (~rst_n) begin
            cnt  <= 0;
            tone <= 0;
        end else begin
            if (cnt >= HALF - 1) begin
                cnt  <= 0;
                tone <= ~tone;
            end else begin
                cnt  <= cnt + 1;
            end
        end
    end

    assign audio_l = tone;
    assign audio_r = tone;
endmodule