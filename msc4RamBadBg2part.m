function [Subset_prep,emsc_mod, Parameters] = msc4RamBadBg2part(Xsaisir,xbg, xbg_optics, xbg_air)
%MSC4RAMBADBG2PART  Extended MSC preprocessing with explicit background constituents.
%
%   This function performs an enhanced Multiplicative Scatter Correction (MSC)
%   tailored for Raman spectroscopy data where instrument‑related background
%   signals must be treated as interfering spectral components. The method
%   simultaneously corrects for baseline variations, multiplicative effects,
%   and contributions from two types of background spectra (optical components
%   and air/oxygen), which are included as separate "bad" constituent spectra
%   in the EMSC model.
%
%   The approach stabilizes the preprocessing by:
%     • Defining a background‑reduced reference spectrum obtained from
%       high‑quality measurements under optimal conditions.
%     • Incorporating instrument background spectra (optics and air) as
%       additional EMSC constituents to be fitted and subtracted.
%     • Allowing polynomial baseline modelling (up to 6th order) through the
%       EMSC framework.
%
%   INPUTS
%     Xsaisir       – Saisir‑format dataset containing sample Raman spectra.
%     xbg           – Background spectrum representing instrument background
%                     (used for constructing the reference spectrum).
%     xbg_optics    – Background spectrum from optical components to be added
%                     as a "bad" constituent in the EMSC model.
%     xbg_air       – Background spectrum representing air/oxygen contributions
%                     to be added as a second "bad" constituent.
%
%   OUTPUTS
%     Subset_prep   – Preprocessed spectra after EMSC correction.
%     emsc_mod      – EMSC model structure containing reference spectrum,
%                     polynomial terms, and added background constituents.
%     Parameters     – Fitted EMSC parameters for each spectrum.
%
%   METHOD OVERVIEW
%     1. A representative sample spectrum measured under optimal conditions
%        (e.g., high laser power, long working distance) is selected and
%        averaged.
%     2. The instrument background spectrum is scaled and subtracted to form a
%        background‑reduced reference spectrum.
%     3. An EMSC model (with polynomial baseline terms) is generated and the
%        reference spectrum is replaced with the corrected average spectrum.
%     4. Optical and air background spectra are added as interfering
%        constituents to be fitted and removed during EMSC.
%     5. EMSC is applied to all spectra, yielding corrected spectra and model
%        parameters.
%
%   This preprocessing strategy is particularly useful for Raman systems where
%   background signals from optics, sapphire windows, or oxygen fluorescence
%   vary between measurements and must be explicitly modelled to avoid bias in
%   subsequent chemometric analysis.
%
% -------------------------------------------------------------------------

% Define a sample spectrum without background signals as reference, to 
% increase orthogonality of the constituent spectra.
XsaisirOptimal = select_from_identifier(Xsaisir,5,'450mW_10cm'); % Use spectra at optimal measurement condition as reference spectrum
XsaisirOptimalAvg = average_from_identifier(XsaisirOptimal,5:14);
XsaisirSampleRef = XsaisirOptimalAvg;
XsaisirSampleRef.d = XsaisirOptimalAvg.d - xbg.d.*0.9; % Remove optical and air background spectrum.The scaling of the backround spectrum is adjusted to avoid unphysical effects. The match was imperfect.

emsc_mod = make_emsc_modfunc(Xsaisir, 3); % Option 3: Simple multiplicatice and linear effect correction
emsc_mod.Model(:,2) = XsaisirSampleRef.d'; % Update ref spec, with background-corrected average spec at optimal measurement conditions (10 cm, 450 mW)

% Add background spectrum as "bad" constituent spectra
[emsc_mod]= add_spec_to_EMSCmod(emsc_mod,xbg_optics,2);
[emsc_mod]= add_spec_to_EMSCmod(emsc_mod,xbg_air,2);

[Subset_prep,~,Parameters] = cal_emsc(Xsaisir, emsc_mod); % Calculate EMSC parameters and correct spectra



end
