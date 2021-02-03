function remap(x, a, b, c, d)
    return x / (b - a) * (d - c) + c
end

function nRGB(r, g, b)
    return {r/255, g/255, b/255}
end

function new_ball(x, y, vx, vy, m, r, e, h)
    local ball = {
        x = x,
        y = y,
        vx = vx,
        vy = vy,
        px = x + vx * dt,
        py = y + vy * dt,
        m = m,
        w = (1/m) or 0,
        r = r or 12,
        e = e or 1,
        h = h or false
    }

    table.insert(balls, ball)
end

function step_ball(ball)
    ball.vx = (ball.px - ball.x) / dt
    ball.vy = (ball.py - ball.y) / dt

    if radius then
        if ball.px + ball.r > width then
            -- resolves penetration
            ball.px = width - ball.r
            -- velocity is not multiplyed with -1 to avoid jitter
            ball.vx = -math.abs(ball.vx) * ball.e
        elseif ball.px - ball.r < 0 then
            ball.px = ball.r
            ball.vx = math.abs(ball.vx) * ball.e
        end

        if ball.py + ball.r > height then
            ball.py = height - ball.r
            ball.vy = -math.abs(ball.vy) * ball.e
        elseif ball.py - ball.r < 0 then
            ball.py = ball.r
            ball.vy = math.abs(ball.vy) * ball.e
        end
    else
        if ball.px > width then
            -- resolves penetration
            ball.px = width
            -- velocity is not multiplyed with -1 to avoid jitter
            ball.vx = -math.abs(ball.vx) * ball.e
        elseif ball.px < 0 then
            ball.px = 0
            ball.vx = math.abs(ball.vx) * ball.e
        end

        if ball.py > height then
            ball.py = height
            ball.vy = -math.abs(ball.vy) * ball.e
        elseif ball.py < 0 then
            ball.py = 0
            ball.vy = math.abs(ball.vy) * ball.e
        end
    end

    ball.x = ball.px
    ball.y = ball.py
            
    ball.vx = ball.vx + (dt * ball.w * gravity.x * air)
    ball.vy = ball.vy + (dt * ball.w * gravity.y * air)

    ball.px = ball.x + (ball.vx * dt)
    ball.py = ball.y + (ball.vy * dt)
end

function new_stick(i1, i2, d, k, h)
    local stick = {
        i1 = i1,
        i2 = i2,
        d = d or ((balls[i1].x - balls[i2].x)^2 + (balls[i1].y - balls[i2].y)^2)^0.5,
        k = k or 1,
        h = h or false
    }

    table.insert(sticks, stick)
end

function project_stick(stick)
    -- shorthand
    stick.ball1 = balls[stick.i1]
    stick.ball2 = balls[stick.i2]

    if not (stick.ball1.w == 0 and stick.ball2.w == 0) then
        -- difference in position x, y
        local dx = stick.ball1.px - stick.ball2.px
        local dy = stick.ball1.py - stick.ball2.py

        -- distance between balls
        local d = (dx^2 + dy^2)^.5

        -- the offset ist the actuale distance minus the
        local ox = (d - stick.d) * (dx / d)
        local oy = (d - stick.d) * (dy / d)

        stick.ball1.px = stick.ball1.px - ((stick.ball1.w / (stick.ball1.w + stick.ball2.w) * ox) * stick.k)
        stick.ball1.py = stick.ball1.py - ((stick.ball1.w / (stick.ball1.w + stick.ball2.w) * oy) * stick.k)

        stick.ball2.px = stick.ball2.px + ((stick.ball2.w / (stick.ball1.w + stick.ball2.w) * ox) * stick.k)
        stick.ball2.py = stick.ball2.py + ((stick.ball2.w / (stick.ball1.w + stick.ball2.w) * oy) * stick.k)
    end
end

function new_quad(x1, y1, x2, y2, x3, y3, x4, y4, m, c)
    local i = #balls
    
    new_ball(x1, y1, 0, 0, m, size, 1, true)
    new_ball(x2, y2, 0, 0, m, size, 1, true)
    new_ball(x3, y3, 0, 0, m, size, 1, true)
    new_ball(x4, y4, 0, 0, m, size, 1, true)

    new_stick(i + 1, i + 2, nil, 1, true)
    new_stick(i + 2, i + 3, nil, 1, true)
    new_stick(i + 3, i + 4, nil, 1, true)
    new_stick(i + 4, i + 1, nil, 1, true)
    new_stick(i + 1, i + 3, nil, 1, true)
    new_stick(i + 2, i + 4, nil, 1, true)

    local quad = {
        c = c or {1, 1, 1},
        vi = {
            i + 1,
            i + 2,
            i + 3,
            i + 4
        },
        v = {
            x1, y1,
            x2, y2,
            x3, y3,
            x4, y4
        }
    }

    table.insert(bodies, quad)
