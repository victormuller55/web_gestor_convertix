abstract class FinanceiroEvent {}

class FinanceiroLoadEvent extends FinanceiroEvent {
  final bool forceRefresh;
  FinanceiroLoadEvent({this.forceRefresh = false});
}
