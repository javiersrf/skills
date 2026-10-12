# Template JSDR (Justificativa e Solução de Desenho de Requisitos)

**Autores:** [@Autor1, @Autor2]  
**Revisores:** [@Revisor1, @Revisor2]  
**Status:** [Em Rascunho / Em Revisão / Aprovado]  
**Data:** [DD/MM/AAAA]

---

## 1. Resumo Executivo
*Explique de forma clara e direta o propósito deste documento. Qual é o objetivo principal da mudança ou nova funcionalidade?*

**O que incluir:**
*   **Visão geral da solução:** O que está sendo proposto.
*   **Objetivos:** Metas de negócio e metas técnicas.
*   **Pilares Estratégicos:** Princípios que guiam a solução (ex: Resiliência, Rastreabilidade, Segurança, Transparência).

---

## 2. Contexto do Projeto
*Descreva o cenário atual que motiva esta iniciativa.*

**O que incluir:**
*   **Contexto de Negócio/Técnico:** Qual é o papel atual do sistema, motor ou produto afetado.
*   **Problemas Identificados:** Liste os "pontos de dor" (pain points), gargalos de performance, falhas arquiteturais, problemas de domínio ou limitações operacionais (ex: processos manuais, falta de auditoria).
*   **Referências:** Links para documentações de apoio essenciais (Wikis, ADRs - Architecture Decision Records, PRDs - Product Requirements Documents).

---

## 3. Arquitetura Atual (As-Is)
*Apresente como o sistema funciona hoje, antes da implementação da solução proposta.*

**O que incluir:**
*   **Descrição do Fluxo Vigente:** Como as integrações, processos ou cargas de dados ocorrem atualmente.
*   **C4 Model - Level 1 (Contexto):** Diagrama mostrando o sistema atual e suas interações com usuários e sistemas externos.
*   **C4 Model - Level 2 (Container):** Diagrama mostrando as aplicações, APIs, bancos de dados e mensageria atuais.
*   **Modelo de Dados Atual:** Diagrama de Entidade-Relacionamento (DER) ou descrição macro das bases existentes.

---

## 4. Arquitetura Proposta (To-Be)
*Detalhe a nova solução arquitetural. Como o sistema passará a operar para resolver os problemas citados?*

**O que incluir:**
*   **Diretrizes e Mudanças Principais:** Padrões adotados (ex: Migração de arquivos para APIs REST, transição para Event-Driven Architecture, uso de CQRS, Event Sourcing).
*   **C4 Model - Level 1 (Contexto Proposto):** Diagrama atualizado de alto nível.
*   **C4 Model - Level 2 (Container Proposto):** Diagrama detalhando os novos serviços, tópicos de mensageria e repositórios de dados.
*   **Componentes da Arquitetura:**
    *   **Micro-serviços:** Liste e defina a responsabilidade de cada API, Worker ou Consumer.
    *   **Persistência:** Estratégia de banco de dados (ex: instâncias primárias para escrita assíncrona e réplicas (Read Replicas) para consulta).

---

## 5. Fluxos de Negócio
*Mapeie o passo a passo lógico das principais jornadas do sistema na nova arquitetura.*

**O que incluir:**
*   **Casos de Uso Principais:** Detalhe dos fluxos essenciais (ex: Atualização de Dados em Background, Processo de Precificação/Decisão).
*   **Comportamento Assíncrono/Síncrono:** Como o sistema lida com validações em APIs versus processamento em background (Workers).
*   **Resiliência e Consistência:** Explicação sobre controle de vazão (throttling), proteção de instâncias e consistência eventual de dados.
*   **Regras de Fallback:** O que o sistema deve fazer em caso de falhas ou ausência de dados (ex: aplicação de valores default de segurança).

---

## 6. Rastreabilidade, Observabilidade e Monitoria
*Defina como a engenharia garantirá a saúde, auditoria e rastreio da aplicação em ambiente produtivo.*

