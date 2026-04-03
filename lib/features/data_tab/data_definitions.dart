import '../../shared/widgets/info_tooltip.dart';

class DataDefinitions {
  DataDefinitions._();

  // ── 市场概览 ──
  static const marketOverviewTitle = '市场概览';
  static const marketOverviewSource = 'DefiLlama API + CoinGecko API';
  static const marketOverviewFields = [
    DataFieldInfo(
      field: 'DeFi 总锁仓 (TVL)',
      description: '所有 DeFi 协议中锁定的加密资产总价值（美元计价）。'
          '数据来自 DefiLlama，汇总了以太坊、Solana 等所有链上的 DeFi 协议。'
          'TVL 反映了 DeFi 生态的整体规模和资金活跃度。',
    ),
    DataFieldInfo(
      field: '加密总市值',
      description: '全球所有加密货币的市值总和，'
          '计算方式为每种加密货币的当前价格 × 流通供应量。'
          '数据来自 CoinGecko /global 接口。',
    ),
    DataFieldInfo(
      field: '24h 涨跌',
      description: '过去 24 小时加密市场总市值的涨跌幅。'
          '正值(绿色)表示市场整体上涨，负值(红色)表示下跌。',
    ),
    DataFieldInfo(
      field: '刷新频率',
      description: 'TVL 数据缓存 5 分钟（DefiLlama），总市值和涨跌幅缓存 2 分钟（CoinGecko）。'
          '下拉页面可手动刷新全部数据。',
    ),
  ];

  // ── TVL 趋势 ──
  static const tvlTrendTitle = 'TVL 趋势';
  static const tvlTrendSource = 'DefiLlama /v2/historicalChainTvl';
  static const tvlTrendFields = [
    DataFieldInfo(
      field: 'TVL (Total Value Locked)',
      description: '每日 DeFi 协议总锁仓量的历史走势。'
          '数据按日聚合，包含所有链的 DeFi 协议。'
          'TVL 下降可能是资金外流，也可能是底层资产价格下跌导致。',
    ),
    DataFieldInfo(
      field: '时间周期',
      description: '可切换 7天/30天/90天/1年的时间范围查看不同粒度的趋势。'
          '短周期适合观察近期波动，长周期适合判断大趋势。',
    ),
    DataFieldInfo(
      field: '刷新频率',
      description: '历史数据缓存 5 分钟。数据按日更新，日内多次请求返回相同结果。'
          '下拉页面可手动刷新。',
    ),
  ];

  // ── 理财平台排行 ──
  static const platformRankingTitle = '理财平台排行';
  static const platformRankingSource = 'DefiLlama /protocols + 交易所公开数据';
  static const platformRankingFields = [
    DataFieldInfo(
      field: '排名',
      description: '按总锁仓量 (TVL) 或总资产规模从高到低排序。'
          'DeFi 协议使用链上实时 TVL，CeFi 交易所使用公开披露的储备金数据。',
    ),
    DataFieldInfo(
      field: 'TVL / 总资产',
      description: 'DeFi 协议：用户存入协议智能合约中的资产总价值。\n'
          'CeFi 交易所：平台公开的总资产储备金（含用户存款）。',
    ),
    DataFieldInfo(
      field: '分类标签',
      description: '借贷 = Aave/Compound 等借贷协议；'
          '流动性质押 = Lido 等 ETH 质押协议；'
          'DEX = Uniswap 等去中心化交易所；'
          '交易所 = Binance/OKX 等中心化交易所。',
    ),
    DataFieldInfo(
      field: '7日变化',
      description: '该协议 TVL 在过去 7 天的涨跌幅，反映近期资金流入/流出情况。',
    ),
    DataFieldInfo(
      field: '刷新频率',
      description: 'DeFi 协议数据缓存 5 分钟（DefiLlama 实时链上数据）。'
          'CeFi 交易所数据为静态数据，来源于交易所公开披露的储备证明报告，按月更新。'
          '下拉页面可手动刷新 DeFi 数据。',
    ),
  ];

