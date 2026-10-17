// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'ShopSphere';

  @override
  String get splashTagline => 'आपकी पसंद की हर चीज़, एक ही जगह।';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get goBack => 'वापस जाएँ';

  @override
  String get errorTitleOffline => 'आप ऑफ़लाइन हैं';

  @override
  String get errorTitleTimeout => 'बहुत समय लग रहा है';

  @override
  String get errorTitleServer => 'कुछ गड़बड़ हो गई';

  @override
  String get errorTitleNotFound => 'नहीं मिला';

  @override
  String get errorTitleGeneric => 'कुछ गड़बड़ हो गई';

  @override
  String get errorNetwork =>
      'अपना इंटरनेट कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get errorTimeout =>
      'सर्वर जवाब देने में धीमा है। कृपया फिर से कोशिश करें।';

  @override
  String get errorServer =>
      'हमारी तरफ़ से कुछ गड़बड़ हुई। कृपया फिर से कोशिश करें।';

  @override
  String get errorNotFound => 'हमें यह नहीं मिला।';

  @override
  String get errorInvalidCredentials => 'यूज़रनेम या पासवर्ड गलत है।';

  @override
  String get errorSessionExpired =>
      'आपका सेशन समाप्त हो गया। कृपया फिर से साइन इन करें।';

  @override
  String get errorUnexpected => 'कुछ अनपेक्षित हुआ। कृपया फिर से कोशिश करें।';

  @override
  String get loginTitle => 'फिर से स्वागत है';

  @override
  String get loginSubtitle => 'खरीदारी जारी रखने के लिए साइन इन करें।';

  @override
  String get usernameLabel => 'यूज़रनेम';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get showPassword => 'पासवर्ड दिखाएँ';

  @override
  String get hidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get useDemoAccount => 'डेमो खाता इस्तेमाल करें';

  @override
  String get usernameRequired => 'अपना यूज़रनेम डालें';

  @override
  String get passwordRequired => 'अपना पासवर्ड डालें';

  @override
  String fieldTooShort(int min) {
    return 'कम से कम $min अक्षर होने चाहिए';
  }

  @override
  String get navShop => 'शॉप';

  @override
  String get navWishlist => 'पसंदीदा';

  @override
  String get navCart => 'कार्ट';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String cartBadgeLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'कार्ट में $count आइटम',
      one: 'कार्ट में 1 आइटम',
      zero: 'कार्ट खाली है',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'प्रोडक्ट खोजें';

  @override
  String get clearSearch => 'खोज साफ़ करें';

  @override
  String get categoryAll => 'सभी';

  @override
  String get sortTooltip => 'प्रोडक्ट क्रमबद्ध करें';

  @override
  String get sortTitle => 'इसके अनुसार क्रमबद्ध करें';

  @override
  String get sortRelevance => 'सुझाए गए';

  @override
  String get sortPriceLowHigh => 'कीमत: कम से ज़्यादा';

  @override
  String get sortPriceHighLow => 'कीमत: ज़्यादा से कम';

  @override
  String get sortRating => 'सबसे अच्छी रेटिंग';

  @override
  String get sortTitleAz => 'नाम: A से Z';

  @override
  String get noProductsTitle => 'कोई प्रोडक्ट नहीं मिला';

  @override
  String get noProductsMessage => 'कोई दूसरी खोज या कैटेगरी आज़माएँ।';

  @override
  String get clearFilters => 'फ़िल्टर हटाएँ';

  @override
  String resultsFor(String query) {
    return '\"$query\" के नतीजे';
  }

  @override
  String get searchClearsCategory => 'खोज सभी कैटेगरी में होती है';

  @override
  String get endOfList => 'अभी के लिए बस इतना ही।';

  @override
  String get offlineBanner => 'आप ऑफ़लाइन हैं';

  @override
  String get offlineCachedBanner =>
      'आप ऑफ़लाइन हैं · सहेजे गए प्रोडक्ट दिख रहे हैं';

  @override
  String discountBadge(String percent) {
    return '-$percent';
  }

  @override
  String get addToWishlist => 'पसंदीदा में जोड़ें';

  @override
  String get removeFromWishlist => 'पसंदीदा से हटाएँ';

  @override
  String ratingLabel(String rating) {
    return '5 में से $rating रेटिंग';
  }

  @override
  String priceLabel(String price, String original) {
    return 'कीमत $price, पहले $original';
  }

  @override
  String get productNotFoundTitle => 'प्रोडक्ट नहीं मिला';

  @override
  String get productNotFoundMessage =>
      'शायद इसे हटा दिया गया है। चलिए आपको शॉप पर वापस ले चलते हैं।';

  @override
  String get backToShop => 'शॉप पर वापस जाएँ';

  @override
  String byBrand(String brand) {
    return '$brand द्वारा';
  }

  @override
  String get inStock => 'स्टॉक में है';

  @override
  String lowStock(int count) {
    return 'सिर्फ़ $count बचे हैं';
  }

  @override
  String get outOfStock => 'स्टॉक में नहीं';

  @override
  String get descriptionTitle => 'विवरण';

  @override
  String reviewsTitle(int count) {
    return 'रिव्यू ($count)';
  }

  @override
  String get noReviews => 'अभी कोई रिव्यू नहीं।';

  @override
  String get quantity => 'मात्रा';

  @override
  String get increaseQuantity => 'मात्रा बढ़ाएँ';

  @override
  String get decreaseQuantity => 'मात्रा घटाएँ';

  @override
  String get addToCart => 'कार्ट में जोड़ें';

  @override
  String get addedToCart => 'कार्ट में जोड़ दिया गया';

  @override
  String get viewCart => 'कार्ट देखें';

  @override
  String get selectProductHint => 'विवरण देखने के लिए कोई प्रोडक्ट चुनें।';

  @override
  String imagePosition(int index, int total) {
    return '$total में से तस्वीर $index';
  }

  @override
  String get cartTitle => 'आपका कार्ट';

  @override
  String get cartEmptyTitle => 'आपका कार्ट खाली है';

  @override
  String get cartEmptyMessage => 'अपनी पसंद की कोई चीज़ ढूँढें और यहाँ जोड़ें।';

  @override
  String get startShopping => 'खरीदारी शुरू करें';

  @override
  String get subtotal => 'उप-योग';

  @override
  String get discount => 'छूट';

  @override
  String get total => 'कुल';

  @override
  String get checkout => 'चेकआउट';

  @override
  String get removeItem => 'हटाएँ';

  @override
  String itemRemoved(String title) {
    return '$title हटा दिया गया';
  }

  @override
  String get undo => 'वापस लें';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '1 आइटम',
    );
    return '$_temp0';
  }

  @override
  String get checkoutTitle => 'ऑर्डर की समीक्षा';

  @override
  String get deliverTo => 'डिलीवरी का पता';

  @override
  String get payment => 'भुगतान';

  @override
  String get cashOnDelivery => 'कैश ऑन डिलीवरी (डेमो)';

  @override
  String get orderSummary => 'ऑर्डर का सारांश';

  @override
  String get placeOrder => 'ऑर्डर करें';

  @override
  String get orderPlacedTitle => 'ऑर्डर हो गया!';

  @override
  String orderPlacedMessage(int id) {
    return 'ऑर्डर #$id कन्फ़र्म हो गया। यह एक डेमो है, इसलिए कुछ भी भेजा नहीं जाएगा।';
  }

  @override
  String youSaved(String amount) {
    return 'आपने $amount बचाए';
  }

  @override
  String get continueShopping => 'खरीदारी जारी रखें';

  @override
  String get wishlistTitle => 'पसंदीदा';

  @override
  String get wishlistEmptyTitle => 'अभी कोई पसंदीदा नहीं';

  @override
  String get wishlistEmptyMessage =>
      'किसी भी प्रोडक्ट पर दिल टैप करें और उसे यहाँ सहेजें।';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get email => 'ईमेल';

  @override
  String get phone => 'फ़ोन';

  @override
  String get appearance => 'दिखावट';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get language => 'भाषा';

  @override
  String get developer => 'डेवलपर';

  @override
  String get errorLab => 'एरर लैब';

  @override
  String get errorLabSubtitle =>
      'जान-बूझकर गड़बड़ी करें और देखें कि ऐप कैसे संभलता है।';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get logoutConfirmTitle => 'लॉग आउट करें?';

  @override
  String get logoutConfirmMessage =>
      'इस डिवाइस पर आपका कार्ट और पसंदीदा साफ़ हो जाएँगे।';

  @override
  String get labIntro =>
      'हर स्थिति DummyJSON के एक असली टेस्ट एंडपॉइंट को कॉल करती है। यहाँ से ऐप खराब नहीं हो सकता।';

  @override
  String get labServerError => 'सर्वर एरर (500)';

  @override
  String get labServerErrorDesc =>
      'GET /http/500 → दोबारा कोशिश वाला आसान एरर संदेश।';

  @override
  String get labNotFound => 'गायब प्रोडक्ट (404)';

  @override
  String get labNotFoundDesc =>
      '/products/9999 खोलता है → \"प्रोडक्ट नहीं मिला\" और वापस जाने का रास्ता।';

  @override
  String get labSlow => 'धीमा नेटवर्क (3 सेकंड)';

  @override
  String get labSlowDesc => 'GET /products?delay=3000 → लोडर दिखता रहता है।';

  @override
  String get labTimeout => 'रिक्वेस्ट टाइमआउट';

  @override
  String get labTimeoutDesc =>
      '5 सेकंड की देरी, 2 सेकंड का टाइमआउट → टाइमआउट संदेश।';

  @override
  String get labExpiredToken => 'एक्सपायर्ड एक्सेस टोकन';

  @override
  String get labExpiredTokenDesc =>
      'एक्सेस टोकन खराब करता है, फिर प्रोफ़ाइल लोड करता है। ऐप चुपचाप टोकन रिफ़्रेश करके दोबारा कोशिश करता है।';

  @override
  String get labBadRefresh => 'खराब रिफ़्रेश टोकन';

  @override
  String get labBadRefreshDesc =>
      'दोनों टोकन खराब करता है। रिफ़्रेश विफल होता है (403) और आप संदेश के साथ साइन आउट हो जाते हैं।';

  @override
  String get labOfflineHint =>
      'ऑफ़लाइन: एयरप्लेन मोड चालू करें और शॉप पर नीचे खींचकर रिफ़्रेश करें।';

  @override
  String get labRun => 'चलाएँ';

  @override
  String labSuccess(int ms) {
    return '$ms ms में सफल';
  }
}
