local confirmed
local heading

function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function DrawPropAxes(prop)
    local propForward, propRight, propUp, propCoords = GetEntityMatrix(prop)

    local propXAxisEnd = propCoords + propRight * 1.0
    local propYAxisEnd = propCoords + propForward * 1.0
    local propZAxisEnd = propCoords + propUp * 1.0

    DrawLine(propCoords.x, propCoords.y, propCoords.z + 0.1, propXAxisEnd.x, propXAxisEnd.y, propXAxisEnd.z, 255, 0, 0, 255)
    DrawLine(propCoords.x, propCoords.y, propCoords.z + 0.1, propYAxisEnd.x, propYAxisEnd.y, propYAxisEnd.z, 0, 255, 0, 255)
    DrawLine(propCoords.x, propCoords.y, propCoords.z + 0.1, propZAxisEnd.x, propZAxisEnd.y, propZAxisEnd.z, 0, 0, 255, 255)
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

local function DrawControlText(text, x, y)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.35)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function placeProp(prop)
    prop = joaat(prop)
    heading = 0.0
    confirmed = false

    RequestModel(prop)
    while not HasModelLoaded(prop) do
        Wait(0)
    end

    local hit, coords, entity

    while not hit do
        hit, coords, entity = RayCastGamePlayCamera(1000.0)
        Wait(0)
    end

    prop = CreateObject(prop, coords.x, coords.y, coords.z, true, false, true)

    CreateThread(function()
        while not confirmed do
            hit, coords, entity = RayCastGamePlayCamera(1000.0)

            SetEntityCoordsNoOffset(prop, coords.x, coords.y, coords.z, false, false, false, true)
            FreezeEntityPosition(prop, true)
            SetEntityCollision(prop, false, false)
            SetEntityAlpha(prop, 100, false)
            DrawPropAxes(prop)
            Wait(0)

            if IsControlPressed(0, 174) then -- Left arrow key
                heading = heading + 1.0
            elseif IsControlPressed(0, 175) then -- Right arrow key
                heading = heading - 1.0
            end

            DrawControlText("Press Left Arrow Key to Rotate Left", 0.5, 0.85)
            DrawControlText("Press Right Arrow Key to Rotate Right", 0.5, 0.9)
            DrawControlText("Press E to Confirm Placement", 0.5, 0.95)
            
            if heading > 360.0 then
                heading = 0.0
            elseif heading < 0.0 then
                heading = 360.0
            end

            SetEntityHeading(prop, heading)

            if IsControlJustPressed(0, 38) then -- "E" key
                confirmed = true
                SetEntityAlpha(prop, 255, false)
                SetEntityCollision(prop, true, true)
                -- DeleteObject(prop)
                -- return coords, heading -- returns coords and heading back to sctipt
            end
        end
    end)
end

exports("placeProp", placeProp)

-- Register a command to trigger the prop placing
RegisterCommand("placeprop", function()
    placeProp(666561306)
end)














