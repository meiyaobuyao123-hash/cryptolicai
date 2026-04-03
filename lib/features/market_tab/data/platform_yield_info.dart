class PlatformYieldInfo {
  final String slug;
  final String name;
  final String type;
  final String oneLiner;       // 一句话说清楚
  final String analogy;        // 生活化类比
  final String howItWorks;     // 收益怎么来的（3步）
  final String mainRisk;       // 最核心的一个风险
  final List<String> otherRisks;
  final String suitableFor;
  final String notSuitableFor;

  const PlatformYieldInfo({
    required this.slug,
    required this.name,
    required this.type,
    required this.oneLiner,
    required this.analogy,
    required this.howItWorks,
    required this.mainRisk,
    required this.otherRisks,
    required this.suitableFor,
    required this.notSuitableFor,
  });

  static PlatformYieldInfo? get(String slug) => _data[slug.toLowerCase()];

  static String productRiskSummary({
    required String riskLevel,
    required double apy,
    required String ilRisk,
    required bool isStablecoin,
    required String exposure,
    required bool isRewardHeavy,
  }) {
    if (isStablecoin && riskLevel == '低' && ilRisk == 'no') {
      return '💚 稳定币存款，无无常损失，风险较低';
    }
    final parts = <String>[];
    if (apy > 20) parts.add('⚠️ 高收益 = 高风险，请谨慎');
    if (isRewardHeavy) parts.add('代币奖励为主，收益可能随时下降');
    if (ilRisk != 'no') parts.add('LP池有无常损失风险');
    if (exposure == 'single' && ilRisk == 'no' && !isRewardHeavy && apy <= 20) {
      parts.add('💚 单币存款，收益来自真实业务');
    }
    if (parts.isEmpty) return '请了解风险后再投资';
    return parts.join('；');
  }

  static const _data = <String, PlatformYieldInfo>{
    'aave-v3': PlatformYieldInfo(
      slug: 'aave-v3',
      name: 'Aave V3',
      type: '借贷',
      oneLiner: '你存钱进去，别人借走付利息给你',
      analogy: '类似银行存款：你存钱 → 银行借给别人 → 借款人还利息 → 银行分一部分给你',
      howItWorks:
          '① 你把 USDT/ETH 等存入 Aave\n'
          '② 需要借钱的人存入抵押品后，借走你的资产\n'
          '③ 借款人按小时付利息，扣除 Aave 10% 抽成后，剩下的就是你的收益',
      mainRisk: '利率不固定 — 借的人少了，你的收益就会下降',
      otherRisks: [
        '智能合约漏洞（概率低，经过多次审计）',
        '极端行情下可能出现坏账',
      ],
      suitableFor: '想要稳健收益的人，特别是存稳定币',
      notSuitableFor: '追求高收益或不能承受利率波动的人',
    ),
    'lido': PlatformYieldInfo(
      slug: 'lido',
      name: 'Lido',
      type: 'ETH 质押',
      oneLiner: '帮你的 ETH 参与网络验证赚奖励',
      analogy: '类似合伙开出租车：你出车（ETH），Lido 出司机（验证节点），赚到的钱按比例分',
      howItWorks:
          '① 你把 ETH 存入 Lido\n'
          '② Lido 用你的 ETH 运行以太坊验证节点\n'
          '③ 以太坊网络发放验证奖励（约 3-4%/年），Lido 抽 10% 后分给你',
      mainRisk: '你收到的 stETH 可能暂时不等于 ETH — 2022年曾短期跌到 0.93',
      otherRisks: [
        '验证节点出错可能被罚款（概率极低）',
        '极端行情下 stETH 卖出可能有折价',
      ],
      suitableFor: '长期持有 ETH，想要额外收益的人',
      notSuitableFor: '需要随时按原价取回 ETH 的人',
    ),
    'compound-v3': PlatformYieldInfo(
      slug: 'compound-v3',
      name: 'Compound',
      type: '借贷',
      oneLiner: '和 Aave 一样，存钱赚利息',
      analogy: '同样是银行存款模式，Compound 是 DeFi 借贷的鼻祖',
      howItWorks:
          '① 你存入 USDC 等资产\n'
          '② 借款人抵押后借走\n'
          '③ 借款利息扣除手续费后分给你',
      mainRisk: '利率随市场波动，行情冷清时收益可能很低',
      otherRisks: [
        '智能合约风险（老牌协议，经过时间考验）',
        '治理决策可能影响利率参数',
      ],
      suitableFor: '追求简单稳定借贷收益的人',
      notSuitableFor: '期望固定收益率的人',
    ),
    'eigenlayer': PlatformYieldInfo(
      slug: 'eigenlayer',
      name: 'EigenLayer',
      type: '再质押',
      oneLiner: '让已质押的 ETH 再赚一份钱',
      analogy: '你已经在上班（ETH质押），EigenLayer 帮你找了份兼职（再质押），一份资产赚两份收益',
      howItWorks:
          '① 你已经有 stETH（在 Lido 质押的 ETH）\n'
          '② 把 stETH 再存入 EigenLayer\n'
          '③ 新的区块链项目付费租用你的安全保障，你获得额外奖励',
      mainRisk: '一旦出问题，你的 ETH 可能被双重罚款 — 既被以太坊罚，又被新项目罚',
      otherRisks: [
        '机制比较新，还没经过长期市场考验',
        '多层嵌套合约，复杂度高',
        '取出来可能要等一段时间',
      ],
      suitableFor: '已熟悉 ETH 质押，愿意承担更多风险赚更多的人',
      notSuitableFor: '新手，或不能承受额外损失的人',
    ),
    'pendle': PlatformYieldInfo(
      slug: 'pendle',
      name: 'Pendle',
      type: '收益交易',
      oneLiner: '把未来的收益变成可交易的代币',
      analogy: '类似债券：你可以提前锁定一个固定利率，或者赌利率会涨',
      howItWorks:
          '① Pendle 把收益资产拆成"本金"和"收益"两个代币\n'
          '② 买"本金代币(PT)" = 锁定固定收益（到期拿回本金+利息）\n'
          '③ 买"收益代币(YT)" = 赌收益率会涨（杠杆化，风险高）',
      mainRisk: '⚠️ 显示的高 APY 通常是 YT 的杠杆化收益，你实际到手的可能低很多，甚至亏损',
      otherRisks: [
        '有到期日，过期后收益代币归零',
        '机制复杂，新手很容易误解',
        '小池子买卖滑点大',
      ],
      suitableFor: '理解期权/债券概念的进阶用户',
      notSuitableFor: '新手！如果你不理解 PT/YT 是什么，请不要投',
    ),
    'morpho': PlatformYieldInfo(
      slug: 'morpho',
      name: 'Morpho',
      type: '借贷优化',
      oneLiner: '在 Aave 之上优化，帮你拿更好的利率',
      analogy: '如果 Aave 是银行，Morpho 就是帮你跳过银行直接找到借款人的中介',
      howItWorks:
          '① 你存入资产到 Morpho\n'
          '② Morpho 尝试直接撮合借贷双方（利率更好）\n'
          '③ 撮合不上就自动存到 Aave（保底收益）',
      mainRisk: '在 Aave 基础上多一层合约，多一层风险',
      otherRisks: [
        '撮合率不稳定，收益时高时低',
        '协议相对较新',
      ],
      suitableFor: '已用过 Aave，想要更优利率的人',
      notSuitableFor: '对 DeFi 完全不了解的人',
    ),
    'rocket-pool': PlatformYieldInfo(
      slug: 'rocket-pool',
      name: 'Rocket Pool',
      type: 'ETH 质押',
      oneLiner: '去中心化的 ETH 质押，和 Lido 类似',
      analogy: '同样是合伙开出租车模式，区别是 Rocket Pool 的司机更多更分散，不依赖大公司',
      howItWorks:
          '① 你存入 ETH\n'
          '② 分散给很多独立的验证节点运行\n'
          '③ 验证奖励扣除费用后分给你，你收到 rETH',
      mainRisk: 'rETH 在极端行情下可能短期折价',
      otherRisks: [
        '小节点运营者的专业性参差不齐',
        '智能合约风险',
      ],
      suitableFor: '看重去中心化理念的 ETH 持有者',
      notSuitableFor: '追求最高收益率的人（通常比 Lido 略低）',
    ),
    'maker': PlatformYieldInfo(
      slug: 'maker',
      name: 'Maker',
      type: '稳定币借贷',
      oneLiner: '用户抵押资产借出 DAI，你赚稳定费',
      analogy: '类似当铺：别人拿值钱的东西（ETH）抵押借钱（DAI），还钱时付利息给你',
      howItWorks:
          '① 借款人存入 ETH 等资产作为抵押\n'
          '② 系统借给他 DAI 稳定币\n'
          '③ 借款人还 DAI 时支付"稳定费"，这就是你的收益来源',
      mainRisk: '极端行情下 DAI 可能暂时偏离 \$1',
      otherRisks: [
        '借款人的清算事件不影响你（但可能影响市场）',
        '治理投票可能调整参数',
      ],
      suitableFor: '追求 DAI 生态稳定收益的人',
      notSuitableFor: '不了解稳定币机制的人',
    ),
  };
}
