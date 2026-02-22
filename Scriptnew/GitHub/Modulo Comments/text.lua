local u = loadstring(game:HttpGet(('https://raw.githubusercontent.com/fiiremax/Scripts/refs/heads/main/Module.lua')))()

local p = u.p 
local MBP = u.MBP 
local IsAround = u.IsAround
local inpast = u.inpast
local GPNames = u.GPNames 
local SPE = u.SPE 
local SVel = u.SVel 
local FINF = u.FINF 
local IPPP = u.IPPP 
local tp = u.tp 
local SICF = u.SICF
local FMC = u.FMC 
local var = getgenv().var
local tm = u.tm
local wfc = u.wfc
local tmr = u.tmr
local cm = u.cm
local env = u.env
local fps = u.fps

--[[
--! FUNCOES UTEIS
fps() - Retorna FPS atual

GPNames() - retorna lista, modo func retorna lista(not arg2())
SPE(part, loc, cframe, angl) - Sticky Part (ordem flexivel) // SPE(part, loc, CFrame.new(0,5,0))

SICF(item, cframe, modo) - Spawna item (ordem flexivel) // SICF("Sword", "Front") // Modes: "Default", "Front", "Head"
IPPP(part, modo) - Verifica se part ta protegida // modo 2 = ignora inv

FMC(...) - Busca models/parts (argumentos em qualquer ordem)
    FMC(50) - raio 50
    FMC(50, function(m) end) - raio + filtro
    FMC("plrs", function(char) end, 30) - players no raio
    FMC(30, workspace.Part) - origem custom
    FMC(part) - retorna player da part

--! SISTEMA DE VARIAVEIS (var)
var(nome) - Retorna variavel
var(nome, valor) - Cria/atualiza
var(tabela) - Cria tabela
var(tabela, key, valor) - Atualiza valor na tabela

--! FUNCOES DE TABELA (tm)
tm.Add(tabela, key, valor) - Adiciona
tm.Find(tabela, key) - Procura
tm.val(tabela, key) - Retorna valor
tm.Remove(tabela, key) - Remove
tm.Clear(tabela) - Limpa

--! WAITFORCHILD FLEXIVEL (wfc)
wfc(nome, parent?, timeout?) - Espera por child (argumentos em qualquer ordem)
    wfc("Head") - espera Head no char
    wfc("Head", workspace) - espera Head no workspace  
    wfc("Head", 5) - espera Head por 5s no char
    wfc("Head", workspace, 5) - espera Head no workspace por 5s

--! SISTEMA DE TIMERS (tmr)
tmr(tag, duracao?, comando?) - Gerencia timers com tags (argumentos em qualquer ordem)

-- Criar e checar timer
tmr("cooldown", 10) - Inicia timer de 10s
tmr("cooldown") - Retorna true se ativo, false se acabou
    
    tmr("ataque", 5)
    repeat task.wait() until not tmr("ataque") - espera timer acabar
    print("Pode atacar!")

-- Controles
tmr("cooldown", 10, "pause") - Pausa timer
tmr("cooldown", 10, "resume") - Retoma timer pausado
tmr("cooldown", 10, "restart") - Reinicia timer com nova duracao
tmr("cooldown", nil, "stop") - Para e remove timer

--! SISTEMA DE CONEXOES (cm)

-- Conexao basica
cm(instance, "EventName", func, throttle?, nome?) - Argumentos em qualquer ordem
    cm(part, "Touched", function(hit) end)
    cm(RunService, "Heartbeat", function() end, 3, "hb") - executa a cada 3 frames
    cm(RunService, "Heartbeat", function() end, {ref = settings, key = "fps"}, "hb") - throttle dinamico via tabela

-- Conexao quando instance e deletada
cm(instance, func, nome?) - func chamada quando instance e deletada

-- PropertyChanged
cm(instance, "PropertyChanged", "PropertyName", func, nome?)
    cm(part, "PropertyChanged", "Size", function() end)

-- Adicionar callback em conexao existente
cm("nome", "Add", func, "once"?) - Adiciona callback em conexao existente
    cm(Players, "PlayerAdded", function(p) end, "tracker")
    cm("tracker", "Add", function(p) end) - adiciona outro callback
    cm("tracker", "Add", function(p) end, "once") - callback executado apenas uma vez

-- Executar apenas uma vez
cm(instance, "EventName", func, "once", nome?)
    cm(part, "Touched", function(hit) end, "once") - desconecta automaticamente apos primeira execucao

-- Gerenciamento de conexoes
cm("nome", "disc") ou cm("nome", "disconnect") - Desconecta conexao
cm("nome", "pause") - Pausa conexao (nao executa callbacks)
cm("nome", "resume") - Retoma conexao pausada
cm("nome", "status") - Retorna status: "none", "paused" ou "active"
    
    local status = cm("hb", "status")
    if status == "active" then
        cm("hb", "pause")
    end
]]--
local OrionLib =  loadstring(game:HttpGet(('https://raw.githubusercontent.com/fiiremax/Scripts/refs/heads/main/Loader.lua')))()