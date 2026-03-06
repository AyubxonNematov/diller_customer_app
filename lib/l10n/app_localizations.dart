import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('uz')
  ];

  /// No description provided for @login.
  ///
  /// In uz, this message translates to:
  /// **'KIRISH'**
  String get login;

  /// No description provided for @testPhone.
  ///
  /// In uz, this message translates to:
  /// **'TEST RAQAM: 99 888 77 66'**
  String get testPhone;

  /// No description provided for @loginTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tizimga kirish'**
  String get loginTitle;

  /// No description provided for @phoneHint.
  ///
  /// In uz, this message translates to:
  /// **'TELEFON RAQAMINGIZNI KIRITING'**
  String get phoneHint;

  /// No description provided for @continueBtn.
  ///
  /// In uz, this message translates to:
  /// **'DAVOM ETISH'**
  String get continueBtn;

  /// No description provided for @back.
  ///
  /// In uz, this message translates to:
  /// **'ORQAGA'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get confirm;

  /// No description provided for @codeSentTo.
  ///
  /// In uz, this message translates to:
  /// **'+{phone} RAQAMIGA KOD YUBORILDI'**
  String codeSentTo(String phone);

  /// No description provided for @verify.
  ///
  /// In uz, this message translates to:
  /// **'TASDIQLASH'**
  String get verify;

  /// No description provided for @register.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish'**
  String get register;

  /// No description provided for @registerForPhone.
  ///
  /// In uz, this message translates to:
  /// **'+{phone} RAQAMI UCHUN'**
  String registerForPhone(String phone);

  /// No description provided for @nameRequired.
  ///
  /// In uz, this message translates to:
  /// **'ISM *'**
  String get nameRequired;

  /// No description provided for @surname.
  ///
  /// In uz, this message translates to:
  /// **'FAMILIYA'**
  String get surname;

  /// No description provided for @address.
  ///
  /// In uz, this message translates to:
  /// **'MANZIL'**
  String get address;

  /// No description provided for @saveAndLogin.
  ///
  /// In uz, this message translates to:
  /// **'SAQLASH VA KIRISH'**
  String get saveAndLogin;

  /// No description provided for @profile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In uz, this message translates to:
  /// **'CHIQISH'**
  String get logout;

  /// No description provided for @marketplace.
  ///
  /// In uz, this message translates to:
  /// **'MARKETPLACE'**
  String get marketplace;

  /// No description provided for @sum.
  ///
  /// In uz, this message translates to:
  /// **'sum'**
  String get sum;

  /// No description provided for @myAccount.
  ///
  /// In uz, this message translates to:
  /// **'MENING HISOBIM'**
  String get myAccount;

  /// No description provided for @dillerMarketGold.
  ///
  /// In uz, this message translates to:
  /// **'Diller Market Gold'**
  String get dillerMarketGold;

  /// No description provided for @earnedSalary.
  ///
  /// In uz, this message translates to:
  /// **'TO\'PLANGAN ISH HAQI'**
  String get earnedSalary;

  /// No description provided for @withdraw.
  ///
  /// In uz, this message translates to:
  /// **'YECHIB OLISH'**
  String get withdraw;

  /// No description provided for @salaryRules.
  ///
  /// In uz, this message translates to:
  /// **'ISH HAQI TIZIMI QOIDALARI'**
  String get salaryRules;

  /// No description provided for @rule1.
  ///
  /// In uz, this message translates to:
  /// **'Har bir mahsulot haridi uchun sizga kafolatlangan ish haqi yoziladi.'**
  String get rule1;

  /// No description provided for @rule2.
  ///
  /// In uz, this message translates to:
  /// **'Ish haqini naqdilashtirish uchun ariza 24 soat davomida ko\'rib chiqiladi.'**
  String get rule2;

  /// No description provided for @rule3.
  ///
  /// In uz, this message translates to:
  /// **'Minimal yechish miqdori: 10 000 sum.'**
  String get rule3;

  /// No description provided for @retry.
  ///
  /// In uz, this message translates to:
  /// **'QAYTA URINISH'**
  String get retry;

  /// No description provided for @user.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi'**
  String get user;

  /// No description provided for @navDiller.
  ///
  /// In uz, this message translates to:
  /// **'DILLER'**
  String get navDiller;

  /// No description provided for @navZakazlar.
  ///
  /// In uz, this message translates to:
  /// **'ZAKAZLAR'**
  String get navZakazlar;

  /// No description provided for @navSavat.
  ///
  /// In uz, this message translates to:
  /// **'SAVAT'**
  String get navSavat;

  /// No description provided for @navProfile.
  ///
  /// In uz, this message translates to:
  /// **'PROFIL'**
  String get navProfile;

  /// No description provided for @locationPermission.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuvga ruxsat'**
  String get locationPermission;

  /// No description provided for @locationDesc.
  ///
  /// In uz, this message translates to:
  /// **'Yaqin dillerlarni topish uchun joylashuvingizga ruxsat bering'**
  String get locationDesc;

  /// No description provided for @grantPermission.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berish'**
  String get grantPermission;

  /// No description provided for @openSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalarga o\'tish'**
  String get openSettings;

  /// No description provided for @later.
  ///
  /// In uz, this message translates to:
  /// **'Keyinroq'**
  String get later;

  /// No description provided for @notifications.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notifications;

  /// No description provided for @general.
  ///
  /// In uz, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @primary.
  ///
  /// In uz, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @notificationsList.
  ///
  /// In uz, this message translates to:
  /// **'{type} — bildirishnomalar'**
  String notificationsList(String type);

  /// No description provided for @zakazlar.
  ///
  /// In uz, this message translates to:
  /// **'Zakazlar'**
  String get zakazlar;

  /// No description provided for @savat.
  ///
  /// In uz, this message translates to:
  /// **'Savat'**
  String get savat;

  /// No description provided for @language.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get language;

  /// No description provided for @langUz.
  ///
  /// In uz, this message translates to:
  /// **'O\'zbekcha'**
  String get langUz;

  /// No description provided for @langRu.
  ///
  /// In uz, this message translates to:
  /// **'Русский'**
  String get langRu;

  /// No description provided for @settings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get settings;

  /// No description provided for @notificationsSettings.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notificationsSettings;

  /// No description provided for @dealerSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Diller qidirish...'**
  String get dealerSearchHint;

  /// No description provided for @categoryAll.
  ///
  /// In uz, this message translates to:
  /// **'BARCHASI'**
  String get categoryAll;

  /// No description provided for @dealersEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Diller topilmadi'**
  String get dealersEmpty;

  /// No description provided for @dealersEmptyHint.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa kategoriya yoki qidiruvni sinab ko\'ring'**
  String get dealersEmptyHint;

  /// No description provided for @dealersError.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik yuz berdi'**
  String get dealersError;

  /// No description provided for @dealersErrorHint.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasini tekshiring'**
  String get dealersErrorHint;

  /// No description provided for @filter.
  ///
  /// In uz, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filterCategory.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriya'**
  String get filterCategory;

  /// No description provided for @filterRegion.
  ///
  /// In uz, this message translates to:
  /// **'Hudud'**
  String get filterRegion;

  /// No description provided for @filterApply.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llash'**
  String get filterApply;

  /// No description provided for @filterClear.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash'**
  String get filterClear;

  /// No description provided for @filterRegionAll.
  ///
  /// In uz, this message translates to:
  /// **'Barcha hududlar'**
  String get filterRegionAll;

  /// No description provided for @clearFiltersShowAll.
  ///
  /// In uz, this message translates to:
  /// **'Filterni tozalash'**
  String get clearFiltersShowAll;

  /// No description provided for @warehouseSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Omborlarni qidirish...'**
  String get warehouseSearchHint;

  /// No description provided for @warehousesEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Omborlar topilmadi'**
  String get warehousesEmpty;

  /// No description provided for @warehousesEmptyHint.
  ///
  /// In uz, this message translates to:
  /// **'Qidiruvni o\'zgartiring yoki keyinroq urinib ko\'ring'**
  String get warehousesEmptyHint;

  /// No description provided for @productSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlarni qidirish...'**
  String get productSearchHint;

  /// No description provided for @productsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar topilmadi'**
  String get productsEmpty;

  /// No description provided for @productsEmptyHint.
  ///
  /// In uz, this message translates to:
  /// **'Qidiruv yoki filterni o\'zgartiring'**
  String get productsEmptyHint;

  /// No description provided for @filterBrand.
  ///
  /// In uz, this message translates to:
  /// **'Brend'**
  String get filterBrand;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
