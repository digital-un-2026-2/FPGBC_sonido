`timescale 1ns / 1ps

module top_TB;

    // Señales de entrada (declaradas como reg para generarlas)
    reg clk = 0;
    reg rst_n = 0; // Iniciamos en 0 (reset activado)

    // Señales de salida del módulo top (declaradas como wire para conectarlas)
    wire audio_l;
    wire audio_r;

    // Instancia del módulo top (Unit Under Test)
    top #(
        .CLK_HZ(27_000_000)
    ) u_top (
        .clk(clk),
        .rst_n(rst_n),
        .audio_l(audio_l),
        .audio_r(audio_r)
    );

    // Generador de reloj a 27 MHz 
    // Periodo completo = ~37.037 ns -> Mitad del periodo = 18.518 ns
    always #18.518 clk = ~clk;

    // Bloque de estímulos y control de la simulación
    initial begin
        // Configurar el archivo VCD para almacenar las ondas generadas
        $dumpfile("top_TB.vcd");
        $dumpvars(0, top_TB);

        // Mantener el reset activo durante los primeros 100 ns
        rst_n = 0;
        #100;
        
        // Liberar el reset (poner en 1) para que el contador empiece a oscilar
        rst_n = 1;

        // Dejar correr la simulación el tiempo suficiente para observar los cambios del tono
        // Simularemos 5 ms para ver varios ciclos de la onda de 440 Hz.
        #5_000_000;
        
        $display("Simulación completada con éxito.");
        $finish;
    end

endmodule