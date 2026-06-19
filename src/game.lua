local Cards = require("src.cards")

local Game = {}
Game.__index = Game

local CARD_WIDTH = 72
local CARD_HEIGHT = 104
local CARD_PADDING = 12
local FIELD_COLUMNS = 6

local function cloneDeck()
    local deck = {}
    for _, card in ipairs(Cards.all) do
        deck[#deck + 1] = {
            id = card.id,
            month = card.month,
            suit = card.suit,
            label = card.label,
            type = card.type,
            value = card.value
        }
    end
    return deck
end

local function shuffle(deck)
    for i = #deck, 2, -1 do
        local j = love.math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

local function sumCardValues(cards)
    local total = 0
    for _, card in ipairs(cards) do
        total = total + card.value
    end
    return total
end

local function pointInRect(px, py, x, y, w, h)
    return px >= x and px <= x + w and py >= y and py <= y + h
end

local function cardColor(card)
    return unpack(Cards.typeColors[card.type] or {0.9, 0.9, 0.9})
end

function Game.new()
    local self = setmetatable({}, Game)
    self.state = "menu"
    self.log = {}
    self:pushMessage("Hwatu Showdown", "사생결단의 한판을 시작해보세요!")
    return self
end

function Game:pushMessage(title, body)
    table.insert(self.log, 1, {title = title, body = body, timer = 6})
    if #self.log > 6 then
        table.remove(self.log)
    end
end

function Game:startGame()
    self.deck = cloneDeck()
    shuffle(self.deck)
    self.playerHand = {}
    self.cpuHand = {}
    self.field = {}
    self.playerCaptures = {}
    self.cpuCaptures = {}
    self.state = "playing"
    self.turn = "player"
    self.selectedCardIndex = nil
    self.matchingFieldIndices = {}
    self.cpuTimer = 0.8
    self.cpuActing = false

    local dealCount = 8
    for _ = 1, dealCount do
        self:drawTo(self.playerHand)
        self:drawTo(self.cpuHand)
        self:drawTo(self.field)
    end

    self:pushMessage("새 게임", "플레이어부터 시작합니다.")
end

function Game:drawTo(target)
    if #self.deck == 0 then
        return nil
    end
    local card = table.remove(self.deck)
    table.insert(target, card)
    return card
end

function Game:update(dt)
    for _, entry in ipairs(self.log) do
        entry.timer = math.max(0, entry.timer - dt)
    end

    if self.state ~= "playing" then
        return
    end

    if self.turn == "cpu" then
        self.cpuTimer = self.cpuTimer - dt
        if self.cpuTimer <= 0 and not self.cpuActing then
            self.cpuActing = true
            self:performCpuTurn()
            self.cpuTimer = 0.8
            self.cpuActing = false
        end
    end
end

