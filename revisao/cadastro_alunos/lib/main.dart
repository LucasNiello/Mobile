import 'package:flutter/material.dart';

void main() {
  runApp(const CadastroAlunosApp());
}

class CadastroAlunosApp extends StatelessWidget {
  const CadastroAlunosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Alunos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CadastroAlunosPage(),
    );
  }
}

class Aluno {
  final String nome;
  final int idade;
  final String curso;

  Aluno({required this.nome, required this.idade, required this.curso});
}

class CadastroAlunosPage extends StatefulWidget {
  const CadastroAlunosPage({super.key});

  @override
  State<CadastroAlunosPage> createState() => _CadastroAlunosPageState();
}

class _CadastroAlunosPageState extends State<CadastroAlunosPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _idadeController = TextEditingController();
  final _cursoController = TextEditingController();

  final List<Aluno> _alunos = [];

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _cursoController.dispose();
    super.dispose();
  }

  void _cadastrarAluno() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _alunos.add(
          Aluno(
            nome: _nomeController.text.trim(),
            idade: int.parse(_idadeController.text.trim()),
            curso: _cursoController.text.trim(),
          ),
        );
      });
      _formKey.currentState!.reset();
      _nomeController.clear();
      _idadeController.clear();
      _cursoController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _removerAluno(int index) {
    setState(() {
      _alunos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Alunos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _idadeController,
                    decoration: const InputDecoration(
                      labelText: 'Idade',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a idade';
                      }
                      final idade = int.tryParse(value.trim());
                      if (idade == null || idade <= 0) {
                        return 'Idade inválida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cursoController,
                    decoration: const InputDecoration(
                      labelText: 'Curso',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o curso';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _cadastrarAluno,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Cadastrar'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Alunos cadastrados (${_alunos.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _alunos.isEmpty
                  ? const Center(
                      child: Text('Nenhum aluno cadastrado ainda.'),
                    )
                  : ListView.separated(
                      itemCount: _alunos.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final aluno = _alunos[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(aluno.nome.isNotEmpty
                                ? aluno.nome[0].toUpperCase()
                                : '?'),
                          ),
                          title: Text(aluno.nome),
                          subtitle: Text(
                              '${aluno.idade} anos • ${aluno.curso}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removerAluno(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
