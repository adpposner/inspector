%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_DataWinUpdate(src,event,dataSpec1,dataSpec2)
%% 
%%  'Data' window update
%%
%%  02-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm fmfig pars flag data proc

FCTNAME = 'SP2_Data_DataWinUpdate';


%--- switch back to SPEC window ---
set(0,'CurrentFigure',fmfig)

%--- init processing format ---
if flag.dataExpType==1 || flag.dataExpType==4   % single/stability: single spectrum
    proc.procFormat = 1;        % 1 spectrum
else                                            % double/editing: 2 spectra
    proc.procFormat = 2;        % 2 spectrum
end

%--- data format ---
% switch flag.dataManu
%     case 1
%         fprintf('Data format: Varian\n');
%     case 2
%         fprintf('Data format: Bruker\n');
%     case 3
%         fprintf('Data format: General Electric\n');
%     case 4
%         fprintf('Data format: Siemens\n');
%     case 5
%         fprintf('Data format: DICOM\n');
% end

% %--- data selection for combined JDE experiment ---
% if flag.dataExpType==3          % editing
%     set(fm.data.editOne,'Enable','on')
%     set(fm.data.editTwo,'Enable','on')
% else
%     set(fm.data.editOne,'Enable','off')
%     set(fm.data.editTwo,'Enable','off')
% end


SP2_Data_ExpTypePars2Display
set(fm.data.expType,'Value',data.expTypeDisplay)