  // ── CeFi vs DeFi ──
  static const cefiDefiTitle = 'CeFi vs DeFi';
  static const cefiDefiSource = 'DefiLlama + 行业研究报告';
  static const cefiDefiFields = [
    DataFieldInfo(
      field: '总规模',
      description: 'CeFi 和 DeFi 理财市场的总资产规模之和。'
          'DeFi 数据来自 DefiLlama 实时 TVL；'
          'CeFi 数据为行业报告估算值（含主要交易所理财产品资产）。',
    ),
    DataFieldInfo(
      field: '收益范围',
      description: 'DeFi 2-8%：主流 DeFi 协议（Aave 借贷、Lido 质押等）的典型年化收益率。\n'
          'CeFi 2-14%：交易所理财产品（活期/定期/结构化）的收益范围，'
          '高收益通常需要锁定期或承担更高风险。',
    ),
    DataFieldInfo(
      field: '安全模式',
      description: '自托管 = 用户自己持有私钥，资金在链上智能合约中，风险是合约漏洞。\n'
          '平台托管 = 用户将资产交给交易所管理，风险是平台倒闭或跑路（如 FTX 事件）。',
    ),
    DataFieldInfo(
      field: '刷新频率',
      description: 'DeFi 占比实时计算（基于市场概览数据，缓存 5 分钟）。'
          'CeFi 总规模为行业研究报告估算值，按季度更新。'
          '对比表中的收益范围、安全模式等为静态参考数据。',
    ),
  ];

  // ── 热门理财产品 ──
  static const hotProductsTitle = '热门理财产品';
  static const hotProductsSource = 'DefiLlama /yields/pools';
  static const hotProductsFields = [
    DataFieldInfo(
      field: 'APY (年化收益率)',
      description: 'Annual Percentage Yield，考虑复利后的年化收益率。'
          '例如 5.2% APY 表示存入 \$10,000 一年后预计获得 \$520 收益。'
          '注意：APY 是浮动的，会随市场供需变化。',
    ),
    DataFieldInfo(
      field: 'TVL',
      description: '该收益池中锁定的总资产价值。'
          'TVL 越高通常说明该池子越受市场认可，流动性越好。',
    ),
    DataFieldInfo(
      field: '风险等级',
      description: '低风险 = APY ≤ 8%，通常是蓝筹协议的稳定币借贷或质押。\n'
          '中风险 = APY 8-20%，可能涉及新协议、代币奖励或轻度杠杆。\n'
          '高风险 = APY > 20%，通常伴随无常损失、代币通胀或协议安全风险。',
    ),
    DataFieldInfo(
      field: '刷新频率',
      description: '收益池数据缓存 2 分钟（DefiLlama Yields API）。'
          'APY 基于链上实时数据计算，可能每小时波动。'
          '下拉页面可手动刷新。',
    ),
  ];

  // ── 收益率分布 ──
  static const yieldDistTitle = '各赛道收益率分布';
  static const yieldDistSource = 'DefiLlama /yields/pools 聚合计算';
  static const yieldDistFields = [
    DataFieldInfo(
      field: '赛道分类',
      description: '质押 = ETH/SOL 等 PoS 链的验证节点质押收益；'
          '借贷 = Aave/Compound 等借贷协议的存款利息；'
          'LP = Uniswap/Curve 等 DEX 的流动性提供收益；'
          '其他 = 再质押、RWA、收益聚合等新兴赛道。',
    ),
    DataFieldInfo(
      field: '最低/中位/最高',
      description: '每个赛道下所有收益池的 APY 统计分布。'
          '最低 = 该赛道中收益最低的池子（通常最安全）；'
          '中位 = 中间值，代表典型收益水平；'
          '最高 = 该赛道中收益最高的池子（上限截断至 100%，通常风险最高）。',
    ),
    DataFieldInfo(
      field: '刷新频率',
      description: '基于热门理财产品同源数据聚合计算，缓存 2 分钟。'
          '下拉页面可手动刷新。',
    ),
  ];

