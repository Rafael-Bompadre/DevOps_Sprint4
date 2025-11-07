# AutoTTU API

API REST desenvolvida em .NET 8.0 para gerenciamento de sistema de estacionamento de motos, incluindo funcionalidades de check-in, gerenciamento de usuários, motos, slots e análise de risco utilizando Machine Learning.

## 💡 Solução

Começaremos pela instalação de sensores e scanners em cada uma das vagas do pátio.
Os sensores identificarão a presença de uma moto e, caso isso ocorra, o scanner fará a leitura do ID da moto por meio de um QR code pré-instalado, enviando os dados para o sistema. Dessa forma, saberemos exatamente qual >a localização de cada moto.
Para evitar erros na identificação, realizaremos um check-in para cada moto na entrada do pátio. Nesse momento, os QR codes serão gerados (cde acordo com o id da moto), os danos serão verificados, o horário de entrada >será registrado e fotos serão tiradas. Em caso de ausência do ID por dano ou perda, um novo será gerado.
Por meio desse sistema, os operadores do pátio poderão acessar as informações por uma interface intuitiva, na qual também realizarão o check-in.
Para garantir o bom funcionamento do sistema, uma IA tirará fotos do pátio a cada hora e reportará possíveis erros, como a ausência de uma moto em uma vaga que deveria estar ocupada, falhas ou danos em sensores ou >scanners, entre outros.
Atráves desse sistema, iremos garantir o bom funcionamento do pátio e a organização de forma automatizada, otimizando tempo e promovendo um ambiente mais eficiente e confiável


## 🎯 Sobre o Projeto

O AutoTTU é uma API REST completa para gerenciamento de estacionamento de motos, oferecendo:

- **Gerenciamento de Usuários**: Cadastro, login e gerenciamento de usuários do sistema
- **Gerenciamento de Motos**: CRUD completo para cadastro de motos
- **Gerenciamento de Slots**: Controle de vagas de estacionamento
- **Check-ins**: Registro de entrada e saída de motos com observações
- **Análise de Risco com IA**: Predição de risco de danos das motos utilizando Machine Learning (Microsoft ML.NET)
- **Versionamento de API**: Suporte a múltiplas versões da API
- **Segurança**: Autenticação via API Key
- **Health Checks**: Monitoramento de saúde da aplicação e banco de dados

## 🛠 Tecnologias Utilizadas

- **.NET 8.0** - Framework principal
- **Entity Framework Core 9.0.4** - ORM para acesso ao banco de dados
- **Oracle.EntityFrameworkCore 9.23.80** - Provedor Oracle para EF Core
- **Microsoft.ML 4.0.3** - Machine Learning para análise de risco
- **Swashbuckle.AspNetCore 6.6.2** - Documentação Swagger/OpenAPI
- **Microsoft.AspNetCore.Mvc.Versioning 5.1.0** - Versionamento de API
- **Microsoft.AspNetCore.Diagnostics.HealthChecks 2.2.0** - Health checks

