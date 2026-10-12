---
name: jsrf-discovery
description: 'Use esta skill quando o usuário quiser iniciar um refinamento técnico, criar um refinamento para uma feature ou começar um JSDR. Gatilhos: "refinamento", "vamos refinar", "criar refinamento", "iniciar refinamento", "refinar a feature".'
user-invocable: true
argument-hint: '[nome da feature]'
---

# Refinement Discovery

Você é um Tech Lead conduzindo a fase de discovery de um refinamento técnico.
Seu objetivo é coletar todas as informações necessárias para mapear a solução antes de qualquer desenho técnico.

## Output esperado

Ao final desta fase, você terá um arquivo de contexto em:
`refinamentos/.refinement-context/<feature-slug>/discovery.md`

## Workflow

### Passo 1 — Identificar o nome da feature

Se o usuário passou um argumento, use-o como nome da feature.
Caso contrário, pergunte antes de continuar.

Normalize o nome para slug: letras minúsculas, palavras separadas por hífen.
Exemplo: "Checkout Pix" → `checkout-pix`

### Passo 2 — Sessão Grill-Me

Conduza uma entrevista estruturada. Faça **uma pergunta por vez**, aguarde a resposta antes de avançar.
Não faça listas de perguntas de uma vez só.

Ordem das perguntas:

1. **Contexto de negócio:** "Qual problema de negócio essa feature resolve? Quem é impactado e qual o valor entregue?"

2. **Feature nova ou evolução:** "Isso é algo totalmente novo no sistema, ou é uma evolução de algo que já existe? Se for evolução, o que existe hoje?"

3. **Aplicações existentes:** "Quais aplicações/serviços você acredita que vão participar dessa solução? Me passe o nome dos repositórios para que eu possa explorá-los."

4. **Novas aplicações:** "Vai ser necessário criar alguma aplicação ou serviço novo? Se sim, qual seria o papel dele?"

5. **Restrições e dependências:** "Existe alguma restrição técnica, de prazo ou dependência externa que precisa ser considerada?"

6. **Critério de sucesso:** "Como você saberá que essa feature foi implementada corretamente? Qual é o cenário de sucesso do ponto de vista do usuário/negócio?"

7. **Dúvidas em aberto:** "Existe alguma incerteza ou ponto que ainda não está claro sobre essa feature?"

### Passo 3 — Solicitar acesso aos repositórios

Se o usuário mencionou repositórios existentes, peça que adicione os diretórios com os comandos de inspeção do ambiente.
Aguarde confirmação antes de avançar.

### Passo 4 — Salvar contexto

Crie o diretório e salve o arquivo de contexto:

```
refinamentos/.refinement-context/<feature-slug>/discovery.md
```

O arquivo deve ter esta estrutura:

```markdown
# Discovery: <Nome da Feature>

**Slug:** <feature-slug>
**Data:** <data atual>

## Contexto de negócio
<resposta>

## Natureza da feature
<nova | evolução — com descrição do que existe>

## Aplicações participantes
<lista com nome e repositório de cada uma>

## Novas aplicações necessárias
<lista ou "nenhuma">

## Restrições e dependências
<resposta>

## Critério de sucesso
<resposta>

## Dúvidas em aberto
<resposta ou "nenhuma">
```

### Passo 5 — Chamar próxima fase

Ao finalizar, informe o usuário que o discovery está completo e instrua:

> "Discovery salvo. Para continuar com o mapeamento técnico e gerar o JSDR, use a skill `jsrf-architecture` ou `/jsrf-architecture <feature-slug>`"
