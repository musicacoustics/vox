function setenable(CALC)
% set gui depending on the state of CALC

global Hndl

if CALC == 0
   set(Hndl.menu(4),           'Enable', 'on')   % foldsig
   set(Hndl.menu(5),           'Enable', 'on')   % tractsig
   set(Hndl.Duration,          'Enable', 'on')
   set(Hndl.DurationStr,       'Enable', 'on')
   set(Hndl.Fs,                'Enable', 'on')
   set(Hndl.FsStr,             'Enable', 'on')
   set(Hndl.FoldLoad,          'Enable', 'on')
   set(Hndl.FoldCalc,          'Enable', 'on')
   set(Hndl.VOWEL,             'Enable', 'on')
   set(Hndl.TractCalcMode,     'Enable', 'on')
   set(Hndl.TractLoad,         'Enable', 'on')
   set(Hndl.TractCalc,         'Enable', 'on')
   set(Hndl.INPUT,             'Enable', 'on')
   set(Hndl.play,              'Enable', 'on')
   set(Hndl.record,            'Enable', 'on')
   set(Hndl.combi,             'Enable', 'on')
   set(Hndl.batch,             'Enable', 'on')
   if voxfigflag('Vocal fold parameters',1) == 1
      set(Hndl.MAXM,           'Enable', 'on')
      set(Hndl.MAXMstr,        'Enable', 'on')
   end
else
   set(Hndl.menu(4),           'Enable', 'off')   % foldsig
   set(Hndl.menu(5),           'Enable', 'off')   % tractsig
   set(Hndl.Duration,          'Enable', 'off')
   set(Hndl.DurationStr,       'Enable', 'off')
   set(Hndl.Fs,                'Enable', 'off')
   set(Hndl.FsStr,             'Enable', 'off')
   set(Hndl.FoldLoad,          'Enable', 'off')
   set(Hndl.FoldCalc,          'Enable', 'off')
   set(Hndl.VOWEL,             'Enable', 'off')
   set(Hndl.TractCalcMode,     'Enable', 'off')
   set(Hndl.TractLoad,         'Enable', 'off')
   set(Hndl.TractCalc,         'Enable', 'off')
   set(Hndl.INPUT,             'Enable', 'off')
   set(Hndl.play,              'Enable', 'off')
   set(Hndl.record,            'Enable', 'off')
   set(Hndl.combi,             'Enable', 'off')
   set(Hndl.batch,             'Enable', 'off')
   if voxfigflag('Vocal fold parameters',1) == 1
      set(Hndl.MAXM,           'Enable', 'off')
      set(Hndl.MAXMstr,        'Enable', 'off')
   end
end