**O que incluir:**
*   **Rastreabilidade Distribuída (Tracing):** Como garantir que uma decisão ou transação possa ser auditada ponta-a-ponta (ex: geração e tráfego de IDs de regra/correlação).
*   **Logs Estruturados (Auditoria):** Quais informações contextuais exatas devem ser "fotografadas" nos logs (ex: valores calculados, IDs de cluster, taxas finais) no momento do processamento.
*   **Monitoria e Alertas (Guardrails):** 
    *   Quais métricas de negócio acompanhar (ex: média móvel de taxas aplicadas).
    *   Mecanismos de detecção de anomalias que devem disparar alertas críticos (prevenindo falhas silenciosas).

---

## 7. Modelo de Dados
*Especifique a estrutura de persistência, schemas, tabelas e dicionário de dados da nova solução.*

**O que incluir:**
*   **Databases e Schemas:** Divisão lógica dos dados por domínio (ex: schema de produto, schema de cluster).

### 7.x Schema: `[nome_do_schema]`
Gerenciado pelo serviço `[nome-do-microservico]`

#### Dicionário de Dados
*(Repita este bloco para cada tabela)*

**Tabela:** `[nome_da_tabela]`
**Descrição:** *Explique o propósito da tabela e suas regras de vida útil (ex: padrão append-only/sem exclusões físicas).*

| Nome do Campo | Tipo | Restrições | Tamanho | Descrição |
| :--- | :--- | :--- | :--- | :--- |
| `id` | SERIAL | PK, NOT NULL | - | Identificador único do registro. |
| `campo_exemplo` | VARCHAR | NOT NULL | 50 | Descrição detalhada do que este campo armazena. |
| `created_at` | TIMESTAMP | DEFAULT now()| - | Data e hora de criação do registro. |

---

## 8. Contratos de API e Mensageria
*Especifique as interfaces de comunicação síncronas (REST/GraphQL) e assíncronas (mensageria/eventos).*

**O que incluir:**

### 8.1 Endpoints HTTP / REST
*(Repita este bloco para cada endpoint)*

**Endpoint:** `[MÉTODO] /caminho/do/recurso`  
**Descrição:** *Explique a finalidade do endpoint e quem o consome.*  
**Autenticação/Autorização:** *[Ex: OAuth2 / Bearer Token - Scope: write:resource]*

**Headers de Requisição:**
| Header | Tipo | Obrigatório | Descrição |
| :--- | :--- | :--- | :--- |
| `Content-Type` | String | Sim | `application/json` |
| `X-Correlation-ID` | String | Sim | UUID para rastreabilidade distribuída. |

**Corpo da Requisição (Request Body):**
```json
{
  "campo_exemplo": "valor"
}
```

**Respostas Esperadas:**
| Código | Descrição | Payload Exemplo |
| :--- | :--- | :--- |
| `200 OK` / `201 Created` | Sucesso na operação | ```json { "id": 123, "status": "SUCCESS" } ``` |
| `400 Bad Request` | Parâmetros ou payload inválidos | ```json { "code": "INVALID_PAYLOAD", "message": "O campo X é obrigatório" } ``` |
| `500 Internal Error` | Erro interno do servidor | ```json { "code": "INTERNAL_ERROR", "message": "Tente novamente mais tarde" } ``` |

---

### 8.2 Tópicos e Eventos de Mensageria (Kafka / SQS / RabbitMQ)
*(Repita este bloco para cada tópico ou evento)*

**Tópico / Fila:** `[nome-do-topico-ou-fila]`  
**Padrão:** *[Ex: Event-Driven / Publish-Subscribe]*  
**Produtor:** `[Nome do Serviço Produtor]`  
**Consumidor(es):** `[Nome dos Serviços Consumidores]`  
**Chave de Particionamento (Partition Key):** `[Ex: customer_id]`

**Payload do Evento:**
```json
{
  "event_id": "uuid-v4",
  "event_type": "NOME_DO_EVENTO",
  "timestamp": "2026-08-12T13:34:48Z",
  "data": {
    "id": 123,
    "status": "PROCESSED"
  }
}
```

