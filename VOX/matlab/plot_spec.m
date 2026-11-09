% plot spectrogramm of signal
set(0,'CurrentFigure',Hndl.figureNumber)
set(Hndl.mainaxes1,'vis','off');
cla;
set(Hndl.mainaxes2,'vis','off');
cla;
axes(Hndl.mainaxes0);
% spectrogram replaces specgram (not recommended); same window (hanning),
% overlap, dB scaling and image as specgram's own plot. specgram
% zero-padded signals shorter than the window, spectrogram does not.
nwin = 1024;
yspec = data.y(:);
if numel(yspec) < nwin
   yspec(nwin) = 0;
end
[Sspec, Fspec, Tspec] = spectrogram(yspec, hanning(nwin), nwin/2, nwin, data.Fs);
if isscalar(Tspec)
   Tspec = [0 1/Fspec(2)];   % as specgram for a single column
end
imagesc(Tspec, Fspec, 20*log10(abs(Sspec)+eps)); axis xy; colormap(jet)
xlabel('Time [s]');
ylabel('Frequency [Hz]');
axis([-inf inf -inf FMAX]);