function load_data(channel, mX)
    if channel == :electron
        n = 800
        data = rand(Normal(mX, 0.5*mX), n)
        return data
    elseif channel == :muon
        n = 1500
        data = rand(Normal(mX, 0.1*mX), n)
        return data
    else
        n = 800
        data = rand(Normal(mX, 0.5*mX), n)
        return data
    end
end

function histogram_fit_likelihood(f, h) 
    bin_midpoints = collect(bincenters(h))
    bin_widths = [(binedges(h)[i+1] - binedges(h)[i]) for i in 1:length(binedges(h))-1]

    observed_counts = bincounts(h)#/integral(h)

    return logfuncdensity(function (params)
        function bin_log_likelihood(i)
            expected_counts = bin_widths[i] * f(params, bin_midpoints[i])
            logpdf(Poisson(expected_counts), observed_counts[i])
        end 

        idxs = eachindex(observed_counts)
        ll_value = bin_log_likelihood(idxs[1])
        for i in idxs[2:end]
            ll_value += bin_log_likelihood(i)
        end
        return ll_value
    end)
end


