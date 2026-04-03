import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reown_appkit/reown_appkit.dart';
import '../../../core/config/wallet_config.dart';
import '../models/wallet_state.dart';

class WalletNotifier extends Notifier<WalletState> {
  ReownAppKitModal? _appKitModal;

  @override
  WalletState build() => const WalletState();

  /// Initialize the AppKit modal — must be called with a BuildContext
  Future<void> initModal(BuildContext context) async {
    if (_appKitModal != null) return;

    _appKitModal = ReownAppKitModal(
      context: context,
      projectId: WalletConfig.projectId,
      metadata: PairingMetadata(
        name: WalletConfig.appName,
        description: WalletConfig.appDescription,
        url: WalletConfig.appUrl,
        icons: [WalletConfig.appIcon],
        redirect: Redirect(
          native: 'cryptoearn://',
          universal: WalletConfig.appUrl,
        ),
      ),
    );

    await _appKitModal!.init();

    // Listen for session changes
    _appKitModal!.onModalConnect.subscribe((event) {
      _updateStateFromSession();
    });

    _appKitModal!.onModalDisconnect.subscribe((event) {
      state = const WalletState();
    });

    _appKitModal!.onModalUpdate.subscribe((event) {
      _updateStateFromSession();
    });

    // Check if already connected
    if (_appKitModal!.isConnected) {
      _updateStateFromSession();
    }
  }

  /// Open wallet connection modal
  Future<void> connect() async {
    if (_appKitModal == null) {
      state = state.copyWith(
        status: WalletConnectionStatus.error,
        error: '钱包未初始化，请重试',
      );
      return;
    }

    state = state.copyWith(status: WalletConnectionStatus.connecting);
    _appKitModal!.openModalView();
  }

  void disconnect() async {
    if (_appKitModal != null && _appKitModal!.isConnected) {
      await _appKitModal!.disconnect();
    }
    state = const WalletState();
  }

  Future<void> switchChain(int chainId, String chainName) async {
    if (!state.isConnected) return;
    state = state.copyWith(chainId: chainId, chainName: chainName);
  }

  void _updateStateFromSession() {
    if (_appKitModal == null) return;

    final session = _appKitModal!.session;
    if (session == null) {
      state = const WalletState();
      return;
    }

    final address = _appKitModal!.session?.getAddress('eip155') ?? '';
    final chainId = int.tryParse(
      _appKitModal!.selectedChain?.chainId ?? '1',
    );

    state = WalletState(
      status: WalletConnectionStatus.connected,
      address: address,
      chainId: chainId,
      chainName: _appKitModal!.selectedChain?.name ?? 'Unknown',
    );
  }

  ReownAppKitModal? get modal => _appKitModal;
}

final walletProvider =
    NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);
