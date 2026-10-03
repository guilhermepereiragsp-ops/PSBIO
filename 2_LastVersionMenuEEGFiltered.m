clear all
close all
clc

pkg load signal
pkg load biosig  % Carrega o pacote biosig necessário para leitura de ficheiros EDF

% Solicita ao utilizador o ficheiro EDF
[filename, pathname] = uigetfile("*.edf", "Selecione um ficheiro EDF");
if isequal(filename, 0)
    disp("Nenhum ficheiro selecionado. Encerrando o programa.");
    return;
end

% Caminho completo do ficheiro
file_path = fullfile(pathname, filename);

% Lê o ficheiro EDF
[data, header] = sload(file_path);

% Define regiões cerebrais e canais associados
regions = {
    'Frontal', {'EEG Fp1', 'EEG Fp2', 'EEG F3', 'EEG F4', 'EEG F7', 'EEG F8', 'EEG Fz' };
    'Temporal', {'EEG T3', 'EEG T4', 'EEG T5', 'EEG T6'};
    'Central', {'EEG C3', 'EEG C4', 'EEG Fz', 'EEG Cz'};
    'Parietal', {'EEG P3', 'EEG P4', 'EEG Pz'};
    'Occipital', {'EEG O1', 'EEG O2'};
};

% Mapeia os índices dos canais para as regiões
region_signals = struct();
for i = 1:size(regions, 1)
    region_name = regions{i, 1};
    region_channels = regions{i, 2};
    region_indices = find(ismember(header.Label, region_channels));
    if isempty(region_indices)
        disp(["Região " region_name " não possui canais no ficheiro."]);
    else
        region_signals.(region_name) = region_indices;
    end
end

