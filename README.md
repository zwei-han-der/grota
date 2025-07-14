# 🌲 Produtos da Grota - E-commerce de Lenha

Wood é um aplicativo Flutter para compra e venda de lenha, com integração ao Firebase, arquitetura orientada a objetos e dois tipos de usuários: cliente e administrador.

## ✨ Funcionalidades

- 🔐 **Autenticação de usuários** (login/cadastro via e-mail e senha)
- 🛒 **Cliente:**
  - 📦 Listagem de produtos de lenha
  - 🔍 Visualização de detalhes do produto (imagem, descrição, preço)
  - ➕ Adição de produtos ao carrinho
  - 💳 Checkout de pedidos
- 🛠️ **Administrador:**
  - ➕✏️❌ CRUD de produtos (adicionar, editar, remover)
  - 📦 Gerenciamento de estoque
- 📱 **Layout responsivo** para diferentes dispositivos
- ⚡ **Gerenciamento de estado** com Provider

## 🏗️ Arquitetura

- 💙 **Flutter** para interface e lógica de navegação
- 🔥 **Firebase Auth** para autenticação
- 🗄️ **Cloud Firestore** para banco de dados
- 🧩 **Provider** para gerenciamento de estado
- 🧑‍💻 **Orientação a objetos** nos modelos e serviços

### 📁 Estrutura de Pastas
```
lib/
  📦 models/         # Modelos de dados (User, Product, CartItem)
  🛠️ services/       # Serviços (autenticação, produtos, carrinho)
  🖥️ screens/        # Telas (auth, customer, admin)
  🧰 utils/          # Utilitários (validações, constantes)
  🏁 app.dart        # Configuração principal do app
  🚀 main.dart       # Ponto de entrada
```

## 🚀 Como rodar o projeto

1. **Clone o repositório:**
   ```sh
   git clone https://github.com/zwei-han-der/Wood.git
   cd Wood
   ```
2. **Instale as dependências:**
   ```sh
   flutter pub get
   ```
3. **Configure o Firebase:**
   - Crie um projeto no [Firebase Console](https://console.firebase.google.com/) 🔥
   - Adicione o app (Android/iOS/Web) e baixe o arquivo de configuração (`google-services.json` ou `GoogleService-Info.plist`)
   - Siga as instruções do [FlutterFire](https://firebase.flutter.dev/docs/overview/)
4. **Execute o app:**
   ```sh
   flutter run
   ```

## 🛠️ Tecnologias Utilizadas
- 💙 Flutter
- 🔥 Firebase (Auth, Firestore)
- 🧩 Provider

## 🔧 Configuração do Firebase

Os arquivos de configuração do Firebase (`android/app/google-services.json` e `lib/firebase_options.dart`) **não estão incluídos no repositório** por motivos de segurança. Para rodar o projeto, obtenha esses arquivos no [console do Firebase](https://console.firebase.google.com/) e coloque-os nos respectivos diretórios.

## 📄 Licença
Este projeto está sob a licença MIT.