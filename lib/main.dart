import 'package:cipshoe/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/shoe_item.dart';
import 'services/storage_service.dart';
import 'services/dashboard_service.dart';
import 'services/logger_service.dart';
import 'screens/web_view_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerService.log('Starting CipShoe App...',
      level: LogLevel.info, tag: 'App');

  // Check if webview should be shown
  LoggerService.log('Checking if WebView should be shown',
      level: LogLevel.debug, tag: 'WebView');
  bool showWebView = await DashboardService.shouldShowWebView();
  LoggerService.log('WebView should be shown: $showWebView',
      level: showWebView ? LogLevel.info : LogLevel.debug, tag: 'WebView');

  // Get the webview URL
  String webViewUrl = await DashboardService.getWebViewUrl();
  LoggerService.log('WebView URL: $webViewUrl',
      level: LogLevel.debug, tag: 'WebView');

  LoggerService.log('Initializing UI...', level: LogLevel.info, tag: 'App');
  runApp(ShoeAIApp(
    showWebView: showWebView,
    webViewUrl: webViewUrl,
  ));
}

class ShoeAIApp extends StatelessWidget {
  final bool showWebView;
  final String webViewUrl;

  const ShoeAIApp(
      {super.key,
      this.showWebView = false,
      this.webViewUrl = 'https://cipshoe-dashboard.com/app'});

  @override
  Widget build(BuildContext context) {
    LoggerService.log('Building app with WebView: $showWebView',
        level: LogLevel.debug, tag: 'UI');
    return MaterialApp(
      title: 'CipShoe AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3D5AFE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D5AFE),
          secondary: const Color(0xFFFF8A65),
          background: Colors.grey[50]!,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Poppins',
        cardTheme: CardTheme(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadowColor: Colors.black26,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF3D5AFE),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3D5AFE), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: showWebView ? WebViewScreen(url: webViewUrl) : const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<ShoeItem> inventory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    LoggerService.log('Initializing HomeScreen',
        level: LogLevel.debug, tag: 'HomeScreen');
    _tabController = TabController(length: 3, vsync: this);
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    LoggerService.log('Loading inventory from storage',
        level: LogLevel.info, tag: 'Inventory');
    final loadedInventory = await StorageService.loadInventory();
    LoggerService.log('Loaded ${loadedInventory.length} items from storage',
        level: LogLevel.success, tag: 'Inventory');
    setState(() {
      inventory.clear();
      inventory.addAll(loadedInventory);
      _isLoading = false;
    });
  }

  Future<void> _saveInventory() async {
    LoggerService.log('Saving inventory with ${inventory.length} items',
        level: LogLevel.info, tag: 'Inventory');
    await StorageService.saveInventory(inventory);
    LoggerService.log('Inventory saved successfully',
        level: LogLevel.success, tag: 'Inventory');
  }

  void _updateInventory() {
    LoggerService.log('Updating inventory UI',
        level: LogLevel.debug, tag: 'Inventory');
    setState(() {});
    _saveInventory();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Loading inventory...',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CipShoe AI',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
            ),
            child: TabBar(
              controller: _tabController,
              // padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              indicator: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.zero,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.white,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              dividerColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2),
                      SizedBox(width: 2),
                      Text('Inventory'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bar_chart),
                      SizedBox(width: 2),
                      Text('Analytics'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.smart_toy),
                      SizedBox(width: 2),
                      Text('AI Assistant'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.grey[50]!,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            InventoryTab(
                inventory: inventory, onInventoryChanged: _updateInventory),
            AnalyticsTab(inventory: inventory),
            AIAssistantTab(inventory: inventory),
          ],
        ),
      ),
    );
  }
}

class InventoryTab extends StatefulWidget {
  final List<ShoeItem> inventory;
  final VoidCallback onInventoryChanged;

  const InventoryTab(
      {super.key, required this.inventory, required this.onInventoryChanged});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  List<ShoeItem> filteredInventory = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedCategory = 'Casual';
  final List<String> categories = ['Casual', 'Sports', 'Formal', 'Running'];

  @override
  void initState() {
    super.initState();
    filteredInventory = widget.inventory;
  }

