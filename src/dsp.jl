function lowpass(threshold::Float64)
    a(x) = x < threshold ? x : threshold
end

function highpass(threshold::Float64)
    a(x) = x > threshold ? x : threshold
end
