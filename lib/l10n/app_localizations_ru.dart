// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get login => 'ВХОД';

  @override
  String get testPhone => 'ТЕСТ НОМЕР: 99 888 77 66';

  @override
  String get loginTitle => 'Вход в систему';

  @override
  String get phoneHint => 'ВВЕДИТЕ НОМЕР ТЕЛЕФОНА';

  @override
  String get continueBtn => 'ПРОДОЛЖИТЬ';

  @override
  String get back => 'НАЗАД';

  @override
  String get confirm => 'Подтверждение';

  @override
  String codeSentTo(String phone) {
    return 'КОД ОТПРАВЛЕН НА +$phone';
  }

  @override
  String get verify => 'ПОДТВЕРДИТЬ';

  @override
  String get register => 'Регистрация';

  @override
  String registerForPhone(String phone) {
    return 'ДЛЯ НОМЕРА +$phone';
  }

  @override
  String get nameRequired => 'ИМЯ *';

  @override
  String get surname => 'ФАМИЛИЯ';

  @override
  String get address => 'АДРЕС';

  @override
  String get saveAndLogin => 'СОХРАНИТЬ И ВОЙТИ';

  @override
  String get profile => 'Профиль';

  @override
  String get logout => 'ВЫХОД';

  @override
  String get marketplace => 'MARKETPLACE';

  @override
  String get sum => 'сум';

  @override
  String get myAccount => 'МОЙ СЧЁТ';

  @override
  String get dillerMarketGold => 'Diller Market Gold';

  @override
  String get earnedSalary => 'ЗАРАБОТАННАЯ ЗАРПЛАТА';

  @override
  String get withdraw => 'ВЫВЕСТИ';

  @override
  String get salaryRules => 'ПРАВИЛА СИСТЕМЫ ЗАРПЛАТЫ';

  @override
  String get rule1 =>
      'За каждую покупку товара вам начисляется гарантированная зарплата.';

  @override
  String get rule2 =>
      'Заявка на вывод зарплаты рассматривается в течение 24 часов.';

  @override
  String get rule3 => 'Минимальная сумма вывода: 10 000 сум.';

  @override
  String get retry => 'ПОВТОРИТЬ';

  @override
  String get user => 'Пользователь';

  @override
  String get navDiller => 'ДИЛЕРЫ';

  @override
  String get navZakazlar => 'ЗАКАЗЫ';

  @override
  String get navSavat => 'КОРЗИНА';

  @override
  String get navProfile => 'ПРОФИЛЬ';

  @override
  String get locationPermission => 'Разрешение на местоположение';

  @override
  String get locationDesc =>
      'Разрешите доступ к местоположению для поиска ближайших дилеров';

  @override
  String get grantPermission => 'Разрешить';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get later => 'Позже';

  @override
  String get notifications => 'Уведомления';

  @override
  String get general => 'Общие';

  @override
  String get primary => 'Основные';

  @override
  String notificationsList(String type) {
    return '$type — уведомления';
  }

  @override
  String get zakazlar => 'Заказы';

  @override
  String get savat => 'Корзина';

  @override
  String get language => 'Язык';

  @override
  String get langUz => 'O\'zbekcha';

  @override
  String get langRu => 'Русский';

  @override
  String get settings => 'Настройки';

  @override
  String get notificationsSettings => 'Уведомления';

  @override
  String get dealerSearchHint => 'Поиск дилера...';

  @override
  String get categoryAll => 'ВСЕ';

  @override
  String get dealersEmpty => 'Дилеры не найдены';

  @override
  String get dealersEmptyHint => 'Попробуйте другую категорию или поиск';

  @override
  String get dealersError => 'Произошла ошибка';

  @override
  String get dealersErrorHint => 'Проверьте подключение к интернету';

  @override
  String get dealersLoading => 'Загрузка...';

  @override
  String get filter => 'Фильтр';

  @override
  String get filterCategory => 'Категория';

  @override
  String get filterRegion => 'Регион';

  @override
  String get filterApply => 'Применить';

  @override
  String get filterClear => 'Очистить';

  @override
  String get filterRegionAll => 'Все регионы';
}
