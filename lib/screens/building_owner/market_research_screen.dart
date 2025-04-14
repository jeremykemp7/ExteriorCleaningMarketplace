import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/navigation_service.dart';
import 'package:intl/intl.dart';

class MarketResearchScreen extends StatefulWidget {
  const MarketResearchScreen({super.key});

  static void navigate() {
    final context = NavigationService.context;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MarketResearchScreen(),
        ),
      );
    }
  }

  @override
  State<MarketResearchScreen> createState() => _MarketResearchScreenState();
}

class _MarketResearchScreenState extends State<MarketResearchScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  
  String? _selectedCity;
  String? _selectedBuildingType;
  double? _minPrice;
  double? _maxPrice;
  double? _minArea;
  double? _maxArea;

  // Analytics data
  double _averagePrice = 0;
  double _averagePricePerSqFt = 0;
  int _totalListings = 0;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final properties = await _firestore
          .collection('properties')
          .where('status', isEqualTo: 'available')
          .get();

      if (properties.docs.isEmpty) return;

      double totalPrice = 0;
      double totalPricePerSqFt = 0;
      int count = 0;

      for (var doc in properties.docs) {
        final data = doc.data();
        final price = (data['price'] as num).toDouble();
        final area = (data['squareFootage'] as num).toDouble();
        
        totalPrice += price;
        totalPricePerSqFt += price / area;
        count++;
      }

      setState(() {
        _totalListings = count;
        _averagePrice = totalPrice / count;
        _averagePricePerSqFt = totalPricePerSqFt / count;
      });
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    }
  }

  Widget _buildAnalyticsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticItem(
                    'Average Price',
                    _currencyFormat.format(_averagePrice),
                    Icons.attach_money,
                  ),
                ),
                Expanded(
                  child: _buildAnalyticItem(
                    'Price per Sq Ft',
                    _currencyFormat.format(_averagePricePerSqFt),
                    Icons.square_foot,
                  ),
                ),
                Expanded(
                  child: _buildAnalyticItem(
                    'Total Listings',
                    _totalListings.toString(),
                    Icons.list_alt,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        title: const Text('Filters'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'City',
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All Cities')),
                          DropdownMenuItem(value: 'New York', child: Text('New York')),
                          DropdownMenuItem(value: 'Los Angeles', child: Text('Los Angeles')),
                          // Add more cities as needed
                        ],
                        onChanged: (value) => setState(() => _selectedCity = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBuildingType,
                        decoration: const InputDecoration(
                          labelText: 'Building Type',
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All Types')),
                          DropdownMenuItem(value: 'Office', child: Text('Office')),
                          DropdownMenuItem(value: 'Retail', child: Text('Retail')),
                          DropdownMenuItem(value: 'Residential', child: Text('Residential')),
                          // Add more types as needed
                        ],
                        onChanged: (value) => setState(() => _selectedBuildingType = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Min Price',
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => _minPrice = double.tryParse(value)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Max Price',
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => _maxPrice = double.tryParse(value)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Min Area (sq ft)',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => _minArea = double.tryParse(value)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Max Area (sq ft)',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => _maxArea = double.tryParse(value)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildFilteredQuery(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final properties = snapshot.data?.docs ?? [];

        if (properties.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No Properties Found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: properties.length,
          itemBuilder: (context, index) => _buildPropertyCard(properties[index]),
        );
      },
    );
  }

  Stream<QuerySnapshot> _buildFilteredQuery() {
    Query query = _firestore.collection('properties')
        .where('status', isEqualTo: 'available')
        .orderBy('price');

    if (_selectedCity != null) {
      query = query.where('city', isEqualTo: _selectedCity);
    }
    
    if (_selectedBuildingType != null) {
      query = query.where('buildingType', isEqualTo: _selectedBuildingType);
    }

    // Note: Additional filtering for price and area ranges will be done in memory
    // as Firestore doesn't support multiple range filters

    return query.snapshots();
  }

  Widget _buildPropertyCard(DocumentSnapshot property) {
    final data = property.data() as Map<String, dynamic>;
    final price = (data['price'] as num).toDouble();
    final area = (data['squareFootage'] as num).toDouble();
    final pricePerSqFt = price / area;

    // Apply in-memory filters for price and area
    if (_minPrice != null && price < _minPrice!) return const SizedBox.shrink();
    if (_maxPrice != null && price > _maxPrice!) return const SizedBox.shrink();
    if (_minArea != null && area < _minArea!) return const SizedBox.shrink();
    if (_maxArea != null && area > _maxArea!) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${data['buildingType']} in ${data['city']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currencyFormat.format(price),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      '${_currencyFormat.format(pricePerSqFt)}/sq ft',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.square_foot, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${NumberFormat('#,##0').format(area)} sq ft',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    data['address'] as String,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (data['description'] != null) ...[
              const SizedBox(height: 8),
              Text(
                data['description'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Research'),
      ),
      body: Column(
        children: [
          _buildAnalyticsCard(),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildPropertyList(),
          ),
        ],
      ),
    );
  }
} 