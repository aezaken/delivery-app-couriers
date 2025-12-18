import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_data/services/api_service.dart';
import 'package:shared_data/models/courier.dart';
import 'package:dispatcher_app/widgets/yandex_suggest_widget.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _addressAController = TextEditingController();
  final _addressBController = TextEditingController();

  bool _isLoading = false;
  List<Courier> _allCouriers = [];
  List<Courier> _filteredCouriers = [];
  Courier? _selectedCourier;
  bool _isFetchingCouriers = false;
  bool _showCourierSelector = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _addressAController.dispose();
    _addressBController.dispose();
    super.dispose();
  }

  Future<void> _fetchCouriers() async {
    setState(() {
      _isFetchingCouriers = true;
      _allCouriers = [];
      _filteredCouriers = [];
    });

    try {
      final apiService = context.read<ApiService>();
      final couriers = await apiService.getOnlineCouriers();

      if (mounted) {
        setState(() {
          _allCouriers = couriers;
          _filteredCouriers = couriers;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при загрузке курьеров: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingCouriers = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final apiService = context.read<ApiService>();

      try {
        final newOrder = await apiService.createOrder(
          customerName: _customerNameController.text,
          addressA: _addressAController.text,
          addressB: _addressBController.text,
          courierId: _selectedCourier?.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _selectedCourier != null
                    ? 'Заказ #${newOrder.id} создан и назначен курьеру ${_selectedCourier!.fullName}!'
                    : 'Заказ #${newOrder.id} успешно создан!',
              ),
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildCourierSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedCourier != null
                      ? 'Выбранный курьер: ${_selectedCourier!.fullName}'
                      : 'Курьер не выбран (опционально)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: Icon(_showCourierSelector ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _showCourierSelector = !_showCourierSelector;
                    if (_showCourierSelector && _allCouriers.isEmpty) {
                      _fetchCouriers();
                    }
                  });
                },
              ),
            ],
          ),
          if (_showCourierSelector) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _isFetchingCouriers ? null : _fetchCouriers,
                    icon: _isFetchingCouriers
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: const Text('Обновить список'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isFetchingCouriers)
              const Center(child: CircularProgressIndicator())
            else if (_filteredCouriers.isEmpty)
              const Text('Нет доступных курьеров')
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _filteredCouriers.length,
                  itemBuilder: (context, index) {
                    final courier = _filteredCouriers[index];
                    return ListTile(
                      title: Text(courier.fullName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courier.latitude != null ? 'Онлайн' : 'Офлайн',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      selected: _selectedCourier?.id == courier.id,
                      selectedTileColor: Colors.blue[100],
                      onTap: () {
                        setState(() {
                          _selectedCourier = courier;
                          _showCourierSelector = false;
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый заказ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Имя клиента',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите имя клиента';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Только один виджет — Адрес А
              YandexSuggestWidget(
                hintText: 'Адрес А (откуда забрать)',
                onSuggestionSelected: (address) {
                  _addressAController.text = address;
                },
              ),
              const SizedBox(height: 16),

              // Адрес Б — ЗАКОММЕНТИРОВАН
              // YandexSuggestWidget(
              //   hintText: 'Адрес Б (куда доставить)',
              //   onSuggestionSelected: (address) {
              //     _addressBController.text = address;
              //   },
              // ),
              const SizedBox(height: 16),

              _buildCourierSelector(),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Создать заказ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}