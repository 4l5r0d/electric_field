function campo_electrico_n_cargas()
    % Interfaz Gráfica
    f = figure('Name', 'Visualización de Campos Eléctricos con n cargas', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 600]);
    
    % Número de cargas
    uicontrol('Style', 'text', 'Position', [20, 560, 100, 20], 'String', 'N° Cargas:', 'HorizontalAlignment', 'left');
    num_cargas_edit = uicontrol('Style', 'edit', 'Position', [120, 560, 60, 20], 'String', '2');
    uicontrol('Style', 'pushbutton', 'Position', [200, 560, 100, 30], 'String', 'Configurar', 'Callback', @configurar_cargas);
    
    % Panel de Configuración
    config_panel = uipanel('Title', 'Configuración de Cargas', 'Position', [0.02, 0.2, 0.3, 0.3]);
    
    % Botones de Visualización 
    uicontrol('Style', 'pushbutton', 'Position', [20, 50, 120, 30], 'String', 'Visualizar 2D', 'Callback', @visualizar_2D);
    uicontrol('Style', 'pushbutton', 'Position', [160, 50, 120, 30], 'String', 'Visualizar 3D', 'Callback', @visualizar_3D);
    
    % Ejes para la Gráfica
    ax = axes('Parent', f, 'Position', [0.35, 0.1, 0.6, 0.8]);
    
    % Datos Dinámicos
    carga_inputs = []; % Para almacenar las referencias a los inputs de cargas y posiciones
    
    % Función para Configurar las Cargas
    function configurar_cargas(~, ~)
        % Obtener número de cargas
        num_cargas = str2double(get(num_cargas_edit, 'String'));
        if isnan(num_cargas) || num_cargas <= 0
            errordlg('Ingrese un número válido de cargas.', 'Error');
            return;
        end
        
        % Limpiar la Configuración
        delete(config_panel.Children);
        carga_inputs = cell(num_cargas, 2);
        
        % Crear N° Entradas
        for i = 1:num_cargas
            uicontrol('Parent', config_panel, 'Style', 'text', 'Position', [10, 300 - 50*i, 70, 20], ...
                      'String', sprintf('Carga %d:', i), 'HorizontalAlignment', 'left');
            carga_inputs{i, 1} = uicontrol('Parent', config_panel, 'Style', 'edit', 'Position', [80, 300 - 50*i, 60, 20], ...
                                           'String', '1e-6');
            uicontrol('Parent', config_panel, 'Style', 'text', 'Position', [150, 300 - 50*i, 70, 20], ...
                      'String', sprintf('Pos %d (x,y,z):', i), 'HorizontalAlignment', 'left');
            carga_inputs{i, 2} = uicontrol('Parent', config_panel, 'Style', 'edit', 'Position', [230, 300 - 50*i, 100, 20], ...
                                           'String', '[0, 0, 0]');
        end
    end

    % Visualización 2D
    function visualizar_2D(~, ~)
        [cargas, posiciones] = obtener_cargas();
        if isempty(cargas)
            return;
        end
        
        % Generar Flechas para el Campo Eléctrico
        [X, Y] = meshgrid(-10:0.5:10, -10:0.5:10);
        Ex = zeros(size(X));
        Ey = zeros(size(X));
        
        % Calcular Contribuciones de Cada Carga
        for i = 1:length(cargas)
            dx = X - posiciones(i, 1);
            dy = Y - posiciones(i, 2);
            R = sqrt(dx.^2 + dy.^2).^3;
            % Evitar divisiones por cero
            R(R == 0) = inf;  
            Ex = Ex + cargas(i) * dx ./ R;
            Ey = Ey + cargas(i) * dy ./ R;
        end
        
        % Visualizar Campo
        cla(ax);
        quiver(ax, X, Y, Ex, Ey, 'b');
        hold(ax, 'on');
        
        % Mostrar Cargas y flechas
        for i = 1:length(cargas)
            plot(ax, posiciones(i, 1), posiciones(i, 2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            text(ax, posiciones(i, 1), posiciones(i, 2), sprintf('%.2e C', cargas(i)), 'VerticalAlignment', 'bottom');
        end
        for i = 1:length(cargas)
            for j = i+1:length(cargas)
                line(ax, [posiciones(i, 1), posiciones(j, 1)], [posiciones(i, 2), posiciones(j, 2)], 'Color', 'k', 'LineStyle', '--');
                distancia = norm(posiciones(i, :) - posiciones(j, :));
                mid_point = (posiciones(i, :) + posiciones(j, :)) / 2;
                text(ax, mid_point(1), mid_point(2), sprintf('%.2f m', distancia), 'Color', 'k', 'HorizontalAlignment', 'center');
            end
        end
        
        title(ax, 'Campo eléctrico (2D)');
        hold(ax, 'off');
    end

    % Visualización 3D
    function visualizar_3D(~, ~)
        [cargas, posiciones] = obtener_cargas();
        if isempty(cargas)
            return;
        end
        
        % Generar Flechas para el Campo Eléctrico
        [X, Y, Z] = meshgrid(-10:2:10, -10:2:10, -10:2:10);
        Ex = zeros(size(X));
        Ey = zeros(size(X));
        Ez = zeros(size(X));
        
        % Calcular Contribuciones de Cada Carga
        for i = 1:length(cargas)
            dx = X - posiciones(i, 1);
            dy = Y - posiciones(i, 2);
            dz = Z - posiciones(i, 3);
            R = sqrt(dx.^2 + dy.^2 + dz.^2).^3;
            % Evitar divisiones por cero
            R(R == 0) = inf;
            Ex = Ex + cargas(i) * dx ./ R;
            Ey = Ey + cargas(i) * dy ./ R;
            Ez = Ez + cargas(i) * dz ./ R;
        end
        
        % Visualizar Campo
        cla(ax);
        quiver3(ax, X, Y, Z, Ex, Ey, Ez, 'b');
        hold(ax, 'on');
        
        % Mostrar Cargas y Flechas
        for i = 1:length(cargas)
            plot3(ax, posiciones(i, 1), posiciones(i, 2), posiciones(i, 3), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            text(ax, posiciones(i, 1), posiciones(i, 2), posiciones(i, 3), sprintf('%.2e C', cargas(i)), 'VerticalAlignment', 'bottom');
        end
        for i = 1:length(cargas)
            for j = i+1:length(cargas)
                line(ax, [posiciones(i, 1), posiciones(j, 1)], [posiciones(i, 2), posiciones(j, 2)], [posiciones(i, 3), posiciones(j, 3)], ...
                     'Color', 'k', 'LineStyle', '--');
                distancia = norm(posiciones(i, :) - posiciones(j, :));
                mid_point = (posiciones(i, :) + posiciones(j, :)) / 2;
                text(ax, mid_point(1), mid_point(2), mid_point(3), sprintf('%.2f m', distancia), 'Color', 'k', 'HorizontalAlignment', 'center');
            end
        end
        
        title(ax, 'Campo eléctrico (3D)');
        hold(ax, 'off');
    end

    % Cargas y Posiciones
    function [cargas, posiciones] = obtener_cargas()
        num_cargas = length(carga_inputs);
        cargas = zeros(num_cargas, 1);
        posiciones = zeros(num_cargas, 3);
        for i = 1:num_cargas
            cargas(i) = str2double(get(carga_inputs{i, 1}, 'String'));
            posiciones(i, :) = str2num(get(carga_inputs{i, 2}, 'String'));
        end
        if any(isnan(cargas)) || any(isnan(posiciones(:)))
            errordlg('Ingrese valores válidos para todas las cargas y posiciones.', 'Error');
            cargas = [];
            posiciones = [];
        end
    end
end
