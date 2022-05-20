module ContainerCapacity

missingMonthlyCleaningFrequencyMapping = Dict(
    0 => 0.0,
	1 => 0.2,
	2 => 0.2,
	3 => 0.2,
	4 => 0.2,
	5 => 0.2,
	6 => 2.154,
	7 => 0.2,
	8 => 0.2,
)

function getContainerMonthlyCleaningFrequency(id::Integer)
    if id == 0
        return 2
    end

    frequencyPerPeriod, periodDuration = digits(id)

    return (frequencyPerPeriod / periodDuration) * 4
end

function getContainerCapacity(containerType::String)
    if(containerType === missing) 
		return missing
	end

	s = split(containerType," ")
	capacityString = s[1]
	capacity = parse(Int64, capacityString)
    return capacity
end

end
