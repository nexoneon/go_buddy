import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/user_service.dart';
import '../../config/config.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final AuthService _authService = AuthService();
  final OrderService _orderService = OrderService();
  final UserService _userService = UserService();

  void _showBookingDialog() async {
    final formKey = GlobalKey<FormState>();
    final addressController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    DateTime? selectedDate;
    bool isBooking = false;
    bool isFormValid = false;

    // Load user's address
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      final user = await _userService.getUser(uid);
      if (user?.address != null && user!.address!.isNotEmpty) {
        addressController.text = user.address!;
      }
    }

    // Function to check if all fields are valid
    void checkFormValidity(StateSetter setDialogState) {
      final valid =
          addressController.text.isNotEmpty &&
          dateController.text.isNotEmpty &&
          timeController.text.isNotEmpty;
      if (valid != isFormValid) {
        setDialogState(() => isFormValid = valid);
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Check initial form validity
          WidgetsBinding.instance.addPostFrameCallback((_) {
            checkFormValidity(setDialogState);
          });

          return Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom +
                  16,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book Service',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter your address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (_) => checkFormValidity(setDialogState),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: const OutlineInputBorder(),
                            suffixIcon: dateController.text.isNotEmpty
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  )
                                : null,
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 30),
                              ),
                            );
                            if (date != null) {
                              selectedDate = date;
                              dateController.text =
                                  '${date.day}/${date.month}/${date.year}';
                              checkFormValidity(setDialogState);
                            }
                          },
                          validator: (v) =>
                              v?.isEmpty == true ? 'Date is required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: timeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Time',
                            prefixIcon: const Icon(Icons.access_time),
                            border: const OutlineInputBorder(),
                            suffixIcon: timeController.text.isNotEmpty
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  )
                                : null,
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              timeController.text = time.format(context);
                              checkFormValidity(setDialogState);
                            }
                          },
                          validator: (v) =>
                              v?.isEmpty == true ? 'Time is required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (isBooking || !isFormValid)
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                setDialogState(() => isBooking = true);
                                try {
                                  final user = _authService.currentUser;

                                  if (user == null) {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please login to book'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  final order = OrderModel(
                                    id: '', // Auto-generated
                                    userId: user.uid,
                                    serviceId: widget.service.id,
                                    serviceName: widget.service.name,
                                    serviceImageUrl: widget.service.imageUrl,
                                    amount: widget.service.price,
                                    status: 'pending',
                                    bookingDate: selectedDate!,
                                    bookingTime: timeController.text,
                                    address: addressController.text,
                                    userPhone: user.phoneNumber ?? '',
                                    createdAt: DateTime.now(),
                                  );

                                  await _orderService.createOrder(order);

                                  if (context.mounted) {
                                    Navigator.pop(context); // Close sheet
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Order placed successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setDialogState(() => isBooking = false);
                                  }
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFormValid
                            ? AppTheme.primaryColor
                            : Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isBooking
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isFormValid
                                  ? 'Confirm Booking'
                                  : 'Fill all fields to book',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Shorthand for service
    final service = widget.service;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: service.imageUrl.isNotEmpty
                  ? Image.network(
                      service.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '₹${service.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service.type,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Professional service with high quality standards. Book now to experience the best service in town.',
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified, color: Colors.green),
                    ),
                    title: const Text('Verified Professional'),
                    subtitle: const Text('Background checked and trained'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, color: Colors.orange),
                    ),
                    title: const Text('4.8 Rating'),
                    subtitle: Text('${service.orderCount} bookings'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: StreamBuilder<bool>(
        stream: _authService.currentUser != null
            ? _orderService.hasUserBookedService(
                _authService.currentUser!.uid,
                service.id,
              )
            : Stream.value(false),
        builder: (context, snapshot) {
          final hasBooked = snapshot.data ?? false;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: hasBooked ? null : _showBookingDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasBooked
                      ? Colors.grey
                      : AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  hasBooked ? 'Already Booked' : 'Book Now',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
