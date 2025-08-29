local sortModule = {}
local price = 2

--// Local Functions
local function LowToHightPrice(array)
	local function partition(array, left, right, pivotIndex)
		local pivotValue = array[pivotIndex]
		array[pivotIndex], array[right] = array[right], array[pivotIndex]

		local storeIndex = left

		for i = left, right - 1 do
			if array[i][price] <= pivotValue[price] then
				array[i], array[storeIndex] = array[storeIndex], array[i]
				storeIndex = storeIndex + 1
			end
		end

		array[storeIndex], array[right] = array[right], array[storeIndex]
		return storeIndex
	end

	local function quicksort(array, left, right)
		if right > left then
			local pivotNewIndex = partition(array, left, right, left)
			quicksort(array, left, pivotNewIndex - 1)
			quicksort(array, pivotNewIndex + 1, right)
		end
	end
	quicksort(array, 1, #array)
end

local function HightToLowPrice(array)
	local function partition(array, left, right, pivotIndex)
		local pivotValue = array[pivotIndex]
		array[pivotIndex], array[right] = array[right], array[pivotIndex]

		local storeIndex = left

		for i = left, right - 1 do
			if array[i][price] >= pivotValue[price] then
				array[i], array[storeIndex] = array[storeIndex], array[i]
				storeIndex = storeIndex + 1
			end
		end

		array[storeIndex], array[right] = array[right], array[storeIndex]
		return storeIndex
	end

	local function quicksort(array, left, right)
		if right > left then
			local pivotNewIndex = partition(array, left, right, left)
			quicksort(array, left, pivotNewIndex - 1)
			quicksort(array, pivotNewIndex + 1, right)
		end
	end
	quicksort(array, 1, #array)
end

local function Limted(array)
	for index in array do
		if not array[index][8] then
			table.remove(array, index)
		end
	end
end

--// Module Functions
sortModule.sort = function(typeOfSort, theTable)
	if typeOfSort == "Sort By Price" then
		LowToHightPrice(theTable)
	elseif typeOfSort == "high to low" then
		HightToLowPrice(theTable)
	elseif typeOfSort == "Limted" then
		Limted(theTable)
	end
end

return sortModule
