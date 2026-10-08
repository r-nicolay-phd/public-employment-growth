# Registro de decisões

Cada entrada traz: o que foi decidido, por quê e qual era a alternativa. Ordem cronológica.

## Ambiente

**D01. Stata 17 MP como linguagem principal, no lugar de R.** O orientador pediu que tudo rode em Stata. A especificação previa R, com Stata só onde não houvesse equivalente. Mapeamento usado: `fixest` → `reghdfe`/`areg`/`xtscc`; `pdynmc`/`plm` → `xtabond2` (com conferência por `xtdpdgmm`); `xtdpdbc` (Breitung, Kripfganz e Hayakawa, 2022) para efeitos fixos com correção de viés; `xthenreg` (Seo e Shin, 2016) e `xthreg` (Hansen, 1999) para limiares; `interflex` (versão Stata de Hainmueller, Mummolo e Xu) para o diagnóstico de interação; `bma` (De Luca e Magnus, 2011) para média bayesiana de modelos; `xtdcce2` para CCE de grupo médio; `weakiv`/`ivreg2` para Anderson-Rubin; `esttab` (tabelas `.tex`) e `putdocx` (tabelas `.docx`). Alternativa descartada: rodar em R e só replicar em Stata, o que duplicaria o código.

**D02. Python só para baixar dados e ler o `.wf1`.** As APIs (Banco Mundial, FMI SDMX 3.0, ILOSTAT) devolvem JSON/CSV paginados que o Stata lê mal; o `.wf1` é binário. Python não faz nenhuma limpeza, construção de variável ou estimação: o script só grava arquivos brutos em `data/raw/`. Toda transformação está nos `.do`. Alternativa: `import delimited` com URL direto no Stata, viável para algumas fontes mas frágil para APIs paginadas.

**D03. Semente fixa** `20261007` (`set seed` e `set sortseed`) em `code/00_setup.do`. Pacotes de usuário e versões registrados em `docs/README.md`.

## Fase 0

**D04. Erro-padrão de referência da Fase 0.** O coeficiente −0,865 é reproduzido exatamente. O erro-padrão 0,269 é obtido com `areg ..., absorb(país) vce(cluster país)`, que conta os efeitos fixos de país nos graus de liberdade da correção de amostra pequena. Com `reghdfe`/`xtreg, fe` (que tratam o efeito fixo como aninhado no cluster) o erro-padrão é 0,261. A diferença é só a correção de graus de liberdade (fator √[(N−1)/(N−K)]). No artigo usamos `reghdfe`, que é o padrão atual e o mesmo de `fixest` com `ssc(fixef.K = "nested")`; registramos as duas versões no log da Fase 0.