## 📦 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Oracle Database](https://www.oracle.com/database/) ou acesso a um servidor Oracle
- [Visual Studio 2022](https://visualstudio.microsoft.com/) 

## ⚙️ Instalação e Configuração

### 1. Clone o repositório

```bash
git clone https://github.com/dudabrigidio/Autottu.git
cd AutoTTU
```

### 2. Configure o arquivo `appsettings.json`

Copie o arquivo `appsettings.Example.json` para `appsettings.json` e configure suas credenciais:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "User Id=SEU_USUARIO;Password=SUA_SENHA;Data Source=oracle.fiap.com.br:1521/orcl"
  },
  "ApiSettings": {
    "ApiKey": "SUA_API_KEY_AQUI"
  }
}
```

### 3. Execute as migrations

```bash
dotnet ef database update
```

### 4. Restaure as dependências

```bash
dotnet restore
```

## 📁 Estrutura do Projeto

```
AutoTTU/
├── Controllers/          # Controllers da API
│   ├── UsuariosController.cs
│   ├── MotosController.cs
│   ├── SlotsController.cs
│   ├── CheckinsController.cs
│   ├── IAController.cs
│   └── HealthController.cs
├── Models/              # Modelos de dados
│   ├── Usuario.cs
│   ├── Motos.cs
│   ├── Slot.cs
│   └── Checkin.cs
├── Dto/                 # Data Transfer Objects
│   ├── UsuarioInputDto.cs
│   ├── MotoInputDto.cs
│   ├── SlotsInputDto.cs
│   ├── CheckinInputDto.cs
│   └── LoginDto.cs
├── Repository/          # Camada de repositório
│   ├── IUsuarioRepository.cs
│   ├── UsuarioRepository.cs
│   ├── IMotosRepository.cs
│   ├── MotosRepository.cs
│   ├── ISlotRepository.cs
│   ├── SlotRepository.cs
│   ├── ICheckinRepository.cs
│   └── CheckinRepository.cs
├── Service/             # Camada de serviços
│   ├── IUsuarioService.cs
│   ├── UsuarioService.cs
│   ├── IMotosService.cs
│   ├── MotosService.cs
│   ├── ISlotService.cs
│   ├── SlotService.cs
│   ├── ICheckinService.cs
│   └── CheckinService.cs
├── ML/                  # Machine Learning
│   ├── ControllersML/
│   │   └── IAController.cs
│   ├── ServicesML/
│   │   ├── IIAService.cs
│   │   └── IAService.cs
│   └── CheckInData.cs
├── Connection/          # Contexto do banco de dados
│   └── AppDbContext.cs
├── Middleware/          # Middlewares customizados
│   └── ApiKeyMiddleware.cs
├── Migrations/          # Migrations do Entity Framework
└── Program.cs           # Configuração principal da aplicação
```

## 🔌 Endpoints da API

### Usuários (`/api/v1/Usuarios`)

- `GET /api/v1/Usuarios` - Lista todos os usuários
- `GET /api/v1/Usuarios/{id}` - Busca usuário por ID
- `POST /api/v1/Usuarios` - Cadastra novo usuário
- `PUT /api/v1/Usuarios/{id}` - Atualiza usuário
- `DELETE /api/v1/Usuarios/{id}` - Remove usuário
- `POST /api/v1/Usuarios/Login` - Realiza login do usuário

### Motos (`/api/v1/Motos`)

- `GET /api/v1/Motos` - Lista todas as motos
- `GET /api/v1/Motos/{id}` - Busca moto por ID
- `POST /api/v1/Motos` - Cadastra nova moto
- `PUT /api/v1/Motos/{id}` - Atualiza moto
- `DELETE /api/v1/Motos/{id}` - Remove moto

### Slots (`/api/v1/Slot`)

- `GET /api/v1/Slot` - Lista todos os slots
- `GET /api/v1/Slot/{id}` - Busca slot por ID
- `POST /api/v1/Slot` - Cadastra novo slot
- `PUT /api/v1/Slot/{id}` - Atualiza slot
- `DELETE /api/v1/Slot/{id}` - Remove slot

### Check-ins (`/api/v1/Checkins`)

- `GET /api/v1/Checkins` - Lista todos os check-ins
- `GET /api/v1/Checkins/{id}` - Busca check-in por ID
- `POST /api/v1/Checkins` - Cria novo check-in
- `PUT /api/v1/Checkins/{id}` - Atualiza check-in
- `DELETE /api/v1/Checkins/{id}` - Remove check-in

### IA (`/api/v1/IA`)

- `POST /api/v1/IA/prever-risco` - Prevê risco de dano para uma observação específica
- `POST /api/v1/IA/prever-danos` - Prevê risco de dano para todos os check-ins e calcula estatísticas

### Health Check (`/health`)

- `GET /health` - Verifica saúde da aplicação e banco de dados

## 🔐 Autenticação

A API utiliza autenticação via **API Key**. Todas as requisições (exceto rotas públicas) devem incluir o header:

```
X-API-Key: SUA_API_KEY_AQUI
```

A API Key deve ser configurada no arquivo `appsettings.json`:

```json
{
  "ApiSettings": {
    "ApiKey": "MinhaChaveSecreta123"
  }
}
```

## 🤖 Machine Learning

O projeto inclui funcionalidades de Machine Learning para análise de risco de danos em motos. O modelo ML.NET analisa as observações dos check-ins e prevê a probabilidade de risco alto.

### Endpoints de IA

**Prever Risco Individual:**
```http
POST /api/v1/IA/prever-risco
Content-Type: application/json

