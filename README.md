# Friday Night Funkin (Re Rewritten)

Se retoma el Rewritten creado por htv04 creado en el motor LOVE (Love2D) Y se actualiza con las ultimas semanas y canciones



---

## Estructura del Proyecto

* main.lua / conf.lua: Archivos de entrada principales .
* src/: Logica del cliente (estados, entidades graficas, sonido y maquina de estados).
* assets/: Recursos graficos, niveles (.json), fuentes y sonidos del cliente.
* server/: Carpeta que contiene la logica exclusiva del Servidor. Tiene su propio main.lua y conf.lua.


---

## Como Ejecutar Localmente

### 1. Correr el Cliente (El Juego en PC)
Asegurate de tener instalado LOVE 11.4 o superior.
Abre una terminal en la raiz del proyecto y ejecuta:
```bash
love .
```
Tips de Depuracion para el Cliente:
* Hitboxes: Puedes presionar la tecla F1 durante el juego para mostrar/ocultar las cajas de colision (hitboxes).
* Consola de depuracion: Si quieres ver los prints en tiempo real en Windows, abre conf.lua y cambia t.console = false por t.console = true.


## Compilacion y Empaquetado


* Generar el .love (Universal - macOS y Linux):
  Genera el archivo universal .love. Este archivo es portatil y puede ser ejecutado directamente en macOS (x64/ARM) y Linux (x64/ARM) simplemente teniendo LOVE instalado.
  ```bash
  make lovefile
  ```
* Compilar para Windows 64-bit (.exe):
  Genera el archivo .exe fusionando tu juego con los DLLs de LOVE que tengas en resources/win64/love/.
  ```bash
  make win64
  ```
* Compilar para Nintendo Switch (.nro):
  Genera un .nro listo para correr en el Homebrew Launcher de la Switch.
  ```bash
  make switch
  ```
* Compilar para Android (.apk):
  Descarga automaticamente el repositorio de love-android, inyecta tu .love, configura el icono, modifica el manifiesto y compila el APK con Gradle.
  ```bash
  make android
  ```

Tambien existen macros rapidos definidos en el Makefile para compilar en lote:
* `make desktop` (lovefile + win64)
* `make console` (lovefile + switch)
* `make mobile`  (lovefile + android)
* `make all`     (Genera todos los anteriores)

* Limpiar compilaciones previas:
  Borra la carpeta temporal build/ generada por los procesos anteriores.
  ```bash
  make clean
  ```