  // ── 链上资产分布 ──
  static const chainDistTitle = '链上资产分布';
  static const chainDistSource = 'DefiLlama /v2/chains';
  static const chainDistFields = [
    DataFieldInfo(
      field: '链名称',
      description: '公链名称，如 Ethereum、Solana、Arbitrum 等。'
          '每条链是一个独立的区块链网络，上面运行着各种 DeFi 协议。',
    ),
    DataFieldInfo(
      field: 'TVL 占比',
      description: '该链上所有 DeFi 协议的 TVL 占全部链总 TVL 的百分比。'
          '注意：TVL ≠ 市值。BTC 市值远高于 ETH，但比特币链不原生支持智能合约，'
          'DeFi 生态较弱（仅 Stacks、Babylon 等少量协议），所以链上 TVL 远低于以太坊。'
          '以太坊承载了 Aave、Uniswap、Lido 等主流 DeFi 协议，TVL 占比最高。',
    ),
    DataFieldInfo(
      field: '刷新频率',
      description: '链 TVL 数据缓存 5 分钟（DefiLlama）。'
          '下拉页面可手动刷新。',
    ),
  ];

  // ── 平台资金与收益 ──
  static const platformTvlApyTitle = '平台资金与收益';
  static const platformTvlApySource = 'DefiLlama /yields/pools 聚合';
  static const platformTvlApyFields = [
    DataFieldInfo(
      field: '本金分布',
      description: '每个 DeFi 平台下所有收益池的 TVL（锁仓量）之和。'
          '反映用户在各平台质押/存入的资金总量。'
          '堆叠条和百分比显示各平台在 DeFi 理财市场中的资金份额。',
    ),
    DataFieldInfo(
      field: '收益分布',
      description: '每个平台所有池子的 APY 范围（最低到最高）和加权平均值。\n'
          '加权平均 = Σ(池子APY × 池子TVL) / 平台总TVL，'
          '反映大资金实际能获得的收益水平（而非简单平均被小池子高APY拉高）。\n'
          '范围条：浅色区域 = 该平台 APY 的最低到最高范围；'
          '深色竖线 = 加权平均值位置。',
    ),
    DataFieldInfo(
      field: '池子数',
      description: '该平台在 DefiLlama 中收录的收益池数量。'
          '池子数越多说明该平台支持的资产和策略越丰富。',
    ),
    DataFieldInfo(
      field: '集中度 — Top3 集中',
      description: '该平台 TVL 最大的 3 个池子占平台总 TVL 的百分比。'
          '越高说明资金越集中在少数池子中，分散度越低。'
          '>80% 为高集中度（红色），50-80% 中（橙色），<50% 低（绿色）。',
    ),
    DataFieldInfo(
      field: '集中度 — 头部资产',
      description: '该平台中 TVL 占比最大的单一资产（如 USDT、ETH）及其占比。'
          '如果一个平台的头部资产占比 >60%，说明用户高度偏好该资产。',
    ),
    DataFieldInfo(
      field: '集中度 — 收益分布条',
      description: '按资金量（TVL）统计收益分布：\n'
          '蓝色 = <5% APY 区间的资金占比（低收益、通常最安全）\n'
          '绿色 = 5-15% APY 区间的资金占比（中等收益）\n'
          '橙色 = >15% APY 区间的资金占比（高收益、风险更高）\n'
          '大部分平台的资金集中在蓝色区（低收益安全区）。',
    ),
    DataFieldInfo(
      field: '集中度等级',
      description: '基于 HHI（赫芬达尔指数）计算的整体集中度。'
          'HHI = Σ(每个池子TVL占比的平方)，范围 0-1。\n'
          'HHI > 0.5 为高集中度，0.25-0.5 为中，<0.25 为低。'
          '高集中度意味着少数池子掌控大量资金，分散性较弱。',
    ),
    DataFieldInfo(
      field: '刷新频率',
      description: '基于收益池数据聚合计算，缓存 2 分钟。'
          '下拉页面可手动刷新。',
    ),
  ];
}