% Menu principal
while true
    disp("\nMenu Principal:");
    disp("1. Listar canais disponíveis");
    disp("2. Visualizar sinal individual");
    disp("3. Visualizar sinal composto por região cerebral");
    disp("4. Análise por bandas de frequência de todas as regiões");
    disp("5. Sair");

    choice = input("Escolha uma opção (1-5): ");

    switch choice
        case 1
            % Lista os nomes dos canais disponíveis
            disp("Canais disponíveis:");
            for i = 1:length(header.Label)
                fprintf("Canal %d: %s\n", i, header.Label{i});
            end

        case 2
            % Solicita o canal a visualizar
            channel_num = input("Digite o número do canal que deseja visualizar: ");

            % Valida o número do canal
            if channel_num < 1 || channel_num > size(data, 2)
                disp("Número de canal inválido.");
            else
                signal = data(:, channel_num);
                sample_rate = header.SampleRate;
                time = (0:length(signal) - 1) / sample_rate;

                channel_name = header.Label{channel_num};

                % Menu para escolha do domínio
                while true
                    disp("\nEscolha a forma de visualização:");
                    disp("1. Domínio do tempo");
                    disp("2. Domínio da frequência");
                    disp("3. Aplicar filtro");
                    disp("4. Voltar");

                    sub_choice = input("Escolha uma opção (1-4): ");

                    switch sub_choice
                        case 1
                            % Plot no domínio do tempo
                            figure;
                            plot(time, signal, 'b');
                            title(["Sinal no Domínio do Tempo - " channel_name]);
                            xlabel("Tempo (s)");
                            ylabel("Amplitude");
                            grid on;

                        case 2


                            % Aplicar filtro ao sinal
                            % Sinal filtrado
                            signal = signal - mean(signal);

                            % Número de amostras
                            L = length(signal);
                            % Taxa de amostragem (frequência do cabeçalho do EDF para o canal 1)
                            fs = 256;  % Certifique-se de que este valor está correto no seu arquivo EDF

                            % ----------- Simulação e Adição de Ruído Branco -----------

                            % Gerar ruído branco com a mesma dimensão do sinal
                            ruido_branco = randn(size(signal));

                            % Adicionar o ruído branco ao sinal original
                            signal_ruidoso = signal + 0.5 * ruido_branco;  % Ajuste a escala do ruído, aqui 0.5


                            % ----------- Filtro para Remoção de Ruído Branco -----------

                            % Criar um filtro passa-faixa para reduzir ruído branco
                            fc_low = 30;   % Frequência de corte inferior (passa-alto)
                            fc_high = 100; % Frequência de corte superior (passa-baixo)
                            ordem = 5;     % Ordem do filtro

                            % Criar o filtro passa-faixa Butterworth
                            [b_band, a_band] = butter(ordem, [fc_low, fc_high] / (fs / 2), 'bandpass');

                            % Aplicar o filtro ao sinal ruidoso
                            sinal_filtrado_ruido = filter(b_band, a_band, signal_ruidoso);

                            % ----------- Transformada de Fourier -----------

                            % FFT do sinal ruidoso
                            NFFT = 2^nextpow2(L); % Número de pontos na FFT
                            Signal_ruido = fft(signal_ruidoso, NFFT) / L;
                            Sinal_filtrado = fft(sinal_filtrado_ruido, NFFT) / L;

                            f = fs * (0:(NFFT/2)-1) / NFFT; % Eixo de frequência




                            % Plot do Sinal ruidoso no domínio das frequências
                            figure;
                            plot(f, 2 * abs(Signal_ruido(1:NFFT/2)), 'b');
                            title('Sinal com Ruído Branco no Domínio das Frequências');
                            xlabel('Frequência (Hz)');
                            ylabel('Amplitude');
                            ylim([0, max(2 * abs(Sinal_filtrado(1:NFFT/2)))]);

                        case 3
                            while true
                                % Novo menu para aplicar filtros
                                disp("Que tipo de filtro deseja aplicar? ");
                                disp("1. Passa-Banda");
                                disp("2. Rejeita-Banda");
                                disp("3. 1+2: ");
                                disp("4. Comparação com o sinal não filtrado");
                                disp("5. Voltar");
                                sub_choice = input("Escolha uma opção (1-5): ");

                                switch sub_choice
                                    case 1
                                        % Sinal filtrado
                                        signal = signal - mean(signal);

                                        % Número de amostras
                                        L = length(signal);

                                        % Taxa de amostragem (frequência do cabeçalho do EDF para o canal 1)
                                        fs = 256;  % Certifique-se de que este valor está correto no seu arquivo EDF

                                        % ----------- Simulação e Adição de Ruído Branco -----------

                                        % Gerar ruído branco com a mesma dimensão do sinal
                                        ruido_branco = randn(size(signal));

                                        % Adicionar o ruído branco ao sinal original
                                        signal_ruidoso = signal + 0.5 * ruido_branco;  % Ajuste a escala do ruído, aqui 0.5


                                        % ----------- Filtro para Remoção de Ruído Branco -----------

                                        % Criar um filtro passa-faixa para reduzir ruído branco
                                        fc_low = 30;   % Frequência de corte inferior (passa-alto)
                                        fc_high = 100; % Frequência de corte superior (passa-baixo)
                                        ordem = 5;     % Ordem do filtro

                                        % Criar o filtro passa-faixa Butterworth
                                        [b_band, a_band] = butter(ordem, [fc_low, fc_high] / (fs / 2), 'bandpass');

                                        % Aplicar o filtro ao sinal ruidoso
                                        sinal_filtrado_ruido = filter(b_band, a_band, signal_ruidoso);

                                        % ----------- Transformada de Fourier -----------





                                        % ----------- Filtro para Remoção da Frequência de Rede -----------

                                        % Criar um filtro rejeita-banda (bandstop) para 50 Hz
                                        f0 = 50; % Frequência central da rede elétrica (50 Hz)
                                        bw = 1;  % Largura de banda rejeitada (ajustável, 2 Hz aqui é padrão)
                                        fc1 = f0 - bw / 2; % Frequência de corte inferior
                                        fc2 = f0 + bw / 2; % Frequência de corte superior

                                        % Criar filtro Butterworth rejeita-banda
                                        [b_notch, a_notch] = butter(ordem, [fc1, fc2] / (fs / 2), 'stop');

                                        % Aplicar o filtro notch ao sinal original
                                        signal_filtrado_notch = filter(b_notch, a_notch, signal);

                                        % FFT do sinal ruidoso
                                        NFFT = 2^nextpow2(L); % Número de pontos na FFT
                                        Signal_ruido = fft(signal_ruidoso, NFFT) / L;
                                        Sinal_filtrado = fft(sinal_filtrado_ruido, NFFT) / L;
                                        Sinal_filtrado_notch = fft(signal_filtrado_notch, NFFT) / L;

                                        f = fs * (0:(NFFT/2)-1) / NFFT; % Eixo de frequência


                                        t = (0:L-1) / fs;

                                        % ----------- Plots Comparativos -----------

                                        % Criar a figura para os gráficos
                                        ylim_frequencias = [0, 0.035]; % Substitua pelos limites do gráfico do meio
                                        figure;



                                        % Subplot 2: Sinal Filtrado no Domínio das Frequências
                                        plot(f, 2 * abs(Sinal_filtrado(1:NFFT/2)), 'b');
                                        title('Sinal Filtrado (Remoção de Ruído Branco) no Domínio das Frequências');
                                        xlabel('Frequência (Hz)');
                                        ylabel('Amplitude');



                                    case 2
                                        % Sinal filtrado
                                        signal = signal - mean(signal);

                                        % Número de amostras
                                        L = length(signal);

                                        % Taxa de amostragem (frequência do cabeçalho do EDF para o canal 1)
                                        fs = 256;  % Certifique-se de que este valor está correto no seu arquivo EDF

                                        % ----------- Simulação e Adição de Ruído Branco -----------

                                        % Gerar ruído branco com a mesma dimensão do sinal
                                        ruido_branco = randn(size(signal));

                                        % Adicionar o ruído branco ao sinal original
                                        signal_ruidoso = signal + 0.5 * ruido_branco;  % Ajuste a escala do ruído, aqui 0.5


                                        % ----------- Filtro para Remoção de Ruído Branco -----------

                                        % Criar um filtro passa-faixa para reduzir ruído branco
                                        fc_low = 30;   % Frequência de corte inferior (passa-alto)
                                        fc_high = 100; % Frequência de corte superior (passa-baixo)
                                        ordem = 5;     % Ordem do filtro

                                        % Criar o filtro passa-faixa Butterworth
                                        [b_band, a_band] = butter(ordem, [fc_low, fc_high] / (fs / 2), 'bandpass');

                                        % Aplicar o filtro ao sinal ruidoso
                                        sinal_filtrado_ruido = filter(b_band, a_band, signal_ruidoso);

                                        % ----------- Transformada de Fourier -----------





                                        % ----------- Filtro para Remoção da Frequência de Rede -----------

                                        % Criar um filtro rejeita-banda (bandstop) para 50 Hz
                                        f0 = 50; % Frequência central da rede elétrica (50 Hz)
                                        bw = 1;  % Largura de banda rejeitada (ajustável, 2 Hz aqui é padrão)
                                        fc1 = f0 - bw / 2; % Frequência de corte inferior
                                        fc2 = f0 + bw / 2; % Frequência de corte superior

                                        % Criar filtro Butterworth rejeita-banda
                                        [b_notch, a_notch] = butter(ordem, [fc1, fc2] / (fs / 2), 'stop');

                                        % Aplicar o filtro notch ao sinal original
                                        signal_filtrado_notch = filter(b_notch, a_notch, signal);

                                        % FFT do sinal ruidoso
                                        NFFT = 2^nextpow2(L); % Número de pontos na FFT
                                        Signal_ruido = fft(signal_ruidoso, NFFT) / L;
                                        Sinal_filtrado = fft(sinal_filtrado_ruido, NFFT) / L;
                                        Sinal_filtrado_notch = fft(signal_filtrado_notch, NFFT) / L;

                                        f = fs * (0:(NFFT/2)-1) / NFFT; % Eixo de frequência


                                        t = (0:L-1) / fs;

                                        % ----------- Plots Comparativos -----------

                                        % Criar a figura para os gráficos
                                        ylim_frequencias = [0, 0.035]; % Substitua pelos limites do gráfico do meio
                                        figure;



                                        % Subplot 3: Sinal Filtrado (notch) no Domínio das Frequências
                                        plot(f, 2 * abs(Sinal_filtrado_notch(1:NFFT/2)), 'b');
                                        title('Sinal Filtrado (Notch 50 Hz) no Domínio das Frequências');
                                        xlabel('Frequência (Hz)');
                                        ylabel('Amplitude');
                                        ylim(ylim_frequencias); % Limite de y para o gráfico de baixo


                                    case 3
                                        % Sinal original centralizado
                                        signal = signal - mean(signal);

                                        % Número de amostras
                                        L = length(signal);

                                        % Taxa de amostragem (verifique no cabeçalho do EDF se corresponde ao canal específico)
                                        fs = 256;

                                        % ----------- Simulação e Adição de Ruído Branco -----------

                                        % Gerar ruído branco com a mesma dimensão do sinal
                                        ruido_branco = randn(size(signal));

                                        % Adicionar o ruído branco ao sinal original
                                        signal_ruidoso = signal + 0.5 * ruido_branco;  % Ajuste a escala do ruído, aqui 0.5

                                        % ----------- Filtro Passa-Banda -----------

                                        % Criar um filtro passa-banda para reduzir ruído branco
                                        fc_low = 30;   % Frequência de corte inferior (passa-alto)
                                        fc_high = 100; % Frequência de corte superior (passa-baixo)
                                        ordem = 5;     % Ordem do filtro

                                        % Criar o filtro passa-banda Butterworth
                                        [b_band, a_band] = butter(ordem, [fc_low, fc_high] / (fs / 2), 'bandpass');

                                        % Aplicar o filtro ao sinal ruidoso
                                        sinal_filtrado_ruido = filter(b_band, a_band, signal_ruidoso);

                                        % ----------- Transformada de Fourier do Passa-Banda -----------

                                        % FFT do sinal filtrado pelo passa-banda
                                        NFFT = 2^nextpow2(L); % Número de pontos na FFT
                                        Sinal_filtrado = fft(sinal_filtrado_ruido, NFFT) / L;

                                        % ----------- Filtro Rejeita-Banda (Notch) -----------

                                        % Configuração do filtro rejeita-banda
                                        f0 = 50; % Frequência central da rede elétrica (50 Hz)
                                        bw = 1;  % Largura de banda rejeitada (1 Hz aqui é padrão)
                                        fc1 = f0 - bw / 2; % Frequência de corte inferior
                                        fc2 = f0 + bw / 2; % Frequência de corte superior

                                        % Criar filtro Butterworth rejeita-banda
                                        [b_notch, a_notch] = butter(ordem, [fc1, fc2] / (fs / 2), 'stop');

                                        % Aplicar o filtro rejeita-banda ao sinal já filtrado no domínio do tempo
                                        signal_filtrado_notch = filter(b_notch, a_notch, sinal_filtrado_ruido);

                                        % FFT do sinal após o filtro rejeita-banda
                                        Sinal_filtrado_notch = fft(signal_filtrado_notch, NFFT) / L;
                                        %Sinal final no dominio dos tempos
                                        sinal_filtrado_final = filter(b_notch, a_notch, sinal_filtrado_ruido);
                                        % ----------- Eixos de Tempo e Frequência -----------

                                        f = fs * (0:(NFFT/2)-1) / NFFT; % Eixo de frequência
                                        t = (0:L-1) / fs; % Eixo de tempo

                                        % ----------- Plots Comparativos -----------

                                        % Criar a figura para os gráficos
                                        ylim_frequencias = [0, 0.035]; % Ajuste os limites do gráfico de frequência conforme necessário
                                        figure;


                                        % Subplot 3: Sinal filtrado (notch) no domínio das frequências
                                        plot(f, 2 * abs(Sinal_filtrado_notch(1:NFFT/2)), 'b');
                                        title('Sinal Filtrado (Notch 50 Hz + Passa-Banda 30-100 Hz) no Domínio das Frequências');
                                        xlabel('Frequência (Hz)');
                                        ylabel('Amplitude');
                                        ylim(ylim_frequencias); % Limite de y para o gráfico de baixo
                                        grid on;



                                    case 4
                                        while true
                                            disp("Comparação com o sinal não filtrado selecionada.");

                                            % Novo menu para comparar os sinais
                                            disp("Para que domínio pretende comparar os sinais? ");
                                            disp("1. Dominio dos tempos");
                                            disp("2. Dominio das frequencias");
                                            disp("3. Voltar");

                                            compare_choice = input("Escolha uma opção (1-3): ");

                                            switch compare_choice
                                                case 1

                                                                         % Sinal original centralizado


                                                                         % Sinal original centralizado
                                                                                                       % Sinal original centralizado
                                                    signal = signal - mean(signal);

                                                    % Número de amostras
                                                    L = length(signal);

                                                    % Taxa de amostragem (verifique no cabeçalho do EDF se corresponde ao canal específico)
                                                    fs = 256;

                                                    % ----------- Simulação e Adição de Ruído Branco -----------

                                                    % Gerar ruído branco com a mesma dimensão do sinal
                                                    ruido_branco = randn(size(signal));

                                                    % Adicionar o ruído branco ao sinal original
                                                    signal_ruidoso = signal + 0.5 * ruido_branco;  % Ajuste a escala do ruído, aqui 0.5

                                                    % ----------- Filtro Passa-Banda -----------

                                                    % Criar um filtro passa-banda para reduzir ruído branco
                                                    fc_low = 30;   % Frequência de corte inferior (passa-alto)
                                                    fc_high = 100; % Frequência de corte superior (passa-baixo)
                                                    ordem = 5;     % Ordem do filtro

                                                    % Criar o filtro passa-banda Butterworth
                                                    [b_band, a_band] = butter(ordem, [fc_low, fc_high] / (fs / 2), 'bandpass');

                                                    % Aplicar o filtro ao sinal ruidoso
                                                    sinal_filtrado_ruido = filter(b_band, a_band, signal_ruidoso);

                                                    % ----------- Transformada de Fourier do Passa-Banda -----------

                                                    % FFT do sinal filtrado pelo passa-banda
                                                    NFFT = 2^nextpow2(L); % Número de pontos na FFT
                                                    Sinal_filtrado = fft(sinal_filtrado_ruido, NFFT) / L;

                                                    % ----------- Filtro Rejeita-Banda (Notch) -----------

                                                    % Configuração do filtro rejeita-banda
                                                    f0 = 50; % Frequência central da rede elétrica (50 Hz)
                                                    bw = 1;  % Largura de banda rejeitada (1 Hz aqui é padrão)
                                                    fc1 = f0 - bw / 2; % Frequência de corte inferior
                                                    fc2 = f0 + bw / 2; % Frequência de corte superior

                                                    % Criar filtro Butterworth rejeita-banda
                                                    [b_notch, a_notch] = butter(ordem, [fc1, fc2] / (fs / 2), 'stop');

                                                    % Aplicar o filtro rejeita-banda ao sinal já filtrado no domínio do tempo
                                                    signal_filtrado_notch = filter(b_notch, a_notch, sinal_filtrado_ruido);

                                                    % FFT do sinal após o filtro rejeita-banda
                                                    Sinal_filtrado_notch = fft(signal_filtrado_notch, NFFT) / L;
                                                    %Sinal final no dominio dos tempos
                                                    sinal_filtrado_final = filter(b_notch, a_notch, sinal_filtrado_ruido);
                                                    % ----------- Eixos de Tempo e Frequência -----------

                                                    f = fs * (0:(NFFT/2)-1) / NFFT; % Eixo de frequência
                                                    t = (0:L-1) / fs; % Eixo de tempo

                                                    % ----------- Plots Comparativos -----------

                                                    % Criar a figura para os gráficos

                                                    figure;
                                                    subplot(2, 1, 1);
                                                    plot(t, signal, 'b');
                                                    title('Sinal Original no Domínio do Tempo');
                                                    xlabel('Tempo (s)');
                                                    ylabel('Amplitude');
                                                    ylim([min(signal), max(signal)]); % Mesma escala
                                                    grid on;
                                                        % Criar uma figura para o gráfico no domínio do tempo
                                                    subplot(2, 1, 2);
                                                    plot(t, sinal_filtrado_final, 'b');
                                                    title('Sinal Filtrado (Passa-Banda + Notch) no Domínio do Tempo');
                                                    xlabel('Tempo (s)');
                                                    ylabel('Amplitude');
                                                    grid on;
                                                    % Ajustar a escala para coincidir com o gráfico original
                                                    xlim([0, max(t)]); % Limites do eixo X (tempo)
                                                    ylim([min(sinal_filtrado_final), max(sinal_filtrado_final)]); % Mesma escala
                                                    % Limites do eixo Y (amplitude)

                                                case 2
                                                    % Sinal original centralizado
                                                    signal = signal - mean(signal);

                                                    % Número de amostras
                                                    L = length(signal);

                                                    % Taxa de amostragem (verifique no cabeçalho do EDF se corresponde ao canal específico)
                                                    fs = 256;

                                                    % ----------- Simulação e Adição de Ruído Branco -----------

                                                    % Gerar ruído branco com a mesma dimensão do sinal
                                                    ruido_branco = randn(size(signal));

                                                    % Adicionar o ruído branco ao sinal original
                                                    signal_ruidoso = signal + 0.5 * ruido_branco;  % Ajuste a escala do ruído, aqui 0.5

                                                    % ----------- Filtro Passa-Banda -----------

                                                    % Criar um filtro passa-banda para reduzir ruído branco
                                                    fc_low = 30;   % Frequência de corte inferior (passa-alto)
                                                    fc_high = 100; % Frequência de corte superior (passa-baixo)
                                                    ordem = 5;     % Ordem do filtro

                                                    % Criar o filtro passa-banda Butterworth
                                                    [b_band, a_band] = butter(ordem, [fc_low, fc_high] / (fs / 2), 'bandpass');

                                                    % Aplicar o filtro ao sinal ruidoso
                                                    sinal_filtrado_ruido = filter(b_band, a_band, signal_ruidoso);

                                                    % ----------- Transformada de Fourier do Passa-Banda -----------

                                                    % FFT do sinal filtrado pelo passa-banda
                                                    NFFT = 2^nextpow2(L); % Número de pontos na FFT
                                                    Sinal_filtrado = fft(sinal_filtrado_ruido, NFFT) / L;
                                                    Signal_ruido = fft(signal_ruidoso, NFFT) / L;


                                                    % ----------- Filtro Rejeita-Banda (Notch) -----------

                                                    % Configuração do filtro rejeita-banda
                                                    f0 = 50; % Frequência central da rede elétrica (50 Hz)
                                                    bw = 1;  % Largura de banda rejeitada (1 Hz aqui é padrão)
                                                    fc1 = f0 - bw / 2; % Frequência de corte inferior
                                                    fc2 = f0 + bw / 2; % Frequência de corte superior

                                                    f = fs * (0:(NFFT/2)-1) / NFFT; % Eixo de frequência

                                                    % Criar filtro Butterworth rejeita-banda
                                                    [b_notch, a_notch] = butter(ordem, [fc1, fc2] / (fs / 2), 'stop');

                                                    % Aplicar o filtro rejeita-banda ao sinal já filtrado no domínio do tempo
                                                    signal_filtrado_notch = filter(b_notch, a_notch, sinal_filtrado_ruido);

                                                    % FFT do sinal após o filtro rejeita-banda
                                                    Sinal_filtrado_notch = fft(signal_filtrado_notch, NFFT) / L;
                                                    %Sinal final no dominio dos tempos
                                                    sinal_filtrado_final = filter(b_notch, a_notch, sinal_filtrado_ruido);
                                                    % ----------- Eixos de Tempo e Frequência -----------

                                                    t = (0:L-1) / fs; % Eixo de tempo
                                                    ylim_frequencias = [0, 0.035]; % Substitua pelos limites do gráfico do meio

                                                    % Sinal ruidoso no domínio das frequências
                                                    figure;
                                                    subplot(2, 1, 1);
                                                    plot(f, 2 * abs(Signal_ruido(1:NFFT/2)), 'b');
                                                    title('Sinal com Ruído Branco no Domínio das Frequências');
                                                    xlabel('Frequência (Hz)');
                                                    ylabel('Amplitude');
                                                    ylim(ylim_frequencias); % Aplicar os mesmos limites
                                                    grid on;

                                                    % Sinal filtrado (passa-banda) no domínio das frequências
                                                    subplot(2, 1, 2);
                                                    plot(f, 2 * abs(Sinal_filtrado_notch(1:NFFT/2)), 'b');
                                                    title('Sinal Filtrado (Notch 50 Hz + Passa-Banda 30-100 Hz) no Domínio das Frequências');
                                                    xlabel('Frequência (Hz)');
                                                    ylabel('Amplitude');
                                                    ylim(ylim_frequencias); % Limite de y para o gráfico de baixo
                                                    grid on;



                                                case 3
                                                    % Voltar
                                                    break;

                                                otherwise
                                                    disp("Opção inválida.");
                                            end
                                        end
                                    case 5
                                        % Voltar ao menu anterior
                                        break;

                                    otherwise
                                        disp("Opção inválida.");
                                end
                            end

                            case 4
                                % Voltar ao menu principal
                                break;

                            otherwise
                                disp("Opção inválida. Tente novamente.");
                        end
                    end
            end

        case 3
            % Define regiões cerebrais e canais associados
            regions = {
                'Frontal', {'EEG Fp1', 'EEG Fp2', 'EEG F3', 'EEG F4', 'EEG F7', 'EEG F8', 'EEG Fz'};
                'Temporal', {'EEG T3', 'EEG T4', 'EEG T5', 'EEG T6'};
                'Central', {'EEG C3', 'EEG C4', 'EEG Cz'};
                'Parietal', {'EEG P3', 'EEG P4', 'EEG Pz'};
                'Occipital', {'EEG O1', 'EEG O2'};
            };

            % Mapeia os índices dos canais para as regiões
            region_signals = struct();
            for i = 1:size(regions, 1)
                region_name = regions{i, 1};
                region_channels = regions{i, 2};
                region_indices = find(ismember(header.Label, region_channels));
                if isempty(region_indices)
                    disp(["Região " region_name " não possui canais no ficheiro."]);
                else
                    region_signals.(region_name) = region_indices;
                end
            end

            % Menu de escolha da região
            while true
                disp("Selecione uma região para visualizar:");
                region_names = fieldnames(region_signals);
                for i = 1:length(region_names)
                    fprintf("%d. %s\n", i, region_names{i});
                end

                region_choice = input("Escolha uma região (número, ou 0 para sair): ");
                if region_choice == 0
                    disp("Encerrando...");
                    break;
                elseif region_choice < 1 || region_choice > length(region_names)
                    disp("Opção inválida. Tente novamente.");
                    continue;
                end

                region_name = region_names{region_choice};
                indices = region_signals.(region_name);
                region_data = data(:, indices);
                sample_rate = header.SampleRate;

                % Cálculo do sinal composto
                composite_signal = mean(region_data, 2);
                time = (0:length(composite_signal) - 1) / sample_rate;

                % Número de subplots
                num_signals = length(indices);
                num_rows = ceil((num_signals + 1) / 2);

                % Submenu para escolher domínio de visualização
                while true
                    disp("\nEscolha o tipo de visualização:");
                    disp("1. Domínio do Tempo");
                    disp("2. Domínio da Frequência");
                    disp("3. Análise por Bandas de Frequência");
                    disp("0. Voltar");

                    submenu_choice = input("Escolha uma opção: ");
                    if submenu_choice == 0
                        break; % Volta ao menu anterior
                    elseif submenu_choice == 1
                        % Visualização no domínio do tempo
                        figure;

                        % Plot do sinal composto
                        subplot(num_rows, 2, 1);
                        plot(time, composite_signal);
                        title("Sinal Composto no Domínio do Tempo");
                        xlabel("Tempo (s)");
                        ylabel("Amplitude");
                        xlim([0 60]);
                        ylim([-40 40]);
                        grid on;

                        % Plot dos sinais individuais
                        for j = 1:num_signals
                            signal = region_data(:, j);
                            time_signal = (0:length(signal) - 1) / sample_rate;

                            subplot(num_rows, 2, j + 1);
                            plot(time_signal, signal);
                            title(["Sinal Individual - " header.Label{indices(j)}]);
                            xlabel("Tempo (s)");
                            ylabel("Amplitude");
                            xlim([0 60]);
                            ylim([-40 40]);
                            grid on;
                        end
                    elseif submenu_choice == 2
                        % Visualização no domínio da frequência
                        figure;

                        % Cálculo da FFT para o sinal composto
                        n = length(composite_signal);
                        f_comp = (0:n-1) * (sample_rate / n);
                        fft_comp_signal = abs(fft(composite_signal)) / n;
                        f_comp = f_comp(1:floor(n/2));
                        fft_comp_signal = fft_comp_signal(1:floor(n/2));

                        % Plot do sinal composto no domínio da frequência
                        subplot(num_rows, 2, 1);
                        plot(f_comp, fft_comp_signal);
                        xlim([0 50]);
                        ylim([0 2]);
                        title("Sinal Composto no Domínio da Frequência");
                        xlabel("Frequência (Hz)");
                        ylabel("Amplitude");
                        grid on;

                        % Plot dos sinais individuais no domínio da frequência
                        for j = 1:num_signals
                            signal = region_data(:, j);
                            n_signal = length(signal);
                            f_signal = (0:n_signal-1) * (sample_rate / n_signal);
                            fft_signal = abs(fft(signal)) / n_signal;
                            f_signal = f_signal(1:floor(n_signal/2));
                            fft_signal = fft_signal(1:floor(n_signal/2));

                            subplot(num_rows, 2, j + 1);
                            plot(f_signal, fft_signal);
                            xlim([0 50]);
                            ylim([0 2]);
                            title(["Sinal Individual - " header.Label{indices(j)}]);
                            xlabel("Frequência (Hz)");
                            ylabel("Amplitude");
                            grid on;
                        end
                    elseif submenu_choice == 3
                        % Análise por bandas de frequência (gráfico de barras)
                        figure;

                        % Definição das bandas de frequência
                        bands = {
                            'Delta', [0.5, 4];
                            'Theta', [4, 8];
                            'Alpha', [8, 13];
                            'Beta', [13, 30];
                            'Gamma', [30, 100];
                        };

                        % FFT do sinal composto
                        n = length(composite_signal);
                        f_comp = (0:n-1) * (sample_rate / n);
                        fft_comp_signal = abs(fft(composite_signal)) / n;
                        f_comp = f_comp(1:floor(n/2));
                        fft_comp_signal = fft_comp_signal(1:floor(n/2));

                        % Cálculo da amplitude média por banda
                        mean_amplitudes = zeros(size(bands, 1), 1);
                        for b = 1:size(bands, 1)
                            band_range = bands{b, 2};
                            band_indices = (f_comp >= band_range(1) & f_comp <= band_range(2));
                            mean_amplitudes(b) = mean(fft_comp_signal(band_indices));
                        end

                        % Gráfico de barras com valores sobre as barras
                        bar(mean_amplitudes);
                        set(gca, 'XTickLabel', bands(:, 1));
                        ylim([0 0.4]); % Limite no eixo Y
                        title(["Amplitude Média por Banda de Frequência - Sinal Composto da Região " region_name]);
                        xlabel("Bandas de Frequência");
                        ylabel("Amplitude Média");
                        grid on;

                        % Adiciona os valores das amplitudes sobre as barras
                        for b = 1:length(mean_amplitudes)
                            text(b, mean_amplitudes(b), sprintf('%.2f', mean_amplitudes(b)), ...
                                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10, 'FontWeight', 'bold');
                        end
                    else
                        disp("Opção inválida. Tente novamente.");
                    end
                end

            end

        case 4
            % Define regiões cerebrais e canais associados
            regions = {
                'Frontal', {'EEG Fp1', 'EEG Fp2', 'EEG F3', 'EEG F4', 'EEG F7', 'EEG F8', 'EEG Fz'};
                'Temporal', {'EEG T3', 'EEG T4', 'EEG T5', 'EEG T6'};
                'Central', {'EEG C3', 'EEG C4', 'EEG Cz'};
                'Parietal', {'EEG P3', 'EEG P4', 'EEG Pz'};
                'Occipital', {'EEG O1', 'EEG O2'};
            };

            % Mapeia os índices dos canais para as regiões
            region_signals = struct();
            for i = 1:size(regions, 1)
                region_name = regions{i, 1};
                region_channels = regions{i, 2};
                region_indices = find(ismember(header.Label, region_channels));
                if isempty(region_indices)
                    disp(["Região " region_name " não possui canais no ficheiro."]);
                else
                    region_signals.(region_name) = region_indices;
                end
            end

            region_names = fieldnames(region_signals);
            num_regions = length(region_names);

            % Definição das bandas de frequência
            bands = {
                'Delta', [0.5, 4];
                'Theta', [4, 8];
                'Alpha', [8, 13];
                'Beta', [13, 30];
                'Gamma', [30, 100];
            };

            % Submenu para selecionar tipo de gráfico
            disp("Selecione o tipo de visualização:");
            disp("1. Gráficos de barras (amplitudes médias por banda)");
            disp("2. Gráficos FFT detalhados para cada região");
            opcao = input("Digite o número da opção desejada: ");

            if opcao == 1
                % Gráficos de barras (amplitudes médias por banda)
                figure;

                % Loop pelas regiões cerebrais
                for r = 1:num_regions
                    region_name = region_names{r};
                    indices = region_signals.(region_name);
                    region_data = data(:, indices);

                    % Cálculo do sinal composto
                    composite_signal = mean(region_data, 2);
                    sample_rate = header.SampleRate;
                    n = length(composite_signal);

                    % FFT do sinal composto
                    f_comp = (0:n-1) * (sample_rate / n);
                    fft_comp_signal = abs(fft(composite_signal)) / n;
                    f_comp = f_comp(1:floor(n/2));
                    fft_comp_signal = fft_comp_signal(1:floor(n/2));

                    % Cálculo da amplitude média por banda
                    mean_amplitudes = zeros(size(bands, 1), 1);
                    for b = 1:size(bands, 1)
                        band_range = bands{b, 2};
                        band_indices = (f_comp >= band_range(1) & f_comp <= band_range(2));
                        mean_amplitudes(b) = mean(fft_comp_signal(band_indices));
                    end

                    % Gráfico de barras para a região atual
                    subplot(ceil(num_regions / 2), 2, r);
                    bar(mean_amplitudes);
                    set(gca, 'XTickLabel', bands(:, 1));
                    ylim([0 0.4]); % Limite no eixo Y
                    title(["Amplitude por Banda - Região " region_name]);
                    xlabel("Bandas de Frequência");
                    ylabel("Amplitude Média");
                    grid on;

                    % Adiciona os valores das amplitudes sobre as barras
                    for b = 1:length(mean_amplitudes)
                        text(b, mean_amplitudes(b), sprintf('%.2f', mean_amplitudes(b)), ...
                            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 8, 'FontWeight', 'bold');
                    end
                end
            elseif opcao == 2
                % Gráficos FFT detalhados para cada região
                figure;

                % Loop pelas regiões cerebrais
                for r = 1:num_regions
                    region_name = region_names{r};
                    indices = region_signals.(region_name);
                    region_data = data(:, indices);

                    % Cálculo do sinal composto
                    composite_signal = mean(region_data, 2);
                    sample_rate = header.SampleRate;
                    n = length(composite_signal);

                    % FFT do sinal composto
                    f_comp = (0:n-1) * (sample_rate / n);
                    fft_comp_signal = abs(fft(composite_signal)) / n;
                    f_comp = f_comp(1:floor(n/2)); % Frequências positivas
                    fft_comp_signal = fft_comp_signal(1:floor(n/2)); % Amplitudes correspondentes

                    % Gráfico FFT para a região atual
                    subplot(ceil(num_regions / 2), 2, r);
                    plot(f_comp, fft_comp_signal, 'LineWidth', 1.5);
                    title(["FFT - Região " region_name]);
                    xlabel("Frequência (Hz)");
                    ylabel("Amplitude");
                    xlim([0 50]); % Foco nas frequências de interesse
                    ylim([0 2]);
                    grid on;

                    % Adicionar anotação de bandas de frequência
                    hold on;
                    for b = 1:size(bands, 1)
                        band_range = bands{b, 2};
                        fill([band_range(1), band_range(2), band_range(2), band_range(1)], ...
                             [0, 0, max(fft_comp_signal), max(fft_comp_signal)] * 0.1, ...
                             'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
                    end
                    hold off;
                end
            else
                disp("Opção inválida. Por favor, execute novamente e selecione 1 ou 2.");
            end


        case 5
            % Sair do programa
            disp("Encerrando o programa...");
            break;

        otherwise
            disp("Opção inválida. Tente novamente.");
    end
end