end

function new_tri(x1, y1, x2, y2, x3, y3, m, c)
    local i = #balls

    new_ball(x1, y1, 0, 0, m, size, 1, true)
    new_ball(x2, y2, 0, 0, m, size, 1, true)
    new_ball(x3, y3, 0, 0, m, size, 1, true)

    new_stick(i + 1, i + 2, nil, 1, true)
    new_stick(i + 2, i + 3, nil, 1, true)
    new_stick(i + 3, i + 1, nil, 1, true)
    
    local tri = {
        c = c or {1, 1, 1},
        vi = {
            i + 1,
            i + 2,
            i + 3
        },
        v = {
            x1, y1,
            x2, y2,
            x3, y3
        }
    }

    table.insert(bodies, tri)
end

function update_body(body)
    body.v = {}

    for j, k in pairs(body.vi) do
        table.insert(body.v, balls[k].x)
        table.insert(body.v, balls[k].y)
    end
end

function new_box(x, y, w, h, m, c)
    new_quad(x, y, x + w, y, x + w, y + h, x, y + h, m, c)
end

function new_rope(x, y, l, d, m, s)
    local i = #balls + 1

    if s then
        new_ball(x, y, 0, 0, 1/0, size, 1, false)
    else
        new_ball(x, y, 0, 0, m, size, 1, true)
    end

    for j = 1, d - 1 do
        new_ball(x, y + (l / d) * j, 0, 0, m, size, 1, true)
        new_stick(i + j - 1, i + j, l / d, 1, false)
    end
end

