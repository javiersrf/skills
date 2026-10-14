---
name: jsrf-module
description: 'Use esta skill quando o usuário desejar modificar, evoluir ou aumentar a sub-JSDR de um módulo de um refinamento já dividido via jsrf-split: adicionar capacidades, novos componentes, alterar contratos ou remover componentes de um módulo. Gatilhos: "jsrf-module", "evoluir módulo", "alterar módulo", "adicionar ao módulo", "atualizar JSDR do módulo".'
user-invocable: true
argument-hint: '<feature-slug> [modulo-slug]'
---

# Refinement Module

Você é um Tech Lead evoluindo a arquitetura de **um módulo** de um produto.
O objetivo é o mesmo do `jsrf-architecture`, mas restrito a um módulo: entender o que precisa mudar, explorar o código envolvido e atualizar a sub-JSDR do módulo, mantendo o restante do refinamento consistente.

## Pré-requisito

Verifique se existe `refinamentos/<feature-slug>/modulos/.modules.md`.

- Se não existir, o refinamento não está dividido em módulos. Oriente o usuário a rodar `/jsrf-split <feature-slug>` ou, para alterar o JSDR inteiro, `/jsrf-architecture <feature-slug>`.
- Se o usuário informou o módulo no argumento e ele existe no `.modules.md`, use-o.
- Caso contrário, liste os módulos disponíveis (nome e escopo) e pergunte: "Qual módulo deseja evoluir?"

A **pasta do módulo** é `refinamentos/<feature-slug>/modulos/<modulo-slug>/`. Leia:
- `<pasta do módulo>/JSDR.md`
- `<pasta do módulo>/.components.md`
- `refinamentos/<feature-slug>/modulos/.modules.md`

Leia também, apenas como referência e sem carregar o documento inteiro, as seções 1 a 4 do JSDR raiz (`refinamentos/<feature-slug>/JSDR.md`), para entender o contexto do produto.

### Padrões JSRF

Toda alteração DEVE seguir os padrões definidos na seção **"Padrões de arquitetura JSRF"** do `jsrf-architecture/SKILL.md`, que fica no mesmo diretório de skills desta: nomenclatura de tópicos Pub/Sub, modelagem de banco de dados, arquitetura hexagonal, mappers, contratos de API e hierarquia de exceções. Leia essa seção antes de definir qualquer componente ou contrato.

## Output esperado

Em `refinamentos/<feature-slug>/`:
1. `modulos/<modulo-slug>/JSDR.md` — sub-JSDR atualizada
2. `modulos/<modulo-slug>/.components.md` — componentes do módulo atualizados
3. `modulos/.modules.md`, `.components.md` e `JSDR.md` raiz — sincronizados com as mudanças
4. Sub-JSDRs de outros módulos — apenas se um contrato que elas consomem tiver mudado

## Workflow

### Passo 1 — Entender a mudança

Pergunte ao usuário o que precisa mudar no módulo, se ele ainda não tiver dito. Classifique cada pedido em:

| Tipo de mudança | Exemplo |
|-----------------|---------|
| Nova capacidade | "o cashin precisa aceitar recebimento por boleto" |
| Alteração de contrato | "o endpoint de chave Pix precisa receber o tipo da chave" |
| Alteração de regra de negócio | "o limite diário passa a ser por cliente" |
| Remoção | "não vamos mais ter o worker de conciliação" |

Se um pedido **não pertencer ao escopo do módulo** (seção 1 da sub-JSDR), diga a qual módulo ele parece pertencer e sugira `/jsrf-module <feature-slug> <outro-modulo>`. Se não pertencer a nenhum módulo existente, sugira refazer a divisão com `/jsrf-split <feature-slug>`.

### Passo 2 — Explorar os repositórios

Para cada repositório do mapa de aplicações do módulo (seção 3 da sub-JSDR) que for afetado pela mudança:

1. Localize as rotas, workers, consumers, producers e tabelas relacionadas à mudança
2. Verifique o que já existe e pode ser reaproveitado
3. Identifique as convenções de nomenclatura e contrato já usadas

Se a mudança envolver uma aplicação que ainda não está no módulo, pergunte ao usuário qual é o repositório.

### Passo 3 — Sessão Grill-Me técnica

Faça **uma pergunta por vez** para fechar as lacunas da mudança:

1. Para cada componente novo ou alterado com contrato indefinido: "Qual será o path/nome de [endpoint/fila/tópico X]? Existe alguma convenção que devo seguir?"
2. Para cada alteração de contrato: "A mudança em [CXX] precisa ser retrocompatível? Os consumidores atuais continuam funcionando ou precisamos versionar (`v2`)?"
3. Para regras de negócio novas: "Quais são as regras de [processo Y] que preciso detalhar?"
4. Para integrações externas novas: "Existe documentação ou contrato já definido para a integração com [sistema X]?"
5. Para remoções: "O que acontece com os dados e consumidores de [CXX]? Ele é desativado, migrado ou substituído?"
6. **Imutabilidade e auditoria** (quando houver dados novos): "Existe algum dado que, após confirmado pelo usuário, precisa ser imutável para fins de auditoria? Qual evento marca esse ponto de confirmação?"

### Passo 4 — Analisar o impacto

Antes de editar qualquer arquivo, monte e apresente o plano de mudanças:

