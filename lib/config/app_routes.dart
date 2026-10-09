class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String leads = '/leads';
  static const String leadDetail = '/leads/:id';
  static const String pipeline = '/pipeline';
  static const String quotes = '/quotes';
  static const String quotationDetail = '/quotes/:id';
  static const String customers = '/customers';
  static const String customerDetail = '/customers/:id';
  static const String tasks = '/tasks';
  static const String campaigns = '/campaigns';
  static const String reports = '/reports';
  static const String settings = '/settings';

  static String leadDetailWithId(String id) => '/leads/$id';
  static String quotationDetailWithId(String id) => '/quotes/$id';
  static String customerDetailWithId(String id) => '/customers/$id';
}
