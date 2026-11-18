# Idle-Mouse‑Move
## Acerca de
Script de PowerShell para Windows de movimiento automático del ratón, evita que el sistema detecte inactividad prolongada.
- ✅ Movimiento alterno del ratón: se desplaza a la izquierda una cantidad definida de píxeles, espera y vuelve a la posición original en bucle.
- ✅ API nativa anti‑suspensión, impide la suspensión del sistema y el apagado automático del monitor.
- ✅ Funciona completamente en local, no requiere conexión a internet. Controla el cursor y la gestión de energía mediante las API de Windows.
- ✅ Dos versiones: versión estable (sin registro en disco), versión de depuración (guarda coordenadas para solucionar errores).

> ⚠️ Aviso importante
> Ambos scripts usan lógica de desplazamiento relativo, **no guardan la posición de referencia del ratón capturada al iniciar el script**.
> Si mueves el ratón manualmente durante la ejecución o se producen pequeñas vibraciones del cursor del sistema, la posición del ratón se desviará gradualmente.

> ⚠️ Limitaciones del entorno
> Las máquinas virtuales y algunas sesiones de escritorio remoto interceptan la API `SetCursorPos`, el ratón no se moverá. El software de seguridad puede bloquear las llamadas del script a las interfaces del sistema Windows.
> En algunos dispositivos solo funciona el movimiento del ratón y no se puede evitar el apagado del monitor,También puede estar relacionado con la política de energía del sistema.

## Lista de archivos
### `mouse_move.ps1` - **【Script principal｜Versión estable】**
- Propósito: uso diario, solo salida por consola, **no escribe archivos de registro en disco**.
- Funcionalidades: movimiento alterno del ratón + activación de la prevención de suspensión del sistema (`SetThreadExecutionState`).
- Lanzador asociado: `run_mouse_move.bat`

### `run_test.ps1` - **【Script de depuración｜Para resolución de problemas】**
- Propósito: diagnóstico y depuración. Genera `mouse_log.txt` en la carpeta del script y guarda las coordenadas del ratón en cada ciclo.
- Funcionalidades: movimiento alterno del ratón + activación de prevención de suspensión + guardado de registros en disco.
- Aviso: escribe registros continuamente en disco, **no apto para ejecución prolongada**.
- Lanzador asociado: `run_test.bat`

### `run_mouse_move.bat`
Lanzador por lotes de la versión estable. Haz doble clic para ejecutar el script principal `mouse_move.ps1`.
> El texto `Keep screen awake` dentro del archivo batch coincide con el comportamiento real; la prevención de suspensión se activa dentro del script PowerShell.
Forma de parada: pulsa `Ctrl+C` en la ventana de consola o ciérrala directamente.

### `run_test.bat`
Lanzador por lotes de depuración. Ejecuta el script de prueba, genera el archivo de registro y activa la prevención de suspensión.

### `mouse_log.txt`
> **Solo se genera al ejecutar `run_test.ps1`. El script principal estable no produce este archivo.**
> Contiene marca de tiempo, número de ciclo y coordenadas del ratón antes y después del movimiento. El archivo funciona en modo añadir, los registros antiguos no se sobrescriben automáticamente.

## Modo de uso
### Método 1: Doble clic (recomendado)
1. Uso diario: haz doble clic en `run_mouse_move.bat`
2. Necesitas registros para depurar: haz doble clic en `run_test.bat`
3. Detener el script: pulsa `Ctrl+C` o cierra la ventana de consola

### Método 2: Ejecución manual desde línea de comandos
```cmd
:: Ejecutar script principal estable
cd carpeta‑del‑script
run_mouse_move.bat

:: Ejecutar script de depuración
run_test.bat
```

### Método 3: Invocar directamente el script de PowerShell
```powershell
# Versión estable
powershell -NoProfile -ExecutionPolicy Bypass -File mouse_move.ps1

# Versión de depuración
powershell -NoProfile -ExecutionPolicy Bypass -File run_test.ps1
```

## Configuración de parámetros
Edita el archivo ps1 correspondiente para modificar los parámetros:

**mouse_move.ps1 (Versión estable)**
```powershell
$moveAmount = 50        # Cantidad de píxeles por movimiento
$leftMoveTime = 5000    # Tiempo de espera en milisegundos tras mover hacia la izquierda
$rightMoveTime = 5000   # Tiempo de espera en milisegundos tras volver a la posición base
```

**run_test.ps1 (Versión de depuración)**
```powershell
$moveAmount = 50        # Cantidad de píxeles por movimiento
$leftTime = 5000        # Tiempo de espera en milisegundos tras mover hacia la izquierda
$rightTime = 5000       # Tiempo de espera en milisegundos tras volver a la posición base
```

## Preguntas frecuentes
### Q1: El ratón no se mueve en absoluto?
Respuesta: Comprueba punto por punto:
1. Estás usando máquina virtual o sesión de escritorio remoto que intercepta `SetCursorPos`;
2. El software de seguridad bloquea las llamadas a la API del ratón de Windows;
3. Ejecuta el script de depuración `run_test.bat` y revisa `mouse_log.txt` para comprobar si el script se ejecuta correctamente.

### Q2: El monitor sigue apagándose aunque el script esté en ejecución?
Respuesta: `SetThreadExecutionState` solo afecta al proceso actual del script. Al cerrar el script se restauran las políticas de energía del sistema. Algunos programas externos de gestión de energía pueden anular el efecto de esta API.

### Q3: No encuentro el archivo mouse_log.txt?
Respuesta: El archivo de registro **solo lo genera el script de depuración run_test.ps1**, el script principal estable no genera registros.

### Q4: La posición del ratón se desvía poco a poco con el tiempo?
Respuesta: El script usa desplazamiento relativo sin fijar el punto inicial. Evita mover el ratón manualmente mientras se ejecuta.

## Detalles técnicos
1. Control del cursor: API `SetCursorPos`, `GetCursorPos` de user32.dll
2. Implementación anti‑suspensión: `SetThreadExecutionState` de kernel32.dll
    - Banderas: `ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED`
    - Efecto: impide la suspensión del sistema y el apagado automático del monitor; deja de funcionar automáticamente al finalizar el proceso.

## Exención de responsabilidad
Este script es solo para aprendizaje y pruebas. Tú asumes todos los riesgos derivados de su uso, incluyendo entre otros anomalías del sistema y comportamientos anómalos del ratón. No lo uses para inactividad automática en videojuegos, algunos juegos detectan entradas simuladas.

## Aviso sobre autores y generación por IA
- Borrador inicial del código generado por **GLM‑4.7‑Flash**;
- Tratamiento de README.md, descripciones, archivo .gitignore y parte de la revisión de código realizado por **Doubao**;
- Revisión adicional de código y pruebas realizadas por **dot‑idk‑dot** y **LLLyyy‑star**
- Versión: 1.0
- Última modificación: 2026‑11‑18
