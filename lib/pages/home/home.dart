import 'package:flutter/material.dart';
import '../configuracao/configuracao.dart';
import '../produto/cadastro_produto.dart';
import '../usuario/cadastro_usuario.dart';
import '../cliente/cadastro_cliente.dart';
import '../pedido/lista_pedidos.dart';
import '../login/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userName, this.userId});
  
  final String userName;
  final int? userId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text(
                  'Bem-vindo, ${widget.userName}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              
              _buildMenuCard(
                context,
                icon: Icons.person_add,
                title: 'Usuários',
                destination: const CadastroUsuarioPage(),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                icon: Icons.people,
                title: 'Clientes',
                destination: const CadastroClientePage(),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                icon: Icons.storefront_rounded,
                title: 'Produtos',
                destination: const CadastroProdutoPage(),
              ),
              const SizedBox(height: 16),
                _buildMenuCard(
                context,
                icon: Icons.shopping_basket_rounded,
                title: 'Pedidos',
                destination: ListaPedidosPage(userId: widget.userId),
              ),
              const SizedBox(height: 16),
                _buildMenuCard(
                context,
                icon: Icons.settings,
                title: 'Configuração',
                destination: ConfiguracaoPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required IconData icon,
    required String title,
    required Widget destination,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, 
                size: 40, 
                color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, 
                size: 30, 
                color: Theme.of(context).colorScheme.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}