import 'package:flutter/material.dart';
import '../models/trading_models.dart';

class TradingForm extends StatefulWidget {
  final Function(CreateOrderRequest) onCreateOrder;
  final Map<String, double> symbolPrices;
  final Function(String) onGetSymbolPrice;

  const TradingForm({
    Key? key,
    required this.onCreateOrder,
    required this.symbolPrices,
    required this.onGetSymbolPrice,
  }) : super(key: key);

  @override
  State<TradingForm> createState() => _TradingFormState();
}

class _TradingFormState extends State<TradingForm> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _volumeController = TextEditingController();
  final _priceController = TextEditingController();
  final _stopLossController = TextEditingController();
  final _takeProfitController = TextEditingController();
  final _commentController = TextEditingController();

  OrderType _orderType = OrderType.market;
  OrderSide _orderSide = OrderSide.buy;
  bool _isLoading = false;

  @override
  void dispose() {
    _symbolController.dispose();
    _volumeController.dispose();
    _priceController.dispose();
    _stopLossController.dispose();
    _takeProfitController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Order',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _symbolController,
                      decoration: const InputDecoration(
                        labelText: 'Symbol',
                        hintText: 'Enter symbol (e.g., EURUSD)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a symbol';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          widget.onGetSymbolPrice(value.toUpperCase());
                        }
                      },
                    ),
                    if (_symbolController.text.isNotEmpty &&
                        widget.symbolPrices
                            .containsKey(_symbolController.text.toUpperCase()))
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Current Price: ${widget.symbolPrices[_symbolController.text.toUpperCase()]?.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<OrderType>(
                            value: _orderType,
                            decoration: const InputDecoration(
                              labelText: 'Order Type',
                              border: OutlineInputBorder(),
                            ),
                            items: OrderType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.toString().split('.').last),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _orderType = value;
                                  if (value == OrderType.market) {
                                    _priceController.clear();
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<OrderSide>(
                            value: _orderSide,
                            decoration: const InputDecoration(
                              labelText: 'Order Side',
                              border: OutlineInputBorder(),
                            ),
                            items: OrderSide.values.map((side) {
                              return DropdownMenuItem(
                                value: side,
                                child: Text(side.toString().split('.').last),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _orderSide = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _volumeController,
                      decoration: const InputDecoration(
                        labelText: 'Volume',
                        hintText: 'Enter volume (e.g., 0.1)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter volume';
                        }
                        final volume = double.tryParse(value);
                        if (volume == null || volume <= 0) {
                          return 'Please enter a valid volume';
                        }
                        return null;
                      },
                    ),
                    if (_orderType != OrderType.market) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          hintText: 'Enter price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (_orderType != OrderType.market &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter price';
                          }
                          if (value != null && value.isNotEmpty) {
                            final price = double.tryParse(value);
                            if (price == null || price <= 0) {
                              return 'Please enter a valid price';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stopLossController,
                      decoration: const InputDecoration(
                        labelText: 'Stop Loss',
                        hintText: 'Enter stop loss price (optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return 'Please enter a valid stop loss price';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _takeProfitController,
                      decoration: const InputDecoration(
                        labelText: 'Take Profit',
                        hintText: 'Enter take profit price (optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return 'Please enter a valid take profit price';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        labelText: 'Comment',
                        hintText: 'Enter order comment (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orderSide == OrderSide.buy
                              ? Colors.green
                              : Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                '${_orderSide.toString().split('.').last.toUpperCase()} ${_orderType.toString().split('.').last.toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = CreateOrderRequest(
        symbol: _symbolController.text.toUpperCase(),
        type: _orderType,
        side: _orderSide,
        volume: double.parse(_volumeController.text),
        price: _orderType != OrderType.market
            ? double.tryParse(_priceController.text)
            : null,
        stopLoss: double.tryParse(_stopLossController.text),
        takeProfit: double.tryParse(_takeProfitController.text),
        comment:
            _commentController.text.isEmpty ? null : _commentController.text,
      );

      await widget.onCreateOrder(request);

      // Clear form after successful order creation
      _formKey.currentState!.reset();
      _symbolController.clear();
      _volumeController.clear();
      _priceController.clear();
      _stopLossController.clear();
      _takeProfitController.clear();
      _commentController.clear();
      setState(() {
        _orderType = OrderType.market;
        _orderSide = OrderSide.buy;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