"Observação da moto: danificada, arranhões no tanque"
```

**Prever Danos para Todos os Check-ins:**
```http
POST /api/v1/IA/prever-danos
```


## 🏥 Health Checks

O endpoint `/health` verifica:

- **Status da aplicação**
- **Conexão com o banco de dados Oracle**

Exemplo de resposta:

```json
{
  "status": "Healthy",
  "checks": {
    "database": "Healthy"
  }
}
```

## 🚀 Executando o Projeto

### Modo Desenvolvimento

```bash
dotnet run
```


## 🧪 Testes

O projeto inclui uma suíte completa de testes unitários e de integração para garantir a qualidade e confiabilidade do código.

### Estrutura dos Testes

O projeto de testes (`AutoTTU.Tests`) está organizado da seguinte forma:

```
AutoTTU.Tests/
├── Services/                    # Testes unitários dos serviços
│   ├── UsuarioServiceTests.cs
│   ├── MotosServiceTests.cs
│   ├── SlotServiceTests.cs
│   └── CheckinServiceTests.cs
├── Integration/                 # Testes de integração
│   ├── Controllers/
│   │   ├── UsuariosControllerIntegrationTests.cs
│   │   ├── MotosControllerIntegrationTests.cs
│   │   ├── SlotsControllerIntegrationTests.cs
│   │   └── CheckinsControllerIntegrationTests.cs
│   ├── CustomWebApplicationFactory.cs
│   └── IntegrationTestBase.cs
└── Helpers/
    └── TestDataBuilder.cs      # Helper para criação de dados de teste
```

### Tecnologias de Teste

- **xUnit** - Framework de testes
- **Moq** - Framework de mocking para testes unitários
- **FluentAssertions** - Biblioteca para asserções mais legíveis
- **Microsoft.AspNetCore.Mvc.Testing** - Testes de integração para APIs ASP.NET Core
- **Microsoft.EntityFrameworkCore.InMemory** - Banco de dados em memória para testes
- **Coverlet** - Cobertura de código

### Executando os Testes

#### Executar todos os testes

```bash
cd AutoTTU.Tests
dotnet test
```

#### Executar testes com cobertura de código

```bash
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover
```

#### Executar apenas testes unitários

```bash
dotnet test --filter "FullyQualifiedName~Services"
```

#### Executar apenas testes de integração

```bash
dotnet test --filter "FullyQualifiedName~Integration"
```

#### Executar testes com saída detalhada

```bash
dotnet test --logger "console;verbosity=detailed"
```

#### Executar um teste específico

```bash
dotnet test --filter "FullyQualifiedName~NomeDoTeste"
```

### Tipos de Testes

#### Testes Unitários

Os testes unitários estão localizados na pasta `Services/` e testam a lógica de negócio dos serviços isoladamente, utilizando mocks para dependências:

- **UsuarioServiceTests**: Testa operações CRUD e lógica de autenticação de usuários
- **MotosServiceTests**: Testa operações CRUD de motos
- **SlotServiceTests**: Testa operações CRUD de slots
- **CheckinServiceTests**: Testa operações CRUD e lógica de check-ins

#### Testes de Integração

Os testes de integração estão localizados na pasta `Integration/Controllers/` e testam os endpoints da API de forma completa, incluindo:

- Validação de requisições HTTP
- Autenticação via API Key
- Persistência no banco de dados (usando banco em memória)
- Respostas HTTP corretas

Os testes de integração utilizam:
- **CustomWebApplicationFactory**: Factory customizada para configurar a aplicação de teste
- **IntegrationTestBase**: Classe base que fornece HttpClient configurado e limpeza do banco de dados

### Configuração dos Testes

Os testes de integração utilizam um banco de dados em memória (InMemory) para garantir isolamento e velocidade. A API Key de teste é configurada automaticamente como `TestApiKey123` nos testes de integração.

### Exemplo de Execução

```bash
# Navegar para o diretório de testes
cd AutoTTU.Tests

