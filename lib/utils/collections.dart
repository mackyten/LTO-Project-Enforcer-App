import 'package:enforcer_auto_fine/enums/collections.dart';

extension CollectionsExtension on Collections {
  String get name {
    switch (this) {
      case Collections.reports:
        return 'reports';
      case Collections.enforcers:
        return 'enforcers';
      case Collections.enforcerIdType:
        return 'enforcer_id_type';
    }
  }
}
