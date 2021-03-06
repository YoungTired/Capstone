classdef Particle < handle
    properties
        inputs
        position
        best_position
        FOM
        best_FOM = 0
        velocity
    end
    methods
        function obj = Particle
            obj.inputs = Input('gc', 'etch depth', [0.02e-6, 0.2e-6]);
            obj.inputs(end + 1) = Input('gc', 'duty cycle', [0.1, 0.9]);
            obj.inputs(end + 1) = Input('gc', 'pitch', [0.5e-6, 0.8e-6]);
            
            for n = 1:length(obj.inputs)
                obj.position(end + 1) = obj.inputs(n).range(1) + (obj.inputs(n).range(2) - obj.inputs(n).range(1))*rand;
            end
            obj.best_position = obj.position;
            obj.velocity = zeros(size(obj.position));
        end
    end
end
