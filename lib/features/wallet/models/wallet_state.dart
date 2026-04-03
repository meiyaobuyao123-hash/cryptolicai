enum WalletConnectionStatus { disconnected, connecting, connected, error }

class WalletState {
  final WalletConnectionStatus status;
  final String? address;
  final int? chainId;
  final String? chainName;
  final String? error;

  const WalletState({
    this.status = WalletConnectionStatus.disconnected,
    this.address,
    this.chainId,
    this.chainName,
    this.error,
  });

  String? get displayAddress {
    if (address == null || address!.isEmpty || address!.length < 10) return address;
    return '${address!.substring(0, 6)}...${address!.substring(address!.length - 4)}';
  }

  bool get isConnected => status == WalletConnectionStatus.connected;

  WalletState copyWith({
    WalletConnectionStatus? status,
    String? address,
    int? chainId,
    String? chainName,
    String? error,
  }) {
    return WalletState(
      status: status ?? this.status,
      address: address ?? this.address,
      chainId: chainId ?? this.chainId,
      chainName: chainName ?? this.chainName,
      error: error ?? this.error,
    );
  }
}
