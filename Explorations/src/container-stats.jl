module ContainerStats

begin
	using Random
	using DataFrames
	using DataInterpolations
	using TimeZones
	import CSV
	using DataFrames
	using Dates
	using Pipe
	using GeoJSON
end

include("data-conversion.jl")

hourInterval = 1000 * 60 * 60

filterRows(m, from, to) = filter(r -> !isnothing(r.measured_at) && r.measured_at > from && r.measured_at < to, m)

function fullnessFactor(measurements::DataFrame, from::DateTime, to::DateTime)
	filteredRows = filterRows(measurements, from, to)
	fd = filteredRows[!, :percent_calculated] |> reverse
	if (length(fd) === 0)
		return 0
    	end
	td = @pipe filteredRows[!, :measured_at] |> map(v -> Dates.value(v), _) |> reverse
	ifd = LinearInterpolation(fd, td)

	println("fd:", length(fd))
	it = Dates.value(from):hourInterval:Dates.value(to)

	fullnessPredicate(v) = v >= 95
	sumFull = @pipe it |> map(v -> ifd(v), _) |> filter(v -> fullnessPredicate(v), _) |> length

	println("sum full: ", sumFull)
	println("length: ", length(it))
    
	return sumFull / length(it)
end

function getFullnessFactorForContainer(containerId::String, from::DateTime, to::DateTime)
	println("Container id: $(containerId)")
	m = measurements = DataConversion.getContainerMeasurements(containerId)
	if (nrow(measurements) === 0)
		return 0
    	end
	f = fullnessFactor(m, from, to)
	return f
    end
    

end

