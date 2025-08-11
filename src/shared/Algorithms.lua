local algorithms = {}

local function partition(array, left, right, pivotIndex)
	local pivotValue = array[pivotIndex]
	array[pivotIndex], array[right] = array[right], array[pivotIndex]

	local storeIndex = left

	for i = left, right - 1 do
		if array[i]:GetAttribute("Price") <= pivotValue:GetAttribute("Price") then
			array[i], array[storeIndex] = array[storeIndex], array[i]
			storeIndex = storeIndex + 1
		end
	end

	array[storeIndex], array[right] = array[right], array[storeIndex]
	return storeIndex
end

function algorithms.quicksort(array, left, right)
	if right > left then
		local pivotNewIndex = partition(array, left, right, left)
		algorithms.quicksort(array, left, pivotNewIndex - 1)
		algorithms.quicksort(array, pivotNewIndex + 1, right)
	end
end

return algorithms

