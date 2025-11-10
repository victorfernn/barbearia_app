# 📋 DOCUMENTAÇÃO TÉCNICA - BARBEARIA APP

## 📑 Índice
1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Tecnologias Utilizadas](#tecnologias-utilizadas)
4. [Estrutura do Projeto](#estrutura-do-projeto)
5. [Modelos de Dados](#modelos-de-dados)
6. [Banco de Dados](#banco-de-dados)
7. [Serviços e APIs](#serviços-e-apis)
8. [Gerenciamento de Estado](#gerenciamento-de-estado)
9. [Telas e Navegação](#telas-e-navegação)
10. [Fluxos de Funcionalidades](#fluxos-de-funcionalidades)
11. [Configuração e Instalação](#configuração-e-instalação)
12. [Testes](#testes)
13. [Deploy](#deploy)

---

## 1. Visão Geral

### 1.1 Propósito
Sistema de gerenciamento para barbearias que permite:
- Cadastro e controle de clientes
- Agendamento de serviços
- Gestão de funcionários
- Catálogo de serviços
- Relatórios financeiros (PDF/Excel)
- Dashboard com métricas

### 1.2 Plataformas
- **Android**: Suportado ✅
- **iOS**: Suportado ✅
- **Web**: Em desenvolvimento 🚧
- **Desktop**: Planejado 📋

### 1.3 Versão Atual
**v1.0.0** - MVP Funcional

---

## 2. Arquitetura

### 2.1 Padrão Arquitetural
**MVC (Model-View-Controller)** com **Provider Pattern**

```
┌─────────────────────────────────────────┐
│              PRESENTATION               │
│  ┌──────────┐  ┌──────────┐  ┌────────┐│
│  │ Screens  │  │ Widgets  │  │ Theme  ││
│  └──────────┘  └──────────┘  └────────┘│
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│           BUSINESS LOGIC                │
│  ┌──────────┐  ┌──────────┐  ┌────────┐│
│  │Providers │  │ Services │  │ Utils  ││
│  └──────────┘  └──────────┘  └────────┘│
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│              DATA LAYER                 │
│  ┌──────────┐  ┌──────────┐  ┌────────┐│
│  │  Models  │  │ Database │  │  APIs  ││
│  └──────────┘  └──────────┘  └────────┘│
└─────────────────────────────────────────┘
```

### 2.2 Fluxo de Dados
```
User Input → Screen → Provider → Service → Database/API
                ↓         ↓
            UI Update ← notifyListeners()
```

---

## 3. Tecnologias Utilizadas

### 3.1 Framework Principal
- **Flutter**: 3.24.5
- **Dart**: 3.5.4

### 3.2 Dependências Core

#### Gerenciamento de Estado
```yaml
provider: ^6.1.2
```

#### Banco de Dados
```yaml
sqflite: ^2.4.1
path_provider: ^2.1.5
path: ^1.9.1
```

#### Networking
```yaml
http: ^1.2.2
dio: ^5.7.0
```

#### UI/UX
```yaml
intl: ^0.19.0
mask_text_input_formatter: ^2.10.0
```

#### Geolocalização
```yaml
geolocator: ^13.0.2
geocoding: ^3.0.0
google_maps_flutter: ^2.10.0
```

#### Relatórios
```yaml
pdf: ^3.11.1
excel: ^4.0.6
printing: ^5.14.1
```

#### Storage
```yaml
shared_preferences: ^2.3.3
```

#### Informações do Sistema
```yaml
package_info_plus: ^8.3.1
device_info_plus: ^11.2.0
```

### 3.3 Dev Dependencies
```yaml
flutter_lints: ^4.0.0
flutter_launcher_icons: ^0.14.1
```

---

## 4. Estrutura do Projeto

```
lib/
├── main.dart                      # Entry point
├── database/
│   └── database_helper.dart       # SQLite helper
├── models/
│   ├── agendamento.dart          # Model: Agendamento
│   ├── cliente.dart              # Model: Cliente
│   ├── funcionario.dart          # Model: Funcionário
│   └── servico.dart              # Model: Serviço
├── providers/
│   └── app_provider.dart         # Estado global
├── screens/
│   ├── agendamentos_screen.dart  # Tela de agendamentos
│   ├── clientes_screen.dart      # Tela de clientes
│   ├── dashboard_screen.dart     # Dashboard/Home
│   ├── home_screen.dart          # Container principal
│   ├── localizacao_screen.dart   # Mapa/Localização
│   ├── login_screen.dart         # Autenticação
│   ├── relatorios_screen.dart    # Relatórios
│   └── servicos_screen.dart      # Catálogo de serviços
└── services/
    ├── cep_service.dart          # Integração ViaCEP
    ├── location_service.dart     # Geolocalização
    ├── report_service.dart       # Geração de relatórios
    └── weather_service.dart      # API OpenWeather

android/                           # Configurações Android
ios/                              # Configurações iOS
web/                              # Configurações Web
assets/                           # Recursos estáticos
```

---

## 5. Modelos de Dados

### 5.1 Cliente
```dart
class Cliente {
  int? id;
  String nome;
  String telefone;
  String? email;
  String? endereco;
  String? cidade;
  String? estado;
  String? cep;
  DateTime dataCadastro;
  String? observacoes;
  
  // Métodos
  Map<String, dynamic> toMap()
  static Cliente fromMap(Map<String, dynamic> map)
}
```

**Campos Obrigatórios:**
- `nome`: String (max 100 chars)
- `telefone`: String (formato: (XX) XXXXX-XXXX)
- `dataCadastro`: DateTime (auto)

**Campos Opcionais:**
- `email`, `endereco`, `cidade`, `estado`, `cep`, `observacoes`

### 5.2 Agendamento
```dart
class Agendamento {
  int? id;
  int clienteId;
  int servicoId;
  int? funcionarioId;
  DateTime dataHora;
  String status; // 'agendado', 'confirmado', 'concluido', 'cancelado'
  String? observacoes;
  
  // Relacionamentos
  String? clienteNome;
  String? servicoNome;
  double? servicoPreco;
  String? funcionarioNome;
  
  // Métodos
  Map<String, dynamic> toMap()
  static Agendamento fromMap(Map<String, dynamic> map)
}
```

**Status Possíveis:**
- `agendado`: Criado mas não confirmado
- `confirmado`: Confirmado pelo cliente
- `concluido`: Serviço realizado
- `cancelado`: Cancelado

### 5.3 Serviço
```dart
class Servico {
  int? id;
  String nome;
  String? descricao;
  double preco;
  int duracaoMinutos;
  bool ativo;
  
  // Métodos
  Map<String, dynamic> toMap()
  static Servico fromMap(Map<String, dynamic> map)
}
```

**Validações:**
- `preco`: > 0
- `duracaoMinutos`: múltiplo de 15 (15, 30, 45, 60...)

### 5.4 Funcionário
```dart
class Funcionario {
  int? id;
  String nome;
  String? telefone;
  String? email;
  String? especialidade;
  bool ativo;
  
  // Métodos
  Map<String, dynamic> toMap()
  static Funcionario fromMap(Map<String, dynamic> map)
}
```

---

## 6. Banco de Dados

### 6.1 Tecnologia
**SQLite** via `sqflite` package

### 6.2 Schema

#### Tabela: clientes
```sql
CREATE TABLE clientes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  telefone TEXT NOT NULL,
  email TEXT,
  endereco TEXT,
  cidade TEXT,
  estado TEXT,
  cep TEXT,
  dataCadastro TEXT NOT NULL,
  observacoes TEXT
);
```

#### Tabela: agendamentos
```sql
CREATE TABLE agendamentos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  clienteId INTEGER NOT NULL,
  servicoId INTEGER NOT NULL,
  funcionarioId INTEGER,
  dataHora TEXT NOT NULL,
  status TEXT NOT NULL,
  observacoes TEXT,
  FOREIGN KEY (clienteId) REFERENCES clientes(id),
  FOREIGN KEY (servicoId) REFERENCES servicos(id),
  FOREIGN KEY (funcionarioId) REFERENCES funcionarios(id)
);
```

#### Tabela: servicos
```sql
CREATE TABLE servicos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  descricao TEXT,
  preco REAL NOT NULL,
  duracaoMinutos INTEGER NOT NULL,
  ativo INTEGER NOT NULL DEFAULT 1
);
```

#### Tabela: funcionarios
```sql
CREATE TABLE funcionarios (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  telefone TEXT,
  email TEXT,
  especialidade TEXT,
  ativo INTEGER NOT NULL DEFAULT 1
);
```

### 6.3 Operações CRUD

**DatabaseHelper** - Singleton Pattern

```dart
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  factory DatabaseHelper() => _instance;
  
  // CRUD Methods
  Future<int> insertCliente(Cliente cliente)
  Future<List<Cliente>> getClientes()
  Future<Cliente?> getCliente(int id)
  Future<int> updateCliente(Cliente cliente)
  Future<int> deleteCliente(int id)
  
  // Similar para outros modelos...
}
```

### 6.4 Dados de Exemplo (Seed)
```dart
Future<void> _insertSampleData(Database db) async {
  // Serviços padrão
  await db.insert('servicos', {
    'nome': 'Corte de Cabelo',
    'descricao': 'Corte masculino tradicional',
    'preco': 35.0,
    'duracaoMinutos': 30,
    'ativo': 1
  });
  
  // Funcionários padrão
  await db.insert('funcionarios', {
    'nome': 'João Silva',
    'telefone': '(11) 98765-4321',
    'especialidade': 'Barbeiro Senior',
    'ativo': 1
  });
}
```

---

## 7. Serviços e APIs

### 7.1 CEP Service (ViaCEP)
```dart
class CepService {
  static const String baseUrl = 'https://viacep.com.br/ws';
  
  Future<Map<String, dynamic>?> buscarCep(String cep) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$cep/json/')
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }
}
```

**Endpoint:** `https://viacep.com.br/ws/{cep}/json/`  
**Método:** GET  
**Resposta:**
```json
{
  "cep": "01310-100",
  "logradouro": "Avenida Paulista",
  "bairro": "Bela Vista",
  "localidade": "São Paulo",
  "uf": "SP"
}
```

### 7.2 Weather Service (OpenWeather)
```dart
class WeatherService {
  static const String apiKey = 'sua_api_key';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  Future<Map<String, dynamic>?> getWeather(
    double lat, 
    double lon
  ) async {
    final url = '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=pt_br';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }
}
```

**Endpoint:** `https://api.openweathermap.org/data/2.5/weather`  
**Parâmetros:**
- `lat`: Latitude
- `lon`: Longitude
- `appid`: API Key
- `units`: metric
- `lang`: pt_br

### 7.3 Location Service
```dart
class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return await Geolocator.getCurrentPosition();
  }
  
  Future<String?> getAddressFromCoordinates(
    double lat, 
    double lon
  ) async {
    List<Placemark> placemarks = 
      await placemarkFromCoordinates(lat, lon);
    
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      return '${place.street}, ${place.locality} - ${place.administrativeArea}';
    }
    return null;
  }
}
```

### 7.4 Report Service
```dart
class ReportService {
  // Geração de PDF
  Future<void> gerarRelatorioPDF(
    List<Agendamento> agendamentos,
    DateTime inicio,
    DateTime fim,
    double total
  ) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Relatório de Agendamentos',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)
              ),
              pw.SizedBox(height: 20),
              pw.Table(/* ... */)
            ]
          );
        }
      )
    );
    
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save()
    );
  }
  
  // Geração de Excel
  Future<void> gerarRelatorioExcel(
    List<Agendamento> agendamentos
  ) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Agendamentos'];
    
    // Headers
    sheet.appendRow(['Data', 'Cliente', 'Serviço', 'Status', 'Valor']);
    
    // Data
    for (var agendamento in agendamentos) {
      sheet.appendRow([
        DateFormat('dd/MM/yyyy HH:mm').format(agendamento.dataHora),
        agendamento.clienteNome,
        agendamento.servicoNome,
        agendamento.status,
        'R\$ ${agendamento.servicoPreco?.toStringAsFixed(2)}'
      ]);
    }
    
    var fileBytes = excel.save();
    // Save file...
  }
}
```

---

## 8. Gerenciamento de Estado

### 8.1 Provider Pattern
```dart
class AppProvider extends ChangeNotifier {
  // State
  List<Cliente> _clientes = [];
  List<Agendamento> _agendamentos = [];
  List<Servico> _servicos = [];
  List<Funcionario> _funcionarios = [];
  bool _isLoading = false;
  
  // Getters
  List<Cliente> get clientes => _clientes;
  bool get isLoading => _isLoading;
  
  // Actions
  Future<void> carregarClientes() async {
    _isLoading = true;
    notifyListeners();
    
    _clientes = await DatabaseHelper().getClientes();
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> adicionarCliente(Cliente cliente) async {
    await DatabaseHelper().insertCliente(cliente);
    await carregarClientes();
  }
  
  // Similar para outros modelos...
}
```

### 8.2 Provider Setup (main.dart)
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const MyApp(),
    ),
  );
}
```

### 8.3 Consumo nas Screens
```dart
class ClientesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CircularProgressIndicator();
        }
        
        return ListView.builder(
          itemCount: provider.clientes.length,
          itemBuilder: (context, index) {
            final cliente = provider.clientes[index];
            return ListTile(
              title: Text(cliente.nome),
              subtitle: Text(cliente.telefone),
            );
          },
        );
      },
    );
  }
}
```

---

## 9. Telas e Navegação

### 9.1 Estrutura de Navegação
```
LoginScreen (/)
    ↓
HomeScreen (Bottom Navigation)
    ├── DashboardScreen (index 0)
    ├── AgendamentosScreen (index 1)
    ├── ClientesScreen (index 2)
    ├── ServicosScreen (index 3)
    └── LocalizacaoScreen (index 4)
```

### 9.2 Bottom Navigation Bar
```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) {
    setState(() {
      _selectedIndex = index;
    });
  },
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Agendamentos',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Clientes',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.cut),
      label: 'Serviços',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.location_on),
      label: 'Localização',
    ),
  ],
)
```

### 9.3 Descrição das Telas

#### 9.3.1 Login Screen
**Funcionalidade:** Autenticação básica  
**Campos:**
- Usuário: admin
- Senha: admin

#### 9.3.2 Dashboard Screen
**Funcionalidade:** Visão geral do negócio  
**Componentes:**
- Cards de estatísticas (receita mensal/anual)
- Lista de próximos agendamentos
- Botão de relatórios
- Widget de clima

#### 9.3.3 Agendamentos Screen
**Funcionalidade:** CRUD de agendamentos  
**Features:**
- Lista de agendamentos
- Filtro por status (agendado, confirmado, concluído, cancelado)
- Adicionar novo agendamento
- Editar agendamento
- Excluir agendamento
- Menu de ações (confirmar, concluir, cancelar)

#### 9.3.4 Clientes Screen
**Funcionalidade:** CRUD de clientes  
**Features:**
- Lista de clientes com avatar inicial
- Busca automática de CEP
- Adicionar novo cliente
- Editar cliente
- Excluir cliente
- Ver histórico de agendamentos

#### 9.3.5 Serviços Screen
**Funcionalidade:** Catálogo de serviços  
**Features:**
- Lista de serviços com preço e duração
- Adicionar novo serviço
- Editar serviço
- Desativar/ativar serviço

#### 9.3.6 Localização Screen
**Funcionalidade:** Mapa interativo  
**Features:**
- Google Maps
- Localização atual
- Endereço da barbearia
- Clima atual

---

## 10. Fluxos de Funcionalidades

### 10.1 Criar Agendamento
```
1. Cliente seleciona "Novo Agendamento"
2. Sistema carrega lista de clientes
3. Cliente seleciona cliente
4. Sistema carrega serviços disponíveis
5. Cliente seleciona serviço
6. Cliente seleciona data e hora
7. Cliente seleciona funcionário (opcional)
8. Cliente adiciona observações (opcional)
9. Sistema valida dados
10. Sistema salva no banco
11. Sistema atualiza lista
12. Sistema exibe confirmação
```

### 10.2 Cadastrar Cliente
```
1. Cliente clica em "Adicionar Cliente"
2. Sistema exibe formulário
3. Cliente preenche nome e telefone (obrigatórios)
4. Cliente preenche CEP
5. Sistema busca endereço automaticamente (ViaCEP)
6. Sistema preenche campos de endereço
7. Cliente revisa dados
8. Sistema valida formulário
9. Sistema salva no banco
10. Sistema atualiza lista
11. Sistema exibe confirmação
```

### 10.3 Gerar Relatório
```
1. Cliente acessa Dashboard
2. Cliente clica em "Relatórios"
3. Sistema exibe tela de relatórios
4. Cliente seleciona período (data início/fim)
5. Cliente seleciona formato (PDF ou Excel)
6. Sistema busca agendamentos do período
7. Sistema calcula totais
8. Sistema gera documento
9. Sistema exibe/compartilha documento
```

---

## 11. Configuração e Instalação

### 11.1 Pré-requisitos
- Flutter SDK: >= 3.5.4
- Dart SDK: >= 3.5.4
- Android Studio / VS Code
- Android SDK (para Android)
- Xcode (para iOS - macOS apenas)

### 11.2 Instalação

#### Passo 1: Clone o repositório
```bash
git clone https://github.com/victorfernn/barbearia_app.git
cd barbearia_app
```

#### Passo 2: Instale as dependências
```bash
flutter pub get
```

#### Passo 3: Configure API Keys

**Google Maps (Android)**
`android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="SUA_API_KEY_AQUI"/>
```

**Google Maps (iOS)**
`ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("SUA_API_KEY_AQUI")
```

**OpenWeather**
`lib/services/weather_service.dart`
```dart
static const String apiKey = 'SUA_API_KEY_AQUI';
```

#### Passo 4: Execute o app
```bash
# Listar dispositivos disponíveis
flutter devices

