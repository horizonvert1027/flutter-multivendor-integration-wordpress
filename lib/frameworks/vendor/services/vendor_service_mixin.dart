import '../../../services/service_config.dart';
import '../../../services/wallet/tera_wallet_service_locator.dart'
    show TeraWalletServiceLocator;
import '../dokan.dart';
import '../wcfm.dart';
import 'dokan_service.dart';
import 'wcfm_service.dart';

mixin ServiceVendorMixin on ConfigMixin {
  @override
  void configWCFM(appConfig) {
    final wcfmService = WCFMService(
      domain: appConfig['url'],
      blogDomain: appConfig['blog'],
      consumerSecret: appConfig['consumerSecret'],
      consumerKey: appConfig['consumerKey'],
    );
    TeraWalletServiceLocator.setup(appConfig['url']);
    api = wcfmService;
    widget = WCFMWidget();
  }

  @override
  void configDokan(appConfig) {
    final dokanService = DokanService(
      domain: appConfig['url'],
      blogDomain: appConfig['blog'],
      consumerSecret: appConfig['consumerSecret'],
      consumerKey: appConfig['consumerKey'],
    );
    TeraWalletServiceLocator.setup(appConfig['url']);
    api = dokanService;
    widget = DokanWidget();
  }
}
