---
name: jsrf-jsdr
description: >-
  Skill voltada para geração de JSDR (Justificativa e Solução de Desenho de Requisitos) detalhada e completa de novas funcionalidades, arquiteturas ou refatorações do ecossistema Jeitto. Utiliza o template oficial em templates/template_JSDR.md e engloba diagramas Mermaid (C4 Model Context/Container, Diagramas de Sequência e DER), mapeamento de dados, fluxos síncronos e assíncronos, estratégias de resiliência, observabilidade e contratos completos de API (REST) e Mensageria (Kafka/SQS). Solicita e processa os inputs: caminho dos repositórios envolvidos, descrição da feature, objetivo da feature e impactos esperados. Salva obrigatoriamente o resultado final em refinamentos/<feature-slug>/JSDR.md.
---

# Skill: jsrf-jsdr

Esta skill instrui o agente na elaboração de um **JSDR (Justificativa e Solução de Desenho de Requisitos)** técnico, exaustivo e pronto para aprovação de engenharia e arquitetura no padrão Jeitto.

---

## 1. Coleta de Inputs Obrigatórios

Ao ser ativada, a skill deve garantir que possui as seguintes informações essenciais. Caso o usuário não tenha fornecido alguma delas na mensagem inicial, o agente deve solicitar ou confirmar antes/durante o detalhamento:

1. **Caminho dos Repositórios Envolvidos na JSDR**:
   - Caminhos absolutos ou relativos dos repositórios/microserviços afetados (ex: `services/payment-gateway`, `services/user-service`).
   - *Uso*: O agente deve inspecionar o código-fonte, schemas, rotas e arquivos existentes para garantir que a arquitetura **As-Is** e os ajustes **To-Be** sejam fiéis à realidade da aplicação.
2. **Descrição da Feature**:
   - O detalhamento funcional do que está sendo construído ou alterado.
   - *Uso*: Alimenta a **Visão geral da solução** (Seção 1) e os **Casos de Uso / Fluxos de Negócio** (Seção 5).
3. **Objetivo da Feature**:
   - As metas de negócio e metas técnicas que motivam a iniciativa.
   - *Uso*: Preenche os **Objetivos** (Seção 1) e a **Contextualização** (Seção 2).
4. **Impactos Esperados**:
   - Efeitos colaterais, mudanças em contratos existentes, volume de dados, carga de infraestrutura, alterações de domínio ou migração de processos.
   - *Uso*: Direciona as **Mudanças Principais** (Seção 4), **Resiliência e Fallback** (Seção 5) e **Guardrails e Alertas** (Seção 6).

---

## 2. Destino do Arquivo de Output

O resultado final do JSDR gerado por esta skill **deve ser obrigatoriamente salvo** no seguinte caminho:

```text
refinamentos/<feature-slug>/JSDR.md
```

- **`<feature-slug>`**: Nome legível da feature em letras minúsculas, separado por hífens (kebab-case).
  - *Exemplo*: Se a feature for "Pix Parcelado", o caminho de salvamento será:  
    `refinamentos/pix-parcelado/JSDR.md` (`refinamentos/pix-parcelado/JSDR.md`)

---

## 3. Princípios Fundamentais do JSDR Jeitto

Ao gerar um JSDR usando esta skill, você deve garantir as seguintes premissas:
1. **Completude sem Placeholders**: Nunca deixe seções com "TBD", "A definir" ou placeholders vazios. Se algum detalhe técnico não for fornecido explicitamente pelo usuário ou encontrado nos repositórios, infira a melhor prática de engenharia com base nos padrões do Jeitto (microserviços resilientes, arquitetura orientada a eventos, tracing distribuído, idempotência).
2. **Inspeção de Código-Fonte**: Se o caminho dos repositórios foi fornecido, navegue e analise os arquivos do projeto para extrair tabelas reais, rotas existentes, modelos e tópicos de mensageria em uso.
3. **Uso Rigoroso de Mermaid**: Todos os modelos de arquitetura (C4 Model), fluxos de processo (Sequence) e modelos de dados (DER) devem ser representados como diagramas Mermaid válidos e bem formatados.
4. **Contratos Precisos**: Toda comunicação entre sistemas deve ter contrato explicitado (código HTTP, headers, payloads JSON com tipos e exemplos, tópicos de mensageria, chave de particionamento e garantias de entrega/idempotência).
5. **Resiliência e Observabilidade**: Todo desenho deve cobrir estratégias de fallback, circuit breaker, throttling, logs estruturados com correlation IDs e métricas/alertas de negócio.

---

## 4. Fluxo de Execução da Skill

Sempre que acionado para gerar um JSDR, siga as etapas abaixo:

### Passo 1: Leitura do Template
Leia o arquivo de template oficial localizado em [`templates/template_JSDR.md`](../../../templates/template_JSDR.md). Mantenha a estrutura de seções exatamente como definida no template:
1. **Resumo Executivo**
2. **Contexto do Projeto**
3. **Arquitetura Atual (As-Is)**
4. **Arquitetura Proposta (To-Be)**
5. **Fluxos de Negócio**
6. **Rastreabilidade, Observabilidade e Monitoria**
7. **Modelo de Dados**
8. **Contratos de API e Mensageria**