# Executar no dispositivo/emulador
flutter run

# Ou especificar dispositivo
flutter run -d <device_id>
```

### 11.3 Build de Produção

#### Android APK
```bash
flutter build apk --release
```
Arquivo gerado: `build/app/outputs/flutter-apk/app-release.apk`

#### Android App Bundle (Google Play)
```bash
flutter build appbundle --release
```
Arquivo gerado: `build/app/outputs/bundle/release/app-release.aab`

#### iOS
```bash
flutter build ios --release
```

---

## 12. Testes

### 12.1 Estrutura de Testes (A Implementar)
```
test/
├── unit/
│   ├── models/
│   │   ├── cliente_test.dart
│   │   ├── agendamento_test.dart
│   │   └── servico_test.dart
│   ├── services/
│   │   ├── cep_service_test.dart
│   │   └── report_service_test.dart
│   └── providers/
│       └── app_provider_test.dart
├── widget/
│   ├── screens/
│   │   ├── login_screen_test.dart
│   │   └── dashboard_screen_test.dart
│   └── widgets/
│       └── custom_button_test.dart
└── integration/
    └── app_test.dart
```

### 12.2 Exemplo de Teste Unitário
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:barbearia_app/models/cliente.dart';

void main() {
  group('Cliente Model', () {
    test('deve criar cliente corretamente', () {
      final cliente = Cliente(
        nome: 'João Silva',
        telefone: '(11) 98765-4321',
        dataCadastro: DateTime.now(),
      );
      
      expect(cliente.nome, 'João Silva');
      expect(cliente.telefone, '(11) 98765-4321');
    });
    
    test('deve converter para Map corretamente', () {
      final cliente = Cliente(
        id: 1,
        nome: 'João Silva',
        telefone: '(11) 98765-4321',
        dataCadastro: DateTime.now(),
      );
      
      final map = cliente.toMap();
      
      expect(map['id'], 1);
      expect(map['nome'], 'João Silva');
      expect(map['telefone'], '(11) 98765-4321');
    });
  });
}
```

