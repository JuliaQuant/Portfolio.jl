module Portfolio

    using Pipe: @pipe
    using TimeSeries
    import StatsBase: std, mean

    export
        # types
        Signal, Weights, Returns,
        PortfolioReturns, Brokerage,
        # dsp
        highpass, lowpass,
        # statistics
        semideviation,
        # utils
        equity_curve,
        # rebalancing
        skip_period,
        # performance-analytics
        returns_annualized, std_annualized, semid_annualized, sharpe_annualized, sortino_annualized,
        # operations
        ensemble_parameters, merge_weights,
        # compute
        run_weights
        # strategies
        strategy_positive_mom_binary, strategy_prive_above_sma_binary, strategy_vol_target_mean, strategy_vol_target, strategy_vol_threshold, strategy_semideviation_target_mean, strategy_semideviation_threshold


    include("types.jl")
    include("dsp.jl")
    include("performance-analytics.jl")
    include("operations.jl")
    include("strategies.jl")
    include("statistics.jl")
    include("utils.jl")
    include("rebalancing.jl")
    include("compute.jl")

end
