function filtert = filtern(Signal, fmin, fmax, Q, Fs, type)
%FILTERN Butterworth filter of a signal.
%   FILTERT = FILTERN(SIGNAL, FMIN, FMAX, Q, FS, TYPE) filters SIGNAL
%   (sample rate FS) with a Butterworth filter of order Q, applied with
%   filter. TYPE is 'low' (cut-off FMIN), 'high' (cut-off FMAX) or
%   'band' (FMIN to FMAX). Frequencies in Hz.
%
%   controlfile uses it to smooth the batch control curves. VOX called it
%   from an external tool folder, so it was missing in the repository.
%
%   See also butter, filter.

switch type
    case 'band'
        Wn = [fmin fmax]/(Fs/2);
        [b, a] = butter(Q, Wn);
    case 'high'
        Wn = fmax/(Fs/2);
        [b, a] = butter(Q, Wn, 'high');
    case 'low'
        Wn = fmin/(Fs/2);
        [b, a] = butter(Q, Wn);
    otherwise
        error('filtern: unknown filter type "%s"', type);
end
filtert = filter(b, a, Signal);
end