function Game:performCpuTurn()
    if self.state ~= "playing" or self.turn ~= "cpu" then
        return
    end

    if #self.cpuHand == 0 then
        self:finishTurn()
        return
    end

    local bestScore = -math.huge
    local bestHandIndex
    local bestFieldIndex

    for i, card in ipairs(self.cpuHand) do
        local matches = self:getMatchingFieldIndices(card)
        if #matches > 0 then
            for _, fieldIndex in ipairs(matches) do
                local fieldCard = self.field[fieldIndex]
                local score = card.value + fieldCard.value
                if score > bestScore then
                    bestScore = score
                    bestHandIndex = i
                    bestFieldIndex = fieldIndex
                end
            end
        elseif bestScore < 0 then
            -- fallback to any non-matching card if no capture possible yet
            local score = card.value * 0.1
            if score > bestScore then
                bestScore = score
                bestHandIndex = i
                bestFieldIndex = nil
            end
        end
    end

    if not bestHandIndex then
        bestHandIndex = love.math.random(#self.cpuHand)
    end

    local playedCard = table.remove(self.cpuHand, bestHandIndex)
    if bestFieldIndex then
        local fieldCard = table.remove(self.field, bestFieldIndex)
        table.insert(self.cpuCaptures, playedCard)
        table.insert(self.cpuCaptures, fieldCard)
        self:pushMessage("CPU", string.format("%s(%d월) 카드를 맞춰 가져갔습니다.", playedCard.suit, playedCard.month))
    else
        table.insert(self.field, playedCard)
        self:pushMessage("CPU", string.format("%s(%d월) 카드를 깔았습니다.", playedCard.suit, playedCard.month))
    end

    self:resolveDrawPhase("cpu")
    self:finishTurn()
end

function Game:finishTurn()
    if self.state ~= "playing" then
        return
    end

    if #self.deck == 0 and #self.playerHand == 0 and #self.cpuHand == 0 then
        self:finalizeGame()
    else
        if self.turn == "player" then
            self.turn = "cpu"
            self.cpuTimer = 0.8
        else
            self.turn = "player"
            self.selectedCardIndex = nil
            self.matchingFieldIndices = {}
        end
    end
end

function Game:finalizeGame()
    self.state = "ended"
    local playerScore = sumCardValues(self.playerCaptures)
    local cpuScore = sumCardValues(self.cpuCaptures)

    local result
    if playerScore > cpuScore then
        result = "승리!"
    elseif playerScore < cpuScore then
        result = "패배..."
    else
        result = "무승부"
    end

    self:pushMessage("라운드 종료", string.format("플레이어 %d점 vs CPU %d점 - %s", playerScore, cpuScore, result))
end

function Game:resolveDrawPhase(owner)
    local drawn = self:drawTo(self.field)
    if not drawn then
        return
    end

    local matches = self:getMatchingFieldIndices(drawn)

    if #matches > 0 then
        -- Choose the highest value card to capture
        table.sort(matches, function(a, b)
            local valueA = self.field[a].value
            local valueB = self.field[b].value
            return valueA > valueB
        end)
        local index = matches[1]
        local fieldCard = table.remove(self.field, index)
        for i, card in ipairs(self.field) do
            if card == drawn then
                table.remove(self.field, i)
                break
            end
        end
        if owner == "player" then
            table.insert(self.playerCaptures, drawn)
            table.insert(self.playerCaptures, fieldCard)
            self:pushMessage("플레이어", string.format("뒷패로 %s(%d월)을 맞춰 추가 획득!", fieldCard.suit, fieldCard.month))
        else
            table.insert(self.cpuCaptures, drawn)
            table.insert(self.cpuCaptures, fieldCard)
            self:pushMessage("CPU", string.format("뒷패로 %s(%d월)을 맞춰 추가 획득.", fieldCard.suit, fieldCard.month))
        end
    else
        -- drawn card already placed on the field, nothing to do
    end
end

function Game:onMousePressed(x, y)
    if self.state == "menu" then
        self:startGame()
        return
    end

    if self.state == "ended" then
        self:startGame()
        return
    end

    if self.turn ~= "player" or self.state ~= "playing" then
        return
    end

    local playerIndex = self:cardIndexAt(self.playerHand, x, y, self:getPlayerCardPosition)
    if playerIndex then
        if self.selectedCardIndex == playerIndex then
            if #self.matchingFieldIndices == 0 then
                self:commitPlayerCard(nil)
            else
                self.selectedCardIndex = nil
                self.matchingFieldIndices = {}
            end
        else
            self.selectedCardIndex = playerIndex
            self.matchingFieldIndices = self:getMatchingFieldIndices(self.playerHand[playerIndex])
        end
        return
    end

    if self.selectedCardIndex then
        local fieldIndex = self:cardIndexAt(self.field, x, y, self:getFieldCardPosition)
        if fieldIndex and self:isFieldMatch(fieldIndex) then
            self:commitPlayerCard(fieldIndex)
            return
        end
    end

    self.selectedCardIndex = nil
    self.matchingFieldIndices = {}
end

function Game:onKeyPressed(key)
    if self.state == "menu" and (key == "return" or key == "space") then
        self:startGame()
    elseif self.state == "ended" and (key == "return" or key == "space") then
        self:startGame()
    elseif key == "r" then
        self:startGame()
    end
end

function Game:getMatchingFieldIndices(card)
    local matches = {}
    for index, fieldCard in ipairs(self.field) do
        if fieldCard.month == card.month and fieldCard ~= card then
            table.insert(matches, index)
        end
    end
    return matches
end

function Game:isFieldMatch(index)
    for _, matchIndex in ipairs(self.matchingFieldIndices) do
        if matchIndex == index then
            return true
        end
    end
    return false
end

function Game:commitPlayerCard(fieldIndex)
    if not self.selectedCardIndex then
        return
    end

    local card = table.remove(self.playerHand, self.selectedCardIndex)
    if fieldIndex then
        local fieldCard = table.remove(self.field, fieldIndex)
        table.insert(self.playerCaptures, card)
        table.insert(self.playerCaptures, fieldCard)
        self:pushMessage("플레이어", string.format("%s(%d월) 카드를 맞춰 가져왔습니다.", card.suit, card.month))
    else
        table.insert(self.field, card)
        self:pushMessage("플레이어", string.format("%s(%d월) 카드를 깔았습니다.", card.suit, card.month))
    end

    self.selectedCardIndex = nil
    self.matchingFieldIndices = {}

    self:resolveDrawPhase("player")
    self:finishTurn()
end

function Game:cardIndexAt(collection, x, y, positionProvider)
    for index, _ in ipairs(collection) do
        local cx, cy = positionProvider(self, index)
        if pointInRect(x, y, cx, cy, CARD_WIDTH, CARD_HEIGHT) then
            return index
        end
    end
    return nil
end

function Game:getPlayerCardPosition(index)
    local startX = 80
    local y = love.graphics.getHeight() - CARD_HEIGHT - 60
    local spacing = CARD_WIDTH + CARD_PADDING
    return startX + (index - 1) * spacing, y
end

function Game:getCpuCardPosition(index)
    local startX = 80
    local y = 60
    local spacing = CARD_WIDTH + CARD_PADDING
    return startX + (index - 1) * spacing, y
end

function Game:getFieldCardPosition(index)
    local columns = FIELD_COLUMNS
    local spacingX = CARD_WIDTH + CARD_PADDING
    local spacingY = CARD_HEIGHT + CARD_PADDING
    local startX = (love.graphics.getWidth() - (spacingX * (columns - 1) + CARD_WIDTH)) / 2
    local startY = (love.graphics.getHeight() - CARD_HEIGHT) / 2 - spacingY / 2

    local column = (index - 1) % columns
    local row = math.floor((index - 1) / columns)
    local x = startX + column * spacingX
    local y = startY + row * spacingY
    return x, y
end

local function drawCard(card, x, y, faceUp, highlight)
    local r, g, b = cardColor(card)
    if not faceUp then
        r, g, b = 0.2, 0.2, 0.24
    end

    if highlight then
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", x - 4, y - 4, CARD_WIDTH + 8, CARD_HEIGHT + 8, 8, 8)
    end

    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", x, y, CARD_WIDTH, CARD_HEIGHT, 8, 8)

    love.graphics.setColor(0.12, 0.12, 0.14)
    love.graphics.rectangle("line", x, y, CARD_WIDTH, CARD_HEIGHT, 8, 8)

    if faceUp then
        love.graphics.setColor(0.1, 0.1, 0.12)
        love.graphics.printf(string.format("%d월", card.month), x + 6, y + 8, CARD_WIDTH - 12, "left")
        love.graphics.printf(card.label, x + 6, y + CARD_HEIGHT - 28, CARD_WIDTH - 12, "right")
    else
        love.graphics.setColor(0.8, 0.8, 0.9)
        love.graphics.printf("화투", x, y + CARD_HEIGHT / 2 - 12, CARD_WIDTH, "center")
    end
end

local function drawCardRow(collection, positionProvider, faceUp, highlightIndex, highlightSet)
    for index, card in ipairs(collection) do
        local x, y = positionProvider(index)
        local highlight = (highlightIndex and highlightIndex == index) or (highlightSet and highlightSet[index])
        drawCard(card, x, y, faceUp, highlight)
    end
end

local function buildHighlightSet(indices)
    local set = {}
    for _, index in ipairs(indices or {}) do
        set[index] = true
    end
    return set
end

function Game:drawSidebar()
    local width = 260
    local height = love.graphics.getHeight()
    local x = love.graphics.getWidth() - width

    love.graphics.setColor(0.08, 0.1, 0.13, 0.92)
    love.graphics.rectangle("fill", x, 0, width, height)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("기록", x + 24, 32)

    local y = 70
    for _, entry in ipairs(self.log) do
        local alpha = math.min(1, entry.timer / 6 + 0.3)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.printf(entry.title, x + 24, y, width - 48, "left")
        love.graphics.setColor(0.8, 0.82, 0.86, alpha)
        love.graphics.printf(entry.body, x + 24, y + 18, width - 48, "left")
        y = y + 60
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("포획 카드", x + 24, height / 2 + 40)

    local playerScore = sumCardValues(self.playerCaptures or {})
    local cpuScore = sumCardValues(self.cpuCaptures or {})

    love.graphics.setColor(0.9, 0.9, 0.96)
    love.graphics.printf(string.format("플레이어: %d점", playerScore), x + 24, height / 2 + 70, width - 48, "left")
    love.graphics.printf(string.format("CPU: %d점", cpuScore), x + 24, height / 2 + 92, width - 48, "left")
end

function Game:drawMenu()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Hwatu Showdown", 0, love.graphics.getHeight() / 2 - 80, love.graphics.getWidth(), "center")
    love.graphics.setColor(0.8, 0.82, 0.86)
    love.graphics.printf("스페이스바나 클릭으로 시작합니다", 0, love.graphics.getHeight() / 2 - 40, love.graphics.getWidth(), "center")
end

function Game:drawEndScreen()
    local playerScore = sumCardValues(self.playerCaptures)
    local cpuScore = sumCardValues(self.cpuCaptures)
    local message = "무승부"
    if playerScore > cpuScore then
        message = "플레이어 승리!"
    elseif playerScore < cpuScore then
        message = "CPU 승리"
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("라운드 종료", 0, love.graphics.getHeight() / 2 - 120, love.graphics.getWidth(), "center")
    love.graphics.printf(message, 0, love.graphics.getHeight() / 2 - 80, love.graphics.getWidth(), "center")
    love.graphics.setColor(0.8, 0.82, 0.86)
    love.graphics.printf(string.format("플레이어 %d점 / CPU %d점", playerScore, cpuScore), 0, love.graphics.getHeight() / 2 - 40, love.graphics.getWidth(), "center")
    love.graphics.printf("스페이스바, 엔터 혹은 클릭으로 다시 시작", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
end

function Game:draw()
    if self.state == "menu" then
        self:drawMenu()
        return
    end

    local highlightSet = buildHighlightSet(self.matchingFieldIndices)

    drawCardRow(self.cpuHand, function(index)
        return self:getCpuCardPosition(index)
    end, false)

    drawCardRow(self.field, function(index)
        return self:getFieldCardPosition(index)
    end, true, nil, highlightSet)

    drawCardRow(self.playerHand, function(index)
        return self:getPlayerCardPosition(index)
    end, true, self.selectedCardIndex)

    love.graphics.setColor(1, 1, 1)
    local turnText = self.turn == "player" and "당신의 차례" or "CPU 차례"
    if self.state == "ended" then
        self:drawEndScreen()
    else
        love.graphics.printf(turnText, 0, 20, love.graphics.getWidth(), "center")
    end

    self:drawSidebar()
end

return Game




