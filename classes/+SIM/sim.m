classdef sim < handle
    %SIM Class to hold numbers used to define simulation parameters eg
    %duration
    properties (SetAccess = private)
        lengthScaleFactor
        densityScaleFactor
        duration
%         dynamicCalc
    end
    
    methods
        % Constructor
        function obj = sim
            %SIM Construct an instance of this class
            %   Detailed explanation goes here
            obj.lengthScaleFactor  = SIM.parameter('Value',1,'Unit','');
            obj.densityScaleFactor = SIM.parameter('Value',1,'Unit','');
            obj.duration = SIM.parameter('Unit','s');
%             obj.dynamicCalc = SIM.parameter('Value',0,'Unit','');
        end
        % Setters
        function setLengthScaleFactor(obj,val,units)
            obj.lengthScaleFactor.setValue(val,units);
        end
        function setDensityScaleFactor(obj,val,units)
            obj.densityScaleFactor.setValue(val,units);
        end
        function setDuration(obj,val,units)
            obj.duration.setValue(val,units);
        end
%         function setDynamicCalc(obj,val,units)
%             obj.dynamicCalc.setValue(val,units);
%         end
    end
end

