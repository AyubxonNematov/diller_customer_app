// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get login => 'KIRISH';

  @override
  String get testPhone => 'TEST RAQAM: 99 888 77 66';

  @override
  String get loginTitle => 'Tizimga kirish';

  @override
  String get phoneHint => 'TELEFON RAQAMINGIZNI KIRITING';

  @override
  String get continueBtn => 'DAVOM ETISH';

  @override
  String get back => 'ORQAGA';

  @override
  String get confirm => 'Tasdiqlash';

  @override
  String codeSentTo(String phone) {
    return '+$phone RAQAMIGA KOD YUBORILDI';
  }

  @override
  String get verify => 'TASDIQLASH';

  @override
  String get register => 'Ro\'yxatdan o\'tish';

  @override
  String registerForPhone(String phone) {
    return '+$phone RAQAMI UCHUN';
  }

  @override
  String get nameRequired => 'ISM *';

  @override
  String get surname => 'FAMILIYA';

  @override
  String get address => 'MANZIL';

  @override
  String get saveAndLogin => 'SAQLASH VA KIRISH';

  @override
  String get profile => 'Profil';

  @override
  String get logout => 'CHIQISH';

  @override
  String get marketplace => 'MARKETPLACE';

  @override
  String get sum => 'sum';

  @override
  String get myAccount => 'MENING HISOBIM';

  @override
  String get dillerMarketGold => 'Diller Market Gold';

  @override
  String get earnedSalary => 'TO\'PLANGAN ISH HAQI';

  @override
  String get withdraw => 'YECHIB OLISH';

  @override
  String get salaryRules => 'ISH HAQI TIZIMI QOIDALARI';

  @override
  String get rule1 =>
      'Har bir mahsulot haridi uchun sizga kafolatlangan ish haqi yoziladi.';

  @override
  String get rule2 =>
      'Ish haqini naqdilashtirish uchun ariza 24 soat davomida ko\'rib chiqiladi.';

  @override
  String get rule3 => 'Minimal yechish miqdori: 10 000 sum.';

  @override
  String get retry => 'QAYTA URINISH';

  @override
  String get user => 'Foydalanuvchi';

  @override
  String get navDiller => 'DILLER';

  @override
  String get navZakazlar => 'ZAKAZLAR';

  @override
  String get navSavat => 'SAVAT';

  @override
  String get navProfile => 'PROFIL';

  @override
  String get locationPermission => 'Joylashuvga ruxsat';

  @override
  String get locationDesc =>
      'Yaqin dillerlarni topish uchun joylashuvingizga ruxsat bering';

  @override
  String get grantPermission => 'Ruxsat berish';

  @override
  String get openSettings => 'Sozlamalarga o\'tish';

  @override
  String get later => 'Keyinroq';

  @override
  String get notifications => 'Bildirishnomalar';

  @override
  String get general => 'General';

  @override
  String get primary => 'Primary';

  @override
  String notificationsList(String type) {
    return '$type — bildirishnomalar';
  }

  @override
  String get zakazlar => 'Zakazlar';

  @override
  String get savat => 'Savat';

  @override
  String get language => 'Til';

  @override
  String get langUz => 'O\'zbekcha';

  @override
  String get langRu => 'Русский';

  @override
  String get settings => 'Sozlamalar';

  @override
  String get notificationsSettings => 'Bildirishnomalar';

  @override
  String get dealerSearchHint => 'Diller qidirish...';

  @override
  String get categoryAll => 'BARCHASI';

  @override
  String get dealersEmpty => 'Diller topilmadi';

  @override
  String get dealersEmptyHint =>
      'Boshqa kategoriya yoki qidiruvni sinab ko\'ring';

  @override
  String get dealersError => 'Xatolik yuz berdi';

  @override
  String get dealersErrorHint => 'Internet aloqasini tekshiring';

  @override
  String get dealersLoading => 'Yuklanmoqda...';

  @override
  String get filter => 'Filter';

  @override
  String get filterCategory => 'Kategoriya';

  @override
  String get filterRegion => 'Hudud';

  @override
  String get filterApply => 'Qo\'llash';

  @override
  String get filterClear => 'Tozalash';

  @override
  String get filterRegionAll => 'Barcha hududlar';

  @override
  String get clearFiltersShowAll => 'Filterni tozalash';
}
