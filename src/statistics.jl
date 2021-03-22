
function semideviation(a; kwargs...)
    return std(map(x -> x < 0 ? x : 0.0, a); kwargs...)
end

function semideviation(ta::TimeArray; kwargs...)
    return semideviation(values(ta); kwargs...)
end
