import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/user_service.dart';
import '../../services/address_service.dart';
import '../../services/connectivity_service.dart';
import '../../models/address_model.dart';
import '../../config/config.dart';
import 'profile_screen.dart';
import 'address_list_screen.dart';

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
  final AddressService _addressService = AddressService();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _wasConnected = true;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _wasConnected = _connectivityService.isConnected;
    // Check if already offline when screen loads
    _isOffline = !_connectivityService.isConnected;
    _connectivityService.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (mounted) {
      final isConnected = _connectivityService.isConnected;

      if (_wasConnected && !isConnected) {
        setState(() => _isOffline = true);
      }

      if (!_wasConnected && isConnected) {
        setState(() => _isOffline = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.wifi, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Back online!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      _wasConnected = isConnected;
    }
  }

  void _showBookingDialog() async {
    // First check if user profile is complete
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to book'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Get user and check profile completion
    final user = await _userService.getUser(uid);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading user data'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Check if required fields are filled
    final missingFields = <String>[];
    if (user.firstName == null || user.firstName!.isEmpty) {
      missingFields.add('First Name');
    }
    if (user.lastName == null || user.lastName!.isEmpty) {
      missingFields.add('Last Name');
    }
    if (user.gender == null || user.gender!.isEmpty) {
      missingFields.add('Gender');
    }
    if (user.address == null || user.address!.isEmpty) {
      missingFields.add('Address');
    }

    if (missingFields.isNotEmpty && mounted) {
      // Show dialog to ask user to complete profile
      final shouldNavigate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Complete Your Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please complete the following before booking:'),
              const SizedBox(height: 12),
              ...missingFields.map(
                (field) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(field),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D7377),
              ),
              child: const Text('Go to Profile'),
            ),
          ],
        ),
      );

      if (shouldNavigate == true && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MobileProfileScreen()),
        );
      }
      return;
    }

    // Profile is complete, proceed with booking dialog
    final formKey = GlobalKey<FormState>();
    final addressController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    DateTime? selectedDate;
    bool isBooking = false;
    bool isFormValid = false;
    bool termsAccepted = false;

    // Pre-fill address logic
    // Fetch default address
    _addressService.getDefaultOrLatestAddress(uid).then((addr) {
      if (addr != null && mounted) {
        addressController.text = addr.fullAddress;
      } else if (user.address != null && user.address!.isNotEmpty) {
        // Fallback to profile address if no saved address found
        addressController.text = user.address!;
      }
      // Note: We can't easily setState here because we are outside the bottom sheet's StatefulBuilder yet.
      // But since we pass controller to the builder, it should show up.
    });

    // Function to check if all fields are valid
    void checkFormValidity(StateSetter setDialogState) {
      final valid =
          addressController.text.isNotEmpty &&
          dateController.text.isNotEmpty &&
          timeController.text.isNotEmpty &&
          termsAccepted;
      if (valid != isFormValid) {
        setDialogState(() => isFormValid = valid);
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Check initial form validity
          WidgetsBinding.instance.addPostFrameCallback((_) {
            checkFormValidity(setDialogState);
          });

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with service info
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0D7377), Color(0xFF14919B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Handle bar
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(100),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(50),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.build_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.service.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${widget.service.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(230),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section title
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0D7377,
                                    ).withAlpha(26),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF0D7377),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Booking Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Address field
                            TextFormField(
                              controller: addressController,
                              readOnly: true, // Make it read-only
                              onTap: () async {
                                final result =
                                    await Navigator.push<AddressModel>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AddressListScreen(
                                              isSelectionMode: true,
                                            ),
                                      ),
                                    );

                                if (result != null) {
                                  addressController.text = result.fullAddress;
                                  checkFormValidity(setDialogState);
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Service Address',
                                hintText: 'Select address',
                                prefixIcon: const Icon(Icons.home_outlined),
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF0D7377),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              maxLines: 2,
                              validator: (v) => v?.isEmpty == true
                                  ? 'Address is required'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            // Date and Time row
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
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
                                        setDialogState(() {
                                          selectedDate = date;
                                          dateController.text =
                                              '${date.day}/${date.month}/${date.year}';
                                        });
                                        checkFormValidity(setDialogState);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: dateController.text.isNotEmpty
                                              ? const Color(0xFF0D7377)
                                              : Colors.grey[300]!,
                                          width: dateController.text.isNotEmpty
                                              ? 2
                                              : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color:
                                                dateController.text.isNotEmpty
                                                ? const Color(0xFF0D7377)
                                                : Colors.grey[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Date',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  dateController.text.isEmpty
                                                      ? 'Select'
                                                      : dateController.text,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        dateController
                                                            .text
                                                            .isEmpty
                                                        ? Colors.grey[400]
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (dateController.text.isNotEmpty)
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 18,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (time != null) {
                                        setDialogState(() {
                                          timeController.text = time.format(
                                            context,
                                          );
                                        });
                                        checkFormValidity(setDialogState);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: timeController.text.isNotEmpty
                                              ? const Color(0xFF0D7377)
                                              : Colors.grey[300]!,
                                          width: timeController.text.isNotEmpty
                                              ? 2
                                              : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color:
                                                timeController.text.isNotEmpty
                                                ? const Color(0xFF0D7377)
                                                : Colors.grey[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Time',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  timeController.text.isEmpty
                                                      ? 'Select'
                                                      : timeController.text,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        timeController
                                                            .text
                                                            .isEmpty
                                                        ? Colors.grey[400]
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (timeController.text.isNotEmpty)
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 18,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Terms & Conditions section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: termsAccepted
                                    ? Colors.green.withAlpha(15)
                                    : Colors.orange.withAlpha(15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: termsAccepted
                                      ? Colors.green.withAlpha(50)
                                      : Colors.orange.withAlpha(50),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.policy_outlined,
                                        color: termsAccepted
                                            ? Colors.green
                                            : Colors.orange,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Terms & Conditions',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: termsAccepted
                                              ? Colors.green[700]
                                              : Colors.orange[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (widget.service.customerResponsibility !=
                                          null &&
                                      widget
                                          .service
                                          .customerResponsibility!
                                          .isNotEmpty)
                                    _buildTermItem(
                                      'Customer Responsibility',
                                      widget.service.customerResponsibility!,
                                      Icons.person_outline,
                                    ),
                                  if (widget.service.note != null &&
                                      widget.service.note!.isNotEmpty)
                                    _buildTermItem(
                                      'Important Note',
                                      widget.service.note!,
                                      Icons.info_outline,
                                    ),
                                  const SizedBox(height: 8),
                                  // Checkbox
                                  InkWell(
                                    onTap: () {
                                      setDialogState(() {
                                        termsAccepted = !termsAccepted;
                                      });
                                      checkFormValidity(setDialogState);
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: termsAccepted
                                                ? const Color(0xFF0D7377)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: termsAccepted
                                                  ? const Color(0xFF0D7377)
                                                  : Colors.grey[400]!,
                                              width: 2,
                                            ),
                                          ),
                                          child: termsAccepted
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'I accept the terms & conditions and service policies',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Confirm Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (isBooking || !isFormValid)
                                    ? null
                                    : () async {
                                        if (formKey.currentState!.validate()) {
                                          setDialogState(
                                            () => isBooking = true,
                                          );
                                          try {
                                            final user =
                                                _authService.currentUser;

                                            if (user == null) {
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Please login to book',
                                                    ),
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
                                              serviceImageUrl: '',
                                              amount: widget.service.price,
                                              status: 'pending',
                                              bookingDate: selectedDate!,
                                              bookingTime: timeController.text,
                                              address: addressController.text,
                                              userPhone: user.phoneNumber ?? '',
                                              createdAt: DateTime.now(),
                                              termsAccepted: termsAccepted,
                                            );

                                            await _orderService.createOrder(
                                              order,
                                            );

                                            if (context.mounted) {
                                              Navigator.pop(
                                                context,
                                              ); // Close sheet
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      const Text(
                                                        'Order placed successfully!',
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } finally {
                                            if (context.mounted) {
                                              setDialogState(
                                                () => isBooking = false,
                                              );
                                            }
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFormValid
                                      ? const Color(0xFF0D7377)
                                      : Colors.grey[300],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: isFormValid ? 2 : 0,
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
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isFormValid
                                                ? Icons.check_circle
                                                : Icons.pending,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            isFormValid
                                                ? 'Confirm Booking'
                                                : termsAccepted
                                                ? 'Fill all fields'
                                                : 'Accept terms to continue',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTermItem(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Shorthand for service
    final service = widget.service;

    return Scaffold(
      body: Column(
        children: [
          // Persistent No Internet Banner
          if (_isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.errorColor,
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'No Internet Connection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Main Content
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: const Color(0xFF0D7377),
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Text(
                    service.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D7377), Color(0xFF14919B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: service.accept
                                    ? Colors.green.withAlpha(26)
                                    : Colors.red.withAlpha(26),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    service.accept
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: service.accept
                                        ? Colors.green
                                        : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    service.accept
                                        ? 'Available'
                                        : 'Unavailable',
                                    style: TextStyle(
                                      color: service.accept
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (service.isFavourite) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withAlpha(26),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Featured',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Customer Responsibility Section
                        if (service.customerResponsibility != null &&
                            service.customerResponsibility!.isNotEmpty)
                          _buildInfoSection(
                            icon: Icons.person_outline,
                            title: 'Customer Responsibility',
                            content: service.customerResponsibility!,
                            color: Colors.blue,
                          ),

                        // Provider Responsibility Section
                        if (service.providerResponsibility != null &&
                            service.providerResponsibility!.isNotEmpty)
                          _buildInfoSection(
                            icon: Icons.engineering_outlined,
                            title: 'Provider Responsibility',
                            content: service.providerResponsibility!,
                            color: Colors.orange,
                          ),

                        // Note Section
                        if (service.note != null && service.note!.isNotEmpty)
                          _buildInfoSection(
                            icon: Icons.note_alt_outlined,
                            title: 'Note',
                            content: service.note!,
                            color: Colors.purple,
                          ),

                        // GoBuddy Cares Section
                        if (service.goBuddyCares != null &&
                            service.goBuddyCares!.isNotEmpty)
                          _buildInfoSection(
                            icon: Icons.favorite_outline,
                            title: 'GoBuddy Cares',
                            content: service.goBuddyCares!,
                            color: const Color(0xFF0D7377),
                          ),

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Service Features
                        const Text(
                          'Service Features',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Feature tiles
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              _buildFeatureTile(
                                icon: Icons.verified,
                                iconColor: Colors.green,
                                title: 'Verified Professional',
                                subtitle: 'Background checked and trained',
                              ),
                              Divider(height: 1, color: Colors.grey[200]),
                              _buildFeatureTile(
                                icon: Icons.schedule,
                                iconColor: Colors.blue,
                                title: 'Flexible Scheduling',
                                subtitle: 'Book at your convenience',
                              ),
                              // Divider(height: 1, color: Colors.grey[200]),
                              // _buildFeatureTile(
                              //   icon: Icons.shield_outlined,
                              //   iconColor: Colors.purple,
                              //   title: 'Service Guarantee',
                              //   subtitle: '100% satisfaction or money back',
                              // ),
                              Divider(height: 1, color: Colors.grey[200]),
                              _buildFeatureTile(
                                icon: Icons.support_agent,
                                iconColor: Colors.orange,
                                title: '24/7 Support',
                                subtitle: 'Always here to help',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
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