%--- convdta visibility ---
% if isfield(flag,'dataManu')
%     if flag.dataManu            % Varian
%         set(fm.data.convdta,'Enable','off')
%     else                        % Bruker
%         set(fm.data.convdta,'Enable','on')
%     end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    I N F O    P R I N T O U T :    S P E C T R U M   1              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(data,'spec1')
    if isfield(data.spec1,'fid')
        %--- additional acquisition parameters: RF 1 / excitation ---
        if isfield(fm.data,'infoSpec1RF1')
            delete(fm.data.infoSpec1RF1)
            fm.data = rmfield(fm.data,'infoSpec1RF1');
        end
        if iscell(dataSpec1.rf1.power)
            fm.data.infoSpec1RF1 = text('Position',[-0.13, 0.760],'String',sprintf('RF1: %s / %.1f ms / %.0f dB / %.0f Hz',...
                                   SP2_PrVersionUscore(dataSpec1.rf1.shape),dataSpec1.rf1.dur,dataSpec1.rf1.power{1},...
                                   dataSpec1.rf1.offset),'FontSize',pars.displFontSize);
        else
            fm.data.infoSpec1RF1 = text('Position',[-0.13, 0.760],'String',sprintf('RF1: %s / %.1f ms / %.0f dB / %.0f Hz',...
                                   SP2_PrVersionUscore(dataSpec1.rf1.shape),dataSpec1.rf1.dur,dataSpec1.rf1.power,...
                                   dataSpec1.rf1.offset),'FontSize',pars.displFontSize);
        end
        
        %--- additional acquisition parameters: RF 2 / refocusing ---
        if isfield(fm.data,'infoSpec1RF2')
            delete(fm.data.infoSpec1RF2)
            fm.data = rmfield(fm.data,'infoSpec1RF2');
        end
        if ~any(strfind(dataSpec1.sequence,'spuls'))    % spulse
            fm.data.infoSpec1RF2 = text('Position',[-0.13, 0.725],'String',sprintf('RF2: %s / %.1f ms / %.0f dB / %.0f Hz',...
                                   SP2_PrVersionUscore(dataSpec1.rf2.shape),dataSpec1.rf2.dur,dataSpec1.rf2.power,...
                                   dataSpec1.rf2.offset),'FontSize',pars.displFontSize);
        end
        
        %--- additional acquisition parameters: water suppression ---
        if isfield(fm.data,'infoSpec1WS')
            delete(fm.data.infoSpec1WS)
            fm.data = rmfield(fm.data,'infoSpec1WS');
        end
        if ~any(strfind(dataSpec1.sequence,'spuls'))    % spulse
            if iscell(dataSpec1.ws.power)
                fm.data.infoSpec1WS = text('Position',[-0.13, 0.690],'String',sprintf('WS:  %s / %.1f ms / array dB / %.0f Hz',...
                                      SP2_PrVersionUscore(dataSpec1.ws.shape),dataSpec1.ws.dur,...
                                      dataSpec1.ws.offset),'FontSize',pars.displFontSize);
            else
                fm.data.infoSpec1WS = text('Position',[-0.13, 0.690],'String',sprintf('WS:  %s / %.1f ms / %.0f dB / %.0f Hz',...
                                      SP2_PrVersionUscore(dataSpec1.ws.shape),dataSpec1.ws.dur,dataSpec1.ws.power,...
                                      dataSpec1.ws.offset),'FontSize',pars.displFontSize);
            end
            if strcmp(dataSpec1.ws.applied,'y')
                set(fm.data.infoSpec1WS,'Color',pars.fgTextColor)
            else
                set(fm.data.infoSpec1WS,'Color',pars.bgTextColor)
            end
        end
        
        %--- additional acquisition parameters: JDE, inversion ---
        if isfield(fm.data,'infoSpec1JDE')
            delete(fm.data.infoSpec1JDE)
            fm.data = rmfield(fm.data,'infoSpec1JDE');
        end
        if isfield(fm.data,'infoSpec1Inv')
            delete(fm.data.infoSpec1Inv)
            fm.data = rmfield(fm.data,'infoSpec1Inv');
        end
        if any(strfind(dataSpec1.sequence,'STEAM'))    % STEAM
            if isfield(data.spec1,'inv')
                if iscell(dataSpec1.inv.ti)
                    fm.data.infoSpec1Inv = text('Position',[-0.13, 0.655],'String',sprintf('Inv: %s / %.1f ms / %.0f dB / %.0f Hz / array',...
                                           SP2_PrVersionUscore(dataSpec1.inv.shape),dataSpec1.inv.dur,dataSpec1.inv.power,...
                                           dataSpec1.inv.offset),'FontSize',pars.displFontSize);
                elseif iscell(dataSpec1.inv.offset)
                    fm.data.infoSpec1Inv = text('Position',[-0.13, 0.655],'String',sprintf('Inv: %s / %.1f ms / %.0f dB / array / %.3f s',...
                                           SP2_PrVersionUscore(dataSpec1.inv.shape),dataSpec1.inv.dur,dataSpec1.inv.power,...
                                           dataSpec1.inv.ti),'FontSize',pars.displFontSize);
                else
                    fm.data.infoSpec1Inv = text('Position',[-0.13, 0.655],'String',sprintf('Inv: %s / %.1f ms / %.0f dB / %.0f Hz / %.3f s',...
                                           SP2_PrVersionUscore(dataSpec1.inv.shape),dataSpec1.inv.dur,dataSpec1.inv.power,...
                                           dataSpec1.inv.offset,dataSpec1.inv.ti),'FontSize',pars.displFontSize);
                end
                if strcmp(dataSpec1.inv.applied,'y')
                    set(fm.data.infoSpec1Inv,'Color',pars.fgTextColor)
                else
                    set(fm.data.infoSpec1Inv,'Color',pars.bgTextColor)
                end
            end
        elseif any(strfind(dataSpec1.sequence,'JDE'))  % JDE
            if iscell(dataSpec1.jde.offset)            % JDE
                if iscell(dataSpec1.jde.shape)
                    if strcmp(dataSpec1.jde.shape{1},dataSpec1.jde.shape{2})
                        fm.data.infoSpec1JDE = text('Position',[-0.13, 0.655],'String',sprintf('JDE: %s / %.1f ms / %.0f dB / %.0f/%.0f Hz',...
                                               SP2_PrVersionUscore(dataSpec1.jde.shape{1}),dataSpec1.jde.dur,dataSpec1.jde.power,...
                                               dataSpec1.jde.offset1,dataSpec1.jde.offset2),'FontSize',pars.displFontSize);
                    else                        
                        fm.data.infoSpec1JDE = text('Position',[-0.13, 0.655],'String',sprintf('JDE: shape array / %.1f ms / %.0f dB / %.0f/%.0f Hz',...
                                               dataSpec1.jde.dur,dataSpec1.jde.power,...
                                               dataSpec1.jde.offset1,dataSpec1.jde.offset2),'FontSize',pars.displFontSize);
                        fprintf('JDE RF shape array: %s / %s\n',dataSpec1.jde.shape{1},dataSpec1.jde.shape{2});
                    end
                else
                    fm.data.infoSpec1JDE = text('Position',[-0.13, 0.655],'String',sprintf('JDE: %s / %.1f ms / %.0f dB / %.0f/%.0f Hz',...
                                           SP2_PrVersionUscore(dataSpec1.jde.shape),dataSpec1.jde.dur,dataSpec1.jde.power,...
                                           dataSpec1.jde.offset1,dataSpec1.jde.offset2),'FontSize',pars.displFontSize);
                end
            elseif iscell(dataSpec1.jde.power)         % JDE efficiency (power array)
                fm.data.infoSpec1JDE = text('Position',[-0.13, 0.655],'String',sprintf('JDE: %s / %.1f ms / array / %.0f Hz',...
                                       SP2_PrVersionUscore(dataSpec1.jde.shape),dataSpec1.jde.dur,...
                                       dataSpec1.jde.offset),'FontSize',pars.displFontSize);
                fprintf('Data 1: Power array: %s dB\n',SP2_Vec2PrintStr(cell2mat(dataSpec1.jde.power)))                   

            else                                    % single experiment
                fm.data.infoSpec1JDE = text('Position',[-0.13, 0.655],'String',sprintf('JDE: %s / %.1f ms / %.0f dB / %.0f Hz',...
                                       SP2_PrVersionUscore(dataSpec1.jde.shape),dataSpec1.jde.dur,dataSpec1.jde.power,...
                                       dataSpec1.jde.offset),'FontSize',pars.displFontSize);
            end
            if strcmp(dataSpec1.jde.applied,'y')
                set(fm.data.infoSpec1JDE,'Color',pars.fgTextColor)
            else
                set(fm.data.infoSpec1JDE,'Color',pars.bgTextColor)
            end
        end
        
        %--- additional acquisition parameters: OVS ---
        if isfield(fm.data,'infoSpec1OVS')
            delete(fm.data.infoSpec1OVS)
            fm.data = rmfield(fm.data,'infoSpec1OVS');
        end
        if ~any(strfind(dataSpec1.sequence,'spuls'))    % spulse
            fm.data.infoSpec1OVS = text('Position',[-0.13, 0.620],'String',sprintf('OVS: %s / %.1f ms / %.0f dB / %.0f Hz',...
                                   SP2_PrVersionUscore(dataSpec1.ovs.shape),dataSpec1.ovs.dur,dataSpec1.ovs.power,...
                                   dataSpec1.ovs.offset),'FontSize',pars.displFontSize);
            if strcmp(dataSpec1.ovs.applied,'y')
                set(fm.data.infoSpec1OVS,'Color',pars.fgTextColor)
            else
                set(fm.data.infoSpec1OVS,'Color',pars.bgTextColor)
            end        
        end
        
        %--- additional acquisition parameters: data dimensions ---
        if isfield(fm.data,'infoSpec1DatDim')
            delete(fm.data.infoSpec1DatDim)
            fm.data = rmfield(fm.data,'infoSpec1DatDim');
        end
        if any(strfind(dataSpec1.sequence,'JDE'))  % JDE
            if isempty(dataSpec1.seqtype)
                fm.data.infoSpec1DatDim = text('Position',[-0.13, 0.585],'String',...
                                          sprintf('%s, spec %.0f, na %.0f, nr %.0f',...
                                          SP2_PrVersionUscore(dataSpec1.sequence),dataSpec1.nspecC,...
                                          dataSpec1.na,dataSpec1.nr),'FontSize',pars.displFontSize);
            else
                fm.data.infoSpec1DatDim = text('Position',[-0.13, 0.585],'String',...
                                          sprintf('%s (%s), spec %.0f, na %.0f, nr %.0f',...
                                          SP2_PrVersionUscore(dataSpec1.sequence),dataSpec1.seqtype,dataSpec1.nspecC,...
                                          dataSpec1.na,dataSpec1.nr),'FontSize',pars.displFontSize);
            end
        else                % any other case
            fm.data.infoSpec1DatDim = text('Position',[-0.13, 0.585],'String',...
                                      sprintf('%s, spec %.0f, nx %.0f, ny %.0f, na %.0f, nr %.0f',...
                                      SP2_PrVersionUscore(dataSpec1.sequence), dataSpec1.nspecC,dataSpec1.nx,...
                                      dataSpec1.ny,dataSpec1.na(1),dataSpec1.nr),'FontSize',pars.displFontSize);
        end
        if isfield(fm.data,'infoSpec1AcqPars')
            delete(fm.data.infoSpec1AcqPars)
            fm.data = rmfield(fm.data,'infoSpec1AcqPars');
        end
        if any(findstr(dataSpec1.sequence,'STEAM')) || any(findstr(dataSpec1.sequence,'svs_st'))        % STEAM MRS
            if length(dataSpec1.te)>1      % array
                fm.data.infoSpec1AcqPars = text('Position',[-0.13, 0.550],'String',sprintf('sw %.1f kHz, sf %.1f MHz, TE array, TM %.1f ms',...
                                           dataSpec1.sw_h/1000,dataSpec1.sf,dataSpec1.tm),'FontSize',pars.displFontSize);
                % fprintf('TE array: %sms\n',SP2_Vec2PrintStr(dataSpec1.te));
            else
                fm.data.infoSpec1AcqPars = text('Position',[-0.13, 0.550],'String',sprintf('sw %.1f kHz, sf %.1f MHz, TE %.1f ms, TM %.1f ms',...
                                           dataSpec1.sw_h/1000,dataSpec1.sf,dataSpec1.te,dataSpec1.tm),'FontSize',pars.displFontSize);
            end
        else                                                % all other sequences (e.g. PRESS)
            fm.data.infoSpec1AcqPars = text('Position',[-0.13, 0.550],'String',sprintf('sw %.1f kHz, sf %.1f MHz, TE %.1f ms',...
                                       dataSpec1.sw_h/1000,dataSpec1.sf,dataSpec1.te),'FontSize',pars.displFontSize);
        end
        
        if isfield(fm.data,'infoSpec1Rcvrs')
            delete(fm.data.infoSpec1Rcvrs)
            fm.data = rmfield(fm.data,'infoSpec1Rcvrs');
        end
        if isfield(data.spec1,'nRcvrs')
            if dataSpec1.nRcvrs>1
                fm.data.infoSpec1Rcvrs = text('Position',[-0.13, 0.515],'String',...
                                         sprintf('TR %.0f ms, tof %.0f Hz, %.0f rcvrs, gain %.0f',...
                                         dataSpec1.tr,dataSpec1.offset,dataSpec1.nRcvrs,dataSpec1.gain),...
                                         'FontSize',pars.displFontSize);
            else
                fm.data.infoSpec1Rcvrs = text('Position',[-0.13, 0.515],'String',...
                                         sprintf('TR %.0f ms, tof %.0f Hz, 1 rcvr, gain %.0f',...
                                         dataSpec1.tr,dataSpec1.offset,dataSpec1.gain),'FontSize',pars.displFontSize);
            end
        end

        %--- additional acquisition parameters: voxel size and position ---
        if isfield(fm.data,'infoSpec1VoxGeo')
            delete(fm.data.infoSpec1VoxGeo)
            fm.data = rmfield(fm.data,'infoSpec1VoxGeo');
        end
        fm.data.infoSpec1VoxGeo = text('Position',[-0.13, 0.480],'String',...
                                  sprintf('vox %s mm, pos %s mm',SP2_Vec2PrintStr(dataSpec1.vox),...
                                  SP2_Vec2PrintStr(dataSpec1.pos)),'FontSize',pars.displFontSize);
                              
        %--- additional acquisition parameters: shims ---
        if isfield(fm.data,'infoSpec1ShimZeroAnd1st')
            delete(fm.data.infoSpec1ShimZeroAnd1st)
            fm.data = rmfield(fm.data,'infoSpec1ShimZeroAnd1st');
        end
        fm.data.infoSpec1ShimZeroAnd1st = text('Position',[-0.13, 0.445],'String',sprintf('0: %.0f, 1st: %.0f, %.0f, %.0f',...
                                   dataSpec1.z0,dataSpec1.x1,dataSpec1.z1c,dataSpec1.y1),'FontSize',pars.displFontSize);

        if isfield(fm.data,'infoSpec1Shim2nd')
            delete(fm.data.infoSpec1Shim2nd)
            fm.data = rmfield(fm.data,'infoSpec1Shim2nd');
        end
        fm.data.infoSpec1Shim2nd = text('Position',[-0.13, 0.410],'String',sprintf('2nd: %.0f, %.0f, %.0f, %.0f, %.0f',...
                                   dataSpec1.x2y2,dataSpec1.xz,dataSpec1.z2c,dataSpec1.yz,dataSpec1.xy),'FontSize',pars.displFontSize);

        if isfield(fm.data,'infoSpec1Shim3rd')
            delete(fm.data.infoSpec1Shim3rd)
            fm.data = rmfield(fm.data,'infoSpec1Shim3rd');
        end
        fm.data.infoSpec1Shim3rd = text('Position',[-0.13, 0.375],'String',sprintf('3rd: %.0f, %.0f, %.0f, %.0f, %.0f, %.0f, %.0f',...
                                   dataSpec1.x3,dataSpec1.zx2y2,dataSpec1.xz2,dataSpec1.z3c,dataSpec1.yz2,dataSpec1.zxy,...
                                   dataSpec1.y3),'FontSize',pars.displFontSize);
    end
