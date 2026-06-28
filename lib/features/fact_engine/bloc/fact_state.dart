part of 'fact_bloc.dart';

sealed class FactState extends Equatable {
  const FactState();
  @override
  List<Object?> get props => [];
}

class FactInitial extends FactState {
  const FactInitial();
}

class FactLoading extends FactState {
  const FactLoading();
}

class FactReady extends FactState {
  const FactReady(this.fact);
  final FactEntity fact;
  @override
  List<Object?> get props => [fact];
}

/// Every eligible fact has been shown this session.
class FactDepleted extends FactState {
  const FactDepleted();
}

class FactFailure extends FactState {
  const FactFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
