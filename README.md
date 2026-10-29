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

El montaje físico de la etapa de audio en la FPGBC requiere una correcta interconexión entre los pines digitales de propósito general (GPIO) de la FPGA y los componentes analógicos de potencia, filtrado y detección. A partir del análisis del esquemático y la verificación en laboratorio realizada sobre la tarjeta, se identifican las siguientes rutas y funciones clave:

### 4.1. Detección de Inserción del Jack y Conmutación de Audio
En la implementación sobre el PCB, se estableció un mecanismo de sensado físico conectado directamente a la FPGA para alternar entre el altavoz y los auriculares:

* **Pin de Detección (Pin 12 FPGA):** Funciona como la entrada digital de sensado. Al insertar el conector Jack de 3.5 mm en el socket, se cierra o abre el contacto mecánico, enviando la señal de alerta al pin 12 de la FPGA para indicar que hay un dispositivo de audio externo conectado.
* **Señales de Audio Activas (Pines 57 y 56 FPGA):** Una vez que el sistema detecta la inserción a través del pin 12, la lógica interna de la FPGA activa de manera conjunta o conmuta las señales de audio hacia los **pines 57 y 56** para enrutar la señal correctamente hacia el conector de los audífonos.
* **Control Lógico de Apagado (Shutdown):** Vinculado al Pin 1 del amplificador TC8002D para permitir que el SoC gestione el consumo energético de la etapa de potencia según sea necesario.
* **Líneas de Alimentación y Referencia:** Conexiones como **Pin 1 FPGA_Vcc** y los puntos de tierra **GND**, indispensables para fijar los voltajes de referencia y evitar ruido eléctrico.

### 4.2. Tabla Resumen de Pines y Conexiones

| Pin / Componente | Nombre o Función | Descripción en el Sistema / Conexión |
| :--- | :--- | :--- |
| **Pin 12 FPGA** | Detección de Jack (*Jack Detect*) | Recibe la señal física al insertar el conector de 3.5 mm para advertir al sistema sobre la presencia de audífonos. |
| **Pin 57 y 56 FPGA** | Canales de Audio / Salidas PWM | Se activan y gestionan en respuesta a la detección del jack para enrutar la señal hacia la salida correspondiente. |
| **Pin 1 del TC8002D** | Control de Apagado (*Shutdown*) | Conectado a la lógica de control de la FPGA para habilitar o apagar el amplificador de potencia. |
| **Pin 1 FPGA_Vcc** | Alimentación | Línea de voltaje (VCC) para alimentar y estabilizar los componentes de la etapa analógica. |
| **GND** | Tierra | Planos de masa comunes para la referencia de voltajes y mitigación de ruido. |

### 4.3. Etapa de Filtrado RC y Amplificación (TC8002D)
* **Filtro Paso-Bajo (RC):** Las señales moduladas por ancho de pulsos (PWM) provenientes de la FPGA atraviesan los componentes pasivos SMD para suprimir las altas frecuencias de conmutación y convertirlas en una onda de voltaje analógica continua.
* **Acoplamiento al Amplificador TC8002D:** La señal condicionada ingresa a las terminales del amplificador Clase AB (TC8002D), el cual se encarga de elevar la potencia para entregar la salida diferencial (`VO1` y `VO2`) hacia el altavoz o el jack según corresponda.
---

## 5. Estructura del Repositorio
- `rtl/`: Archivos de descripción de hardware en Verilog correspondientes a la lógica digital de la APU.
- `documentos/`: Hojas de datos (datasheets del amplificador TC8002D), notas teóricas y documentación de ingeniería inversa.
- `sim/`: Archivos de simulación y testbenches para la verificación de los canales de audio.
