@echo off
setlocal EnableDelayedExpansion
title Limpeza Completa do Windows - Versao Final V5 Server Edition (Automatica)
color 0A

echo ==========================================================
echo          LIMPEZA COMPLETA DO WINDOWS - V5 Server Edition
echo                   (MODO AUTOMATICO)
echo ==========================================================
echo.
echo Este script remove apenas arquivos temporarios, caches e
echo logs que os proprios programas recriam automaticamente.
echo Nada de login, sessao ou configuracao e apagado.
echo.
echo.

:: ----------------------------------------------------------
:: VERIFICA ADMINISTRADOR
:: ----------------------------------------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ERRO: Execute este script como Administrador.
    echo Clique com o botao direito no arquivo e escolha
    echo "Executar como administrador".
    echo.
    pause
    exit
)

:: Etapas avancadas: mude para S se quiser que rodem automaticamente
set "ADVANCED=N"

:: ============================================================
:: LIMPEZA PADRAO (100% segura - nada aqui exige confirmacao)
:: ============================================================

echo [01/33] Limpando C:\Windows\Temp...
del /f /s /q "%windir%\Temp\*.*" 2>nul
for /d %%i in ("%windir%\Temp\*") do rd /s /q "%%i" 2>nul

echo [02/33] Limpando Temp do Usuario...
del /f /s /q "%TEMP%\*.*" 2>nul
for /d %%i in ("%TEMP%\*") do rd /s /q "%%i" 2>nul

echo [03/33] Limpando Local Temp...
del /f /s /q "%LOCALAPPDATA%\Temp\*.*" 2>nul
for /d %%i in ("%LOCALAPPDATA%\Temp\*") do rd /s /q "%%i" 2>nul

echo [04/33] Limpando Prefetch (o Windows recria automaticamente)...
del /f /q "%windir%\Prefetch\*.*" 2>nul

echo [05/33] Limpando Arquivos Recentes...
del /f /s /q "%APPDATA%\Microsoft\Windows\Recent\*.*" 2>nul

echo [06/33] Limpando Cache DNS...
ipconfig /flushdns >nul

echo [07/33] Limpando Windows Update...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
rd /s /q "%windir%\SoftwareDistribution\Download" 2>nul
mkdir "%windir%\SoftwareDistribution\Download" 2>nul
rd /s /q "%windir%\SoftwareDistribution\DeliveryOptimization" 2>nul
mkdir "%windir%\SoftwareDistribution\DeliveryOptimization" 2>nul
net start bits >nul 2>&1
net start wuauserv >nul 2>&1

echo [08/33] Limpando Delivery Optimization...
rd /s /q "%ProgramData%\Microsoft\Windows\DeliveryOptimization" 2>nul
mkdir "%ProgramData%\Microsoft\Windows\DeliveryOptimization" 2>nul

echo [09/33] Limpando Logs do Windows (Logs, CBS, DISM, Panther)...
del /f /s /q "%windir%\Logs\*.*" 2>nul
del /f /s /q "%windir%\Logs\CBS\*.*" 2>nul
del /f /s /q "%windir%\Logs\DISM\*.*" 2>nul
del /f /s /q "%windir%\Panther\*.*" 2>nul

echo [10/33] Limpando Crash Dumps e Minidumps...
rd /s /q "%LOCALAPPDATA%\CrashDumps" 2>nul
mkdir "%LOCALAPPDATA%\CrashDumps" 2>nul
del /f /q "%windir%\Minidump\*.*" 2>nul
del /f /q "%windir%\MEMORY.DMP" 2>nul

echo [11/33] Limpando Windows Error Reporting...
rd /s /q "%ProgramData%\Microsoft\Windows\WER" 2>nul
mkdir "%ProgramData%\Microsoft\Windows\WER" 2>nul
rd /s /q "%LOCALAPPDATA%\Microsoft\Windows\WER" 2>nul
mkdir "%LOCALAPPDATA%\Microsoft\Windows\WER" 2>nul