  void _addShoe() {
    LoggerService.log('Opening add shoe form',
        level: LogLevel.debug, tag: 'Inventory');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Add New Shoe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                    controller: _nameController,
                    decoration:
                        _inputDecoration('Shoe Name', Icons.shopping_bag)),
                const SizedBox(height: 16),
                TextField(
                  controller: _priceController,
                  decoration: _inputDecoration('Price', Icons.attach_money,
                      prefixText: '\$ '),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _sizeController,
                  decoration: _inputDecoration('Size', Icons.straighten),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _quantityController,
                  decoration: _inputDecoration('Quantity', Icons.inventory),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _inputDecoration('Category', Icons.category),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                        value: category, child: Text(category));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty &&
                        _priceController.text.isNotEmpty &&
                        _sizeController.text.isNotEmpty &&
                        _quantityController.text.isNotEmpty) {
                      setState(() {
                        final newShoe = ShoeItem(
                          name: _nameController.text,
                          price: double.parse(_priceController.text),
                          size: double.parse(_sizeController.text),
                          quantity: int.parse(_quantityController.text),
                          category: _selectedCategory,
                          lastUpdated: DateTime.now(),
                        );
                        widget.inventory.add(newShoe);
                        filteredInventory = widget.inventory;
                        widget.onInventoryChanged();
                      });
                      _clearFields();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Add to Inventory',
                      style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  void _clearFields() {
    _nameController.clear();
    _priceController.clear();
    _sizeController.clear();
    _quantityController.clear();
    _selectedCategory = 'Casual';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Items',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white70),
                    ),
                    Text(
                      '${widget.inventory.length}',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Low Stock Items',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white70),
                    ),
                    Text(
                      '${widget.inventory.where((shoe) => shoe.quantity < 5).length}',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredInventory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items in inventory',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add shoes',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredInventory.length,
                    itemBuilder: (context, index) {
                      return ShoeCard(
                        shoe: filteredInventory[index],
                        onDelete: () {
                          setState(() {
                            widget.inventory.remove(filteredInventory[index]);
                            filteredInventory = widget.inventory;
                            widget.onInventoryChanged();
                          });
                        },
                        onUpdateQuantity: (newQuantity) {
                          setState(() {
                            filteredInventory[index].quantity = newQuantity;
                            filteredInventory[index].lastUpdated =
                                DateTime.now();
                            widget.onInventoryChanged();
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addShoe,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

class AnalyticsTab extends StatelessWidget {
  final List<ShoeItem> inventory;

  const AnalyticsTab({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    if (inventory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to see analytics',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final totalValue =
        inventory.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final avgPrice = totalValue / inventory.length;
    final categoryCount = <String, int>{};
    for (var shoe in inventory) {
      categoryCount[shoe.category] = (categoryCount[shoe.category] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights,
                        color: Colors.white.withOpacity(0.9), size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Inventory Analytics',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                const Divider(color: Colors.white30, height: 24),
                Text('Total Items: ${inventory.length}',
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Total Value: \$${totalValue.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Average Price: \$${avgPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text('Category Distribution',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...categoryCount.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${entry.value} (${((entry.value / inventory.length) * 100).toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: entry.value / inventory.length,
                                backgroundColor: Colors.grey[200],
                                color: Theme.of(context).primaryColor,
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.watch_later,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text('Stock Status',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatusRow(
                      context,
                      'Low Stock',
                      inventory.where((shoe) => shoe.quantity < 5).length,
                      Colors.red),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                      context,
                      'Medium Stock',
                      inventory
                          .where((shoe) =>
                              shoe.quantity >= 5 && shoe.quantity < 15)
                          .length,
                      Colors.orange),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                      context,
                      'Well Stocked',
                      inventory.where((shoe) => shoe.quantity >= 15).length,
                      Colors.green),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
      BuildContext context, String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        Text(
          '$count items',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class AIAssistantTab extends StatefulWidget {
  final List<ShoeItem> inventory;

  const AIAssistantTab({super.key, required this.inventory});

  @override
  State<AIAssistantTab> createState() => _AIAssistantTabState();
}

class _AIAssistantTabState extends State<AIAssistantTab> {
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;

  Future<void> _askAI(String question) async {
    if (question.trim().isEmpty) return;

    LoggerService.log('Sending question to AI: "$question"',
        level: LogLevel.info, tag: 'AI');

    setState(() {
      _chatHistory.add({'user': question});
      _questionController.clear();
      _isLoading = true;
    });

    try {
      String inventorySummary = _generateInventorySummary();
      LoggerService.log('Generated inventory summary for AI context',
          level: LogLevel.debug, tag: 'AI');

      LoggerService.log('Calling GPT API...', level: LogLevel.info, tag: 'AI');
      String response = await _callGPT35Turbo(question, inventorySummary);

      LoggerService.log('Received AI response',
          level: LogLevel.success, tag: 'AI');
      setState(() {
        _chatHistory.add({'ai': response});
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.log('Error calling AI service: $e',
          level: LogLevel.error, tag: 'AI');
      setState(() {
        _chatHistory
            .add({'ai': 'Error: Could not connect to AI service. ($e)'});
        _isLoading = false;
      });
    }
  }

  String _generateInventorySummary() {
    if (widget.inventory.isEmpty) return "The inventory is currently empty.";
    final totalValue = widget.inventory
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final categoryCount = <String, int>{};
    for (var shoe in widget.inventory) {
      categoryCount[shoe.category] = (categoryCount[shoe.category] ?? 0) + 1;
    }
    return "Current inventory: ${widget.inventory.length} items, total value: \$${totalValue.toStringAsFixed(2)}. Categories: ${categoryCount.entries.map((e) => "${e.key}: ${e.value}").join(", ")}. Low stock items (<5): ${widget.inventory.where((shoe) => shoe.quantity < 5).length}.";
  }

  Future<String> _callGPT35Turbo(
      String question, String inventorySummary) async {
    const String url = 'https://api.openai.com/v1/chat/completions';
    LoggerService.log('Making HTTP request to OpenAI',
        level: LogLevel.debug, tag: 'API');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': API_KEY,
    };

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content':
              'You are an AI assistant specialized in shoe inventory management. Provide accurate, concise answers based on the given inventory data and general knowledge about shoes and inventory practices. Inventory summary: $inventorySummary',
        },
        {
          'role': 'user',
          'content': question,
        },
      ],
      'max_tokens': 150,
      'temperature': 0.7,
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      LoggerService.log('API request successful (${response.statusCode})',
          level: LogLevel.success, tag: 'API');
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      LoggerService.log('API request failed with status ${response.statusCode}',
          level: LogLevel.error, tag: 'API');
      throw Exception(
          'Failed to get response from GPT-3.5 Turbo: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _chatHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.smart_toy,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'AI Assistant',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Ask me anything about your inventory or shoes!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == _chatHistory.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('Thinking...'),
                              ],
                            ),
                          ),
                        );
                      }

                      final message = _chatHistory[index];
                      final isUser = message.containsKey('user');

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).primaryColor
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight:
                                  isUser ? const Radius.circular(0) : null,
                              bottomLeft:
                                  !isUser ? const Radius.circular(0) : null,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            isUser ? message['user']! : message['ai']!,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: 'Ask about inventory or shoes...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24)),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    prefixIcon: Icon(Icons.search,
                        color: Theme.of(context).primaryColor),
                  ),
                  onSubmitted: _askAI,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _askAI(_questionController.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShoeCard extends StatelessWidget {
  final ShoeItem shoe;
  final VoidCallback onDelete;
  final Function(int) onUpdateQuantity;

  const ShoeCard({
    super.key,
    required this.shoe,
    required this.onDelete,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    Color stockColor;
    String stockStatus;

    if (shoe.quantity < 5) {
      stockColor = Colors.red;
      stockStatus = "LOW";
    } else if (shoe.quantity < 15) {
      stockColor = Colors.orange;
      stockStatus = "MEDIUM";
    } else {
      stockColor = Colors.green;
      stockStatus = "GOOD";
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    shoe.name,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: stockColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$stockStatus STOCK',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: stockColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(context, Icons.attach_money,
                    '\$${shoe.price.toStringAsFixed(2)}'),
                const SizedBox(width: 8),
                _buildInfoChip(context, Icons.straighten, 'Size ${shoe.size}'),
                const SizedBox(width: 8),
                _buildInfoChip(context, Icons.category, shoe.category),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Updated: ${_formatDate(shoe.lastUpdated)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (shoe.quantity > 0) {
                          onUpdateQuantity(shoe.quantity - 1);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${shoe.quantity}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: stockColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onUpdateQuantity(shoe.quantity + 1),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
