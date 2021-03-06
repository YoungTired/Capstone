classdef Grid < handle
    properties
        data
        mind
        examples
    end
    methods
        function obj = Grid(data, mind)
            obj.data = data;
            obj.mind = mind;
            obj.examples = data.examples;
            [obj.examples(:).predictions] = deal(0);
            [obj.examples(:).accuracy] = deal(0);
            
            for n = 1:length(obj.examples)
                obj.examples(n).predictions =...
                    obj.mind.infer(obj.examples(n).features);
                obj.examples(n).accuracy =...
                    abs(obj.examples(n).predictions -...
                    obj.examples(n).labels)/obj.examples(n).labels;
            end
        end
        
        function obj = add_mind(obj, mind)
            obj.mind = mind;
            for n = 1:length(obj.examples)
                obj.examples(n).predictions =...
                    obj.mind.infer(obj.examples(n).features);
                obj.examples(n).accuracy =...
                    abs(obj.examples(n).predictions -...
                    obj.examples(n).labels)/obj.examples(n).labels;
            end
        end
        
        function map_data(obj, sel)
            inputs = find(strcmp(sel, ':') == 1);
            labels = reshape([obj.examples.labels],...
                round(length(obj.examples)^(1/length(obj.data.inputs))...
                *ones(1, length(obj.data.inputs))));
            features = reshape([obj.examples.features],...
                [length(obj.examples(1).features) length(obj.examples)])';
            h = heatmap(round(unique(features(:, inputs(1)))*1e9),...
                round(flipud(unique(features(:, inputs(2)))),2,'significant'),...
                reshape(flipud(labels(sel{:})),...
                round(length(obj.examples)^(1/length(obj.data.inputs))),...
                round(length(obj.examples)^(1/length(obj.data.inputs)))));
            
            ylabel('Duty Cycle (a.u.)');
            xlabel('Etch Depth (nm)');
            title('Maximum Transmission (a.u.)');
            set(gca,'FontSize',12);
        end
        
        function map_mind(obj, sel)
            inputs = find(strcmp(sel, ':') == 1);
            predictions = reshape([obj.examples.predictions],...
                round(length(obj.examples)^(1/length(obj.data.inputs))...
                *ones(1, length(obj.data.inputs))));
            features = reshape([obj.examples.features],...
                [length(obj.examples(1).features) length(obj.examples)])';
            h = heatmap(round(unique(features(:, inputs(1)))*1e9),...
                round(flipud(unique(features(:, inputs(2)))),2,'significant'),...
                reshape(flipud(predictions(sel{:})),...
                round(length(obj.examples)^(1/length(obj.data.inputs))),...
                round(length(obj.examples)^(1/length(obj.data.inputs)))));
            
            ylabel('Duty Cycle (a.u.)');
            xlabel('Etch Depth (nm)');
            title('Maximum Transmission (a.u.)');
            set(gca,'FontSize',12);
        end
        
        function map_mind_accuracy(obj, sel)
            inputs = find(strcmp(sel, ':') == 1);
            accuracy = reshape([obj.examples.accuracy],...
                round(length(obj.examples)^(1/length(obj.data.inputs))...
                *ones(1, length(obj.data.inputs))));
            features = reshape([obj.examples.features],...
                [length(obj.examples(1).features) length(obj.examples)])';
            h = heatmap(unique(features(:, inputs(1))),...
                flipud(unique(features(:, inputs(2)))),...
                reshape(flipud(accuracy(sel{:})),...
                round(length(obj.examples)^(1/length(obj.data.inputs))),...
                round(length(obj.examples)^(1/length(obj.data.inputs)))));
            
            sum = 0;
            for n = 1:length(obj.examples)
                sum = sum + obj.examples(n).accuracy;
            end
            average = sum/length(obj.examples)
        end
    end
end
