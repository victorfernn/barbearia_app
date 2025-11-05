# barbearia_app

# Barbearia Premium - Sistema de Gerenciamento

Um aplicativo Flutter completo para gerenciamento de barbearias com todas as funcionalidades essenciais para o dia a dia do negócio.

## 🚀 Funcionalidades

### ✅ Requisitos Implementados
- **6 Telas Principais**: Login, Dashboard, Agendamentos, Clientes, Serviços, Relatórios e Localização
- **CRUD Completo**: Gerenciamento completo de Clientes, Agendamentos e Serviços
- **2 APIs Externas**: 
  - CEP API (ViaCEP) para busca de endereços
  - Weather API para informações climáticas
- **Banco SQLite**: Armazenamento local com SQLite usando o sqflite
- **Dashboard Interativo**: Visão geral com métricas e ações rápidas
- **Geolocalização**: Localização da barbearia e cálculo de distância
- **Relatórios**: Geração e exportação de relatórios em PDF e Excel

### 🏪 Gestão da Barbearia
- **Agendamentos**: Criar, editar, cancelar e controlar status
- **Clientes**: Cadastro completo com busca por CEP automática
- **Serviços**: Catálogo de serviços com preços e duração
- **Relatórios**: Análises de receita e agendamentos por período
- **Localização**: Mapa e direções para a barbearia

### 📱 Interface e UX
- Design moderno e responsivo
- Tema personalizado para barbearias
- Navegação intuitiva com bottom navigation
- Feedback visual em todas as ações
- Estados de loading e error handling

## 🛠 Tecnologias Utilizadas

### Frontend
- **Flutter**: Framework principal
- **Dart**: Linguagem de programação
- **Provider**: Gerenciamento de estado
- **Material Design**: Interface visual

### Backend/Local
- **SQLite**: Banco de dados local
- **sqflite**: Plugin para SQLite no Flutter

### APIs e Serviços
- **ViaCEP**: API de CEP brasileira
- **OpenWeatherMap**: API de clima (configurável)
- **Geolocator**: Serviços de geolocalização

### Geração de Arquivos
- **pdf**: Geração de relatórios em PDF
- **excel**: Geração de planilhas Excel
- **share_plus**: Compartilhamento de arquivos

## 📋 Pré-requisitos

- Flutter SDK (versão 3.9.2 ou superior)
- Dart SDK
- Android Studio ou Visual Studio Code
- Emulador Android ou dispositivo físico

## 🔧 Instalação

1. **Clone o repositório**
```bash
git clone [URL_DO_REPOSITORIO]
cd barbearia_app
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure as permissões (Android)**
As permissões já estão configuradas no `android/app/src/main/AndroidManifest.xml`:
- Internet
- Localização (fine e coarse)
- Armazenamento (read e write)

4. **Execute o aplicativo**
```bash
flutter run
```

## 🔑 Credenciais de Login

Para testar o aplicativo, use as seguintes credenciais:

- **Email**: admin@barbearia.com
- **Senha**: 123456

## 🎯 Como Usar

### 1. Login
- Abra o aplicativo e faça login com as credenciais fornecidas

### 2. Dashboard
- Visualize métricas gerais da barbearia
- Informações do clima local
- Acesso rápido às funcionalidades principais

### 3. Gerenciar Agendamentos
- Navegue para "Agendamentos"
- Crie novos agendamentos clicando no botão "+"
- Edite ou altere status dos agendamentos existentes
- Use filtros por data e status

### 4. Cadastrar Clientes
- Vá para "Clientes"
- Adicione novos clientes com busca automática de CEP
- Edite ou visualize informações detalhadas

### 5. Configurar Serviços
- Acesse "Serviços"
- Cadastre serviços com preço e duração
- Duplique ou desative serviços conforme necessário

### 6. Gerar Relatórios
- Entre em "Relatórios"
- Selecione o período desejado
- Exporte em PDF ou Excel
- Compartilhe os arquivos gerados

### 7. Localização
- Vá para "Localização"
- Visualize informações da barbearia
- Veja sua distância atual
- Acesse direções no Google Maps

## 📊 Banco de Dados

O aplicativo usa SQLite com as seguintes tabelas:

- **clientes**: Informações dos clientes
- **servicos**: Catálogo de serviços
- **agendamentos**: Agendamentos e histórico
- **funcionarios**: Dados dos funcionários

Os dados são persistidos localmente no dispositivo.

## 🚀 Próximas Implementações

- [ ] Notificações push para lembretes
- [ ] Integração com calendário do sistema
- [ ] Sistema de pagamentos
- [ ] Chat interno para comunicação
- [ ] Backup na nuvem
- [ ] Sistema de avaliações de clientes

---

**Desenvolvido com ❤️ usando Flutter & Dart**
