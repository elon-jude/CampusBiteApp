//Jude Yankson - 2425400769 - Group 1
import 'package:flutter/material.dart';

void main() {
  runApp(const CampusBitesApp());
}

class MenuItem {
  final String name;
  final double price;
  final String category;

  MenuItem({
    required this.name,
    required this.price,
    required this.category,
  });
}
class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({
    required this.item,
    this.quantity = 1,
  });

  double get subtotal => item.price * quantity;
}

//the menu items
final List<MenuItem> menuItems = [
  MenuItem(
    name: 'Jollof Rice',
    price: 25.00,
    category: 'Meals',
  ),
  MenuItem(
    name: 'Fried Rice',
    price: 28.00,
    category: 'Meals',
  ),
  MenuItem(
    name: 'Waakye',
    price: 22.00,
    category: 'Meals',
  ),
  MenuItem(
    name: 'Chicken Burger',
    price: 30.00,
    category: 'Meals',
  ),
  MenuItem(
    name: 'Coke',
    price: 8.00,
    category: 'Drinks',
  ),
  MenuItem(
    name: 'Malt',
    price: 10.00,
    category: 'Drinks',
  ),
  MenuItem(
    name: 'Bottled Water',
    price: 5.00,
    category: 'Drinks',
  ),
];

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onAdd;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.category,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 239, 176, 210),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'GH₵ ${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onAdd,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}


class CampusBitesApp extends StatefulWidget {
  const CampusBitesApp({super.key});

  @override
  State<CampusBitesApp> createState() => _CampusBitesAppState();
}

class _CampusBitesAppState extends State<CampusBitesApp> {
  final List<CartItem> cart = [];

  void addToCart(MenuItem item) {
    setState(() {
      final existingIndex = cart.indexWhere(
        (cartItem) => cartItem.item.name == item.name,
      );

      if (existingIndex != -1) {
        cart[existingIndex].quantity++;
      } else {
        cart.add(
          CartItem(item: item),
        );
      }
    });
  }

  void clearCart() {
    setState(() {
      cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusBites',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: MenuScreen(
        cart: cart,
        onAddToCart: addToCart,
      ),
    );
  }
}


class MenuScreen extends StatefulWidget {
  final List<CartItem> cart;
  final Function(MenuItem) onAddToCart;

  const MenuScreen({
    super.key,
    required this.cart,
    required this.onAddToCart,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  void addItem(MenuItem item) {
    widget.onAddToCart(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        duration: const Duration(seconds: 1),
      ),
    );

    setState(() {});
  }

  void openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cart: widget.cart,
        ),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = widget.cart.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CampusBites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: openCart,
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(
                Icons.shopping_cart,
              ),
            ),
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];

          return MenuItemCard(
            item: item,
            onAdd: () {
              addItem(item);
            },
          );
        },
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final List<CartItem> cart;

  const CartScreen({
    super.key,
    required this.cart,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  String? pickupTime;

  double get total {
    return widget.cart.fold<double>(
      0,
      (sum, cartItem) => sum + cartItem.subtotal,
    );
  }

  void increaseQuantity(int index) {
    setState(() {
      widget.cart[index].quantity++;
    });
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (widget.cart[index].quantity > 1) {
        widget.cart[index].quantity--;
      } else {
        widget.cart.removeAt(index);
      }
    });
  }

  void removeItem(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });
  }

  void checkout() {
    if (widget.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add items to your cart first.',
          ),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final orderNumber =
          'CB-${DateTime.now().millisecondsSinceEpoch}';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            name: nameController.text.trim(),
            phone: phoneController.text.trim(),
            pickupTime: pickupTime!,
            cart: List<CartItem>.from(widget.cart),
            total: total,
            orderNumber: orderNumber,
            onNewOrder: () {
              widget.cart.clear();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Cart'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 70,
                color: Colors.grey,
              ),
              SizedBox(height: 15),
              Text(
                'Your cart is empty.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add something delicious from the menu!',
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // CART ITEMS
            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                final cartItem = widget.cart[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItem.item.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'GH₵ ${cartItem.item.price.toStringAsFixed(2)} each',
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Subtotal: GH₵ ${cartItem.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                decreaseQuantity(index);
                              },
                              icon: const Icon(
                                Icons.remove_circle_outline,
                              ),
                            ),

                            Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                increaseQuantity(index);
                              },
                              icon: const Icon(
                                Icons.add_circle_outline,
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                removeItem(index);
                              },
                              icon: const Icon(
                                Icons.delete,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

           
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: GH₵ ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Checkout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

          
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: phoneController,
                    keyboardType:
                        TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '0241234567',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          !RegExp(
                            r'^0\d{9}$',
                          ).hasMatch(value.trim())) {
                        return 'Enter exactly 10 digits starting with 0';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    initialValue: pickupTime,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Time',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '10:00',
                        child: Text('10:00'),
                      ),
                      DropdownMenuItem(
                        value: '12:00',
                        child: Text('12:00'),
                      ),
                      DropdownMenuItem(
                        value: '14:00',
                        child: Text('14:00'),
                      ),
                      DropdownMenuItem(
                        value: '16:00',
                        child: Text('16:00'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        pickupTime = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a pickup time';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: checkout,
                      child: const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class ReceiptScreen extends StatelessWidget {
  final String name;
  final String phone;
  final String pickupTime;
  final List<CartItem> cart;
  final double total;
  final String orderNumber;
  final VoidCallback onNewOrder;

  const ReceiptScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.pickupTime,
    required this.cart,
    required this.total,
    required this.orderNumber,
    required this.onNewOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'), 
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Center(
              child: Icon(
                Icons.check_circle,
                size: 70,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Order Number: $orderNumber',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text('Customer: $name'),
            Text('Phone: $phone'),
            Text('Pickup Time: $pickupTime'),

            const Divider(height: 30),

            const Text(
              'Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final cartItem = cart[index];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,

                    title: Text(
                      cartItem.item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      '${cartItem.item.category} • Quantity: ${cartItem.quantity}',
                    ),

                    trailing: Text(
                      'GH₵ ${cartItem.subtotal.toStringAsFixed(2)}',
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            Text(
              'Total: GH₵ ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onNewOrder();

                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );
                },
                child: const Text(
                  'New Order',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

