import 'package:basketly/features/catalog/domain/browse_sort.dart';
import 'package:basketly/features/catalog/domain/department.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum BrowseStatus { loading, ready, error }

/// One class, not sealed states: the chosen filters must survive while
/// new results load, so the chips don't jump back.
class BrowseState extends Equatable {
  const BrowseState({
    this.department,
    this.sort = BrowseSort.popular,
    this.status = BrowseStatus.loading,
    this.departments = const [],
    this.products = const [],
    this.message = '',
  });

  final String? department; // null = everything
  final BrowseSort sort;
  final BrowseStatus status;
  final List<Department> departments;
  final List<Product> products;
  final String message;

  Department? get selectedDepartment {
    for (final d in departments) {
      if (d.slug == department) return d;
    }
    return null;
  }

  BrowseState copyWith({
    ValueGetter<String?>? department, // a function, so null can be set on purpose
    BrowseSort? sort,
    BrowseStatus? status,
    List<Department>? departments,
    List<Product>? products,
    String? message,
  }) {
    return BrowseState(
      department: department != null ? department() : this.department,
      sort: sort ?? this.sort,
      status: status ?? this.status,
      departments: departments ?? this.departments,
      products: products ?? this.products,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [department, sort, status, departments, products, message];
}
