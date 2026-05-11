classdef Tracks < handle
    % Class to parse the results from quickLook to tracks.
    %
    % Usage:
    % obj = Tracks();
    % obj.doTracks(rh); <- will call initialize(rh)
    % obj.calcSNRmetrics(); <- after doTracks(rh) is called.
    %
    % Output is organized as follows:
    %
    % out.SYSTEM.FREQ.VARIABLE, e.g.:
    % out.G.L1.amplitude for the Lomb amplitude for GPS L1.
    %
    % Therefore the rh is parsed in per-satellite information, separated by
    % system and frequency. Each VARIABLE is an N-dimensional matrix of
    % the form: NUM_AZIMS x NUM_SVS x NUM_DOYS x NUM_YEARS
    % where NUM_AZIMS = 4 for azRes = 90: 360/90 = 4.
    % Also, NUM_SVS depend on each system total satellites, and
    % NUM_DOYS and NUM_YEARS depend on the length of rh.
    %
    % Example, 3 years for GPS L1, with 32 SVs, the result dimensions will
    % be 4 x 32 x 365 x 3. Notice that the dimensions would be the same if
    % instead of being 3 full years, thye were 2 and a half, or 2 and 1
    % day, since MATLAB will automatically reserve space for the matrix, to
    % keep the shape among all dimensions.
    % This can be optimized by, for example, continuing the years during
    % the day-of-year dimension.
    %
    %
    % TODO: evaluate a change to TOTAL_DAYS x NUM_AZIMS x NUM_SVS
    % where TOTAL_DAYS will be indexed by (1 : 365) + 365 * (year - year0)
    % Thus no uncessesary memory is allocated.

    properties (Constant, GetAccess = private)
        % Constants

        speedOfLight = 299792458; % Speed of light
    end

    properties (SetAccess = public, GetAccess = public) % set permission have been changed from private to public (Giulio)
        % Public properties, azRes is set by the user, but could be set
        % privately as a constant too.
        azRes;
        % Percentage factor for Alsp normalization, i.e. 20% (highest)
        percFactor_AlspNorm;
        % Percentage factor for phase zeroing, i.e. 15% (lowest)
        percFactor_phaseZeroed;
        % Sigma multiplier: metric valid region.
        % High enough to remove outliers, but low enough to cover trustable
        % phase variations induced by actual climate variable.
        % Is more related with data variability, which can account for
        % signal level, estimation errors/variance, are other noise sources.
        metric_region_sigma;
        % P2N thereshold
        % Same reasoning as in metric_region_sigma. Not a statistical
        % approach, mainly to account for good signal levels, but leaving
        % some margin to actual changes do to climate variables.
        % Too high can mask the ECVs to monitor, but too low can include a
        % lot of undesired measurements.
        p2n_th;
        % When being less conservative in p2n_th and metric_region_sigma,
        % the mean/median converges to the weighted. Preferably, a
        % medium-high p2n threshold and 2 or 3-sigma region can be set. This
        % should account for real changes in the ECV to monitor, leading to
        % trustable results.
        % The weighted mean is anyway together with the normal mean.
        
        % Output struct
        out;
    end

    properties (SetAccess = private, GetAccess = private) % set permission have been changed from private to public (Giulio)
        % Private variables used among functions.

        cc;         % Constellation collector
        azTotal;    % Total azimuth divisions. For azRes = 90, 4 divisions.
        azPairs;    % Pairs of azimuths to combine.
        yearList;   % Array containing visible years in rh.
        year0;      % First year, used for handling the dimensions and save
        % memory
        doyList;    % Array containing visible days of the year in rh.
        doy0        % First day of year, used for handling the dimensions
        % and save memory, but is irrelevant if there is a
        % year change.
        dim_az;
        dim_sv;
        dim_doy;
    end

    methods
        function this = Tracks(rh)
            % Constructor Function

            % Constellation Collector
            this.cc = Core.getConstellationCollector;
            % Resolution for azimuth indexing
            this.azRes = 90;
            this.percFactor_AlspNorm = 20;
            this.percFactor_phaseZeroed = 15;
            this.metric_region_sigma = 2;
            this.p2n_th = 3;

            this.azTotal = 360/this.azRes;
            this.azPairs = reshape(1 : this.azTotal, this.azTotal/2, 2).';
            this.dim_az = 2; this.dim_sv = 3; this.dim_doy = 1;

            if nargin ~= 0
                this.doTracks(rh);
            end
        end
    end

    methods (Access = 'private')
        function initialize(this, rh)
            % Initialization function, it initialized the private
            % proeprties as well as the output struct with NAN values.

            % Get doy for time indexing
            [years, doys, ~] = rh.time.getDOY;
            this.yearList = unique(years);
            this.year0 = this.yearList(1);
            this.doyList = unique(doys);
            this.doy0 = this.doyList(1);
            % Array containing visible systems in rh.
            sysList = unique(rh.sat(:,1));
            % Array containing frequencyes per system in rh.
            wlList = unique(rh.wl);

            % Look for system
            sysLabelList = [];
            for sysc = sysList.'
                % Get System information
                sysInfo = this.cc.getSys(sysc);
                sysLabel = sysInfo.SYS_NAME;
                this.out.(sysLabel) = [];
                sysLabelList = [sysLabelList, {sysLabel}];
                % Get frequency labels
                sysFreqs = sysInfo.F;
                sysFreqsLabels = fieldnames(sysFreqs);
                sysFreqsValues = [];
                for fname = sysFreqsLabels.'
                    sysFreqsValues = [sysFreqsValues; getfield(sysFreqs, cell2mat(fname))];
                end
                % Get number of SVs
                sysNumSVs = length(sysInfo.go_ids);
                % Get dimensions, depend on the system because depend on
                % the number of satellites.

                dims = [(diff(minMax(this.doyList)) + 1)*length(this.yearList), this.azTotal, sysNumSVs];

                % Look for band
                freqLabels = [];
                for wl = wlList.' % for
                    freq = this.speedOfLight/wl * 1e-6;
                    [~, freqLabelIdx] = min(abs(sysFreqsValues - freq));
                    freqLabel = cell2mat(sysFreqsLabels(freqLabelIdx));
                    freqLabels = [freqLabels; {freqLabel}];
                    this.out.(sysLabel).(freqLabel) = [];
                    this.out.(sysLabel).(freqLabel).wl = wl;

                    % Measurements
                    this.out.(sysLabel).(freqLabel).time.dates = NaT(dims(this.dim_doy),1);
                    this.out.(sysLabel).(freqLabel).time.years = nan(dims(this.dim_doy),1);

                    this.out.(sysLabel).(freqLabel).height.values = nan(dims);
                    this.out.(sysLabel).(freqLabel).height.azAvg = nan([dims(this.dim_doy), dims(this.dim_az)/2, dims(this.dim_sv)]);
                    this.out.(sysLabel).(freqLabel).height.avg = nan(dims([this.dim_doy, this.dim_sv]));

                    this.out.(sysLabel).(freqLabel).amplitude.values = nan(dims);
                    this.out.(sysLabel).(freqLabel).amplitude.azAvg = nan([dims(this.dim_doy), dims(this.dim_az)/2, dims(this.dim_sv)]);
                    this.out.(sysLabel).(freqLabel).amplitude.avg = nan(dims([this.dim_doy, this.dim_sv]));

                    this.out.(sysLabel).(freqLabel).phase.values = nan(dims);
                    this.out.(sysLabel).(freqLabel).phase.azAvg = nan([dims(this.dim_doy), dims(this.dim_az)/2, dims(this.dim_sv)]);
                    this.out.(sysLabel).(freqLabel).phase.avg = nan(dims([this.dim_doy, this.dim_sv]));

                    this.out.(sysLabel).(freqLabel).p2n.values = nan(dims);


                    % Metrics
                    this.out.(sysLabel).(freqLabel).h0.values = nan([dims([this.dim_az, this.dim_sv]) length(this.yearList)]);

                    this.out.(sysLabel).(freqLabel).deltaHeightEff.values = nan(dims);
                    this.out.(sysLabel).(freqLabel).deltaHeightEff.azAvg = nan([dims(this.dim_doy), dims(this.dim_az)/2, dims(this.dim_sv)]);
                    this.out.(sysLabel).(freqLabel).deltaHeightEff.avg = nan(dims([this.dim_doy, this.dim_sv]));

                    this.out.(sysLabel).(freqLabel).AlspNorm.values = nan(dims);
                    this.out.(sysLabel).(freqLabel).AlspNorm.azAvg = nan([dims(this.dim_doy), dims(this.dim_az)/2, dims(this.dim_sv)]);
                    this.out.(sysLabel).(freqLabel).AlspNorm.avg = nan(dims([this.dim_doy, this.dim_sv]));

                    this.out.(sysLabel).(freqLabel).phaseZeroed.values = nan(dims);
                    this.out.(sysLabel).(freqLabel).phaseZeroed.azAvg = nan([dims(this.dim_doy), dims(this.dim_az)/2, dims(this.dim_sv)]);
                    this.out.(sysLabel).(freqLabel).phaseZeroed.avg = nan(dims([this.dim_doy, this.dim_sv]));

                end
                this.out.(sysLabel).sysc = sysc;
                this.out.(sysLabel).dims = dims;
                this.out.(sysLabel).freqs = freqLabels;
            end
            this.out.sys = sysLabelList;
        end

        function doTracks(this, rh)
            % Function for generate the tracks by parsing rh to
            % per-satellite information, separated by system and frequency,
            % and each variable is a N-dimensional matrix of the form:
            % NUM_AZIMS x NUM_SVS x NUM_DOYS x NUM_YEARS
            % where NUM_AZIMS = 4 for azRes = 90: 360/90 = 4.
            % Also, NUM_SVS depend on each system total satellites, and
            % NUM_DOYS and NUM_YEARS depend on the length of rh.

            this.initialize(rh);
            get_az_ix = @(az)(mod(floor(mod(az/this.azRes, this.azTotal) + 0), this.azTotal) + 1);

            [years, doys, ~] = rh.time.getDOY;
            dates = rh.time.getDateTime;

            % Look for system
            for sysLabel = this.out.sys.'
                sysLabel = cell2mat(sysLabel);
                % Get System information
                sysc = this.out.(sysLabel).sysc;
                sysInfo = this.cc.getSys(sysc);
                sysLabel = sysInfo.SYS_NAME;
                sysIdx = find(rh.sat(:,1) == sysc);

                % Look for band
                for freqLabel = this.out.(sysLabel).freqs.' % For freq in the system
                    freqLabel = cell2mat(freqLabel);
                    wl = this.out.(sysLabel).(freqLabel).wl;
                    wlIdx = find(rh.wl == wl);

                    % Look for year
                    for year = this.yearList.'
                        yearIdx = find(years == year);
                        % Look for date in system and band
                        for doy = this.doyList.'
                            doyIdx = find(doys == doy);
                            % Get indexes for satellites at this system,
                            % frequency, year and day of year
                            indexes = intersect(sysIdx, wlIdx);
                            indexes = intersect(indexes, doyIdx);
                            indexes = intersect(indexes, yearIdx);

                            if(indexes)
                                % Get visible satellites and corresponding
                                % azimuths angles.
                                svsVisible =  str2num(char(string(rh.sat(indexes,2:end))));
                                svsVisibleUnique = str2num(char(unique(string(rh.sat(indexes,2:end)))));
                                azims = rh.arc_az(indexes);

                                % Sanity checking
                                %clc
                                %sprintf('Obtained')
                                %[indexes, azims, svsVisible, this.doys(indexes), rh.wl(indexes), rh.value(indexes)]
                                %testsv = "G01";
                                %sprintf('Checking for %s and doy %d and year %d', testsv, doy, year)
                                %[rh.arc_az(find(string(rh.sat) == testsv)), this.doys(find(string(rh.sat) == testsv)), rh.wl(find(string(rh.sat) == testsv)), rh.value(find(string(rh.sat) == testsv))]


                                % set values per satellite for all found
                                % azimuths.
                                rhAll = rh.value(indexes);
                                pwrAll = rh.p_amp(indexes);
                                phAll = rh.ph(indexes);
                                p2nAll = rh.p2n(indexes);

                                elMeanAll = mean(rh.el_lim(indexes,:),2);
                                doyDim = doy - this.doy0 + 1;
                                yearDim = year - this.year0 + 1;
                                yearOffset = 365 * (yearDim - 1);
                                for sv = svsVisibleUnique.'
                                    rhs = rhAll(svsVisible == sv);
                                    pwr = pwrAll(svsVisible == sv);
                                    ph = phAll(svsVisible == sv);
                                    p2n = p2nAll(svsVisible == sv);

                                    az = azims(svsVisible == sv);
                                    azIdx = get_az_ix(az);

                                    this.out.(sysLabel).(freqLabel).height.values(doyDim + yearOffset, azIdx, sv) = rhs;
                                    this.out.(sysLabel).(freqLabel).amplitude.values(doyDim + yearOffset, azIdx, sv) = pwr;
                                    this.out.(sysLabel).(freqLabel).phase.values(doyDim  + yearOffset, azIdx, sv) = ph;
                                    this.out.(sysLabel).(freqLabel).p2n.values(doyDim + yearOffset, azIdx, sv) = p2n;
                                end
                                this.out.(sysLabel).(freqLabel).time.dates(doyDim + yearOffset) = unique(dateshift(dates(indexes),'start','day'));
                                this.out.(sysLabel).(freqLabel).time.years(doyDim + yearOffset) = year;
                            end
                        end
                    end

                    % Calculate average over azimuth sections for each day,
                    % i.e. height(:,1:azTotal,sv), where azTotal = number
                    % of azimuth sections, 4 if azRes = 90.
                    % So make a row-wise average and add as a 5th column
                    % (or "azTotal+1"-th column).
                    dims = this.out.(sysLabel).dims;
                    for sv = 1 : dims(this.dim_sv)
                        for pairIdx = 1 : size(this.azPairs, 2)
                            arcIdx = this.azPairs(:,pairIdx);
                            avg = mean(this.out.(sysLabel).(freqLabel).height.values(:,arcIdx,sv),2,'omitnan');
                            avg(find(avg == 0)) = nan;
                            this.out.(sysLabel).(freqLabel).height.azAvg(:,pairIdx,sv) = avg;

                            avg = mean(this.out.(sysLabel).(freqLabel).amplitude.values(:,arcIdx,sv),2,'omitnan');
                            avg(find(avg == 0)) = nan;
                            this.out.(sysLabel).(freqLabel).amplitude.azAvg(:,pairIdx,sv) = avg;

                            avg = mean(this.out.(sysLabel).(freqLabel).phase.values(:,arcIdx,sv),2,'omitnan');
                            avg(find(avg == 0)) = nan;
                            this.out.(sysLabel).(freqLabel).phase.azAvg(:,pairIdx,sv) = avg;

                            avg = mean(this.out.(sysLabel).(freqLabel).p2n.values(:,arcIdx,sv),2,'omitnan');
                            avg(find(avg == 0)) = nan;
                            this.out.(sysLabel).(freqLabel).p2n.azAvg(:,pairIdx,sv) = avg;
                        end

                        avg = mean(this.out.(sysLabel).(freqLabel).height.azAvg(:,:,sv),2,'omitnan');
                        avg(find(avg == 0)) = nan;
                        this.out.(sysLabel).(freqLabel).height.avg(:,sv) = avg;

                        avg = mean(this.out.(sysLabel).(freqLabel).amplitude.azAvg(:,:,sv),2,'omitnan');
                        avg(find(avg == 0)) = nan;
                        this.out.(sysLabel).(freqLabel).amplitude.avg(:,sv) = avg;

                        avg = mean(this.out.(sysLabel).(freqLabel).phase.azAvg(:,:,sv),2,'omitnan');
                        avg(find(avg == 0)) = nan;
                        this.out.(sysLabel).(freqLabel).phase.avg(:,sv) = avg;

                        avg = mean(this.out.(sysLabel).(freqLabel).p2n.azAvg(:,:,sv),2,'omitnan');
                        avg(find(avg == 0)) = nan;
                        this.out.(sysLabel).(freqLabel).p2n.avg(:,sv) = avg;
                    end
                end
            end
        end
    end

    methods (Access = 'public')

        function calcSNRmetrics(this)
            % Function to calculate SNR metrics for each system and
            % frequency. Furthermore, each N-dimensional variable is
            % processed according to each year, satellite and azimuth. So,
            % the processing takes place in the day-of-year dimension.

            % Metrics
            for sysLabel = this.out.sys.' % For system
                sysLabel = cell2mat(sysLabel);
                for freqLabel = this.out.(sysLabel).freqs.' % For freq in the system
                    freqLabel = cell2mat(freqLabel);
                    dims = this.out.(sysLabel).dims;

                    this.out.(sysLabel).(freqLabel).h0.values = nan([dims([this.dim_az, this.dim_sv]) length(this.yearList)]);

                    this.out.(sysLabel).(freqLabel).deltaHeightEff.values = nan(dims);
                    this.out.(sysLabel).(freqLabel).deltaHeightEff.azAvg = nan([dims(this.dim_doy), dims(this.dim_az)/2, dims(this.dim_sv)]);
                    this.out.(sysLabel).(freqLabel).deltaHeightEff.avg = nan(dims([this.dim_doy, this.dim_sv]));

                    this.out.(sysLabel).(freqLabel).AlspNorm.values = nan(dims);
                    this.out.(sysLabel).(freqLabel).AlspNorm.azAvg = nan([dims(this.dim_doy), dims(this.dim_az)/2, dims(this.dim_sv)]);
                    this.out.(sysLabel).(freqLabel).AlspNorm.avg = nan(dims([this.dim_doy, this.dim_sv]));

                    this.out.(sysLabel).(freqLabel).phaseZeroed.values = nan(dims);
                    this.out.(sysLabel).(freqLabel).phaseZeroed.azAvg = nan([dims(this.dim_doy), dims(this.dim_az)/2, dims(this.dim_sv)]);
                    this.out.(sysLabel).(freqLabel).phaseZeroed.avg = nan(dims([this.dim_doy, this.dim_sv]));

                    for sv = 1 : dims(this.dim_sv) % For each SV present in the freq. There are 4 arcs per SV.
                        for arc = 1 : dims(this.dim_az) % For each arc
                            % Processing of height: calculate average H0
                            % and Heff per arc.
                            yearList = unique(this.out.(sysLabel).(freqLabel).time.years);
                            year0 = min(yearList);
                            for year = yearList.'
                                doyIndexes = find(this.out.(sysLabel).(freqLabel).time.years == year);
                                yearIdx = year - year0 + 1;
                                % Get peak to noise ratio
                                p2n = this.out.(sysLabel).(freqLabel).p2n.values(doyIndexes,arc,sv);
                                % Calculate h0 over arc
                                h0 = this.out.(sysLabel).(freqLabel).height.values(doyIndexes,arc,sv);
                                
                                plot_debug = false;
                                if plot_debug
                                    figure(300)
                                    clf;
                                    filt_meas = this.out.(sysLabel).(freqLabel).phase.values(doyIndexes,arc,sv);
                                    plot(doyIndexes, filt_meas, 'b.', 'MarkerSize', 8); hold on; grid on;
                                end
                                % 1st Validation based on p2n. To filter
                                % out noisy measurements.
                                filt_doys = p2n >= this.p2n_th;
                                % Filter out doys
                                doyIndexes = doyIndexes(filt_doys);
                                h0 = h0(filt_doys);

                                % 2nd validation, based on daily metric
                                % differences. Idea is that daily
                                % differences shouldn't be too high. For
                                % example, phase was taken. Done to filter
                                % out noisy metric estimations, i.e., where
                                % noise does not necessarily come from low
                                % p2n, but from estimation errors (like
                                % phase estimation errors).
                                filt_meas = this.out.(sysLabel).(freqLabel).phase.values(doyIndexes,arc,sv);
                                if plot_debug
                                    plot(doyIndexes, filt_meas, 'ms', 'MarkerSize', 8)
                                end

                                diffs = diff(filt_meas);
                                mh0 = mean(diffs,'omitnan');
                                sh0 = std(diffs,'omitnan') * this.metric_region_sigma;
                                sigmaplus = mh0 + sh0;
                                sigmaneg = mh0 - sh0;
                                filt_doys = (diffs > sigmaneg) & (diffs < sigmaplus);
                                filt_doys = [false;filt_doys];
                                doyIndexes = doyIndexes(filt_doys);
                                if plot_debug
                                    filt_meas = this.out.(sysLabel).(freqLabel).phase.values(doyIndexes,arc,sv);
                                    plot(doyIndexes, filt_meas, 'kv', 'MarkerSize', 8)
                                    legend('Raw metric','After 1st filt. (p2n)', 'After 2nd filt. (daily diffs)')
                                    title('Metric with and without filtering')
                                    ylabel('Metric')
                                    xlabel('Time (days)')
                                end

                                % Averaged height over days
                                h0 = mean(h0(filt_doys),'omitnan');
                                this.out.(sysLabel).(freqLabel).h0.values(arc,sv,yearIdx) = h0;
                                % Delta height effective
                                this.out.(sysLabel).(freqLabel).deltaHeightEff.values(doyIndexes,arc,sv) = ...
                                    h0 - this.out.(sysLabel).(freqLabel).height.values(doyIndexes,arc,sv);

                                % Processing of amplitude: calculate A_LSP and
                                % A_LSP_20% to normalize.
                                % Get amplitudes, this variable will be ovewritten
                                amplitudes = this.out.(sysLabel).(freqLabel).amplitude.values(doyIndexes,arc,sv);
                                % Calculate non-NAN indexes, and mean of top
                                % 20% of those.
                                idxNoNAN = ~isnan(amplitudes);
                                amplitudes = amplitudes(idxNoNAN);
                                amplitudesTop20 = sort(amplitudes,'descend');
                                topPercIdx = ceil(this.percFactor_AlspNorm / 100 * length(amplitudes));
                                amplitudesTop20 = mean(amplitudesTop20(1 : topPercIdx),'omitnan');
                                % Normalize amplitudes and set values >1 to 1
                                amplitudes = this.out.(sysLabel).(freqLabel).amplitude.values(doyIndexes,arc,sv) / amplitudesTop20;
                                amplitudes(amplitudes > 1) = 1;
                                this.out.(sysLabel).(freqLabel).AlspNorm.values(doyIndexes,arc,sv) = amplitudes;

                                % Processing of phase: zeroing and phase time
                                % difference.
                                phase = this.out.(sysLabel).(freqLabel).phase.values(doyIndexes,arc,sv);
                                for ii = 2 : length(phase)
                                    phase(ii,:) = 0.5*phase(ii,:) + 0.5*phase(ii-1);
                                end
                                % Calculate non-NAN indexes, and mean of lowest
                                % 15% of those.
                                phaseLowest15 = sort(phase,'ascend');
                                lowestPercIdx = ceil(this.percFactor_phaseZeroed / 100 * length(phase));
                                phaseLowest15 = mean(phaseLowest15(1 : lowestPercIdx),'omitnan');

                                % Mean phase of lowest 15% substracted to phase
                                % time series.
                                phaseZeroed = phase - phaseLowest15;
                                this.out.(sysLabel).(freqLabel).phaseZeroed.values(doyIndexes,arc,sv) = phaseZeroed;
                            end
                        end
                        % Calculate average over azimuth sections for each day,
                        % i.e. AlspNorm(:,1:azTotal,sv), where azTotal = number
                        % of azimuth sections, 4 if azRes = 90.
                        % So make a row-wise average and add as a 5th column
                        % (or "azTotal+1"-th column).
                        %for sv = 1 : dims(this.dim_sv)
                        for pairIdx = 1 : size(this.azPairs, 2)
                            arcIdx = this.azPairs(:,pairIdx);
                            avg = mean(this.out.(sysLabel).(freqLabel).deltaHeightEff.values(:,arcIdx,sv),2,'omitnan');
                            avg(find(avg == 0)) = nan;
                            this.out.(sysLabel).(freqLabel).deltaHeightEff.azAvg(:,pairIdx,sv) = avg;

                            avg = mean(this.out.(sysLabel).(freqLabel).AlspNorm.values(:,arcIdx,sv),2,'omitnan');
                            avg(find(avg == 0)) = nan;
                            this.out.(sysLabel).(freqLabel).AlspNorm.azAvg(:,pairIdx,sv) = avg;

                            avg = mean(this.out.(sysLabel).(freqLabel).phaseZeroed.values(:,arcIdx,sv),2,'omitnan');
                            avg(find(avg == 0)) = nan;
                            this.out.(sysLabel).(freqLabel).phaseZeroed.azAvg(:,pairIdx,sv) = avg;
                        end

                        avg = mean(this.out.(sysLabel).(freqLabel).deltaHeightEff.azAvg(:,:,sv),2,'omitnan');
                        avg(find(avg == 0)) = nan;
                        this.out.(sysLabel).(freqLabel).deltaHeightEff.avg(:,sv) = avg;

                        avg = mean(this.out.(sysLabel).(freqLabel).AlspNorm.azAvg(:,:,sv),2,'omitnan');
                        avg(find(avg == 0)) = nan;
                        this.out.(sysLabel).(freqLabel).AlspNorm.avg(:,sv) = avg;

                        avg = mean(this.out.(sysLabel).(freqLabel).phaseZeroed.azAvg(:,:,sv),2,'omitnan');
                        avg(find(avg == 0)) = nan;
                        this.out.(sysLabel).(freqLabel).phaseZeroed.avg(:,sv) = avg;
                        %end
                    end
                end
            end
        end

        function concat(this, tracks)
            try
                isnew = isempty(this.out);
            catch
                isnew = true;
            end
            if isnew
                this.out = tracks.out;
            else
                % Check systems
                for sys_label = tracks.out.sys
                    % Check if system exists
                    try
                        isnew = isempty(this.out) || isempty(intersect(fieldnames(this.out), {'sys'})) || isempty(intersect(this.out.sys, sys_label));
                    catch
                        isnew = true;
                    end
                    % Convert cell2string
                    sys_label = cell2mat(sys_label);
                    sys = tracks.out.(sys_label);
                    % Add if doesn't exist
                    if isnew
                        this.out.sys(end+1) = {sys_label};
                        this.out.(sys_label) = sys;
                    else
                        % Increase dimension in time
                        this.out.(sys_label).dims(1) = this.out.(sys_label).dims(1) + 1;

                        % Check freqs
                        for freq_label = sys.freqs.'
                            % Check if freq exists
                            try
                                isnew = isempty(this.out.(sys_label)) || isempty(intersect(fieldnames(this.out.(sys_label)), {'freqs'})) || isempty(intersect(this.out.(sys_label).freqs, freq_label));
                            catch
                                isnew = true;
                            end
                            % Convert cell2string
                            freq_label = cell2mat(freq_label);
                            band = sys.(freq_label);
                            % Add if doesn't exist
                            if isnew
                                this.out.(sys_label).freqs(end+1) = {freq_label};
                                this.out.(sys_label) = sys;
                            else
                                for fname_ext = setdiff(fieldnames(band), [{'wl'}, {'h0'}]).'
                                    fname_ext = cell2mat(fname_ext);
                                    for fname_int = fieldnames(band.(fname_ext)).'
                                        fname_int = cell2mat(fname_int);
                                        this.out.(sys_label).(freq_label).(fname_ext).(fname_int) = ...
                                            [this.out.(sys_label).(freq_label).(fname_ext).(fname_int); ...
                                            band.(fname_ext).(fname_int)];
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        function weightedMeans(this)
            % Weighted average for metrics. At the moment, only for
            % phaseZeroed and AlspNorm.
            % This can be applied on every track individually during
            % processing, instead of calling at the end in post-processing.
            % The function was created after results were obtained, this is
            % why it is callable in post-processing.
            %
            % The idea behind is that individual SV phases can be noisy
            % (at this point, it makes sense to use the terms phase and
            % phaseZeroed interchangeably). Therefore, to have a better
            % estimation, one could take all SVs phases for each arc and
            % calculate the daily mean (i.e. mean along all SVs for that
            % day at that arc).
            % However, if there are outliers, like a bad phase estimation
            % despite a high p2n value in calcSNRmetrics(), the overall
            % mean will be affected. Thus, the idea is to downweight for
            % every day and for every arc, the measurements of those SVs
            % which are "far" from the mean.
            % Example: if phase of all SVs except one is around 30 degrees,
            % then that one SVs will be downweighted to not affect the
            % mean too much, but its value is still considered valid since
            % it has a high p2n, otherwise it would have been filtered out
            % by calcMetrics() function above.
            %
            % The weights are exp(1 - w), with w being a function of

            for sysLabel = this.out.sys.' % For system
                sysLabel = cell2mat(sysLabel);
                for freqLabel = this.out.(sysLabel).freqs.' % For freq in the system
                    freqLabel = cell2mat(freqLabel);
                    dims = this.out.(sysLabel).dims;

                    % Variables
                    arc_phases_weighted_mean = nan(dims(this.dim_doy),dims(2));
                    arc_alsp_weighted_mean = nan(dims(this.dim_doy),dims(2));
                    for arc = 1 : dims(this.dim_az)
                        % Phases
                        arc_phases = reshape(this.out.(sysLabel).(freqLabel).phaseZeroed.values(:,arc,:), dims(this.dim_doy), dims(this.dim_sv));
                        weights = this.do_weight_function(arc_phases, freqLabel);
                        weights = weights ./ sum(weights,2,'omitnan');
                        arc_phases_weighted_mean(:,arc) = zero2nan(sum(nan2zero(weights) .* nan2zero(arc_phases),2));

                        % AlspNorm
                        arc_AlspNorm = reshape(this.out.(sysLabel).(freqLabel).AlspNorm.values(:,arc,:), dims(this.dim_doy), dims(this.dim_sv));
                        weights = this.do_weight_function(arc_AlspNorm, freqLabel);
                        weights = weights ./ sum(weights,2,'omitnan');
                        arc_alsp_weighted_mean(:,arc) = zero2nan(sum(nan2zero(weights) .* nan2zero(arc_AlspNorm),2));
                    end
                    this.out.(sysLabel).(freqLabel).phaseZeroed.azAvgW = arc_phases_weighted_mean;
                    this.out.(sysLabel).(freqLabel).AlspNorm.azAvgW = arc_alsp_weighted_mean;
                end
            end
        end

        function wf = do_weight_function(this, metric, freqLabel)
            metric_median = median(metric,2,'omitnan');
            z_sq = (metric - metric_median).^2;
            sigma_sq = 0.5 * metric_median.^2;
            w = z_sq ./ sigma_sq;
            wf = exp(-w);

            plot_debug = false;
            if plot_debug
                ix = 100;

                figure(300);
                clf;
                plot(metric(ix,:),'bo','MarkerFaceColor','b');
                hold on; grid on;
                plot([1 32], metric_median(ix)*[1 1], 'k--','linewidth', 1)
                bound_up = metric_median(ix) + sqrt(sigma_sq(ix));
                plot([1 32], bound_up*[1 1],'k-.','MarkerFaceColor','r')
                bound_down = metric_median(ix) - sqrt(sigma_sq(ix));
                plot([1 32], bound_down*[1 1],'k-.','MarkerFaceColor','r','HandleVisibility','off')
                yyaxis right
                plot(wf(ix,:),'ro','MarkerFaceColor','r')
                legend('metric y','$X$','$X \pm \sigma$','wf','interpreter','LaTex')
                title([sprintf('%s, day %d - Weighting Function: ', freqLabel, ix), '$wf = e^{({z^2}/{\sigma^2})}, z = (y - X(y))^2, \sigma^2 = 0.5 * X(y)$'],...
                    'interpreter','LaTex','fontsize',15)
                xlabel('SV number')
                yyaxis left
                ylabel('$y$','interpreter','LaTex','fontsize',15)
                set(gca, 'YColor','b')
                yyaxis right
                ylabel('$wf$','interpreter','LaTex','fontsize',15)
                set(gca, 'YColor','r')
            end
        end
    end
end

