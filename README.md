# EEG Durante Tarefas de Aritmética Mental

Projeto da UC de Processamento de Sinal Biológico (PSBIO), Licenciatura em Engenharia Biomédica, ISEP.

## Conceito

Estudo da atividade cerebral durante o cálculo mental a partir de sinais de eletroencefalografia (EEG), em repouso e durante uma tarefa de subtração em série. Os sinais são filtrados e analisados no domínio da frequência, por bandas (delta, theta, alfa, beta e gama) e por regiões cerebrais (frontal, temporal, central, parietal e occipital), para comparar o comportamento de sujeitos com pontuação alta e baixa na tarefa.

## Aplicação

Um script com menu interativo permite explorar qualquer ficheiro EDF da base de dados:

1. **Listar canais** do ficheiro.
2. **Sinal individual** de um canal, no domínio do tempo e da frequência, com filtragem:
   - passa-banda Butterworth de ordem 5 (30–100 Hz, banda gama);
   - rejeita-banda Butterworth de ordem 5 (50 Hz, interferência da rede elétrica);
   - os dois filtros em cascata, com comparação com o sinal não filtrado (tempo e frequência).
3. **Sinal composto por região** (média dos canais da região): domínio do tempo, domínio da frequência e amplitude média por banda.
4. **Análise por bandas de todas as regiões**, em gráficos de barras ou em espetros FFT.

Na filtragem, é adicionado ruído branco simulado ao sinal para demonstrar o efeito do filtro passa-banda.

Principais conclusões do relatório (8 sujeitos, 4 de pontuação alta e 4 de baixa, região frontal):

- Todas as bandas aumentam durante a tarefa, com maior crescimento de delta e theta nos sujeitos de pontuação alta.
- Os sujeitos de pontuação alta apresentam menor crescimento de alfa e beta.
- Na banda gama (30–100 Hz), os sujeitos de pontuação alta têm um espetro mais homogéneo, e os de pontuação baixa picos mais elevados e irregulares.

Trata-se de um estudo exploratório, com uma amostra pequena.

## Diretórios

```
.
├── 2_LastVersionMenuEEGFiltered.m   # Script principal (menu interativo)
├── edfread.m                        # Leitor de EDF alternativo (não usado pelo menu)
└── A6-Relatório_Final_PSBIO_.pdf    # Relatório
```

## Dados

Os dados são da base **EEG During Mental Arithmetic Tasks** (PhysioNet), com 36 sujeitos e 2 ficheiros por sujeito: `SubjectXY_1.edf` (repouso) e `SubjectXY_2.edf` (tarefa). Não estão incluídos neste repositório. Podem ser descarregados em [physionet.org/content/eegmat](https://physionet.org/content/eegmat/).

Referência: Zyma I. et al., *Electroencephalograms during Mental Arithmetic Task Performance*, Data, 2019, 4(1):14, [doi:10.3390/data4010014](https://doi.org/10.3390/data4010014).

## Como executar

Requer **GNU Octave** com os pacotes `signal` e `biosig` (o script usa `pkg load` e `sload`, por isso não corre em MATLAB sem alterações).

```octave
pkg install -forge signal
pkg install -forge biosig
```

1. Abrir o Octave na pasta do projeto e executar `2_LastVersionMenuEEGFiltered`.
2. Selecionar um ficheiro `.edf` na janela que abre.
3. Escolher as opções no menu da linha de comandos.

## Autores

Guilherme Pereira, Rita Portugal e João Melo  
Licenciatura em Engenharia Biomédica, ISEP, Porto, Portugal

Docentes: Luís Coelho e Joaquim Alves (Departamento de Física, ISEP)
