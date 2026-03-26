import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/presentation/pages/cart_page.dart';
import 'package:front_end/features/auth/presentation/pages/favorites_page.dart';
import 'package:front_end/features/auth/presentation/pages/my_orders_page.dart';
import 'package:image_picker/image_picker.dart';
import 'buyer_home_page.dart';
import 'package:front_end/features/auth/presentation/pages/customer_home.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_state.dart';
import 'package:front_end/features/auth/presentation/cubit/favorite_cubit.dart';
import 'package:front_end/features/auth/presentation/cubit/favorite_state.dart';
import 'package:front_end/features/auth/presentation/cubit/cart_cubit.dart';
import 'package:front_end/features/auth/presentation/cubit/cart_state.dart';
import 'package:front_end/features/auth/presentation/cubit/order_cubit.dart'; 
import 'package:front_end/features/auth/presentation/cubit/order_state.dart';
import 'login_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  int? _selectedShopId;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  int _unreadFavoritesCount = 0;
  int _lastTotalFavorites = 0;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _goToProducts(int shopId) {
    setState(() {
      _selectedShopId = shopId;
      _selectedIndex = 0; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        String currentUsername = "Guest User";
        String currentUserEmail = "No Email Provided";

        if (authState is AuthSuccess) {
          currentUsername = authState.user.username;
          currentUserEmail = authState.user.email;
        }

        Widget homeContent;
        if (_selectedShopId == null) {
          homeContent = BuyerHomePage(onShopSelected: _goToProducts);
        } else {
          homeContent = CustomerHomePage(shopId: _selectedShopId!);
        }

        List<Widget> pages = [
          homeContent, 
          const FavoritesPage(),
          const MyOrdersPage(),
          const CartPage(), 
        ];

        return MultiBlocListener(
          listeners: [
            BlocListener<FavoriteCubit, FavoriteState>(
              listener: (context, favState) {
                if (favState is FavoriteLoaded) {
                  if (favState.favorites.length > _lastTotalFavorites && _selectedIndex != 1) {
                    setState(() {
                      _unreadFavoritesCount += (favState.favorites.length - _lastTotalFavorites);
                    });
                  }
                  _lastTotalFavorites = favState.favorites.length;
                }
              },
            ),
          ],
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color(0xFFF0F2F5),
            drawer: _buildModernDrawer(context, currentUsername, currentUserEmail),
            appBar: AppBar(
              title: const Text(
                "DEVICE HUB",
                style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.notes_rounded, size: 30, color: Color(0xFF1A237E)),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: _buildCircularAvatar(35),
                  ),
                ),
              ],
            ),
            body: pages[_selectedIndex],
            bottomNavigationBar: _buildBottomNav(),
            extendBody: true, 
          ),
        );
      },
    );
  }

  Widget _buildModernDrawer(BuildContext context, String name, String email) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(30))),
      child: Column(
        children: [
          Container(
            height: 230,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      _buildCircularAvatar(85),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.camera_alt, size: 15, color: Color(0xFF1A237E)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text("All Shops"),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0;
                _selectedShopId = null; 
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text("My Cart"),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: const Text("My Orders"),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 2);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCircularAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: _profileImage != null
            ? Image.file(_profileImage!, fit: BoxFit.cover)
            : Icon(Icons.person, size: size * 0.6, color: const Color(0xFF1A237E)),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 20),
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_filled, 0),
          _favoriteNavItem(1), 
          _ordersNavItem(2), 
          _cartNavItem(3), 
        ],
      ),
    );
  }

  Widget _favoriteNavItem(int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() { _selectedIndex = index; _unreadFavoritesCount = 0; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Badge(
          label: Text(_unreadFavoritesCount.toString()),
          isLabelVisible: _unreadFavoritesCount > 0, 
          backgroundColor: Colors.red,
          child: Icon(
            Icons.favorite,
            color: isSelected ? const Color(0xFF1A237E) : Colors.white70,
            size: isSelected ? 28 : 24,
          ),
        ),
      ),
    );
  }

  Widget _ordersNavItem(int index) {
    bool isSelected = _selectedIndex == index;
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, orderState) {
        int orderCount = 0;
        if (orderState is OrdersLoaded) {
          orderCount = orderState.orders.length;
        }
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Badge(
              label: Text(orderCount.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
              isLabelVisible: orderCount > 0,
              backgroundColor: Colors.red,
              child: Icon(
                Icons.local_shipping_rounded,
                color: isSelected ? const Color(0xFF1A237E) : Colors.white70,
                size: isSelected ? 28 : 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cartNavItem(int index) {
    bool isSelected = _selectedIndex == index;
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        int cartCount = 0;
        if (cartState is CartUpdated) { 
          cartCount = cartState.items.length; 
        }
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Badge(
              label: Text(cartCount.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
              isLabelVisible: cartCount > 0,
              backgroundColor: Colors.red,
              child: Icon(
                Icons.shopping_cart,
                color: isSelected ? const Color(0xFF1A237E) : Colors.white70,
                size: isSelected ? 28 : 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          if (index == 0) _selectedShopId = null; 
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF1A237E) : Colors.white70,
          size: isSelected ? 28 : 24,
        ),
      ),
    );
  }
}