/* Autor: Livia Lucizano */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mescla_invest_app/core/utils/snackbar_utils.dart';
import 'package:mescla_invest_app/features/exchange/data/services/exchange_service.dart';
import 'package:mescla_invest_app/features/exchange/data/models/exchange_model.dart';
import 'package:mescla_invest_app/features/catalog/presentation/widgets/startup_detail/detailed_catalog_modal_layout.dart';
import 'package:mescla_invest_app/routes/app_routes.dart';

/// Modal de confirmação exibido antes de enviar uma ordem de compra ou venda.
/// Apresenta um resumo completo da operação e permite ao usuário confirmar ou cancelar.
class OrderConfirmationModal extends StatefulWidget {
  /// Tipo da ordem (compra ou venda).
  final TipoOrdem tipo;

  /// Modo da ordem (mercado ou limitada).
  final ModoOrdem modo;

  /// ID da startup selecionada para a ordem.
  final String startupId;

  /// Nome da startup selecionada para exibição no resumo.
  final String startupNome;

  /// Símbolo do token da startup.
  final String simbolo;

  /// Quantidade de tokens a ser negociada.
  final int quantidadeTokens;

  /// Preço unitário de cada token.
  final double precoUnitario;

  const OrderConfirmationModal({
    required this.tipo,
    required this.modo,
    required this.startupId,
    required this.startupNome,
    required this.simbolo,
    required this.quantidadeTokens,
    required this.precoUnitario,
    super.key,
  });

  @override
  State<OrderConfirmationModal> createState() => _OrderConfirmationModalState();
}

class _OrderConfirmationModalState extends State<OrderConfirmationModal> {
  /// Serviço responsável por enviar a ordem ao backend.
  final ExchangeService _exchangeService = ExchangeService();

  /// Indica se o envio da ordem está em andamento (controla loading do botão).
  bool _carregando = false;

  /// Formata um valor [double] para o padrão monetário brasileiro.
  /// Exemplo: 1500.5 → "R$ 1500,50"
  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Calcula o valor total da operação (preço unitário × quantidade).
  double get _calcularTotal {
    return widget.quantidadeTokens * widget.precoUnitario;
  }

  /// Envia a ordem ao backend via [ExchangeService], exibe feedback ao usuário
  /// e navega para a tela de sucesso em caso de êxito.
  Future<void> _enviarOrdem() async {
    setState(() => _carregando = true);

    try {
      await _exchangeService.abrirOrdem(
        tipo: widget.tipo,
        modo: widget.modo,
        startupId: widget.startupId,
        quantidadeTokens: widget.quantidadeTokens,
        precoUnitario: widget.precoUnitario,
        startupNome: '',
        simbolo: '',
      );

      if (!mounted) return;

      // Exibe snackbar contextual conforme tipo e modo da ordem.
      if(widget.tipo == TipoOrdem.compra){
        if(widget.modo == ModoOrdem.mercado){
          showSuccessSnackBar(context, 'Compra realizada com sucesso!');
        }
        else{
          showSuccessSnackBar(context, 'Ordem de compra criada com sucesso!');
        }
      }
      else{
        showSuccessSnackBar(context, 'Ordem de compra criada com sucesso!');
      }

      // Fecha o modal de confirmação.
      Navigator.pop(context);
      // Retorna para a listagem do Balcão limpando o fluxo anterior.
      Navigator.pushNamedAndRemoveUntil(
        context, 
        AppRoutes.ordemSucesso, 
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      
      // Verifica se o erro é de saldo insuficiente para exibir mensagem específica.
      final textoErro = error.toString().toLowerCase();
      if (textoErro.contains('saldo insuficiente')) {
        showErrorSnackBar(context, 'Saldo insuficiente para abrir esta ordem de compra.');
      } else {
        showErrorSnackBar(context, 'Erro ao processar sua ordem. Tente novamente mais tarde.');
      }
    } finally {
      // Garante que o estado de loading seja desativado mesmo em caso de erro.
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF353988);

    return DetailedCatalogModalLayout(
      title: 'Confirmação de Ordem',
      subtitle: 'Revise com atenção antes de prosseguir',
      height: 9, // Mantém o modal proporcional e compacto na base da tela
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Linha: tipo da ordem.
              _buildLinhaResumo('Tipo de ordem:',
                widget.tipo == TipoOrdem.compra ? 'Ordem de compra' : 'Ordem de venda'
              ),
              const Divider(height: 24, color: Color(0xFFA2A2A2)),
              
              // Linha: nome da startup.
              _buildLinhaResumo('Startup selecionada:', widget.startupNome),
              const Divider(height: 24, color: Color(0xFFA2A2A2)),
              
              // Linha: símbolo do token.
              _buildLinhaResumo('Símbolo do Token:', widget.simbolo),
              const Divider(height: 24, color: Color(0xFFA2A2A2)),
              
              // Linha: quantidade de tokens.
              _buildLinhaResumo('Quantidade de tokens escolhida:', '${widget.quantidadeTokens} tokens'),
              const Divider(height: 24, color: Color(0xFFA2A2A2)),
              
              // Linha: preço unitário.
              _buildLinhaResumo('Valor unitário de cada token:', _formatarMoeda(widget.precoUnitario)),
              const Divider(height: 24, color: Color(0xFFA2A2A2)),
              
              // Linha: valor total calculado dinamicamente.
              _buildLinhaResumo('Valor total a ser ${widget.tipo == TipoOrdem.compra ? "investido" : "arrecadado"}:', _formatarMoeda(_calcularTotal)),
              const Divider(height: 24, color: Color(0xFFA2A2A2)),
              
              const SizedBox(height: 12),
              
              // Botão de confirmação: desabilitado e com loading durante o envio.
              Center(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _enviarOrdem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _carregando
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            'Confirmar Ordem',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              )              
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói uma linha do resumo da ordem com um rótulo em negrito
  /// e o valor correspondente abaixo, separados por divisores.
  Widget _buildLinhaResumo(String rotulo, String valor) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        // Rótulo descritivo do campo.
        Text(
          rotulo,
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        // Valor correspondente ao rótulo.
        Text(
          valor,
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}