end
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    I N F O    P R I N T O U T :    S P E C T R U M   2              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(data,'spec2')
    if isfield(data.spec2,'fid') && isfield(data.spec2,'ovs')
        %--- additional acquisition parameters: RF 1 / excitation ---
        if isfield(fm.data,'infoSpec2RF1')
            delete(fm.data.infoSpec2RF1)
            fm.data = rmfield(fm.data,'infoSpec2RF1');
        end
        fm.data.infoSpec2RF1 = text('Position',[0.51,  0.760],'String',sprintf('RF1: %s / %.1f ms / %.0f dB / %.0f Hz',...
                               SP2_PrVersionUscore(dataSpec2.rf1.shape),dataSpec2.rf1.dur,dataSpec2.rf1.power,...
                               dataSpec2.rf1.offset),'FontSize',pars.displFontSize);

        %--- additional acquisition parameters: RF 2 / refocusing ---
        if isfield(fm.data,'infoSpec2RF2')
            delete(fm.data.infoSpec2RF2)
            fm.data = rmfield(fm.data,'infoSpec2RF2');
        end
        if ~any(strfind(dataSpec2.sequence,'spuls'))    % spulse
            fm.data.infoSpec2RF2 = text('Position',[0.51,  0.725],'String',sprintf('RF2: %s / %.1f ms / %.0f dB / %.0f Hz',...
                                   SP2_PrVersionUscore(dataSpec2.rf2.shape),dataSpec2.rf2.dur,dataSpec2.rf2.power,...
                                   dataSpec2.rf2.offset),'FontSize',pars.displFontSize);
        end
        
        %--- additional acquisition parameters: water suppression ---
        if isfield(fm.data,'infoSpec2WS')
            delete(fm.data.infoSpec2WS)
            fm.data = rmfield(fm.data,'infoSpec2WS');
        end
        if ~any(strfind(dataSpec2.sequence,'spuls'))    % spulse
            fm.data.infoSpec2WS = text('Position',[0.51,  0.690],'String',sprintf('WS:  %s / %.1f ms / %.0f dB / %.0f Hz',...
                                  SP2_PrVersionUscore(dataSpec2.ws.shape),dataSpec2.ws.dur,dataSpec2.ws.power,...
                                  dataSpec2.ws.offset),'FontSize',pars.displFontSize);
            if strcmp(dataSpec2.ws.applied,'y')
                set(fm.data.infoSpec2WS,'Color',pars.fgTextColor)
            else
                set(fm.data.infoSpec2WS,'Color',pars.bgTextColor)
            end
        end
        
        %--- additional acquisition parameters: JDE, inversion ---
        if isfield(fm.data,'infoSpec2JDE')
            delete(fm.data.infoSpec2JDE)
            fm.data = rmfield(fm.data,'infoSpec2JDE');
        end
        if isfield(fm.data,'infoSpec2Inv')
            delete(fm.data.infoSpec2Inv)
            fm.data = rmfield(fm.data,'infoSpec2Inv');
        end
        if any(strfind(dataSpec2.sequence,'STEAM'))    % STEAM
            if isfield(data.spec2,'inv')
