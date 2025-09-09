

## Criar Projeto Flutter 🛠️

1. **Verifique a instalação do Flutter**:\
   Certifique-se de que o Flutter está configurado corretamente.

   ```bash
   flutter doctor
   ```

2. **Crie o projeto**:\
   Execute o comando abaixo para criar a estrutura do projeto.

   ```bash
   flutter create projeto
   ```

3. **Acesse o diretório**:\
   Navegue até a pasta do projeto.

   ```bash
   cd projeto
   ```

4. **Execute o projeto**:\
   Conecte um dispositivo ou emulador e inicie o app.

   ```bash
   flutter run
   ```

## Configurar Dependências 📦

1. **Adicione dependências no** `pubspec.yaml`:\
   Abra o arquivo `pubspec.yaml` e adicione as dependências necessárias.

   Exemplo:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     path_provider: ^2.1.4  # Para acessar caminhos de arquivos
     intl: ^0.19.0         # Para formatar data e hora
   ```

2. **Atualize as dependências**:\
   Execute o comando para baixar as dependências.

   ```bash
   flutter pub get
   ```


## Executar o Aplicativo 🏃‍♂️

1. **Conecte um dispositivo ou emulador**:\
   Use um dispositivo físico ou configure um emulador Android/iOS.

2. **Execute o app**:

   ```bash
   flutter run
   ```

## Dicas Extras 🚀

**Debugging**: Use `flutter doctor` para verificar problemas de configuração.
