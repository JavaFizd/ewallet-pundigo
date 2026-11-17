import 'package:flutter_test/flutter_test.dart';
import 'package:pundigo/models/user_model.dart';
import 'package:pundigo/data/app_state.dart';

void main() {
  test('PundiGo AppState initialization and persona test', () {
    final appState = AppState.instance;
    expect(appState.user.name, isNotEmpty);
    expect(UserModel.computeInitials('Dinda Syahfitri'), 'DS');
    expect(UserModel.computeInitials('Taufiq'), 'TA');
  });
}