%             fm.data.infoSpec2Inv = text('Position',[0.51, 0.655],'String',sprintf('Inv: %s / %.1f ms / %.0f dB / %.0f Hz / %.3f s',...
%                                    SP2_PrVersionUscore(dataSpec2.inv.shape),dataSpec2.inv.dur,dataSpec2.inv.power,...
%                                    dataSpec2.inv.offset,dataSpec2.inv.ti),'FontSize',pars.displFontSize);
            
                if iscell(dataSpec2.inv.ti)
                    fm.data.infoSpec2Inv = text('Position',[0.51, 0.655],'String',sprintf('Inv: %s / %.1f ms / %.0f dB / %.0f Hz / array',...
                                           SP2_PrVersionUscore(dataSpec2.inv.shape),dataSpec2.inv.dur,dataSpec2.inv.power,...
                                           dataSpec2.inv.offset),'FontSize',pars.displFontSize);
                else
                    fm.data.infoSpec2Inv = text('Position',[0.51, 0.655],'String',sprintf('Inv: %s / %.1f ms / %.0f dB / %.0f Hz / %.3f s',...
                                           SP2_PrVersionUscore(dataSpec2.inv.shape),dataSpec2.inv.dur,dataSpec2.inv.power,...
                                           dataSpec2.inv.offset,dataSpec2.inv.ti),'FontSize',pars.displFontSize);
                end
                if strcmp(dataSpec2.inv.applied,'y')
                    set(fm.data.infoSpec2Inv,'Color',pars.fgTextColor)
                else
                    set(fm.data.infoSpec2Inv,'Color',pars.bgTextColor)
                end
            end
        elseif any(strfind(dataSpec2.sequence,'JDE'))  % JDE
            %--- additional acquisition parameters: JDE ---
            if isfield(fm.data,'infoSpec2JDE')
                delete(fm.data.infoSpec2JDE)
                fm.data = rmfield(fm.data,'infoSpec2JDE');
            end
            if iscell(dataSpec2.jde.offset)
                switch dataSpec2.nr
                    case 1
                        fm.data.infoSpec2JDE = text('Position',[0.51,  0.655],'String',sprintf('JDE: %s / %.1f ms / %.0f dB / %.0f Hz',...
                                               SP2_PrVersionUscore(dataSpec2.jde.shape),dataSpec2.jde.dur,dataSpec2.jde.power,...
                                               dataSpec2.jde.offset{1}),'FontSize',pars.displFontSize);
                    case 2
                        if size(dataSpec2.jde.offset,2)>1
                            if size(dataSpec2.jde.shape,2)>1
                                fm.data.infoSpec2JDE = text('Position',[0.51,  0.655],'String',sprintf('JDE: %s / %.1f ms / %.0f dB / %.0f/%.0f Hz',...
                                                       SP2_PrVersionUscore(dataSpec2.jde.shape{1}),dataSpec2.jde.dur,dataSpec2.jde.power,...
                                                       dataSpec2.jde.offset{1},dataSpec2.jde.offset{2}),'FontSize',pars.displFontSize);
                            else
                                fm.data.infoSpec2JDE = text('Position',[0.51,  0.655],'String',sprintf('JDE: %s / %.1f ms / %.0f dB / %.0f/%.0f Hz',...
                                                       SP2_PrVersionUscore(dataSpec2.jde.shape),dataSpec2.jde.dur,dataSpec2.jde.power,...
                                                       dataSpec2.jde.offset{1},dataSpec2.jde.offset{2}),'FontSize',pars.displFontSize);
                            end
                        else
                            fprintf('\n*** WARNING: ***\nInconsistent number of JDE offsets found for water reference scan.\n');
                        end
                    case 3
                        if size(dataSpec2.jde.offset,2)>2
                            fm.data.infoSpec2JDE = text('Position',[0.51,  0.655],'String',sprintf('JDE: %s / %.1f ms / %.0f dB / %.0f/%.0f/%.0f Hz',...
                                                   SP2_PrVersionUscore(dataSpec2.jde.shape),dataSpec2.jde.dur,dataSpec2.jde.power,...
                                                   dataSpec2.jde.offset{1},dataSpec2.jde.offset{2},dataSpec2.jde.offset{3}),'FontSize',pars.displFontSize);
                        else
                            fprintf('\n*** WARNING: ***\nInconsistent number of JDE offsets found for water reference scan.\n');
                        end
                    case 4
                        if size(dataSpec2.jde.offset,2)>3
                            fm.data.infoSpec2JDE = text('Position',[0.51,  0.655],'String',sprintf('JDE: %s / %.1f ms / %.0f dB / %.0f/%.0f/%.0f/%.0f Hz',...
                                                   SP2_PrVersionUscore(dataSpec2.jde.shape),dataSpec2.jde.dur,dataSpec2.jde.power,...
                                                   dataSpec2.jde.offset{1},dataSpec2.jde.offset{2},dataSpec2.jde.offset{3},dataSpec2.jde.offset{4}),'FontSize',pars.displFontSize);
                        else
                            fprintf('\n*** WARNING: ***\nInconsistent number of JDE offsets found for water reference scan.\n');
                        end
                    otherwise
                        if size(dataSpec2.jde.offset,2)>3
                            fm.data.infoSpec2JDE = text('Position',[0.51,  0.655],'String',sprintf('JDE: %s / %.1f ms / %.0f dB / %.0f/%.0f/%.0f/%.0f/... Hz',...
                                                   SP2_PrVersionUscore(dataSpec2.jde.shape),dataSpec2.jde.dur,dataSpec2.jde.power,...
                                                   dataSpec2.jde.offset{1},dataSpec2.jde.offset{2},dataSpec2.jde.offset{3},dataSpec2.jde.offset{4}),'FontSize',pars.displFontSize);
                        else
                            fprintf('\n*** WARNING: ***\nInconsistent number of JDE offsets found for water reference scan.\n');
                        end
                end
            elseif iscell(dataSpec2.jde.power)         % JDE efficiency (power array)
                fm.data.infoSpec2JDE = text('Position',[0.51, 0.655],'String',sprintf('JDE: %s / %.1f ms / array / %.0f Hz',...
                                       SP2_PrVersionUscore(dataSpec2.jde.shape),dataSpec2.jde.dur,...
                                       dataSpec2.jde.offset),'FontSize',pars.displFontSize);
                fprintf('Data 2: Power array: %s dB\n',SP2_Vec2PrintStr(cell2mat(dataSpec2.jde.power)))                   
            else
                fm.data.infoSpec2JDE = text('Position',[0.51,  0.655],'String',sprintf('JDE: %s / %.1f ms / %.0f dB / %.0f Hz',...
                                       SP2_PrVersionUscore(dataSpec2.jde.shape),dataSpec2.jde.dur,dataSpec2.jde.power,...
                                       dataSpec2.jde.offset),'FontSize',pars.displFontSize);
            end
            if isfield(fm.data,'infoSpec2JDE')
                if strcmp(dataSpec2.jde.applied,'y')
                    set(fm.data.infoSpec2JDE,'Color',pars.fgTextColor)
                else
                    set(fm.data.infoSpec2JDE,'Color',pars.bgTextColor)
                end
            end
        end
        
        %--- additional acquisition parameters: OVS ---
        if isfield(fm.data,'infoSpec2OVS')
            delete(fm.data.infoSpec2OVS)
            fm.data = rmfield(fm.data,'infoSpec2OVS');
        end
        if ~any(strfind(dataSpec2.sequence,'spuls'))    % spulse
            fm.data.infoSpec2OVS = text('Position',[0.51, 0.620],'String',sprintf('OVS: %s / %.1f ms / %.0f dB / %.0f Hz',...
                                   SP2_PrVersionUscore(dataSpec2.ovs.shape),dataSpec2.ovs.dur,dataSpec2.ovs.power,...
                                   dataSpec2.ovs.offset),'FontSize',pars.displFontSize);
            if strcmp(dataSpec2.ovs.applied,'y')
                set(fm.data.infoSpec2OVS,'Color',pars.fgTextColor)
            else
                set(fm.data.infoSpec2OVS,'Color',pars.bgTextColor)
            end
        end
        
        %--- additional acquisition parameters: bandwidth, tof,... ---
        if isfield(fm.data,'infoSpec2DatDim')
            delete(fm.data.infoSpec2DatDim)
            fm.data = rmfield(fm.data,'infoSpec2DatDim');
        end
        if any(strfind(dataSpec2.sequence,'JDE'))  % JDE
            if isempty(dataSpec2.seqtype)
                fm.data.infoSpec2DatDim = text('Position',[0.51, 0.585],'String',...
                                          sprintf('%s, spec %.0f, na %.0f, nr %.0f',...
                                          SP2_PrVersionUscore(dataSpec2.sequence),dataSpec2.nspecC,...
                                          dataSpec2.na,dataSpec2.nr),'FontSize',pars.displFontSize);
            else
                fm.data.infoSpec2DatDim = text('Position',[0.51, 0.585],'String',...
                                          sprintf('%s (%s), spec %.0f, na %.0f, nr %.0f',...
                                          SP2_PrVersionUscore(dataSpec2.sequence),dataSpec2.seqtype,dataSpec2.nspecC,...
                                          dataSpec2.na,dataSpec2.nr),'FontSize',pars.displFontSize);
            end
        else                % any other case
            fm.data.infoSpec2DatDim = text('Position',[0.51, 0.585],'String',...
                                      sprintf('%s, spec %.0f, nx %.0f, ny %.0f, na %.0f, nr %.0f',...
                                      SP2_PrVersionUscore(dataSpec2.sequence), dataSpec2.nspecC,dataSpec2.nx,...
                                      dataSpec2.ny,dataSpec2.na(1),dataSpec2.nr),'FontSize',pars.displFontSize);
        end
        if isfield(fm.data,'infoSpec2AcqPars')
            delete(fm.data.infoSpec2AcqPars)
            fm.data = rmfield(fm.data,'infoSpec2AcqPars');
        end
        if any(findstr(dataSpec2.sequence,'STEAM')) || any(findstr(dataSpec2.sequence,'svs_st'))      % STEAM MRS
            fm.data.infoSpec2AcqPars = text('Position',[0.51,  0.550],'String',...
                                       sprintf('sw %.1f kHz, sf %.1f MHz, TE %.1f ms, TM %.1f ms',dataSpec2.sw_h/1000,...
                                       dataSpec2.sf,dataSpec2.te,dataSpec2.tm),'FontSize',pars.displFontSize);
        else                                                % any other sequence (e.g. PRESS)
            fm.data.infoSpec2AcqPars = text('Position',[0.51,  0.550],'String',...
                                       sprintf('sw %.1f kHz, sf %.1f MHz, TE %.1f ms',dataSpec2.sw_h/1000,...
                                       dataSpec2.sf,dataSpec2.te),'FontSize',pars.displFontSize);
        end
        
        if isfield(fm.data,'infoSpec2Rcvrs')
            delete(fm.data.infoSpec2Rcvrs)
            fm.data = rmfield(fm.data,'infoSpec2Rcvrs');
        end
        if isfield(data.spec2,'nRcvrs')
            if dataSpec2.nRcvrs>1
                fm.data.infoSpec2Rcvrs = text('Position',[0.51,  0.515],'String',...
                                         sprintf('TR %.0f ms, tof %.0f Hz, %.0f rcvrs, gain %.0f',...
                                         dataSpec2.tr,dataSpec2.offset,dataSpec2.nRcvrs,dataSpec2.gain),...
                                         'FontSize',pars.displFontSize);
            else
                fm.data.infoSpec2Rcvrs = text('Position',[0.51,  0.515],'String',...
                                         sprintf('TR %.0f ms, tof %.0f Hz, 1 rcvr, gain %.0f',...
                                         dataSpec2.tr,dataSpec2.offset,dataSpec2.gain),...
                                         'FontSize',pars.displFontSize);
            end
        end
        
        %--- additional acquisition parameters: voxel size and position ---
        if isfield(fm.data,'infoSpec2VoxGeo')
            delete(fm.data.infoSpec2VoxGeo)
            fm.data = rmfield(fm.data,'infoSpec2VoxGeo');
        end
        fm.data.infoSpec2VoxGeo = text('Position',[0.51,  0.480],'String',...
                                  sprintf('vox %s mm, pos %s mm',SP2_Vec2PrintStr(dataSpec2.vox),...
                                  SP2_Vec2PrintStr(dataSpec2.pos)),'FontSize',pars.displFontSize);
        
        %--- additional acquisition parameters: shims ---
        if isfield(fm.data,'infoSpec2ShimZeroAnd1st')
            delete(fm.data.infoSpec2ShimZeroAnd1st)
            fm.data = rmfield(fm.data,'infoSpec2ShimZeroAnd1st');
        end
        fm.data.infoSpec2ShimZeroAnd1st = text('Position',[0.51,  0.445],'String',sprintf('0: %.0f, 1st: %.0f, %.0f, %.0f',...
                                   dataSpec2.z0,dataSpec2.x1,dataSpec2.z1c,dataSpec2.y1),'FontSize',pars.displFontSize);

        if isfield(fm.data,'infoSpec2Shim2nd')
            delete(fm.data.infoSpec2Shim2nd)
            fm.data = rmfield(fm.data,'infoSpec2Shim2nd');
        end
        fm.data.infoSpec2Shim2nd = text('Position',[0.51,  0.410],'String',sprintf('2nd: %.0f, %.0f, %.0f, %.0f, %.0f',...
                                   dataSpec2.x2y2,dataSpec2.xz,dataSpec2.z2c,dataSpec2.yz,dataSpec2.xy),'FontSize',pars.displFontSize);

        if isfield(fm.data,'infoSpec2Shim3rd')
            delete(fm.data.infoSpec2Shim3rd)
            fm.data = rmfield(fm.data,'infoSpec2Shim3rd');
        end
        fm.data.infoSpec2Shim3rd = text('Position',[0.51,  0.375],'String',sprintf('3rd: %.0f, %.0f, %.0f, %.0f, %.0f, %.0f, %.0f',...
                                   dataSpec2.x3,dataSpec2.zx2y2,dataSpec2.xz2,dataSpec2.z3c,dataSpec2.yz2,dataSpec2.zxy,...
                                   dataSpec2.y3),'FontSize',pars.displFontSize);
    end