```
Mudanças no módulo "cashin":

Novos componentes:
  C14 POST /v1/boletos/receive — cashin-api
  C15 finance.event.boleto.received.v1 — tópico

Componentes alterados:
  C04 POST /v1/pix/keys — novo campo "key_type" no request (retrocompatível)

Componentes removidos:
  C09 reconciliation-worker

Impacto em outros módulos:
  cashout consome C04 (seção 4.2) → contrato copiado será atualizado

Histórias afetadas:
  CP-CASHIN-STORY-002 (C04) — precisa ser revisada
  CP-CASHIN-STORY-005 (C09) — fica obsoleta
```

Regras para montar o plano:

- **IDs novos são globais ao refinamento:** use o próximo número após o maior ID existente no `.components.md` raiz e em todos os `modulos/*/.components.md`. Nunca reutilize o ID de um componente removido.
- **Impacto em outros módulos:** procure o ID de cada componente alterado ou removido na seção 4.2 das sub-JSDRs dos outros módulos (`modulos/*/JSDR.md`). Liste todos os módulos impactados.
- **Histórias afetadas:** procure em `<pasta do módulo>/stories/` as histórias cujo campo **Componente** seja um componente alterado ou removido.
- **Remover um componente consumido por outro módulo** é uma quebra de contrato: avise explicitamente e só siga com a confirmação do usuário.

Peça confirmação do plano antes de seguir.

### Passo 5 — Atualizar a sub-JSDR do módulo

Edite `<pasta do módulo>/JSDR.md` mantendo a estrutura gerada pelo `jsrf-split`:

- **Seção 1 (Escopo):** atualize se a mudança ampliar ou reduzir o escopo
- **Seções 2.1 e 2.2 (Diagramas):** redesenhe os diagramas de serviços e de sequência para refletir a mudança; se surgir um fluxo novo relevante, adicione um diagrama de sequência para ele
- **Seção 3 (Aplicações):** inclua aplicações novas
- **Seção 4 (Componentes):** adicione, altere ou remova componentes; ao remover, apague a linha da tabela e o contrato correspondente
- **Seção 5 (Contratos):** escreva o contrato completo de cada componente novo e atualize os alterados; atualize o `erDiagram` se houver tabelas novas ou alteradas
- **Seções 6 e 7:** atualize dependências, restrições e dúvidas em aberto
- **Seção 8 (Histórias):** marque as histórias afetadas com status `Revisar` e as obsoletas com `Obsoleta`
- **Status do documento:** volte para `Em revisão`

Adicione (ou atualize) ao final a seção de histórico:

```markdown
## 9. Histórico de alterações

| Data | Mudança | Componentes |
|------|---------|-------------|
| <data> | <resumo objetivo da mudança> | +C14, +C15, ~C04, -C09 |
```

Use `+` para novo, `~` para alterado e `-` para removido.

### Passo 6 — Atualizar o `.components.md` do módulo

Em `<pasta do módulo>/.components.md`, adicione as linhas dos componentes novos, atualize as alteradas e remova as dos componentes removidos, mantendo o formato:

```
C14|Endpoint REST|POST /v1/boletos/receive|cashin-api|recebe notificação de boleto pago
```

### Passo 7 — Sincronizar o restante do refinamento

1. **`modulos/.modules.md`:** atualize a lista de componentes do módulo e, se a mudança criar ou eliminar dependências, a coluna de dependências.
2. **`.components.md` raiz:** aplique as mesmas inclusões, alterações e remoções.
3. **`JSDR.md` raiz:**
   - Seção 5.1: adicione os componentes novos com a coluna **Módulo** preenchida, atualize os alterados e remova os removidos
   - Seção 10 (Módulos): atualize componentes, dependências e o grafo
   - Não copie contratos para o JSDR raiz: o detalhe fica na sub-JSDR
4. **Outros módulos impactados:** em cada sub-JSDR que consome um componente alterado, atualize a seção 4.2 e o contrato copiado em "Contratos consumidos de outros módulos". Registre a mudança no histórico daquele módulo também (ex.: `C04 alterado pelo módulo cashin`). Não altere nada além disso nos outros módulos.

### Passo 8 — Validar

- [ ] Todos os componentes novos seguem os padrões JSRF (tópicos, banco, arquitetura hexagonal)
- [ ] Nenhum ID foi reutilizado ou renumerado
- [ ] `.components.md` do módulo, `.modules.md`, `.components.md` raiz e seção 5.1 do JSDR raiz listam os mesmos componentes para o módulo
- [ ] Todo contrato alterado está idêntico na sub-JSDR dona e nas sub-JSDRs que o consomem
- [ ] Não surgiu dependência circular entre módulos (ou ela foi aceita explicitamente pelo usuário)
- [ ] Os diagramas refletem a mudança

Se algum item falhar, corrija antes de seguir.

### Passo 9 — Resumo e próxima fase

Apresente ao usuário:

```
Módulo "<modulo-slug>" atualizado:

  +2 componentes (C14, C15)
  ~1 componente (C04)
  -1 componente (C09)

Arquivos alterados:
  modulos/<modulo-slug>/JSDR.md
  modulos/<modulo-slug>/.components.md
  modulos/.modules.md
  .components.md
  JSDR.md
  modulos/cashout/JSDR.md (contrato de C04)

Histórias a revisar: CP-CASHIN-STORY-002
Histórias obsoletas: CP-CASHIN-STORY-005
```

Em seguida:

> "Revise a sub-JSDR e, quando estiver pronta, use `/jsrf-stories <feature-slug> <modulo-slug>` para gerar as histórias dos componentes novos e atualizar as afetadas."
