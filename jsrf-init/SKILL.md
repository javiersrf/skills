---
name: jsrf-init
description: >-
  Skill voltada para inicializar a estrutura e o diretório de refinamento de um novo projeto ou funcionalidade do ecossistema Jeitto. Cria a pasta em refinamentos/<feature-slug>/. Aceita como input a descrição do projeto/feature, opcionalmente o caminho dos repositórios envolvidos e, opcionalmente, o feature-slug (gerando um slug kebab-case automático a partir da descrição caso não seja informado). Prepara o ambiente para a fase de discovery (jsrf-discovery).
---

# Skill: jsrf-init

Esta skill é responsável por **inicializar o espaço de trabalho de refinamento** de uma nova funcionalidade ou projeto no ecossistema Jeitto, criando o diretório padrão para armazenar os artefatos de arquitetura e especificação técnica.

---

## 1. Inputs da Skill

1. **Descrição do Projeto / Feature** (*Obrigatório*):
   - Texto descritivo explicando o que é a funcionalidade, o escopo inicial ou o problema de negócio.
2. **Repositório da Aplicação Tratada** (*Opcional*):
   - Caminho local ou relativo do repositório/microserviço afetado (ex: `services/payment-gateway` ou `~/meu-repo`).
   - Permite ao agente pré-carregar os caminhos para inspeção nas fases posteriores.
3. **`feature-slug`** (*Opcional*):
   - Identificador único da funcionalidade formatado em kebab-case (ex: `pix-parcelado`, `extrato-consolidado`).
   - **Regra de Geração Automática**: Caso o usuário **não** informe o `feature-slug`, você deve gerar automaticamente um slug conciso, limpo e descritivo em letras minúsculas separadas por hífens com base na **Descrição do Projeto**.

---

## 2. Estrutura de Diretórios e Arquivos Gerados

A skill deve criar a seguinte estrutura na máquina do usuário:

```text
refinamentos/<feature-slug>/
├── README.md              # Briefing inicial e metadados da feature
```

---

## 3. Fluxo de Execução da Skill

Sempre que acionado para inicializar um refinamento, siga o fluxo abaixo:

### Passo 1: Validação e Processamento dos Inputs
- Verifique se a **Descrição do Projeto** foi fornecida. Se não foi, solicite uma breve explicação da funcionalidade ao usuário.
- Se o **Repositório da Aplicação** foi fornecido, registre-o no arquivo de briefing.
- Verifique se o **`feature-slug`** foi fornecido:
  - Se **fornecido**: Remova caracteres especiais e formate em kebab-case (ex: `Pix Parcelado!` -> `pix-parcelado`).
  - Se **não fornecido**: Analise a Descrição do Projeto, extraia os termos principais e gere um slug representativo (ex: "Criar motor de cálculo de limites" -> `motor-calculo-limites`).

### Passo 2: Criação do Diretório
- Crie o diretório `refinamentos/<feature-slug>/`.

### Passo 3: Geração do Arquivo de Briefing (`README.md`)
No diretório criado, crie o arquivo `README.md` contendo o briefing inicial:

```markdown
# Refinamento: <Nome da Feature>

**Feature Slug:** `<feature-slug>`  
**Repositório da Aplicação:** `<repositório informado ou a definir>`  
**Data de Inicialização:** <Data Atual DD/MM/AAAA>  
**Status:** Inicializado / Em Refinamento  

---

## Descrição do Projeto
<Descrição fornecida pelo usuário>

---

## Próximos Passos
1. Coletar os repositórios envolvidos, objetivos e impactos esperados.
2. Executar `/jsrf-discovery <feature-slug>` para conduzir o discovery de negócio.
```

### Passo 4: Confirmação e Próximos Passos
Ao concluir, exiba uma mensagem amigável confirmando:
- O `feature-slug` utilizado.
- O caminho absoluto do diretório criado.
- A instrução para utilizar `/jsrf-discovery <feature-slug>` a seguir para iniciar o discovery.

---

## 4. Checklist de Validação

- [ ] A descrição da feature foi capturada.
- [ ] O repositório da aplicação foi registrado (se fornecido).
- [ ] O `feature-slug` foi processado ou gerado automaticamente em formato kebab-case limpo.
- [ ] O diretório `refinamentos/<feature-slug>/` foi criado com sucesso no sistema.
- [ ] O arquivo `README.md` de inicialização foi gravado no diretório.
- [ ] O usuário foi notificado com o caminho completo e os próximos passos.
