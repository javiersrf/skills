---
name: jsrf-check
description: >-
  Skill voltada para validação minuciosa e auditoria técnica de histórias por um Dev Especialista. Recebe como input o feature-slug do refinamento, opcionalmente o módulo (quando o refinamento foi dividido via jsrf-split) e a lista de histórias (ou valida todas as histórias da pasta stories/ do refinamento ou do módulo). Inspeciona o conteúdo de cada história, cruza os contratos REST, Kafka/SQS, entidades de banco e regras de negócio diretamente com o código-fonte dos repositórios envolvidos, e gera um relatório detalhado em CHECK_REPORT.md apontando inconsistências, lacunas e readiness para desenvolvimento.
---

# Skill: jsrf-check

Esta skill atua como um **Desenvolvedor Especialista / Tech Lead auditor**. Seu objetivo é entrar em cada história técnica gerada pelo refinamento, validar sua consistência interna e **cruzar as especificações diretamente com o código-fonte existente nos repositórios envolvidos**, identificando divergências, contratos quebrados ou pendências antes do início da codificação.

---

## 1. Inputs da Skill

1. **`feature-slug`** (*Obrigatório*):
   - O identificador do refinamento (ex: `pix-parcelado`, `motor-calculo-limites`).
2. **`modulo-slug`** (*Opcional*):
   - O módulo a auditar, quando o refinamento foi dividido via `/jsrf-split` (ex: `cashin`). Ver "Detecção de módulos" abaixo.
3. **Lista de Histórias / Stories** (*Opcional*):
   - Lista específica de IDs (ex: `STORY-001, STORY-002`) ou informe "todas" para auditar todo o diretório `<pasta base>/stories/`.
4. **Caminho dos Repositórios Envolvidos** (*Opcional/Carregado do JSDR*):
   - Os repositórios mapeados no `JSDR.md` ou `.components.md` da pasta base para inspeção de código.

### Detecção de módulos

Antes de auditar, verifique se existe `refinamentos/<feature-slug>/modulos/.modules.md`.

- **Sem módulos:** a **pasta base** é `refinamentos/<feature-slug>/`.
- **Com módulos:** a skill atua dentro de um módulo.
  1. Se o usuário informou o módulo e ele existe no `.modules.md`, use-o.
  2. Caso contrário, liste os módulos (nome, escopo e quantidade de histórias em `modulos/<modulo-slug>/stories/`) e pergunte: "Este refinamento está dividido em módulos. Qual módulo deseja auditar?" Aceite também "todos": nesse caso, repita a auditoria para cada módulo que tiver histórias, gerando um relatório por módulo.
  3. A **pasta base** passa a ser `refinamentos/<feature-slug>/modulos/<modulo-slug>/`.

Em modo módulo, use a sub-JSDR do módulo como referência e, além das validações da seção 2, confira se as histórias respeitam as fronteiras do módulo:
- Nenhuma história implementa um componente que pertence a outro módulo
- As dependências de outros módulos usadas nas histórias estão listadas na seção 4.2 da sub-JSDR, com contrato idêntico ao do módulo dono (`modulos/<outro-modulo>/JSDR.md`)

---

## 2. O que o Dev Especialista Audita

O agente inspeciona minuciosamente cada história (`<pasta base>/stories/*-STORY-00X.md`) e confronta com o código-fonte real do projeto:

### 1. **Consistência de Contratos de API (REST)**
- O endpoint, método HTTP e URI definidos na história existem no repositório?
- Os DTOs de entrada e saída correspondem aos tipos e structs no código Go/Java/Node/TypeScript?
- Os status HTTP de sucesso e erro estão alinhados com o padrão Jeitto (`400 BAD_REQUEST`, `422 UNPROCESSABLE_ENTITY`, `500 INTERNAL_SERVER_ERROR`)?

### 2. **Consistência de Mensageria (Pub/Sub & SQS)**
- Os nomes dos tópicos seguem estritamente a convenção Jeitto:  
  `<domain>.<business-domain>.<message-type>.<entity>.<action>.v1`  
  *(ex: `finance.command.payment.process.v1`)*
