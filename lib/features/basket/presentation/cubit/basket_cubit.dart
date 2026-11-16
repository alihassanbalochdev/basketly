import 'package:basketly/features/basket/data/basket_storage.dart';
import 'package:basketly/features/basket/domain/basket_line.dart';
import 'package:basketly/features/basket/domain/basket_pricing.dart';
import 'package:basketly/features/basket/presentation/cubit/basket_state.dart';
import 'package:basketly/features/catalog/domain/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BasketCubit extends Cubit<BasketState> {
  /// No storage (as in tests) means the basket lives in memory only.
  BasketCubit([this._storage]) : super(const BasketState());

  final BasketStorage? _storage;

  /// Loads the basket saved last time. Called once, when the app starts.
  Future<void> restore() async {
    final saved = await _storage?.load();
    if (saved == null || isClosed) return;
    emit(BasketState(
      lines: Map.unmodifiable({for (final line in saved.lines) line.key: line}),
      promoCode: saved.promoCode,
    ));
  }

  /// Every new state is written to the device. One place, so no
  /// method can forget to save.
  @override
  void onChange(Change<BasketState> change) {
    super.onChange(change);
    final next = change.nextState;
    _storage?.save(next.lines.values.toList(), next.promoCode);
  }

  void add(Product product, {int quantity = 1, String? size, String? colour}) {
    final key = lineKey(product.id, size: size, colour: colour);
    final current = state.lines[key]?.quantity ?? 0;

    _setLine(key, BasketLine(
      product: product,
      quantity: current + quantity,
      size: size,
      colour: colour,
    ));
  }

  /// [key] is a [BasketLine.key]. Zero or less removes the line.
  void setQuantity(String key, int quantity) {
    final line = state.lines[key];
    if (line == null) return;
    if (quantity <= 0) {
      remove(key);
    } else {
      _setLine(key, line.copyWith(quantity: quantity));
    }
  }

  /// Removes a line and returns it, so the screen can offer Undo.
  BasketLine? remove(String key) {
    final line = state.lines[key];
    if (line == null) return null;
    final next = Map.of(state.lines)..remove(key);
    emit(state.copyWith(lines: Map.unmodifiable(next)));
    return line;
  }

  /// Puts back a line that [remove] took out.
  void restoreLine(BasketLine line) => _setLine(line.key, line);

  /// Returns false when the code doesn't exist.
  bool applyPromo(String code) {
    final promo = findPromo(code);
    if (promo == null) return false;
    emit(state.copyWith(promoCode: () => promo.code));
    return true;
  }

  void clearPromo() => emit(state.copyWith(promoCode: () => null));

  /// Empties the basket after an order is placed.
  void clear() => emit(const BasketState());

  void _setLine(String key, BasketLine line) {
    final next = Map.of(state.lines)..[key] = line;
    emit(state.copyWith(lines: Map.unmodifiable(next)));
  }
}
