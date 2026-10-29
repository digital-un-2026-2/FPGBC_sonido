# FPGBC_sonido
Módulo de Sonido para la FPGBC (Game Boy Color)
Asignatura: Electrónica Digital II - Universidad Nacional de Colombia (2026-2)

## Integrantes
- Cristian Camilo Niño Gutierrez
- Edyson fabian Vargas camargo
- Ana Gabriela Caicedo Cangrejo

## 📋 Tabla de Contenidos
1. [Descripción General](#1-descripción-general)
2. [Arquitectura y Diagrama de Bloques](#2-arquitectura-y-diagrama-de-bloques)
3. [Ingeniería Inversa: Subsistema de Audio (APU)](#3-ingeniería-inversa-subsistema-de-audio-apu)
4. [Análisis del Esquemático y Conexiones Físicas](#4-análisis-del-esquemático-y-conexiones-físicas)
5. [Estructura del Repositorio](#5-estructura-del-repositorio)

---

## 1. Descripción General
Este repositorio contiene el diseño, la documentación teórica y la implementación en hardware del subsistema de sonido (APU) para el proyecto FPGBC. El módulo se encarga de sintetizar digitalmente los canales de audio de la Game Boy Color y gestionar la interfaz de conversión y amplificación hacia el hardware físico.

---

## 2. Arquitectura y Diagrama de Bloques 
<img width="1202" height="1001" alt="b5aa53dc-4c1e-4104-bc7b-0b5720a0a706" src="https://github.com/user-attachments/assets/64b72848-0c45-4774-9e23-929fea74eb06" />

---

## 3. Ingeniería Inversa: Subsistema de Audio (APU)
A partir del análisis del hardware original de la Game Boy Color y las especificaciones técnicas de la APU, se identificaron los 4 canales independientes de síntesis de sonido:
* **Canal 1 (Onda Cuadrada con Sweep):** Genera tonos cuadrados con control de barrido de frecuencia (*sweep*) y envolvente de volumen (*envelope*).
* **Canal 2 (Onda Cuadrada simple):** Genera tonos cuadrados con ciclo de trabajo configurable y envolvente, sin barrido de frecuencia.
* **Canal 3 (Tabla de Ondas):** Reproduce patrones de onda personalizados de 32 muestras almacenados en la RAM interna de onda (*Wave RAM*).
* **Canal 4 (Ruido Blanco):** Genera efectos de percusión y ruido mediante un registro de desplazamiento con retroalimentación lineal (LFSR).

---

## 4. Análisis del Esquemático y Conexiones Físicas
| Pin / Componente | Nombre o Función | Descripción en el Sistema / Conexión |
| :--- | :--- | :--- |
| **Pin 57 FPGA** | Salida de Audio Principal (PWM) | Transmite la señal modulada por ancho de pulso generada por la APU hacia la red de acondicionamiento analógico |
| **Pin 56 FPGA** | Conmutación / Detección de Jack | Se activa junto al pin 57 al insertar el conector Jack de 3.5 mm para gestionar el cambio de salida o canal secundario |
| **Pin 12 FPGA** | Control de Apagado (*Shutdown*) | Vinculado al Pin 1 del amplificador TC8002D para permitir que el SoC gestione el consumo energético |
| **Pin 1 FPGA_Vcc** | Alimentación | Línea de voltaje (VCC) proveniente de la FPGA para alimentar y estabilizar componentes de la etapa |
| **GND** | Tierra / Referencia | Planos de masa comunes para fijar las referencias de voltaje y evitar ruidos eléctricos |

---

## 5. Estructura del Repositorio
- `rtl/`: Archivos de descripción de hardware en Verilog correspondientes a la lógica digital de la APU.
- `documentos/`: Hojas de datos (datasheets del amplificador TC8002D), notas teóricas y documentación de ingeniería inversa.
- `sim/`: Archivos de simulación y testbenches para la verificación de los canales de audio.