### 12.3 Executar Testes
```bash
# Todos os testes
flutter test

# Teste específico
flutter test test/unit/models/cliente_test.dart

# Com cobertura
flutter test --coverage
```

---

## 13. Deploy

### 13.1 Google Play Store (Android)

#### Requisitos
1. Conta Google Play Developer ($25 taxa única)
2. App Bundle (.aab)
3. Ícone do app (512x512)
4. Screenshots (diversos tamanhos)
5. Descrição e termos

#### Passos
```bash
# 1. Configurar assinatura
# Gerar keystore
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# 2. Configurar android/key.properties
storePassword=<senha>
keyPassword=<senha>
keyAlias=upload
storeFile=<caminho>/upload-keystore.jks

# 3. Build
flutter build appbundle --release

# 4. Upload no Google Play Console
```

### 13.2 Apple App Store (iOS)

#### Requisitos
1. Apple Developer Account ($99/ano)
2. App Store Connect configurado
3. Certificados e provisioning profiles
4. Screenshots para diversos dispositivos

#### Passos
```bash
# 1. Build
flutter build ios --release

# 2. Archive no Xcode
# 3. Upload via Xcode ou Transporter
# 4. Submeter para revisão no App Store Connect
```

### 13.3 CI/CD (GitHub Actions)
```yaml
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.5'
    - run: flutter pub get
    - run: flutter analyze
    - run: flutter test
    - run: flutter build apk --release
```

---

## 📝 Changelog

### v1.0.0 (2025-11-10)
- ✅ Implementação inicial
- ✅ CRUD completo (Clientes, Agendamentos, Serviços, Funcionários)
- ✅ Dashboard com estatísticas
- ✅ Relatórios PDF/Excel
- ✅ Integração com APIs (ViaCEP, OpenWeather, Google Maps)
- ✅ Interface Material Design 3

---

## 🤝 Contribuindo

### Guidelines
1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Código
- Seguir [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Usar `flutter analyze` antes de commit
- Manter cobertura de testes > 80%
- Documentar funções públicas

---

## 📄 Licença
Este projeto está sob a licença MIT.

---

## 👥 Autores
- **Victor Fernandes** - *Desenvolvedor Principal*

---

## 📞 Suporte
Para suporte, envie um email para: support@barbeariaapp.com

---

**Última atualização:** 10 de Novembro de 2025  
**Versão do documento:** 1.0.0