end

%--- extract water from water + metab scan ---
if strcmp(dataSpec1.fidFilePath,dataSpec2.fidFilePath)
    if ~isfield(fm.data,'dat2ExtractWater')
        fm.data.dat2ExtractWater = uicontrol('Style','Pushbutton','String','Water','Position',[540 432 55 18],'Callback','SP2_Data_Dat2ExtractWater;',...
                                             'TooltipString',sprintf('Extract water reference\n(Last water scan, ECC by first water scan)'),'FontSize',pars.fontSize);
    end
    flag.dataIdentScan = 1;
else
    flag.dataIdentScan = 0;
    if isfield(fm.data,'dat2ExtractWater')
        delete(fm.data.dat2ExtractWater)
        fm.data = rmfield(fm.data,'dat2ExtractWater');
    end
end


%--- ppm calib update ---
set(fm.data.ppmCalib,'String',sprintf('%.3f',data.ppmCalib))

%--- ppm calib update ---
set(fm.data.fidCut,'String',sprintf('%.0f',data.fidCut))

%--- minimum saturation-recovery delay ---
if flag.dataExpType==2      % sat-recovery
    set(fm.data.satRecMinTILab,'Color',pars.fgTextColor)
    set(fm.data.satRecMinTI,'Enable','on')
else
    set(fm.data.satRecMinTILab,'Color',pars.bgTextColor)
    set(fm.data.satRecMinTI,'Enable','off')
