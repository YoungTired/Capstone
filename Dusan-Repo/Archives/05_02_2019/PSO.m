classdef PSO < handle
    properties
        particles
        best_position
        best_FOM = 0
        stag_FOM = 0
        intertia = 0.8
        c1 = 2
        c2 = 2
        file_name
        
        data
        get_data
        outputs = struct('monitor', {}, 'attribute', {})
    end
    methods
        function obj = PSO(file_name, num_particles, data)
            obj.file_name = file_name;
            obj.particles = Particle;
            for n = 2:num_particles
                obj.particles(end + 1) = Particle;
            end
            obj.best_position = obj.particles(1).best_position;
            switch nargin
                case 2
                    obj.get_data = false;
                case 3
                    obj.data = data;
                    obj.get_data = true;
            end
        end
        
        function run(obj, num_iterations, plot_data)
            switch nargin
                case 2
                    plot_data = false;
                case 3
                    figure(1);
            end
            
            path(path, 'C:\Program Files\Lumerical\fdtd\api\matlab');
            h = appopen('fdtd');
            
            v = waitbar(0, 'Running PSO...');
            count = 0;
            for k = 1:num_iterations
                for m = 1:length(obj.particles)
                    waitbar(count/(num_iterations*length(obj.particles)));
                    code = strcat('load("',char(obj.file_name),'");',...
                        'switchtolayout;');
                    appevalscript(h, code);
                    
                    % update structure parameters
                    for n = 1:length(obj.particles(m).inputs)
                        code = strcat('select("',...
                            char(obj.particles(m).inputs(n).structure),'");',...
                            'set("',char(...
                            obj.particles(m).inputs(n).parameter),...
                            '", ',num2str(obj.particles(m).position(n)),');');
                        appevalscript(h, code);
                    end
                    
                    code = strcat('run;');
                    appevalscript(h, code);

                    % get FOM
                    % for now, this will be custom-written
                    % for example,
                    % code = strcat(...
                    %     'port = getresult("FDTD::ports::port 1", "T");',...
                    %     'FOM = min(port.T);');
                    
                    labels = [];
                    for n = 1:length(obj.outputs)
                        code = strcat('monitor = getresult("',...
                            char(obj.outputs(n).monitor),'");',...
                            'labels = ',char(obj.outputs(n).attribute),';');
                        appevalscript(h, code);
                        labels = cat(2, labels, appgetvar(h, 'labels')');
                    end
                    obj.particles(m).FOM = max(labels);
                    
                    % update global bests
                    if obj.particles(m).FOM >= obj.best_FOM
                        obj.best_FOM = obj.particles(m).FOM;
                        obj.best_position = obj.particles(m).position;
                        obj.stag_FOM = 0;
                    end
                    
                    % update particle bests
                    if obj.particles(m).FOM >= obj.particles(m).best_FOM
                        obj.particles(m).best_FOM = obj.particles(m).FOM;
                        obj.particles(m).best_position...
                            = obj.particles(m).position;
                    end
                    
                    % add example to dataset (if applicable)
                    if obj.get_data == true
                        obj.data.examples(end + 1).features...
                            = obj.particles(m).position;
                        obj.data.examples(end).labels = labels;
                    end
                    
                    % plot data
                    if plot_data == true
                        scatter(obj.particles(m).position(1),...
                            obj.particles(m).position(2));
                        ylim(obj.particles(1).inputs(2).range);
                        xlim(obj.particles(1).inputs(1).range);
                        hold on;
                    end
                    
                    % update velocity and position of particle
                    obj.particles(m).velocity...
                        = obj.intertia*obj.particles(m).velocity...
                        + obj.c1*rand*(obj.particles(m).best_position...
                        - obj.particles(m).position)...
                        + obj.c2*rand*(obj.best_position...
                        - obj.particles(m).position);
                    obj.particles(m).position...
                        = obj.particles(m).position + obj.particles(m).velocity;
                    
                    % boundary condition NEED A SMARTER METHOD for now, the
                    % particle is moved to the boundary it tries to cross
                    for n = 1:length(obj.particles(m).inputs)
                        if obj.particles(m).position(n)...
                            > obj.particles(m).inputs(n).range(2)
                            obj.particles(m).position(n)...
                                = obj.particles(m).inputs(n).range(2);
                        elseif obj.particles(m).position(n)...
                                < obj.particles(m).inputs(n).range(1)
                            obj.particles(m).position(n)...
                                = obj.particles(m).inputs(n).range(1);
                        end
                    end 
                    count = count + 1;
                end
                obj.swarm_regroup(5);
            end
            close(v);
        end
        
        function swarm_regroup(obj, threshold)
            obj.stag_FOM = obj.stag_FOM + 1;
            if obj.stag_FOM >= threshold
                obj.stag_FOM = 0;
                for n = 1:length(obj.particles)
                    for nn = 1:length(obj.particles(n).inputs)
                        obj.particles(n).position(nn)...
                            = obj.particles(n).inputs(nn).range(1)...
                            + (obj.particles(n).inputs(nn).range(2)...
                            - obj.particles(n).inputs(nn).range(1))*rand;
                    end
                    obj.particles(n).best_position...
                        = obj.particles(n).position;
                    obj.particles(n).velocity...
                        = zeros(size(obj.particles(n).position));
                    obj.particles(n).FOM = 0;
                    obj.particles(n).best_FOM = 0;
                end
                obj.best_position = obj.particles(n).position;
                obj.best_FOM = 0;
            end
        end
    end
end
