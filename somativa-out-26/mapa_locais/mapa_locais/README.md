# Mapa de Locais — Flutter + Cloud Firestore

Aplicativo Android para encontrar estabelecimentos por cidade: mapa com marcadores, pesquisa, filtros, cadastro/edição/exclusão de locais e favoritos. Os dados ficam no Cloud Firestore (coleção `locais`).

Avaliação formativa — Desenvolvimento de Aplicação Mobile com Flutter (SENAI).

## Telas

| Tela | O que faz |
|------|-----------|
| 1 — Mapa | Seleção de cidade (São Paulo, Campinas, Jundiaí), pesquisa, mapa representado com marcadores dos locais da cidade, botão para os resultados |
| 2 — Resultados | Lista do Firestore com pesquisa, filtro por cidade, categoria e favoritos; cadastrar, editar e excluir |
| 3 — Detalhes | Todas as informações do local, favoritar, editar, excluir, voltar e "Ver no mapa" |

Cadastro e edição abrem em Bottom Sheet; a exclusão pede confirmação em um diálogo.

## Estrutura

```
lib/
├── main.dart                  inicializa Firebase + login anônimo
├── firebase_options.dart      gerado pelo FlutterFire (não editar)
├── models/local.dart          modelo Local (fromMap / toMap / copyWith)
├── services/
│   ├── local_service.dart     único ponto de acesso ao Firestore (CRUD)
│   ├── auth_service.dart      login anônimo
│   └── dados_exemplo.dart     18 locais de exemplo
├── screens/                   mapa, resultados e detalhes
├── widgets/                   card, formulário, mapa, barra inferior, chips...
├── dialogs/confirm_delete.dart
└── utils/                     filtros, horário, formatação, mensagens, constantes
test/                          31 testes automatizados (sem Firebase)
testes_regras/                 testes das regras no emulador do Firestore
firestore.rules                regras de segurança
```

## Como configurar

Pré-requisitos: Flutter instalado, Android Studio com um emulador (ou celular com depuração USB), Node.js (para a Firebase CLI).

0. **Projeto** — crie com o nome `mapa_locais` (os testes importam `package:mapa_locais/...`) e copie por cima `lib/`, `test/`, `testes_regras/`, `firestore.rules` e este README:
   ```
   flutter create mapa_locais
   ```
1. **Pacotes**
   ```
   flutter pub add firebase_core cloud_firestore firebase_auth
   ```
2. **Firebase Console** (https://console.firebase.google.com)
   - Crie o projeto (ex.: `mapa-locais-flutter`).
   - *Firestore Database → Criar banco de dados* → local `southamerica-east1 (São Paulo)` → **modo de produção**.
   - *Firestore Database → Regras*: cole o conteúdo de `firestore.rules` e clique em **Publicar**.
   - *Authentication → Primeiros passos → Método de login*: ative **Anônimo**.
3. **FlutterFire**
   ```
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Escolha o projeto criado e a plataforma **android**. Isso gera `lib/firebase_options.dart`.
4. **Rodar**
   ```
   flutter run
   ```
   Na primeira execução a coleção está vazia: abra **Resultados** e toque em **Carregar locais de exemplo** (grava 18 locais, 6 por cidade).

## Testes

```
flutter test
```
31 testes: modelo, filtros (T02, T03, T04), horário, card, formulário (validação, cadastro, edição), diálogo de exclusão e posições do mapa.

Regras de segurança (opcional, precisa de Java):
```
cd testes_regras
npm install
npm test
```
14 cenários: sem login é negado, dados inválidos são recusados, favoritar e excluir funcionam com login.

## Decisões

- **Filtros em memória**: o Firestore entrega a coleção e o Flutter filtra (como no tutorial). Com poucos documentos, isso permite combinar texto, cidade, categoria e favoritos sem índices compostos. A pesquisa ignora maiúsculas e acentos.
- **Tempo real**: as telas usam `snapshots()`, então cadastro, edição, exclusão e favorito aparecem na hora, sem recarregar.
- **Mapa representado**: desenhado com `CustomPainter` (o mapa real é desafio extra). Como o modelo não tem coordenadas, a posição de cada marcador vem do ID do documento — é sempre a mesma, o que permite o "Ver no mapa" destacar o local certo.
- **Segurança**: login anônimo + regras que exigem autenticação e validam tipo e tamanho de cada campo. Limitação: não separa administrador de usuário comum (isso exigiria login real — desafio extra nível 3).
- **Imagens**: o modelo não tem campo de foto (Firebase Storage é desafio extra); cada categoria usa um ícone e uma cor.

## Problemas comuns

| Sintoma | Causa provável |
|---------|----------------|
| "Sem permissão no banco de dados" | Regras não publicadas ou login anônimo desativado |
| `firebase_options.dart` não encontrado | Falta rodar `flutterfire configure` |
| Erro de `minSdk` no build | Flutter antigo: em `android/app/build.gradle.kts` use `minSdk = 23` |
| Salvar fica carregando sem fim | Aparelho sem internet (o Firestore espera a conexão para confirmar) |
