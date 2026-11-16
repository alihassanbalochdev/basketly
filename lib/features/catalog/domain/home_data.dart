import 'package:basketly/features/catalog/domain/department.dart';
import 'package:basketly/features/catalog/domain/product.dart';

/// Everything the Home screen needs, fetched together.
typedef HomeData = ({
  List<Department> departments,
  Product? deal,
  List<Product> buyAgain,
});