echo [12/33] Limpando Cache de Miniaturas e Icones...
del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" 2>nul
del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*.db" 2>nul

echo [13/33] Limpando Cache DirectX (Shader Cache)...
rd /s /q "%LOCALAPPDATA%\D3DSCache" 2>nul
mkdir "%LOCALAPPDATA%\D3DSCache" 2>nul

echo [14/33] Limpando Cache de Fontes...
net stop FontCache >nul 2>&1
net stop "FontCache3.0.0.0" >nul 2>&1
del /f /q "%windir%\ServiceProfiles\LocalService\AppData\Local\FontCache\*.dat" 2>nul
net start FontCache >nul 2>&1
net start "FontCache3.0.0.0" >nul 2>&1

echo [15/33] Limpando Cache de Internet (IE/Edge legado)...
del /f /s /q "%LOCALAPPDATA%\Microsoft\Windows\INetCache\*.*" 2>nul
del /f /s /q "%LOCALAPPDATA%\Microsoft\Windows\WebCache\*.*" 2>nul

echo [16/33] Limpando Cache do Google Chrome (todos os perfis)...
for /d %%p in ("%LOCALAPPDATA%\Google\Chrome\User Data\*") do (
    rd /s /q "%%p\Cache" 2>nul
    rd /s /q "%%p\Code Cache" 2>nul
    rd /s /q "%%p\GPUCache" 2>nul
)

echo [17/33] Limpando Cache do Microsoft Edge (todos os perfis)...
for /d %%p in ("%LOCALAPPDATA%\Microsoft\Edge\User Data\*") do (
    rd /s /q "%%p\Cache" 2>nul
    rd /s /q "%%p\Code Cache" 2>nul
    rd /s /q "%%p\GPUCache" 2>nul
)

echo [18/33] Limpando Cache do Firefox (todos os perfis)...
for /d %%p in ("%APPDATA%\Mozilla\Firefox\Profiles\*") do (
    rd /s /q "%%p\cache2" 2>nul
)

echo [19/33] Esvaziando Lixeira...
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1

echo [20/33] Limpando Cache da Microsoft Store...
start /wait wsreset.exe

echo [21/33] Limpando Componentes Antigos do Windows (WinSxS - sem remover backups de update)...
DISM /Online /Cleanup-Image /StartComponentCleanup /NoRestart

echo [22/33] Limpando arquivos temporarios orfaos do Windows Installer...
del /f /q "%windir%\Installer\$PatchCache$\*.tmp" 2>nul

echo [23/33] Limpando cache/logs do OneDrive (nao mexe nos arquivos sincronizados)...
rd /s /q "%LOCALAPPDATA%\Microsoft\OneDrive\setup\logs" 2>nul
del /f /s /q "%LOCALAPPDATA%\Microsoft\OneDrive\logs\*.*" 2>nul

echo [24/33] Limpando cache do Microsoft Teams (mantem login/sessao)...
rd /s /q "%APPDATA%\Microsoft\Teams\Cache" 2>nul
rd /s /q "%APPDATA%\Microsoft\Teams\Code Cache" 2>nul
rd /s /q "%APPDATA%\Microsoft\Teams\GPUCache" 2>nul
rd /s /q "%APPDATA%\Microsoft\Teams\Service Worker\CacheStorage" 2>nul
for /d %%p in ("%LOCALAPPDATA%\Packages\MSTeams_*") do (
    rd /s /q "%%p\LocalCache\Microsoft\MSTeams\EBWebView\Default\Cache" 2>nul
)

echo [25/33] Limpando cache do Spotify (mantem login/playlists offline)...
rd /s /q "%LOCALAPPDATA%\Spotify\Storage" 2>nul
rd /s /q "%LOCALAPPDATA%\Spotify\Data" 2>nul

echo [26/33] Limpando cache do Discord (mantem login/token)...
for /d %%p in ("%APPDATA%\discord" "%LOCALAPPDATA%\Discord") do (
    rd /s /q "%%p\Cache" 2>nul
    rd /s /q "%%p\Code Cache" 2>nul
    rd /s /q "%%p\GPUCache" 2>nul
)

