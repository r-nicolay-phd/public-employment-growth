# Log das novas estimações para a Kyklos (parecer simulado)

Execução de `PROMPT_Claude_Code_Kyklos_novas_estimacoes.md` em 13/11/2026, Stata 17 (StataMP, `C:\Program Files\Stata17\StataMP-64.exe`, modo batch), na pasta `Estimações`.

## Registro antes de estimar

- **Adendo.** `docs/plan_addendum_kyklos.md`, escrito antes de qualquer estimação nova e commitado sozinho com a mensagem pedida: commit `3faa1ea65b7a1827107b30169962cf81732260ca`, 13/11/2026 17:55:25 (−0300), branch `revisao-ejpe`.
- **O que o adendo fixa:**
  - as especificações, amostras e inferências de cada bloco;
  - as regras de decisão do Bloco 11, sem alteração;
  - as definições operacionais que o prompt deixava abertas, listadas abaixo.
- **Commits.** As demais alterações do projeto continuam sem commit; o commit do adendo incluiu só esse arquivo.

## Definições registradas no adendo (opções conservadoras)

- **Bloco 1, padrão reproduzido:** o coeficiente anual do mesmo ano é negativo e significativo a 5% **tanto** no FE **quanto** no GMM (coluna 1, 1986–2004).
- **Bloco 1, colapso:** queda de pelo menos 50% e p ≥ 0,05 no GMM, com a medida defasada ou com a medida sobre o PIB tendencial. O título só se mantém se, além disso, o coeficiente defasado não for significativo.
- **Bloco 2, condição de sinal:** exige que o IC de 95% do viés (mesmo ano − defasada, bootstrap) concorde com o sinal previsto pela elasticidade nominal. Se o IC da elasticidade contém 1, o viés previsto é zero e o IC do viés precisa conter zero.
- **Bloco 4, H2 no texto principal:** usa o p de bootstrap do salário relativo no modelo em log da amostra estrita.
- **Bloco 5, jackknife:** usa o erro de Driscoll-Kraay da amostra inteira.
- **Bloco 5, choque purgado:** como é um regressor gerado, os erros vêm de bootstrap por blocos de país que refaz a purga em cada replicação.
- **Bloco 8, mecanismo:** condição (a), (b) ou (c) significativa a 5%. Na regra, a condição (a) conta com o consumo e o WGI, a medida das réplicas.

## Decisões durante a execução

- **Mollick e Cabral (2011).** O PDF está em `Consensus/mollick2011.pdf` e foi lido; o prompt previa uma réplica aproximada apenas se o PDF faltasse. A especificação publicada foi extraída com as páginas:
  - amostra e dados: p. 124–127;
  - modelo: eq. (2), p. 129;
  - estimador e instrumentos: p. 130;
  - coeficientes: Tabela 2, p. 131, e Tabela 3, p. 134.
- **Rótulo da réplica.** A tabela continua marcada "approximate replication": safra atual do WDI, sem as medidas de ativos externos (IFI, GEQ).
- **Coeficiente quinquenal publicado.** É maior em valor absoluto que o anual; o que muda é a significância. Isso consta da nota.
- **Investimento público (Bloco 2).** Série bruta do IMF ICSD (P51G_S13), mais próxima de "formação bruta de capital fixo do governo geral" que o investimento líquido das GFS.
- **Choque purgado (Bloco 5).** "Por país" foi implementado como inclinações específicas por país no crescimento corrente e em duas defasagens, com efeitos fixos de país e ano (`absorb(id year id#c.g ...)`).
- **Romano-Wolf.** No Bloco 4, usa os mesmos 999 sorteios de países da Tabela S13 (`rw_draws.dta`); a família registrada reproduz o p de 0,002. No Bloco 5, foi feito só para o choque (a), como pede o texto do bloco.
- **Bloco 6, simulação.**
  - A série sintética registrada (passeio aleatório em ln W desde o primeiro ano do país) gera uma razão folha/PIB não estacionária. Na verificação de uma replicação, o AR(1) é ≈ 1,01, o DP dentro do país é cerca de quatro vezes o observado e há valores de até ~78% do PIB.
  - A regra registrada foi aplicada sem ajuste.
  - Foi acrescentado, **depois de ver esse resultado**, um diagnóstico pós-hoc fora da regra (`06b`, painel E da Tabela S24): a mesma hipótese nula, com a série ancorada na razão observada do ano anterior.
  - Uma primeira tentativa de diagnóstico, um AR(1) por país, também derivava (AR ≈ 1,03) e foi substituída pela versão ancorada.
  - Os dois aparecem declarados como pós-hoc na tabela e no memorando.
