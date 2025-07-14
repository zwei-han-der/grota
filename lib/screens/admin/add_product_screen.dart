import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProductScreen extends StatefulWidget {
  final Product? produto;
  const AddProductScreen({super.key, this.produto});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nome = '';
  String _descricao = '';
  String _imagem = '';
  String _preco = '';
  bool _loading = false;
  String? _erro;
  File? _imagemFile;
  Uint8List? _imagemBytes;
  String _estoque = '';
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _estoqueController = TextEditingController();
  final TextEditingController _imagemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.produto != null) {
      _nome = widget.produto!.nome;
      _descricao = widget.produto!.descricao;
      _preco = widget.produto!.preco.toString();
      _imagem = widget.produto!.imagens.isNotEmpty ? widget.produto!.imagens.first : '';
      _estoque = widget.produto!.estoque.toString();
      _nomeController.text = _nome;
      _descricaoController.text = _descricao;
      _precoController.text = _preco;
      _estoqueController.text = _estoque;
      _imagemController.text = _imagem;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _estoqueController.dispose();
    _imagemController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imagemBytes = bytes;
          _imagemFile = null;
          _imagem = '';
        });
      } else {
        setState(() {
          _imagemFile = File(picked.path);
          _imagemBytes = null;
          _imagem = '';
        });
      }
    }
  }

  Future<String?> _uploadImageToStorage() async {
    try {
      if (_imagemBytes == null) return null;
      final fileName = 'produtos/${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putData(_imagemBytes!);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      setState(() {
        _erro = 'Erro ao fazer upload da imagem: ${e.toString()}';
      });
      return null;
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _erro = null; });
    try {
      String imagemUrl = _imagem;
      if (_imagemBytes != null) {
        final url = await _uploadImageToStorage();
        if (url != null) {
          imagemUrl = url;
        } else {
          setState(() { _loading = false; });
          return;
        }
      }
      final produto = Product(
        id: widget.produto?.id ?? '',
        nome: _nome,
        descricao: _descricao,
        preco: double.tryParse(_preco) ?? 0,
        imagens: imagemUrl.isNotEmpty ? [imagemUrl] : [],
        estoque: int.tryParse(_estoque) ?? 0,
      );
      final service = Provider.of<ProductService>(context, listen: false);
      if (widget.produto == null) {
        await service.adicionarProduto(produto);
      } else {
        await service.atualizarProduto(produto);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() { _erro = 'Erro ao salvar produto: ${e.toString()}'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Adicionar Produto'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Produto',
                        prefixIcon: Icon(FontAwesomeIcons.box),
                      ),
                      onChanged: (v) => _nome = v,
                      validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        prefixIcon: Icon(FontAwesomeIcons.alignLeft),
                      ),
                      onChanged: (v) => _descricao = v,
                      validator: (v) => v == null || v.isEmpty ? 'Informe a descrição' : null,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _precoController,
                      decoration: const InputDecoration(
                        labelText: 'Preço',
                        prefixIcon: Icon(FontAwesomeIcons.dollarSign),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => _preco = v,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe o preço';
                        final p = double.tryParse(v.replaceAll(',', '.'));
                        if (p == null || p < 0) return 'Preço inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _estoqueController,
                      decoration: const InputDecoration(
                        labelText: 'Estoque',
                        prefixIcon: Icon(FontAwesomeIcons.boxesStacked),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _estoque = v,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe o estoque';
                        final n = int.tryParse(v);
                        if (n == null || n < 0) return 'Estoque inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imagemController,
                            decoration: const InputDecoration(
                              labelText: 'URL da Imagem',
                              prefixIcon: Icon(FontAwesomeIcons.image),
                            ),
                            onChanged: (v) => setState(() { _imagem = v; _imagemFile = null; _imagemBytes = null; }),
                            validator: (v) {
                              if ((v == null || v.isEmpty) && _imagemFile == null && _imagemBytes == null) {
                                return 'Informe a imagem';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.upload),
                          tooltip: 'Selecionar imagem do dispositivo',
                          onPressed: _pickImage,
                        ),
                      ],
                    ),
                    if (_imagemBytes != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.memory(_imagemBytes!, height: 120),
                      )
                    else if (_imagemFile != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.file(_imagemFile!, height: 120),
                      )
                    else if (_imagem.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.network(_imagem, height: 120, errorBuilder: (c, e, s) => const SizedBox()),
                      ),
                    const SizedBox(height: 24),
                    if (_erro != null) ...[
                      Text(_erro!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: const Icon(FontAwesomeIcons.floppyDisk),
                        label: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : Text(widget.produto == null ? 'Salvar Produto' : 'Salvar Alterações'),
                        onPressed: _loading ? null : _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF780000),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 