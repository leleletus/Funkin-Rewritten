

# ── Herramientas devkitPro ──
DEVKITPRO ?= C:/devkitPro
NACPTOOL  := $(DEVKITPRO)/tools/bin/nacptool
ELF2NRO   := $(DEVKITPRO)/tools/bin/elf2nro

all: lovefile desktop console

desktop: lovefile win64 macos

console: lovefile switch

lovefile:
	@rm -rf build/lovefile
	@mkdir -p build/lovefile

	@cd src/fnf-love; zip -r -9 ../../build/lovefile/funkin-rewritten.love .

	@mkdir -p build/release
	@rm -f build/release/funkin-rewritten-lovefile.zip
	@cd build/lovefile; zip -9 -r ../release/funkin-rewritten-lovefile.zip .


win64: lovefile
	@rm -rf build/win64
	@mkdir -p build/win64

	@cp resources/win64/love/OpenAL32.dll build/win64
	@cp resources/win64/love/SDL2.dll build/win64
	@cp resources/win64/love/license.txt build/win64
	@cp resources/win64/love/lua51.dll build/win64
	@cp resources/win64/love/mpg123.dll build/win64
	@cp resources/win64/love/love.dll build/win64
	@cp resources/win64/love/msvcp120.dll build/win64
	@cp resources/win64/love/msvcr120.dll build/win64

	@cat resources/win64/love/love.exe build/lovefile/funkin-rewritten.love > build/win64/funkin-rewritten.exe

	@mkdir -p build/release
	@rm -f build/release/funkin-rewritten-win64.zip
	@cd build/win64; zip -9 -r ../release/funkin-rewritten-win64.zip .

macos: lovefile
	@rm -rf build/macos
	@mkdir -p "build/macos/Friday Night Funkin' Rewritten.app"

	@cp -r resources/macos/love.app/. "build/macos/Friday Night Funkin' Rewritten.app"

	@cp build/lovefile/funkin-rewritten.love "build/macos/Friday Night Funkin' Rewritten.app/Contents/Resources"

	@mkdir -p build/release
	@rm -f build/release/funkin-rewritten-macos.zip
	@cd build/macos; zip -9 -r ../release/funkin-rewritten-macos.zip .


switch: lovefile
	@echo "━━━ [SWITCH] Compilando NRO para Nintendo Switch ━━━"
	@rm -rf build/switch
	@mkdir -p build/switch/romfs
	@mkdir -p build/switch/nro

	@echo "1. Copiando .love al RomFS..."
	@cp build/lovefile/funkin-rewritten.love build/switch/romfs/game.love

	@echo "2. Generando NACP (metadata)..."
	@$(NACPTOOL) --create "Friday Night Funkin' Rewritten" djvemo "$$(cat version.txt 2>/dev/null || echo '1.0.0')" build/switch/funkin-rewritten.nacp

	@echo "3. Generando NRO..."
	@$(ELF2NRO) resources/switch/love.elf build/switch/nro/funkin-rewritten.nro \
		--icon=resources/switch/icon.jpg \
		--nacp=build/switch/funkin-rewritten.nacp \
		--romfsdir=build/switch/romfs

	@echo "4. Limpiando archivos temporales..."
	@rm -rf build/switch/romfs
	@rm -f build/switch/funkin-rewritten.nacp

	@echo "5. Empaquetando ZIP..."
	@mkdir -p build/release
	@rm -f build/release/funkin-rewritten-switch.zip
	@cd build/switch/nro && zip -9 -r ../../release/funkin-rewritten-switch.zip .
	@echo "✓ build/release/funkin-rewritten-switch.zip"

clean:
	@rm -rf build