- **Bloco 10.**
  - **Recessões:** usam o sinal do hiato de Hamilton em t − 1 (log do PIB menos tendência).
  - **Correlação das tendências:** calculada nas taxas de crescimento (tendência × PIB corrente), porque em nível as duas correlações são ≈ 1.
  - **Quebras do GFSM:** os arquivos das GFS não informam a base metodológica (colunas COUNTRY, SECTOR, …, STATUS), então a verificação não foi feita.
  - **Tabela S28:** foi criada para as verificações do Bloco 10, que o prompt não numerava.
- **Regeneração das tabelas antigas (Bloco 10.6):**
  - nota da Tabela A3 corrigida: painéis A–C usam o crescimento do PIB per capita, e o painel D, o do PIB real;
  - painel C da A3 passa a citar "Mollick and Vianna (2024)";
  - a A5 lê do registro coeficientes antes arredondados em 4 casas, e o duplo arredondamento produzia diferenças de 0,001 (0,169 × 0,170; −0,058 × −0,059). As chaves usadas na A5 passaram a ser gravadas com 8 casas (`02_timing`, `04_cobertura`, `07_estrutural`, `12_inferencia`);
  - a remissão "Figure 9" na A5 vira "Figure 4" pela renumeração Kyklos (`kyklos_numbering.py`);
  - o `master.do` da revisão foi rodado de novo dentro da rodada final (`KYK_REBUILD = 1`).
- **Backups.** Os do-files de `code/revisao` alterados foram copiados antes para `backup_kyklos/code/revisao_estimacoes/`.
- **Rodadas.** Cada bloco foi testado isoladamente. Erros encontrados e corrigidos:
  - sintaxe do `missing()`;
  - `kboot` com `=`;
  - aspas nos rótulos de país;
  - nomes truncados (`str6`);
  - campos de tabela apagados pelo `rv_fmt` (programa `rclass`);
  - `e(N)` perdido depois do `boottest`.
  
  A simulação de teste em execução foi interrompida para rodar tudo do zero na rodada final.

## Rodada final e verificação

- **Rodada.** `code/kyklos/master_kyklos.do` rodou do início ao fim numa sessão limpa do Stata, com `KYK_REBUILD = 1`: primeiro o `master.do` da revisão, depois os 12 do-files Kyklos. Não houve nenhum erro. Tempo total: 6.409 s, sendo 2.293 s da revisão e 4.116 s dos blocos Kyklos. Os mais longos foram `06_simulacao` (1.739 s), `05_lp_predeterminado` (1.145 s) e `01_mollick_cabral` (506 s).
- **Reprodução.** Os números da rodada final são idênticos aos dos testes de cada bloco (sementes fixas).
- **Memorando.** Todos os números citados no `output/kyklos/RESULTS_MEMO.md` foram conferidos contra os `.csv` de `output/kyklos/tables/` e o registro `data/interim/kyklos/kv.csv`.
- **Rótulos internos.** Nenhum rótulo visível contém "draft", "rascunho", "rodada", "OPRA" ou "MV (" nas tabelas (`.docx`, `.tex`) e figuras (PDF, EPS) de `output/kyklos/` e `replication_kyklos/output/`. Só o comentário de cabeçalho dos `.tex` citava `code/revisao`; foi corrigido nos arquivos e na rotina (`code/revisao/00_setup.do`, linha 360).
- **Notas das tabelas novas.** Todas trazem amostra, efeitos fixos, controles, tipo de erro-padrão e número de replicações. A exceção é a S28, que não usa bootstrap.
- **Figura S7.** Na primeira rodada, o coeficiente observado ficava fora do eixo do painel (a); o eixo foi ampliado e o `06c` rodou de novo.
- **Pacote de replicação:**
  - código da revisão refeito a partir de `code/revisao`;
  - `code/kyklos/` com caminhos ajustados (`data/analysis/intermediate`, `output/generated/kyklos`, `code/config.do`);
  - adendo em `docs/`;
  - mapeamento das Tabelas S19–S28 e das Figuras S5–S8 no README;
  - `kyklos_numbering.py` copiando as exibições novas;
  - `deviations_from_plan.md` com a seção "post-plan, pre-registered in addendum 3faa1ea" e o diagnóstico pós-hoc à parte.
  - A versão do `code/kyklos` adaptada ao pacote não foi rodada dentro do pacote; só os caminhos mudaram em relação ao código executado.
- **Commits.** Nenhum além do commit do adendo.