--[[
function new_mesh(x, y, w, h, d, m)
    --[[
    local i = #balls + 1
    local k = 0
    local s = h / d

    for ny = y, y + h, s do
        local j = 0
        for nx = x, x + w, w / d do
            new_ball(nx, ny, 0, 0, m, size, 1)
            if j < d then new_stick(i + j, i + j + 1, s) end
            if k < d then new_stick(i + j, i + j + k, s) end
            j = j + 1
        end
        k = k + 1
    end
    ]]--[[

    local o = #balls
    local ws = w / d
    local hs = h / d

    for j = 0, d - 1 do
        for i = 0, d - 1 do
            new_ball(x + i * ws, y + j * hs, 0, 0, 1/0, size, 1)
            local n = o + j * d + i
            if i < d then new_stick(n, n + 1, ws) end
            if j < d then new_stick(n, n + d + 1, hs) end
        end
    end
end
]]

function love.load()
    width, height = 960, 480
    
    love.window.setTitle("PBD implemented by m4dh0rs3")
    love.window.setMode(width, height)

    love.graphics.setBackgroundColor(89/255, 72/255, 113/255)
    love.graphics.setLineWidth(2)

    balls = {}
    sticks = {}
    bodies = {}

    resolve = 2 * #sticks
    dt = 0.6

    gravity = {x = 0, y = 9.81}
    air = 1

    size = 6
    mass = 3

    pause = false
    pick = false
    near = 12
    skeleton = false
    radius = false

    --[[
    new_engine(256, 256, 64, 1 / 16)
    new_stick(1, 2, 4)
    new_rope(width / 2 + 128, 128, 256, 64, mass, false)
    new_engine(width - 256, height - 256, 64, 1 / 8)
    new_stick(#balls, #balls - 1, 4)
    

    --[[new_mesh(128, 128, 256, 256, 4, mass)


    new_ball(width / 2, height / 4, 0, 0, 1/0, size, 1)
    new_ball(width / 2, height / 2, 0, 0, mass, size, 1)
    new_muscle(1, 2, 64, 245, 1 / 16, 1)
    new_ball(width / 2, height / 4, 0, 0, 1/0, size, 1)
    new_ball(width / 2, height / 2, 0, 0, mass, size, 1)
    new_muscle(3, 4, 64, 245, 1 / 16, 1)
    ]]

    resolve = 2 * #sticks
end

function love.update()
    mx, my = love.mouse.getPosition()
    
    if not pause then
        for i, ball in pairs(balls) do
            step_ball(ball)
        end

        for j = 1, resolve do
            for i, stick in pairs(sticks) do
                project_stick(stick)
            end
        end
    else
        for i, stick in pairs(sticks) do
            stick.d = ((balls[stick.i1].x - balls[stick.i2].x)^2 + (balls[stick.i1].y - balls[stick.i2].y)^2)^0.5
        end

    end

    if pick then
        if pick.type == 1 then
            balls[pick.i].x = mx
            balls[pick.i].y = my

            balls[pick.i].px = mx
            balls[pick.i].py = my
        end
    end

    for i, body in pairs(bodies) do
        update_body(body)
    end
end

function toClipboard()
    text = "--PBD\nb,s=new_ball,new_stick\nlocal i=#balls\n"

    for i, ball in pairs(balls) do
        text = text.."b("..ball.x..","..ball.y..",0,0,"..ball.m..","..ball.r..","..ball.e..")\n"
    end

    for i, stick in pairs(sticks) do
        text = text.."s("..stick.i1.."+i,"..stick.i2.."+i)\n"
    end

    love.system.setClipboardText(text)
end

function love.keyreleased(key)
    if key == "space" then
        pause = not pause
    elseif key == "c" then
        balls = {}
        sticks = {}
        bodies = {}
    elseif key == "s" then
        toClipboard()
    elseif key == "k" then
        skeleton = not skeleton
    elseif key == "r" then
        radius = not radius
    elseif key == "q" then
        new_box(mx, my, 64, 64, 3, nRGB(198, 76, 68))
    elseif key == "t" then
        new_tri(mx, my, mx+64, my, mx+64, my+64, 3, nRGB(99, 189, 93))
    end

    resolve = 2 * #sticks
end

function love.quit()
    toClipboard()
end

function love.mousepressed(mx, my, btn)
    local i, d = 0, 9e9

    for j, ball in pairs(balls) do
        local k = ((mx - ball.x)^2 + (my - ball.y)^2)^0.5

        if k < d then
            d = k
            i = j
        end
    end

    if btn == 1 then
        if d > near or i == 0 then
            new_ball(mx, my, 0, 0, mass, size, 1)
        else
            pick = {
                i = i,
                type = 1
            }
        end
    elseif btn == 2 and d < near and i ~= 0 then
        pick = {
            i = i,
            type = 2
        }
    elseif btn == 3 then
        new_rope(mx, my, width / 4, 24, mass, true)
    end

    resolve = 2 * #sticks
end

function love.mousereleased(mx, my)
    if pick then
        if pick.type == 2 then
            local i, d = 0, 9e9

            for j, ball in pairs(balls) do
                local k = ((mx - ball.x)^2 + (my - ball.y)^2)^0.5

                if k < d then
                    d = k
                    i = j
                end
            end

            if i ~= 0 and d < near and pick.i ~= i then
                if ((balls[pick.i].x-balls[i].x)^2 + (balls[pick.i].y-balls[i].y)^2)^.5 < 8 then
                    new_stick(pick.i, i, 0, 1, true)
                else
                    new_stick(pick.i, i)
                end
            elseif pick.i == i and d < near then
                ball = balls[pick.i]
                
                if ball.w == 0 then
                    ball.w = 1/mass
                    ball.m = mass
                else
                    ball.w = 0
                    ball.m = 1/0
                    ball.px = ball.x
                    ball.py = ball.y
                end
            end
        end

        pick = false
    end

    resolve = 2 * #sticks
end

function love.draw()
    if not skeleton then
        for i, body in pairs(bodies) do
            draw_body(body)
        end
    end

    for i, stick in pairs(sticks) do
        draw_stick(stick)
    end

    for i, ball in pairs(balls) do
        draw_ball(ball)
    end

    if pick and pick.type == 2 then
        love.graphics.setColor(242/255, 233/255, 228/255)
        love.graphics.line(
            balls[pick.i].x,
            balls[pick.i].y,
            mx, my
        )
    end

    draw_debug()
end

function draw_debug()
    love.graphics.setColor(200/255, 201/255, 244/255)
    love.graphics.print("Delta Time: "..dt, 16, 16)
    love.graphics.print("Constraint Projection: "..resolve, 16, 32)
    love.graphics.print("Balls: "..#balls, 16, 48)
    love.graphics.print("Sticks: "..#sticks, 16, 64)
    
    love.graphics.print("FPS: "..love.timer.getFPS(), 16, 80)

    if pause then
        love.graphics.print("PAUSED", width - 64, 16)
    end
end

function draw_stick(stick)
    if skeleton or (not stick.h) then
        love.graphics.setColor(188/255, 129/255, 105/255)

        love.graphics.line(
            balls[stick.i1].x,
            balls[stick.i1].y,
            balls[stick.i2].x,
            balls[stick.i2].y
        )
    end
end

function draw_body(body)
    love.graphics.setColor(body.c)
    love.graphics.polygon("fill", body.v)
end

function draw_ball(ball)
    if skeleton or (not ball.h) then
        love.graphics.setColor(120/255, 171/255, 172/255)

        if ball.w == 0 then
            love.graphics.circle("fill", ball.x, ball.y, ball.r)
        else
            love.graphics.circle("line", ball.x, ball.y, ball.r)
        end
    end
end