### Passo 2: Análise e Mapeamento dos Inputs
Combine as informações recebidas (**Caminho dos Repositórios**, **Descrição da Feature**, **Objetivo** e **Impactos Esperados**) e, se repositórios foram indicados, explore a estrutura de pastas e código existente. Identifique:
- O problema de negócio/técnico atual (As-Is).
- Os sistemas, microserviços e bancos de dados envolvidos.
- Os atores do sistema (usuários, parceiros, sistemas legados, cronjobs/workers).
- O fluxo proposto (To-Be) com padrões de integração (REST vs Kafka/SQS).
- As entidades de banco de dados a serem criadas ou alteradas.

### Passo 3: Construção dos Diagramas Mermaid
Gere diagramas Mermaid sintaticamente válidos e limpos para:
- **C4 Context (Level 1)**: As-Is e To-Be (Usar sintaxe `graph TD` ou `C4Context`).
- **C4 Container (Level 2)**: As-Is e To-Be detalhando microserviços, APIs, Workers, Filas/Tópicos e Datastores.
- **Diagrama de Sequência**: `sequenceDiagram` ilustrando as interações síncronas/assíncronas passo a passo entre os atores e sistemas.
- **Modelo ER (DER)**: `erDiagram` ilustrando tabelas, chaves primárias/estrangeiras e relacionamentos (1:N, N:M).

> ⚠️ **Atenção aos Rótulos Mermaid**: Coloque aspas em torno de textos com caracteres especiais ou parênteses em rótulos Mermaid (ex: `node["Serviço A (REST)"]`).

### Passo 4: Detalhamento do Modelo de Dados
Para cada tabela envolvida:
- Especifique a estratégia de ciclo de vida (ex: *append-only*, mutável, chave-valor, cache em Redis).
- Crie uma tabela Markdown contendo: `Nome do Campo`, `Tipo`, `Restrições` (PK, FK, NOT NULL, UNIQUE, DEFAULT), `Tamanho` e `Descrição detalhada`.

### Passo 5: Elaboração dos Contratos de API e Mensageria
- **Endpoints REST**:
  - Método e URI completa (ex: `POST /v1/transactions/process`).
  - Headers exigidos (ex: `Authorization`, `X-Correlation-ID`, `X-Idempotency-Key`).
  - Payload de requisição (JSON schema / exemplo).
  - Tabela de respostas (200/201, 400, 401, 422, 500) com estrutura de payload de erro padronizada.
- **Tópicos e Eventos de Mensageria**:
  - Nome do tópico/fila (ex: `jeitto.payments.v1.transaction-processed`).
  - Padrão (Pub/Sub, Point-to-Point).
  - Produtor, Consumidores e Chave de Particionamento (*Partition Key*).
  - Payload JSON do evento com metadados de auditoria (`event_id`, `event_type`, `timestamp`, `correlation_id`, `data`).

### Passo 6: Definição do Plano de Rastreabilidade & Guardrails
- **Tracing**: Garantir a propagação do `X-Correlation-ID` entre todos os saltos de rede (APIs e Mensageria).
- **Logs Estruturados**: Especificar campos obrigatórios no log JSON (ex: `customer_id`, `rule_id`, `execution_time_ms`, `decision_result`).
- **Alertas**: Definir gatilhos para SLOs/SLA com base nos **Impactos Esperados** (ex: taxa de erro > 1% em 5 min, p99 latency > 800ms, DLQ depth > 100 mensagens).

### Passo 7: Salvando o Arquivo Final
- Calcule o `<feature-slug>` a partir do nome/descrição da feature em minúsculas separadas por hífen.
- Crie o diretório `refinamentos/<feature-slug>/` (se não existir).
- Escreva todo o documento gerado em `refinamentos/<feature-slug>/JSDR.md`.

---

## 5. Checklist de Validação do JSDR Gerado

Antes de entregar o JSDR ao usuário, execute este checklist:
- [ ] Foram considerados ou solicitados os inputs: *Caminhos dos Repositórios*, *Descrição*, *Objetivo* e *Impactos Esperados*.
- [ ] Todas as 8 seções do template `templates/template_JSDR.md` foram preenchidas.
- [ ] Os diagramas Mermaid estão presentes e sem erros de sintaxe.
- [ ] Os diagramas C4 (Contexto e Container) cobrem o estado As-Is e To-Be.
- [ ] O modelo de dados está mapeado em `erDiagram` e em tabelas de dicionário de dados detalhadas.
- [ ] Todos os endpoints REST e eventos de mensageria possuem contratos com JSON de exemplo completos.
- [ ] Mecanismos de resiliência (fallback, idempotência, dead-letter queues) foram detalhados.
- [ ] Não há textos genéricos ou marcadores de rascunho pendentes.
- [ ] O arquivo final foi salvo no caminho correto: `refinamentos/<feature-slug>/JSDR.md`.