end

%--- Klose mode ---
if flag.dataPhaseCorr       % Klose 
%     set(fm.data.kloseComb,'Enable','on')
    set(fm.data.kloseSep,'Enable','on')
    set(fm.data.kloseSelect,'Enable','on')
    if flag.dataKloseMode==3    % single selected
        set(fm.data.phaseCorrNr,'Enable','on')
    else                    % separate
        set(fm.data.phaseCorrNr,'Enable','off')
    end
%     set(fm.data.kloseSep,'Enable','on')
else                        % 1st point
%     set(fm.data.kloseComb,'Enable','off')
    set(fm.data.kloseSep,'Enable','off')
    set(fm.data.kloseSelect,'Enable','off')
    set(fm.data.phaseCorrNr,'Enable','off')
end

%--- receiver selection ---
if flag.dataRcvrAllSelect           % all FIDs
    set(fm.data.rcvrSelStr,'Enable','off')
else                            % selected FIDs
    set(fm.data.rcvrSelStr,'Enable','on')
end

%--- data selection ---
if flag.dataAllSelect           % all FIDs
    set(fm.data.sumSelStr,'Enable','off')
else                            % selected FIDs
    set(fm.data.sumSelStr,'Enable','on')
end

%--- update of scrolling selection ---
set(fm.data.plotAnaFid1,'Value',flag.dataAna==1)
set(fm.data.plotAnaSpec1,'Value',flag.dataAna==2)
set(fm.data.plotAnaFid2,'Value',flag.dataAna==3)
set(fm.data.plotAnaSpec2,'Value',flag.dataAna==4)
                