- O payload do evento definido na história possui os campos obrigatórios do envelope padrão (`event_id`, `timestamp`, `producer`, `data`)?

### 3. **Consistência do Modelo de Dados (PostgreSQL)**
- As tabelas e colunas citadas na história existem nas migrations/DDL do repositório?
- Os tipos de dados (`UUID`, `DECIMAL(15,2)`, `TIMESTAMP WITH TIME ZONE`) e restrições de nulidade conferem com o schema físico?

### 4. **Prontidão de Desenvolvimento & Quality Gates (Readiness)**
- A história descreve claramente o fluxo síncrono/assíncrono?
- Há plano de testes detalhado (Testes Unitários, Testes de Integração, Cobertura de Mutantes)?
- Há dependências bloqueantes ou componentes anteriores não finalizados?

---

## 3. Arquivo Gerado (`CHECK_REPORT.md`)

A skill gera e salva obrigatoriamente o relatório de auditoria técnica em:
`<pasta base>/CHECK_REPORT.md`

Ou seja, `refinamentos/<feature-slug>/CHECK_REPORT.md` sem módulos, ou `refinamentos/<feature-slug>/modulos/<modulo-slug>/CHECK_REPORT.md` em modo módulo.

### Estrutura do `CHECK_REPORT.md`:

```markdown
# 🔍 Relatório de Validação Técnica (jsrf-check)

**Feature Slug:** `<feature-slug>`  
**Módulo:** `<modulo-slug>` (omita esta linha se o refinamento não tiver módulos)  
**Data da Auditoria:** <DD/MM/AAAA HH:mm>  
**Avaliador:** Dev Especialista AI (jsrf-check)  
**Status Geral:** 🟢 PRONTO PARA DESENVOLVIMENTO / 🟡 ATENÇÃO REQUERIDA / 🔴 REPROVADO

---

## 📊 Resumo da Auditoria

| História | Componente | Status | Inconsistências Encontradas |
| :--- | :--- | :--- | :--- |
| `STORY-001` | `POST /v1/checkout/sessions` | 🟢 Aprovado | Nenhuma divergência com o repositório. |
| `STORY-002` | `payment-process-worker` | 🟡 Ajuste Necessário | Tópico Kafka com divergência na convenção de nomes. |

---

## 📋 Detalhamento da Validação por História

### 📄 STORY-001: <Título da História>
- **Análise do Código Existente:** Verificado repositório `services/payment-gateway`.
- **Contrato REST:** ✅ DTOs compatíveis com `pkg/dto/checkout.go`.
- **Banco de Dados:** ✅ Tabela `checkout_sessions` validada na migration `003_create_checkout.sql`.
- **Qualidade & Testes:** ✅ Quality gates cobrem 100% de cenários de erro.

### 📄 STORY-002: <Título da História>
- **Análise do Código Existente:** Verificado repositório `services/payment-checkout-api`.
- **Mensageria:** ⚠️ **Atenção**: O tópico `payment.process` no código deve ser renomeado para a convenção Jeitto `finance.command.payment.process.v1`.
- **Recomendação:** Ajustar a constante `TopicPaymentProcess` em `config/kafka.go`.

---

## 🛠️ Ações Recomendadas Antes do Início da Sprint
1. Ajustar convenção do tópico em `STORY-002`.
2. Validar limite de caracteres no campo `external_reference`.
```

---

## 4. Checklist de Validação

- [ ] Verificou se o refinamento tem módulos e, se tiver, definiu o módulo a auditar.
- [ ] Leu e analisou todas as histórias solicitadas em `<pasta base>/stories/`.
- [ ] Inspecionou o código-fonte nos repositórios para validação de contratos, tabelas e DTOs.
- [ ] Verificou a nomenclatura Jeitto de tópicos Pub/Sub.
- [ ] Em modo módulo, validou as fronteiras e as dependências entre módulos.
- [ ] Gerou o arquivo `CHECK_REPORT.md` em `<pasta base>/`.
- [ ] Apresentou o resumo com status visual (🟢/🟡/🔴) e recomendações claras para a equipe de engenharia.
