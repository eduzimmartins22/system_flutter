import 'package:flutter/material.dart';

class ClientRegistrationPage extends StatefulWidget {
  const ClientRegistrationPage({super.key});

  @override
  _ClientRegistrationPageState createState() => _ClientRegistrationPageState();
}

class _ClientRegistrationPageState extends State<ClientRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController cpfCnpjController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController neighborhoodController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController ufController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: idController,
                decoration: InputDecoration(labelText: 'ID (Código interno do cliente) '),
                keyboardType: TextInputType.number,
              ), // Setar um valor, n digitar...
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nome *'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: typeController,
                decoration: InputDecoration(labelText: 'Tipo (F - Física / J - Jurídica) '),
              ),// mudar aceitação de valores para tipo F e tipo J





              TextFormField(
                controller: cpfCnpjController,
                decoration: InputDecoration(labelText: 'CPF/CNPJ '),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: cepController,
                decoration: InputDecoration(labelText: 'CEP'),
                keyboardType: TextInputType.number,
              ), // tentar colocar o resto das informações automaticamente



              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Endereço'),
              ),
              TextFormField(
                controller: neighborhoodController,
                decoration: InputDecoration(labelText: 'Bairro'),
              ),
              TextFormField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'Cidade'),
              ),
              TextFormField(
                controller: ufController,
                decoration: InputDecoration(labelText: 'UF'),
                maxLength: 2,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Salvar os dados ou realizar alguma ação
                  }
                },
                child: Text('Salvar'), //limpar os campos e salvar em algum Cache
              ),
            ],
          ),
        ),
      ),
    );
  }
}
