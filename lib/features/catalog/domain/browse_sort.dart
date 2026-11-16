/// Each sort option knows its label and how Supabase should order rows.
enum BrowseSort {
  popular('Most popular', 'popularity', ascending: false),
  priceLow('Price: low to high', 'price', ascending: true),
  priceHigh('Price: high to low', 'price', ascending: false),
  newest('Newest', 'created_at', ascending: false);

  const BrowseSort(this.label, this.column, {required this.ascending});

  final String label;
  final String column;
  final bool ascending;
}