%--- amplitude window ---
if flag.dataAmpl        % direct assignment of amplitude range
    set(fm.data.amplMinLab,'Color',pars.fgTextColor)
    set(fm.data.amplMin,'Enable','on')
    set(fm.data.amplMaxLab,'Color',pars.fgTextColor)
    set(fm.data.amplMax,'Enable','on')
else                    % full (automatically determined) amplitude range
    set(fm.data.amplMinLab,'Color',pars.bgTextColor)
    set(fm.data.amplMin,'Enable','off')
    set(fm.data.amplMaxLab,'Color',pars.bgTextColor)
    set(fm.data.amplMax,'Enable','off')
end

%--- ppm window ---
if flag.dataPpmShow     % direct assignment of ppm window
    set(fm.data.ppmShowMinLab,'Color',pars.fgTextColor)
    set(fm.data.ppmShowMin,'Enable','on')
    set(fm.data.ppmShowMaxLab,'Color',pars.fgTextColor)
    set(fm.data.ppmShowMax,'Enable','on')
else                    % full spectral range
    set(fm.data.ppmShowMinLab,'Color',pars.bgTextColor)
    set(fm.data.ppmShowMin,'Enable','off')
    set(fm.data.ppmShowMaxLab,'Color',pars.bgTextColor)
    set(fm.data.ppmShowMax,'Enable','off')
end

%--- frequency correction ---
if flag.dataFormat==4       % phase mode
    set(fm.data.phaseLinCorr,'Enable','on')
else
    set(fm.data.phaseLinCorr,'Enable','off')
end


                

                


end
