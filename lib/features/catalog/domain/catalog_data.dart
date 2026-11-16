import 'package:basketly/features/catalog/domain/department.dart';
import 'package:basketly/features/catalog/domain/product.dart';

typedef BrowseData = ({List<Department> departments, List<Product> products});

typedef ProductDetail = ({Product product, Department department});