echo [27/33] Limpando cache do Slack (mantem login/sessao)...
rd /s /q "%APPDATA%\Slack\Cache" 2>nul
rd /s /q "%APPDATA%\Slack\Code Cache" 2>nul
rd /s /q "%APPDATA%\Slack\GPUCache" 2>nul

echo [28/33] Removendo pastas residuais de upgrade do Windows ($Windows~BT/WS)...
if exist "%SystemDrive%\$Windows.~BT" (
    takeown /F "%SystemDrive%\$Windows.~BT" /R /A /D Y >nul 2>&1
    icacls "%SystemDrive%\$Windows.~BT" /reset /T /C /Q >nul 2>&1
    rd /s /q "%SystemDrive%\$Windows.~BT" 2>nul
)
if exist "%SystemDrive%\$Windows.~WS" (
    takeown /F "%SystemDrive%\$Windows.~WS" /R /A /D Y >nul 2>&1
    icacls "%SystemDrive%\$Windows.~WS" /reset /T /C /Q >nul 2>&1
    rd /s /q "%SystemDrive%\$Windows.~WS" 2>nul
)

echo [29/33] Limpando cache do npm (Node.js), se instalado...
where npm >nul 2>&1 && call npm cache clean --force >nul 2>&1

echo [30/33] Limpando cache do pip (Python), se instalado...
where pip >nul 2>&1 && call pip cache purge >nul 2>&1

echo [31/33] Limpando cache do NuGet (.NET), se instalado...
where dotnet >nul 2>&1 && call dotnet nuget locals all --clear >nul 2>&1

echo [32/33] Abrindo Limpeza de Disco para voce revisar itens de sistema
echo         (marque tambem "Windows Upgrade Log Files" se aparecer na lista)...
start "" cleanmgr.exe

echo [33/33] Limpeza padrao concluida.
echo Limpeza padrao concluida em %date% %time% >> "%LOG%"
echo.

:: ============================================================
:: LIMPEZA AVANCADA (desativada por padrao neste modo automatico)
:: Para ativar, mude a linha "set ADVANCED=N" acima para "S".
:: Cada bloco abaixo roda direto, sem perguntar, se ADVANCED=S.
:: ============================================================

if /i not "%ADVANCED%"=="S" goto :FIM

echo ==========================================================
echo                  ETAPAS AVANCADAS
echo ==========================================================
echo.

:: Windows.old (IRREVERSIVEL: impede voltar para o Windows anterior)
if exist "%SystemDrive%\Windows.old" (
    echo Apagando Windows.old, isso pode demorar...
    takeown /F "%SystemDrive%\Windows.old" /R /A /D Y >nul 2>&1
    icacls "%SystemDrive%\Windows.old" /reset /T /C /Q >nul 2>&1
    rd /s /q "%SystemDrive%\Windows.old" 2>nul
    echo Windows.old removido. >> "%LOG%"
) else (
    echo Nenhuma pasta Windows.old encontrada, pulando esta etapa.
)
echo.

:: Hibernacao (hiberfil.sys) - reversivel
powercfg /hibernate off
echo Hibernacao desativada. >> "%LOG%"
echo.

:: Reset avancado do WinSxS (impede desinstalar updates antigos)
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase /NoRestart
echo WinSxS ResetBase executado. >> "%LOG%"
echo.

:: Pontos de restauracao antigos (mantem so o mais recente)
PowerShell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$points = Get-CimInstance Win32_ShadowCopy | Sort-Object InstallDate; if ($points.Count -gt 1) { $points | Select-Object -SkipLast 1 | ForEach-Object { vssadmin delete shadows /Shadow=$($_.ID) /quiet } }" >nul 2>&1
echo Pontos de restauracao antigos removidos, mantido o mais recente. >> "%LOG%"
echo.

:FIM
echo ==========================================================
echo             LIMPEZA CONCLUIDA COM SUCESSO!
echo ==========================================================
echo.
exit