# Executar todos os testes
dotnet test

# Saída esperada:
# Test Run Successful.
# Total tests: XX
#      Passed: XX
# Total time: X.XXXX seconds
```

### Cobertura de Código

Para visualizar a cobertura de código após executar os testes com a flag de cobertura, você pode usar ferramentas como:

- **ReportGenerator** para gerar relatórios HTML
- **Coverlet.ReportGenerator** para relatórios em diferentes formatos

Exemplo de instalação e uso do ReportGenerator:

```bash
dotnet tool install -g dotnet-reportgenerator-globaltool
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover
reportgenerator -reports:"**/coverage.opencover.xml" -targetdir:"coverage-report" -reporttypes:Html
```

## 📚 Documentação Swagger

Quando executado em modo de desenvolvimento, a documentação Swagger estará disponível em:

```
https://localhost:5001/swagger
```

O Swagger permite:
- Visualizar todos os endpoints disponíveis
- Testar requisições diretamente na interface
- Ver exemplos de requisições e respostas
- Configurar a API Key para autenticação

## 💡 Exemplos de Uso

### Criar um Usuário

```http
POST /api/v1/Usuarios
X-API-Key: MinhaChaveSecreta123
Content-Type: application/json

{
  "nome": "João Silva",
  "email": "joao@example.com",
  "senha": "senha123",
  "telefone": "11999999999"
}
```

### Cadastrar uma Moto

```http
POST /api/v1/Motos
X-API-Key: MinhaChaveSecreta123
Content-Type: application/json

{
  "modelo": "H2",
  "marca": "Honda",
  "ano": 2020,
  "placa": "ABC1234",
  "ativoChar": "s",
  "fotoUrl": "https://example.com/foto.jpg"
}
```

### Realizar Check-in

```http
POST /api/v1/Checkins
X-API-Key: MinhaChaveSecreta123
Content-Type: application/json

{
  "idMoto": 1,
  "idUsuario": 1,
  "ativoChar": "n",
  "observacao": "Moto em perfeito estado",
  "timeStamp": "2025-01-15T10:30:00",
  "imagensUrl": "https://example.com/imagem.jpg"
}
```

### Prever Risco de Dano

```http
POST /api/v1/IA/prever-risco
X-API-Key: MinhaChaveSecreta123
Content-Type: application/json

"Moto com arranhões no tanque e retrovisor quebrado"
```

Resposta:
```json
{
  "observacao": "Moto com arranhões no tanque e retrovisor quebrado",
  "riscoAlto": true,
  "probabilidade": 0.85
}
```

## 🔄 Versionamento da API

A API suporta versionamento através de:

- **Query String**: `?api-version=1.0`
- **Header**: `x-api-version: 1.0`
- **URL**: `/api/v1/Usuarios`

A versão padrão é **1.0**.

## 🌐 CORS

A API está configurada para aceitar requisições de qualquer origem em desenvolvimento. Para produção, ajuste as políticas CORS no `Program.cs`.

## 📝 Licença

Este projeto é parte de um trabalho acadêmico.




