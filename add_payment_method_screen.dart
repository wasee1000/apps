import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_dialog.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/subscription_provider.dart';

class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  final String? planId;

  const AddPaymentMethodScreen({
    Key? key,
    this.planId,
  }) : super(key: key);

  @override
  ConsumerState<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends ConsumerState<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvcController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  
  bool _isProcessing = false;
  bool _saveAsDefault = true;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvcController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  Future<void> _addPaymentMethod() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Parse expiry date
      final expiryParts = _expiryDateController.text.split('/');
      final expiryMonth = expiryParts[0];
      final expiryYear = expiryParts[1];
      
      // Add payment method
      await ref.read(paymentMethodsProvider.notifier).addPaymentMethod(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvc: _cvcController.text,
        cardHolderName: _cardHolderNameController.text,
      );
      
      if (_saveAsDefault) {
        // Get the newly added payment method
        final paymentMethods = await ref.read(paymentMethodsProvider.future);
        if (paymentMethods.isNotEmpty) {
          final newPaymentMethod = paymentMethods.first;
          await ref.read(paymentMethodsProvider.notifier).setDefaultPaymentMethod(
            newPaymentMethod.id,
          );
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment method added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back or to payment screen
        if (widget.planId != null) {
          context.go('/subscription/payment?plan_id=${widget.planId}');
        } else {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Error',
            message: 'Failed to add payment method: ${e.toString()}',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Method'),
        centerTitle: true,
      ),
      body: _isProcessing
          ? const LoadingIndicator(message: 'Adding payment method...')
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card details
                      Text(
                        'Card Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Card number
                      CustomTextField(
                        controller: _cardNumberController,
                        label: 'Card Number',
                        hintText: '1234 5678 9012 3456',
                        prefixIcon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CardNumberFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          }
                          
                          final cleanValue = value.replaceAll(' ', '');
                          if (cleanValue.length < 16) {
                            return 'Please enter a valid card number';
                          }
                          
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Expiry date and CVC
                      Row(
                        children: [
                          // Expiry date
                          Expanded(
                            child: CustomTextField(
                              controller: _expiryDateController,
                              label: 'Expiry Date',
                              hintText: 'MM/YY',
                              prefixIcon: Icons.calendar_today,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _ExpiryDateFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter expiry date';
                                }
                                
                                if (!value.contains('/')) {
                                  return 'Invalid format';
                                }
                                
                                final parts = value.split('/');
                                if (parts.length != 2) {
                                  return 'Invalid format';
                                }
                                
                                final month = int.tryParse(parts[0]);
                                final year = int.tryParse(parts[1]);
                                
                                if (month == null || year == null) {
                                  return 'Invalid format';
                                }
                                
                                if (month < 1 || month > 12) {
                                  return 'Invalid month';
                                }
                                
                                final now = DateTime.now();
                                final currentYear = now.year % 100;
                                final currentMonth = now.month;
                                
                                if (year < currentYear || 
                                    (year == currentYear && month < currentMonth)) {
                                  return 'Card expired';
                                }
                                
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // CVC
                          Expanded(
                            child: CustomTextField(
                              controller: _cvcController,
                              label: 'CVC',
                              hintText: '123',
                              prefixIcon: Icons.security,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter CVC';
                                }
                                
                                if (value.length < 3) {
                                  return 'Invalid CVC';
                                }
                                
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Card holder name
                      CustomTextField(
                        controller: _cardHolderNameController,
                        label: 'Card Holder Name',
                        hintText: 'John Doe',
                        prefixIcon: Icons.person,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card holder name';
                          }
                          
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Save as default
                      CheckboxListTile(
                        value: _saveAsDefault,
                        onChanged: (value) {
                          setState(() {
                            _saveAsDefault = value ?? true;
                          });
                        },
                        title: const Text('Save as default payment method'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 32),
                      
                      // Add button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: _addPaymentMethod,
                          text: 'Add Payment Method',
                        ),
                      ),
                      
                      // Security note
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your payment information is secure',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// Card number formatter
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    // Remove all non-digits
    String value = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 16 digits
    if (value.length > 16) {
      value = value.substring(0, 16);
    }
    
    // Format with spaces
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      if ((i + 1) % 4 == 0 && i != value.length - 1) {
        buffer.write(' ');
      }
    }
    
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Expiry date formatter
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    // Remove all non-digits
    String value = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 4 digits
    if (value.length > 4) {
      value = value.substring(0, 4);
    }
    
    // Format with slash
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      if (i == 1 && i != value.length - 1) {
        buffer.write('/');
      }
    }
    
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

