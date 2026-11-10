% plot upper signal in db
if ~isfield(data, 'z')   % signals without impedance (loaded *.mat, *.wav, ...): show y
   data.z = data.y;
end
set(0,'CurrentFigure',Hndl.figureNumber)
set(Hndl.mainaxes0,'vis','off');
cla;
axes(Hndl.mainaxes2);
if TRACTDISP == 1 | TRACTDISP == 2       % FRF
   H_calc=make_fft_vox(data.y, 1024);     % y =  vocal tract response
elseif TRACTDISP == 3 | TRACTDISP == 4   % Impedance
   H_calc=make_fft_vox(data.z, 1024);     % z = impedance of the glottis
end
lines=length(H_calc)*2;
df=data.Fs/lines;
f_calc=0:data.Fs/lines:(lines/2-1)*df;
if BG load('background');
   if TRACTDISP == 1 | TRACTDISP == 2
      bg.y=bg.y/max(abs(bg.y))*max(abs(data.y));
      H_calc_bg=make_fft(bg.y,lines);
   elseif TRACTDISP == 3 | TRACTDISP == 4
      bg.z=bg.z/max(abs(bg.z))*max(abs(data.z));
      H_calc_bg=make_fft(bg.z,lines);
   end
   lines=length(H_calc_bg)*2;
   df_bg=bg.Fs/lines;
   f_calc_bg=0:bg.Fs/lines:(lines/2-1)*df_bg;
   plot(f_calc_bg,H_calc_bg,bgstyle,f_calc,H_calc,fgstyle);
   if get(Hndl.INPUT,'value')==2;
      voxaxis([0 FMAX max(max(H_calc),max(H_calc_bg))-58 max(max(H_calc), ...
         max(H_calc_bg))+2]); % tract signal
   else
      voxaxis([0 FMAX max(max(H_calc),max(H_calc_bg))-88 max(max(H_calc), ...
         max(H_calc_bg))+2]); % other signal
   end;
else
   plot(f_calc,H_calc,fgstyle);
   if get(Hndl.INPUT,'value')==2;
      voxaxis([0 FMAX max(H_calc)-58 max(H_calc)+2]); % tract signal
   else
      voxaxis([0 FMAX max(H_calc)-88 max(H_calc)+2]); % other signal
   end;
end;
xlabel('Frequency [Hz]');
grid on;ylabel('Level [dB]');
axes(Hndl.mainaxes1);
if TRACTDISP == 1
   warning off
   if BG
      plot(bg.t,10*log10((bg.y/max(abs(bg.y))*max(abs(data.y))).^2), ...
         bgstyle,data.t,10*log10(data.y.^2),fgstyle);
   else
      plot(data.t,10*log10(data.y.^2),fgstyle);
   end;
   warning on
   voxaxis([0 max(data.t)*1.001 max(10*log10(data.y.^2))-65 max(10*log10(data.y.^2))+5]);
else
   if BG
      plot(bg.t,10*log10((bg.z/max(abs(bg.z))*max(abs(data.z))).^2), ...
         bgstyle,data.t,10*log10(data.z.^2),fgstyle);
   else
      plot(data.t,10*log10(data.z.^2),fgstyle);
   end;
   voxaxis([0 max(data.t)*1.001 max(10*log10(data.z.^2))-65 max(10*log10(data.z.^2))+5]);
end
xlabel('Time [s]');
grid on;
ylabel('Sound pressure level [dB]');
voxcolor([Hndl.mainaxes1 Hndl.mainaxes2]);   % black fgstyle lines follow the theme
