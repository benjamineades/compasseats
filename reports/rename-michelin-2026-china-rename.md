# Rename apply - rename-michelin-2026-china

**DRY RUN - rolled back.** Everything below is what would have happened.
Every name in the database is exactly as it was.

| field | value |
|---|---|
| batch key | `rename-michelin-2026-china` |
| CSV | `fixtures/rename/michelin-2026-china-names.csv` |
| rows in the file | 263 |
| renamed | 263 |
| already right (`no_change`) | 0 |
| refused (`reject`) | 0 |
| needs your eyes (`review`) | 0 |
| note | Michelin 2026 China card names, 263 rows |

## Verdicts

Population: all 263 data row(s) in the CSV. Every row gets exactly one.

| verdict | rows | what it means |
|---|---|---|
| `rename` | 263 | the name changes |
| `no_change` | 0 | the venue already carries the new name; skipped, not an error |
| `reject` | 0 | the row failed a check; the whole batch stops |
| `review` | 0 | a human has to answer this one; the whole batch stops |

## Downstream impact

Population: the 263 row(s) this batch would rename, read from the database before a single name changed.

263 of the 263 hold at least one award. 0 have a `blurbs` row. Every one of them keeps its slug.

| venue id | city | from | to | awards by publisher | blurb | slug (unchanged) |
|---|---|---|---|---|---|---|
| `ve_00c898a89c` | guangzhou | Huage Privacy Kitchen | Hua Ge Si Chu | michelin 2 | no | /guangzhou/huage-privacy-kitchen |
| `ve_015c3461ad` | xiamen | Chic 1699 Yuanyang Privacy Kitchen | Chic 1699 | michelin 2 | no | /xiamen/chic-1699-yuanyang-privacy-kitchen |
| `ve_01b7949aea` | yangzhou | Quyuan | Liuyuanchun Teahouse | michelin 2 | no | /yangzhou/quyuan |
| `ve_025cd433e8` | beijing | Xiangbinxuan Restaurant | Xiang Bin Xuan (Huayuan Road) | michelin 2 | no | /beijing/xiangbinxuan-restaurant |
| `ve_027040b69f` | hangzhou | Wumingshi Noodle Restaurant | Er Ba Jiu Su Mian Guan | michelin 2 | no | /hangzhou/wumingshi-noodle-restaurant |
| `ve_02939d941a` | guangzhou | Haimen Yuzai Shop | Hai Men Yu Zi Dian (Yanling Road) | michelin 2 | no | /guangzhou/haimen-yuzai-shop |
| `ve_0460a32c7d` | shanghai | Yuting Restaurant | Cong's Kitchen | michelin 2 | no | /shanghai/yuting-restaurant |
| `ve_0b0173ebae` | beijing | Qiantang Garden Restaurant | Qiantang Garden (Shuangyushu North Road) | michelin 2 | no | /beijing/qiantang-garden-restaurant |
| `ve_0b942c3ee4` | hangzhou | Liufang Wuzi Noodle Restaurant | Wu Zi Mian Guan | michelin 2 | no | /hangzhou/liufang-wuzi-noodle-restaurant |
| `ve_0ba160383c` | quanzhou | West Street | Che Qiao Tou Wen A Shui Wan (Daxi Street) | michelin 2 | no | /quanzhou/west-street |
| `ve_0bc5323db1` | shanghai | Yunhe Restaurant | Yunhe Noodle (Huangpu) | michelin 2 | no | /shanghai/yunhe-restaurant |
| `ve_0cf7c0fc2d` | yangzhou | 熊二湘菜馆 Xiong Er Xiang Cai Guan | Cai Gen Xiang Xiao Guan | michelin 2 | no | /yangzhou/xiong-er-xiang-cai-guan |
| `ve_0e534fbaaf` | guangzhou | Rongyi | Ease (Yuexiu) | michelin 2 | no | /guangzhou/rongyi |
| `ve_0e8f46440b` | nanjing | Xinfangyuan Restaurant Nanjing Head Store | Xin Fang Yuan | michelin 2 | no | /nanjing/xinfangyuan-restaurant-nanjing-head-store |
| `ve_0ede725a20` | nanjing | Xiaopanji Duck Blood Vermicelli Soup | Xiao Pan Ji Ya Xie Fen Si Tang | michelin 2 | no | /nanjing/xiaopanji-duck-blood-vermicelli-soup |
| `ve_11145845a4` | beijing | Zhiguan Restaurant | Zhiguan Courtyard | michelin 2 | no | /beijing/zhiguan-restaurant |
| `ve_116a14d35a` | taizhou | Hongda Xingli Restaurant | Hong Da Xing Li Fan Dian | michelin 2 | no | /taizhou/hongda-xingli-restaurant |
| `ve_1488ed42ea` | beijing | Hongfanqie | Hong Fan Qie (Yuyuantan South Road) | michelin 2 | no | /beijing/hongfanqie |
| `ve_14f90c6a05` | guangzhou | 容易发牛杂店 | Rong Yi Fa Niu Za Dian (Yuexiu) | michelin 2 | no | /guangzhou/guangzhou-fi5owy |
| `ve_156612d964` | taizhou | Qunhui Seafood Lobster | Guoping Seafood | michelin 2 | no | /taizhou/qunhui-seafood-lobster |
| `ve_16b408725d` | xiamen | Zhonghua Cheng Noodles With Satay Sauce | Chen Xian Sen Sha Cha Mian | michelin 2 | no | /xiamen/zhonghua-cheng-noodles-with-satay-sauce |
| `ve_16e5a2e0f0` | guangzhou | Lao Xiguan Laifen | Lao Xiguan Laifen (Wenming Road) | michelin 2 | no | /guangzhou/lao-xiguan-laifen |
| `ve_16e9923170` | fuzhou | Huashengtang | Mei Ya Bo Hua Sheng Tang | michelin 2 | no | /fuzhou/huashengtang |
| `ve_16ecb158f6` | xiamen | 月华沙茶面 | Yue Hua Sha Cha Mian | michelin 2 | no | /xiamen/xiamen-qamm6w |
| `ve_16f13cb80f` | shanghai | Yong Fu Xiao Xian | YongFu Mini (Pudong) | michelin 2 | no | /shanghai/yong-fu-xiao-xian |
| `ve_182038319c` | shanghai | Dadong Restaurant | Da Dong (Xuhui) | michelin 2 | no | /shanghai/dadong-restaurant |
| `ve_1907996693` | guangzhou | Happiness Station | Xing Fu Yi Zhan (Yulei Third Street) | michelin 2 | no | /guangzhou/happiness-station |
| `ve_19b20dfec4` | changzhou | Taihu Lake | Tai Hu San Bai Guan | michelin 2 | no | /changzhou/taihu-lake |
| `ve_19c49ddd1f` | xiamen | Laosongbian Food Shop | Lao Song Bian Shi Dian | michelin 2 | no | /xiamen/laosongbian-food-shop |
| `ve_1acc9ddd6e` | guangzhou | Guangzhou Restaurant | Chōwa | michelin 2, best-chef-awards 1 | no | /guangzhou/guangzhou-restaurant |
| `ve_1af2a4131e` | beijing | J & E Mansion | Mansion Cuisine by Jingyan | michelin 2, la-liste 1 | no | /beijing/j-e-mansion |
| `ve_1afae7044e` | changzhou | Changzhou Yinsi Noodle Restaurant | Sheng Xing Mian Guan | michelin 2 | no | /changzhou/changzhou-yinsi-noodle-restaurant |
| `ve_1b2c03f776` | guangzhou | 创发茶餐厅 | Chuang Fa | michelin 2 | no | /guangzhou/guangzhou-riiyew |
| `ve_1c6912f8ae` | taizhou | Binhaizhen | Bei Men Niu Xie Geng | michelin 2 | no | /taizhou/binhaizhen |
| `ve_1cbfbbefdc` | guangzhou | Taotaoju | Qi Cun Da Tou Hui | michelin 2 | no | /guangzhou/taotaoju |
| `ve_1d76320fee` | wenzhou | Wenzhou Restaurant | He Jiu Jia | michelin 2 | no | /wenzhou/wenzhou-restaurant |
| `ve_1dc8aff442` | hangzhou | Grandma''s Home | Hangzhou House | michelin 2 | no | /hangzhou/grandma-s-home |
| `ve_1f01073866` | nanjing | Liji Islamic Restaurant | Li Ji Qing Zhen Guan | michelin 2 | no | /nanjing/liji-islamic-restaurant |
| `ve_1f3c3fd54c` | guangzhou | Taian Men | Taian Table | la-liste 1, michelin 1 | no | /guangzhou/taian-men |
| `ve_1f4aafb6c5` | taizhou | Lige Langouste | Mr. Liang Seafood | michelin 2 | no | /taizhou/lige-langouste |
| `ve_1fe3d010a2` | hangzhou | Xiaolao Wonton | Xiao Lao Hun Tun | michelin 2 | no | /hangzhou/xiaolao-wonton |
| `ve_214cfada26` | guangzhou | Shudao Soodle (Kaihua Int'l. Shop) | Soodle | michelin 2 | no | /guangzhou/shudao-soodle-kaihua-int-l-shop |
| `ve_220fd92029` | taizhou | Laobian | Lao Bian Jiu Jia (Jindai Road) | michelin 2 | no | /taizhou/laobian |
| `ve_233a70ec6d` | nanjing | Zhengqing Beef Guotie Shop | Zheng Qing Niu Rou Guo Tie Dian | michelin 2 | no | /nanjing/zhengqing-beef-guotie-shop |
| `ve_2368174d5b` | yangzhou | Liuji, Dengzhou | Liu She Ji | michelin 2 | no | /yangzhou/liuji-dengzhou |
| `ve_2766d50b55` | nanjing | Jinling | Jin Ling Wang Jia Hun Tun (Jiqing Road) | michelin 2 | no | /nanjing/jinling |
| `ve_27c58623d2` | fuzhou | Longkushan Food Store | Longkushan Eatery | michelin 2 | no | /fuzhou/longkushan-food-store |
| `ve_29d118509d` | shanghai | Rong Restaurant | Rong Cuisine (Huangpu) | michelin 2 | no | /shanghai/rong-restaurant |
| `ve_2ae8d2a042` | taizhou | Ziyang Old Street | Rong Jia Xiao Chi (Ziyang Street) | michelin 2 | no | /taizhou/ziyang-old-street |
| `ve_2b7c417eb0` | beijing | Sichuan Provincial Government Restaurant | Lao Chuan Ban | michelin 2 | no | /beijing/sichuan-provincial-government-restaurant |
| `ve_2f34823c41` | shanghai | 南翔馒头店 | Nanxiang Steamed Bun | michelin 2 | no | /shanghai/shanghai-xajxis |
| `ve_326f6967cf` | guangzhou | 同记鸡粥 | Tong Ji | michelin 2 | no | /guangzhou/guangzhou-ffohc8 |
| `ve_33c0ec99ea` | xiamen | Waldorf Astoria Xiamen | Hokklo | michelin 2 | no | /xiamen/waldorf-astoria-xiamen |
| `ve_3431b7271e` | guangzhou | Zijin Restaurant | Zijin Shi Fang | michelin 2 | no | /guangzhou/zijin-restaurant |
| `ve_346f053e97` | guangzhou | Bingsheng Taste | BingSheng Mansion (Xiancun Road) | michelin 3 | no | /guangzhou/bingsheng-taste |
| `ve_348be5a2fb` | guangzhou | LN Hotel Five | Lingnan Haiyanlou (Binjiang East Road) | michelin 2 | no | /guangzhou/ln-hotel-five |
| `ve_35c10411c4` | shanghai | Taste of China | Oriental Sense & Palate | michelin 3 | no | /shanghai/taste-of-china |
| `ve_362df974af` | hangzhou | Hangzhou Longjingshan Park | Ye Long Jing | michelin 2 | no | /hangzhou/hangzhou-longjingshan-park |
| `ve_3685a7f175` | shanghai | Lucai Seafood | Lu Style (Huangpu) | michelin 2 | no | /shanghai/lucai-seafood |
| `ve_36e6b1664a` | guangzhou | Feitun Rougu Tea | FT · Bak Kut Teh (Yuexiu) | michelin 2 | no | /guangzhou/feitun-rougu-tea |
| `ve_37341fa372` | quanzhou | Jianlaifa Restaurant | Jian Lai Fa | michelin 2 | no | /quanzhou/jianlaifa-restaurant |
| `ve_386b5b5e79` | guangzhou | 新泰乐黄鳝专门店 | Xin Tai Le (Yuexiu) | michelin 2 | no | /guangzhou/guangzhou-jo7klo |
| `ve_38a720dd68` | yangzhou | Yangzhou | Yangzhou Yan (38 Changchun Road) | michelin 2 | no | /yangzhou/yangzhou |
| `ve_3959d1eab4` | guangzhou | Yu Yue Heen - Four Seasons Hotel Guangzhou | Yu Yue Heen | michelin 2 | no | /guangzhou/yu-yue-heen-four-seasons-hotel-guangzhou |
| `ve_3966886aeb` | fuzhou | Shangxiahang | Shang Xing | michelin 2 | no | /fuzhou/shangxiahang |
| `ve_39d22a063e` | beijing | Beijing Kitchen | The Beijing Kitchen (Jianguo Road) | michelin 2 | no | /beijing/beijing-kitchen |
| `ve_3b54c9f5ca` | shanghai | Laimei Luzi | Maison Lameloise | michelin 2, la-liste 1, oad 1 | no | /shanghai/laimei-luzi |
| `ve_3b5cc5997a` | guangzhou | Sining Liufuji | Enning Liu Fu Ji (Donghua East Road) | michelin 2 | no | /guangzhou/sining-liufuji |
| `ve_3c1c176fb0` | xiamen | 宴遇 | Yanyu (Jiahe Road) | michelin 2 | no | /xiamen/xiamen-6i7viy |
| `ve_3cbcb3b38a` | nanjing | Nanjing Dahui | Du Shi Li De Xiang Cun | michelin 2 | no | /nanjing/nanjing-dahui |
| `ve_3e561feda9` | suzhou | Sucheng Jiayan | Su Cheng Jia Yan (Ligongdi Road) | michelin 2 | no | /suzhou/sucheng-jiayan |
| `ve_3f7b8ed781` | suzhou | Pingjiang River | Pingjiangsong | michelin 2 | no | /suzhou/pingjiang-river |
| `ve_40083176bc` | beijing | The Georg By Georg Jensen Hus | The Georg | michelin 2 | no | /beijing/the-georg-by-georg-jensen-hus |
| `ve_40135edd08` | guangzhou | Minji Food | Mian Ji (Yuexiu) | michelin 2 | no | /guangzhou/minji-food |
| `ve_404cbd8475` | nanjing | Fangpo Gaotuan Shop | Fang Po | michelin 2 | no | /nanjing/fangpo-gaotuan-shop |
| `ve_43df8a2af9` | fuzhou | Tongli Rouyan Laopu | Yi Tong Lou | michelin 2 | no | /fuzhou/tongli-rouyan-laopu |
| `ve_4473c30ea7` | beijing | Jasmine restaurant | MO Jasmine | michelin 2 | no | /beijing/jasmine-restaurant |
| `ve_450c5c9eb7` | beijing | XIANG LIN TIAN XIA RESTAURANT | Xiang Lin Tian Xia | michelin 2 | no | /beijing/xiang-lin-tian-xia-restaurant |
| `ve_45a1b54b5a` | wenzhou | Wenzhou Mansion | Shuang Jing Tou | michelin 2 | no | /wenzhou/wenzhou-mansion |
| `ve_466ef261dc` | guangzhou | Hunan Restaurant | Hunan Cuisine | michelin 2 | no | /guangzhou/hunan-restaurant |
| `ve_4732e861db` | wenzhou | Yantouzhen | Yan Ji Gao Tou Pu | michelin 2 | no | /wenzhou/yantouzhen |
| `ve_47575e3f57` | wenzhou | Changren Wonton | Chang Ren Hun Tun Pu | michelin 2 | no | /wenzhou/changren-wonton |
| `ve_47ede2d4aa` | taizhou | Tongbai | Tang A Yi Bian Shi | michelin 2 | no | /taizhou/tongbai |
| `ve_4a18464f0a` | guangzhou | Sa'erta Dongxiang Shouzhua Restaurant | Sa Er Ta Dongxiang Shou Zhua | michelin 2 | no | /guangzhou/sa-erta-dongxiang-shouzhua-restaurant |
| `ve_4a3f18795d` | xiamen | Azhong Restaurant | A Zhong Shi Fang | michelin 2 | no | /xiamen/azhong-restaurant |
| `ve_4b0e487c12` | taizhou | Taizhou | Lao Tai Zhou | michelin 2 | no | /taizhou/taizhou |
| `ve_4bb832227c` | shanghai | Usual Place Noodle Restaurant | Lao Di Fang Mian Guan | michelin 2 | no | /shanghai/usual-place-noodle-restaurant |
| `ve_4cf56bc68c` | xiamen | Cong Hui Tong an Feng Rou | Cong Hui Tongan Lao Mei Shi Fan Dian | michelin 2 | no | /xiamen/cong-hui-tong-an-feng-rou |
| `ve_4ed10d8cc8` | guangzhou | Huixingyuan Restaurant | Hui Xing Yuan | michelin 2 | no | /guangzhou/huixingyuan-restaurant |
| `ve_4f22bd0e88` | hangzhou | Fanglaoda Noodles | Fang Lao Da (Shangcheng) | michelin 2 | no | /hangzhou/fanglaoda-noodles |
| `ve_4f7a800d7e` | nanjing | Gate of China, Nanjing | Chi Man | michelin 2 | no | /nanjing/gate-of-china-nanjing |
| `ve_4f80d1c56e` | guangzhou | Liangjie Nanning Pu Miao Sheng Zha Rice Noodle | Liang Jie Nanning Pumiao Shengzha Mifen | michelin 2 | no | /guangzhou/liangjie-nanning-pu-miao-sheng-zha-rice-noodle |
| `ve_4fb3596a23` | beijing | Fangzhuanchang Hutong | No. 69 Fangzhuanchang Zhajiangmian (Fangzhuanchang Hutong) | michelin 2 | no | /beijing/fangzhuanchang-hutong |
| `ve_502a1361dd` | hangzhou | Weidao | Xiao Shan Wei Dao | michelin 2 | no | /hangzhou/weidao |
| `ve_50fcf225a9` | changzhou | Yanzhi | Jiu Yan (Hehai East Road) | michelin 2 | no | /changzhou/yanzhi |
| `ve_5129a7ce2d` | shanghai | Xian | Wu You Xian | michelin 2 | no | /shanghai/xian |
| `ve_51d39ce232` | guangzhou | 南园酒家 | Nan Yuan | michelin 2 | no | /guangzhou/guangzhou-z4nz30 |
| `ve_51d92fd612` | nanjing | The Ritz-Carlton, Nanjing | Dai Yuet Heen | michelin 2 | no | /nanjing/the-ritz-carlton-nanjing |
| `ve_51eafde305` | xiamen | Fuyu Datong Duck Zhou | Fu Yu Da Tong Ya Rou Zhou | michelin 2 | no | /xiamen/fuyu-datong-duck-zhou |
| `ve_5358922bfc` | shanghai | Vivant | Vivant by Johnny Pham | michelin 2, best-chef-awards 1 | no | /shanghai/vivant |
| `ve_5439a35462` | hangzhou | Baozhongbao Restaurant | Bao Zhong Bao Shi Fu | michelin 2 | no | /hangzhou/baozhongbao-restaurant |
| `ve_545d5d504b` | xiamen | Minhe South | Minnan Minnan (Siming) | michelin 2 | no | /xiamen/minhe-south |
| `ve_548b41f4ff` | fuzhou | Jiang Nan NYC | Jiangnan Wok ‧ Rong | michelin 2 | no | /fuzhou/jiang-nan-nyc |
| `ve_55a80e1d17` | suzhou | Yanyuan Park | Yangzhou Yan · Qu Yuan | michelin 2 | no | /suzhou/yanyuan-park |
| `ve_567d9f103c` | beijing | Jade Garden | Giada Garden | michelin 2 | no | /beijing/jade-garden |
| `ve_5782845a81` | fuzhou | Jinrong South Road | Yong Zhou Ji Bian Rou (Jinrong South Road) | michelin 2 | no | /fuzhou/jinrong-south-road |
| `ve_594cd8ed54` | guangzhou | Xiangqun Restaurant | Xiang Qun (Longjin East Road) | michelin 2 | no | /guangzhou/xiangqun-restaurant |
| `ve_5b34bc394e` | xiamen | Wu Wei Shu Shi | Wuwei Natural Food | michelin 2 | no | /xiamen/wu-wei-shu-shi |
| `ve_5bb470fe65` | guangzhou | Song Sichuan Cuisine | Song Yuan | michelin 2 | no | /guangzhou/song-sichuan-cuisine |
| `ve_5c2048e226` | xiamen | 好食来大排档 | Hao Shi Lai | michelin 2 | no | /xiamen/xiamen-hdm2hw |
| `ve_5c6146eda4` | quanzhou | Aqiu Niupai Shop | A Qiu Niu Pai (Huxin Street) | michelin 2 | no | /quanzhou/aqiu-niupai-shop |
| `ve_5f54cf44b8` | suzhou | Tongdexing | Tong De Xing (Jiayu Fang) | michelin 2 | no | /suzhou/tongdexing |
| `ve_5ffdc0cb19` | shanghai | 福1015 | Fu 1015 | asia-50-best-restaurants 2, michelin 2, la-liste 1 | no | /shanghai/shanghai-gjadhw |
| `ve_60213ad03e` | guangzhou | Beijing Road Pedestrian Street Comprehensive Management Office | Temple Street | michelin 2 | no | /guangzhou/beijing-road-pedestrian-street-comprehensive-management-office |
| `ve_615254eaed` | shanghai | 老正兴菜馆 | Lao Zheng Xing | michelin 2 | no | /shanghai/shanghai-gtyaw8 |
| `ve_61f1a5a54b` | shanghai | Fu Yi Ling San Jiu | Fu 1039 | michelin 2, oad 1 | no | /shanghai/fu-yi-ling-san-jiu |
| `ve_6340373046` | guangzhou | Hongtufu Restaurant | Hongtu Hall | michelin 2 | no | /guangzhou/hongtufu-restaurant |
| `ve_643f7f9a62` | beijing | Honglu Beijing Restaurant | Lu Shang Lu | michelin 2 | no | /beijing/honglu-beijing-restaurant |
| `ve_6672d45c44` | beijing | Beijing Da Dong | Gastro Esthetics DaDong | michelin 2, best-chef-awards 1 | no | /beijing/beijing-da-dong |
| `ve_674ed12b78` | shanghai | Gongdelin | Gong De Lin (West Nanjing Road) | michelin 2 | no | /shanghai/gongdelin |
| `ve_680ba6ae90` | guangzhou | Xinji Seafood Restaurant | Xin Wen Ji (Panfu Road) | michelin 2 | no | /guangzhou/xinji-seafood-restaurant |
| `ve_6999ba83ec` | hangzhou | Dragon Well Manor | Longjing Manor | michelin 2, oad 1 | no | /hangzhou/dragon-well-manor |
| `ve_69a5bf5664` | suzhou | Suzhehui Peasant-Style Yard | Ge Jia Wu Farmer’s House | michelin 2 | no | /suzhou/suzhehui-peasant-style-yard |
| `ve_6a5ce2a273` | shanghai | Laowang Guowu Restaurant | Wang Lu (Pudong) | michelin 2 | no | /shanghai/laowang-guowu-restaurant |
| `ve_6f5ab461ea` | shanghai | Jing Mei Su Mian | Jingmei Wuxi Noodles (Yanping Road) | michelin 2 | no | /shanghai/jing-mei-su-mian |
| `ve_6f82b3520a` | beijing | Pangmei Noodle Restaurant | Pang Mei Noodles (Xiang'er Hutong) | michelin 2 | no | /beijing/pangmei-noodle-restaurant |
| `ve_6fc43f582e` | shanghai | Renhe Restaurant | Ren He Guan (Xuhui) | michelin 2 | no | /shanghai/renhe-restaurant |
| `ve_708f092edb` | quanzhou | Licheng District, Quanzhou | Hall Thing (Licheng) | michelin 2 | no | /quanzhou/licheng-district-quanzhou |
| `ve_70ca3373b2` | hangzhou | 桂语山房高级餐厅 | Guiyu (Xihu) | michelin 2, la-liste 1 | no | /hangzhou/hangzhou-bgq3ei |
| `ve_7176a2f9d7` | nanjing | Nanjing Duck Blood Vermicelli Soup | Zhi He Lao Ya Fen Si Tang | michelin 2 | no | /nanjing/nanjing-duck-blood-vermicelli-soup |
| `ve_74763ed659` | beijing | Dongcheng Furong Restaurant | Furong | michelin 2 | no | /beijing/dongcheng-furong-restaurant |
| `ve_763d077255` | yangzhou | 何园 | Hu Yuan Mei Shi | michelin 2 | no | /yangzhou/yangzhou-7wgtw0 |
| `ve_7874ea5ed1` | xiamen | Sili Noodles With Barbeque Sauce | Shan Li Yan Sha Cha Mian | michelin 2 | no | /xiamen/sili-noodles-with-barbeque-sauce |
| `ve_78e5d38e3e` | shanghai | M on the Bund | Meet the Bund (Zhongshan Dong Er Road) | asia-50-best-restaurants 4, best-chef-awards 2, la-liste 1, michelin 1, oad 1 | no | /shanghai/m-on-the-bund |
| `ve_7c2a8db0cc` | guangzhou | Bingsheng Seafood Restaurant | Fa Sing Garden (Jinsui Road) | michelin 2 | no | /guangzhou/bingsheng-seafood-restaurant |
| `ve_7d700ff172` | hangzhou | Vallie Hotel | L'éclat 19 | michelin 2 | no | /hangzhou/vallie-hotel |
| `ve_810781d02c` | wenzhou | Shen Xian Mian | Sun Guo Hua Qing Jiang San Xian Mian (Renmin North Road) | michelin 2 | no | /wenzhou/shen-xian-mian |
| `ve_821f15690f` | shanghai | Xiyue No.8 | Canton 8 (Huangpu) | michelin 2, oad 1 | no | /shanghai/xiyue-no-8 |
| `ve_832a291604` | hangzhou | Le Meridien Hangzhou Binjiang | Yue Ji (Binjiang) | michelin 2 | no | /hangzhou/le-meridien-hangzhou-binjiang |
| `ve_8517995e19` | guangzhou | Lei Garden | Lei Garden (Yuexiu) | michelin 2, la-liste 1 | no | /guangzhou/lei-garden |
| `ve_858d4a4ba7` | fuzhou | Backstreet Laohua | Hou Jie Lao Hua (216 Tonghu Road) | michelin 2 | no | /fuzhou/backstreet-laohua |
| `ve_85c6feef1b` | quanzhou | Qing Yu | Qing You Yu | michelin 2 | no | /quanzhou/qing-yu |
| `ve_88553fb416` | beijing | Shijiu | Poetry‧Wine (Dongsanhuan Middle Road) | michelin 2 | no | /beijing/shijiu |
| `ve_885573af29` | shanghai | Lanxin Restaurant | Lan Xin (Jinxian Road) | michelin 2 | no | /shanghai/lanxin-restaurant |
| `ve_8855f2f247` | shanghai | Yongxing Restaurant | Sheng Yong Xing (Huangpu) | michelin 2 | no | /shanghai/yongxing-restaurant |
| `ve_889a42dda9` | taizhou | Shen Jimaixia Dough Shop | Shen Ji Mai Xia Mian Pi Dian | michelin 2 | no | /taizhou/shen-jimaixia-dough-shop |
| `ve_892eae0859` | suzhou | Weiji'ao Noodle Restaurant | Wei Ji Ao Mian Guan (East Baita Road) | michelin 2 | no | /suzhou/weiji-ao-noodle-restaurant |
| `ve_894c978cf0` | shanghai | Ji Pin Xiao Xian | Ji Pin Court | michelin 2, la-liste 1 | no | /shanghai/ji-pin-xiao-xian |
| `ve_8974cad8e9` | taizhou | Road Bridge Jiang Noodles Soup | Ma Lu Qiao Jiang Tang Mian | michelin 2 | no | /taizhou/road-bridge-jiang-noodles-soup |
| `ve_8a5b0b0df3` | beijing | Old Beijing Chaishi | Ladychai | michelin 2 | no | /beijing/old-beijing-chaishi |
| `ve_8b3a664168` | shanghai | Zhoushe | Zhou She (Minhang) | michelin 2 | no | /shanghai/zhoushe |
| `ve_8bb1dc1f91` | fuzhou | Guan Zhong Wang Shi | Guan Zhong Wang Shi (Gulou) | michelin 2 | no | /fuzhou/guan-zhong-wang-shi |
| `ve_8c3f87f67f` | yangzhou | Fanshuichang Fish Noodles | Fan Shui Chang Yu Mian (North Jiefang Road) | michelin 2 | no | /yangzhou/fanshuichang-fish-noodles |
| `ve_8cbb6e9fa9` | shanghai | Hao Sheng II | Hao Sheng | michelin 2 | no | /shanghai/hao-sheng-ii |
| `ve_8ce0987360` | wenzhou | Huangyumian | Yangjia Shantou Mai Mian Lao Dian (Canghe Lane) | michelin 2 | no | /wenzhou/huangyumian |
| `ve_8d96aa8573` | shanghai | Maolong Restaurant | Mao Long | michelin 2 | no | /shanghai/maolong-restaurant |
| `ve_8db1436125` | beijing | Shengyongxing Restaurant | Sheng Yong Xing (Chaoyang) | michelin 2, oad 1 | no | /beijing/shengyongxing-restaurant |
| `ve_8ddc148987` | fuzhou | Yuxiandu | Yu Xian Lou | michelin 2 | no | /fuzhou/yuxiandu |
| `ve_8eebb0534c` | fuzhou | Nan'ao Shan | Shan Hai Nan Yan | michelin 2 | no | /fuzhou/nan-ao-shan |
| `ve_8ff48e1c8f` | shanghai | Xin Rong Ji | The House of Rong | asia-50-best-restaurants 3, michelin 2, oad 1 | no | /shanghai/xin-rong-ji |
| `ve_91b0601a41` | taizhou | Huipu Snack Booth | Hui Pu Pai Dang | michelin 2 | no | /taizhou/huipu-snack-booth |
| `ve_92b5f3a2f3` | shanghai | Sole Lla | Sole | michelin 2 | no | /shanghai/sole-lla |
| `ve_931133988a` | guangzhou | Wenjian | Wen Ji Yixinji | michelin 2 | no | /guangzhou/wenjian |
| `ve_9345ef8e01` | taizhou | Asan Seafood | Fullie's Seafood House | michelin 2 | no | /taizhou/asan-seafood |
| `ve_93ad314358` | shanghai | 扬州饭店 | Yangzhou Fan Dian (Huangpu) | michelin 2 | no | /shanghai/shanghai-rc1yms |
| `ve_958e8f01d5` | shanghai | Shanghai Delight | Huaiyang Delights (Jingan) | michelin 2 | no | /shanghai/shanghai-delight |
| `ve_959d4758e4` | taizhou | Noodle Nine | Jiu Wei | michelin 2 | no | /taizhou/noodle-nine |
| `ve_983ce43901` | quanzhou | Luojimian Line Hu | Luo Ji Mian Xian Hu | michelin 2 | no | /quanzhou/luojimian-line-hu |
| `ve_992e7faf4b` | shanghai | Rong Shu Huang Yu Mian | Rongjia Noodles Soup with Yellow Croaker (Jingan) | michelin 2 | no | /shanghai/rong-shu-huang-yu-mian |
| `ve_9a47242102` | taizhou | Zhang Yuan Chui Fan | Zhang Yuan Chui Fan (Yanyu Road) | michelin 2 | no | /taizhou/zhang-yuan-chui-fan |
| `ve_9a84effcd4` | guangzhou | 达杨原味炖品 | Dayang (Wenming Road) | michelin 2 | no | /guangzhou/guangzhou-q9xhpy |
| `ve_9ba3a5d492` | nanjing | Wuminglao Braised Noodles | Wu Ming Lao Lu Mian | michelin 2 | no | /nanjing/wuminglao-braised-noodles |
| `ve_9c582cd9ed` | suzhou | Samsung Mutton Restaurant | San Xing Yang Rou Guan | michelin 2 | no | /suzhou/samsung-mutton-restaurant |
| `ve_9e3ff3f767` | quanzhou | Lucky Zhang's（ 8大道张家興） | Zhang Lin A Shan Jiang Mu Ya | michelin 2 | no | /quanzhou/lucky-zhang-s-8 |
| `ve_9f2b2906c2` | quanzhou | Quanzhou | Chun Sheng | michelin 2 | no | /quanzhou/quanzhou |
| `ve_a119bb8427` | beijing | Mingyuan | Mingyuan Restaurant | michelin 2 | no | /beijing/mingyuan |
| `ve_a3dcfd53ea` | taizhou | Weichen Snack Bar | Wei Chen Xiao Chi | michelin 2 | no | /taizhou/weichen-snack-bar |
| `ve_a3e49b0fb3` | guangzhou | Sheraton Guangzhou Hotel | Stay Here | michelin 2 | no | /guangzhou/sheraton-guangzhou-hotel |
| `ve_a4c83564e5` | shanghai | Taotaoju | Tou Zao | michelin 2, best-chef-awards 1 | no | /shanghai/taotaoju |
| `ve_a4cfa692ff` | guangzhou | Lingnan Restaurant | Lingnan House | michelin 2, best-chef-awards 1 | no | /guangzhou/lingnan-restaurant |
| `ve_a4f1a3bf9c` | changzhou | Wuyue Square | Hua Yue Dou Xiang | michelin 2 | no | /changzhou/wuyue-square |
| `ve_a709525134` | xiamen | Xi Xia Chinese Cuisine | A Xi Xia Mian | michelin 2 | no | /xiamen/xi-xia-chinese-cuisine |
| `ve_a85f950dc3` | shanghai | Lailai Snack Dumpling | Qiao Ai Lai Lai Xiao Long (Huangpu) | michelin 2 | no | /shanghai/lailai-snack-dumpling |
| `ve_a8a1e98cc4` | quanzhou | Ant Privacy Kitchen | Antstory | michelin 2 | no | /quanzhou/ant-privacy-kitchen |
| `ve_a9d88204ae` | changzhou | Tianning Temple | Chang Xian De (Tianning) | michelin 2 | no | /changzhou/tianning-temple |
| `ve_a9e4115195` | guangzhou | Zhuzaiji Restaurant Head Office | Zhu Zai Ji Shi Fu (Jiangnan Avenue) | michelin 2 | no | /guangzhou/zhuzaiji-restaurant-head-office |
| `ve_aa194713b5` | fuzhou | Xingxian Restaurant | A Xin Xian Lao (Gongnong Road) | michelin 2 | no | /fuzhou/xingxian-restaurant |
| `ve_ab77079d98` | xiamen | Mingyue Xiamian | Ming Yue Xia Mian (Xiahe Road) | michelin 2 | no | /xiamen/mingyue-xiamian |
| `ve_ab89dbb319` | beijing | Yibin Burning Noodle | Yibin | michelin 2 | no | /beijing/yibin-burning-noodle |
| `ve_abd6c983fc` | beijing | Tianchu Miaoxiang | Tianchumiaoxiang Vegetarian (Chaoyang) | michelin 2 | no | /beijing/tianchu-miaoxiang |
| `ve_ad61d5e039` | guangzhou | Jianji Noodles Restaurant | Jian Ji (Liwan) | michelin 2 | no | /guangzhou/jianji-noodles-restaurant |
| `ve_ad8e3e0807` | taizhou | Xinrongji | Xin Rong Ji (Linhai) | asia-50-best-restaurants 1, michelin 1 | no | /taizhou/xinrongji |
| `ve_af3baeb42c` | ningde | Fuding Authentic Bianrou | Fu Ding Zheng Zong Bian Rou (Jianxin Road) | michelin 2 | no | /ningde/fuding-authentic-bianrou |
| `ve_b075220a1b` | beijing | 黑天鹅餐厅 | Blackswan | michelin 2, best-chef-awards 1, la-liste 1 | no | /beijing/beijing-6m8heo |
| `ve_b172568649` | shanghai | Shanghai Bvlgari Hotel-Banquet Hall | Bao Li Xuan | michelin 2, oad 1 | no | /shanghai/shanghai-bvlgari-hotel-banquet-hall |
| `ve_b47c884651` | guangzhou | Yayuan Restaurant | Jia Yuan | michelin 2 | no | /guangzhou/yayuan-restaurant |
| `ve_b66dbcd3f4` | suzhou | Yumiantang | Yu Mian Tang (Nanxin Road) | michelin 2 | no | /suzhou/yumiantang |
| `ve_b69e4aa4be` | guangzhou | Dagefan | Da Ge Fan (Tangxiayong West Road) | michelin 2 | no | /guangzhou/dagefan |
| `ve_b7fc0083cc` | nanjing | Ningfu | Pin Ning Fu | michelin 2 | no | /nanjing/ningfu |
| `ve_bb2dc8bf0e` | shanghai | Polux by Paul Pairet | Polux | michelin 2 | no | /shanghai/polux-by-paul-pairet |
| `ve_bc7ea4dff4` | beijing | Tongheju | Tong He Ju (Yuetan South Street) | michelin 2 | no | /beijing/tongheju |
| `ve_bd23f794b5` | yangzhou | Chuanchengyuan | Cheng Yuan | michelin 2 | no | /yangzhou/chuanchengyuan |
| `ve_bdcb7d5b71` | yangzhou | Laohu Noodle Restaurant | Lao Hu Mian Guan | michelin 2 | no | /yangzhou/laohu-noodle-restaurant |
| `ve_be11ec0b37` | guangzhou | Haixian Street Restaurant | Hai Xian Jie Cai Guan | michelin 2 | no | /guangzhou/haixian-street-restaurant |
| `ve_bf3adf5226` | beijing | Four Seasons Beijing | Cai Yi Xuan | michelin 2, oad 1 | no | /beijing/four-seasons-beijing |
| `ve_c146f02657` | shanghai | Chenglonghang | Cheng Long Hang (Huangpu) | michelin 2 | no | /shanghai/chenglonghang |
| `ve_c34958da29` | shanghai | Yuxing Ji | Yu Ge Zhanjiang (Jingan) | michelin 2 | no | /shanghai/yuxing-ji |
| `ve_c4eac998eb` | taizhou | Xinrongji Cuisine Linghu Branch | Rong Cun (Gucheng Street) | michelin 2 | no | /taizhou/xinrongji-cuisine-linghu-branch |
| `ve_c8ceea9779` | shanghai | Lei Garden Restaurant | Lei Garden (Pudong) | michelin 2 | no | /shanghai/lei-garden-restaurant |
| `ve_c90b07f1bf` | beijing | Longting | The House of Dynasties | michelin 2 | no | /beijing/longting |
| `ve_c95452bfed` | beijing | Ling Long | Lamdre | asia-50-best-restaurants 4, michelin 2, oad 2, best-chef-awards 1, la-liste 1 | no | /beijing/ling-long |
| `ve_cafb98b169` | beijing | Rong Rest. Beijing Dawang Rd. Br. | Rong Cuisine (Baiziwan South Er Road) | michelin 3 | no | /beijing/rong-rest-beijing-dawang-rd-br |
| `ve_cbb08ffdee` | guangzhou | Yutang Chunnuan Restaurant | Jade River | la-liste 1, michelin 1 | no | /guangzhou/yutang-chunnuan-restaurant |
| `ve_d03a39c2c2` | nanjing | Jinling Yangjia Wonton Restaurant | Jin Ling Yang Jia Hun Tun Dian (Caodu Lane) | michelin 2 | no | /nanjing/jinling-yangjia-wonton-restaurant |
| `ve_d3814835da` | shanghai | Jingxihui | Amazing Chinese Cuisine (Changning) | michelin 2, la-liste 1 | no | /shanghai/jingxihui |
| `ve_d399685f96` | guangzhou | Yongli Restaurant | Yong Zuo | michelin 2 | no | /guangzhou/yongli-restaurant |
| `ve_d3f69a8eff` | nanjing | Xiaoli Steamed Bun Stuffed With Juicy Pork | Cui Jie Xiao Chi | michelin 2 | no | /nanjing/xiaoli-steamed-bun-stuffed-with-juicy-pork |
| `ve_d46114d738` | changzhou | Tianning District | Qing Wa Xiang (Tianning) | michelin 2 | no | /changzhou/tianning-district |
| `ve_d485a840c0` | shanghai | Shanghai Grandmother Restaurant | Fabula | michelin 2 | no | /shanghai/shanghai-grandmother-restaurant |
| `ve_d5746d246e` | hangzhou | Zhiweiguan | Zhi Zhu | michelin 2 | no | /hangzhou/zhiweiguan |
| `ve_d658df99a8` | quanzhou | Jiufu Minnan Flavor | Zhuang Ji Quan Fu Lu Mian Guan | michelin 2 | no | /quanzhou/jiufu-minnan-flavor |
| `ve_d786202a4e` | guangzhou | Weishi Furniture Fangcai | Wei Shi Jia | michelin 2 | no | /guangzhou/weishi-furniture-fangcai |
| `ve_d82e2354e6` | fuzhou | Wenru No.9 Assembly Hall | Wenru No.9 | michelin 3 | no | /fuzhou/wenru-no-9-assembly-hall |
| `ve_dac6f2bd65` | yangzhou | Shuangdong Hotel | Shuang Dong | michelin 2 | no | /yangzhou/shuangdong-hotel |
| `ve_dc479eb6ab` | shanghai | Dahuchun | Da Hu Chun (Middle Sichuan Road) | michelin 2 | no | /shanghai/dahuchun |
| `ve_dd9529abf4` | changzhou | Detan Hotel | Fang Xiang by Detan (Zhonglou) | michelin 2 | no | /changzhou/detan-hotel |
| `ve_de7979639f` | guangzhou | Sichu | BingSheng Private Kitchen (Tianhe East Road) | michelin 2, la-liste 1, oad 1 | no | /guangzhou/sichu |
| `ve_dfa9421242` | xiamen | 好德来姜母鸭 | Bai Jia Chun Hao De Lai Jiang Mu Ya (Zhongxing Road) | michelin 2 | no | /xiamen/xiamen-oeaknu |
| `ve_e08de51373` | beijing | Yuhuatai Restaurant | Yu Hua Tai (Xicheng) | michelin 2 | no | /beijing/yuhuatai-restaurant |
| `ve_e1de2a4f90` | shanghai | Linhu Vegetarian | The Lakeside Veggie | michelin 2 | no | /shanghai/linhu-vegetarian |
| `ve_e2e5854a3f` | xiamen | Luchengxuan | Zhen Zhen Hai Li Jian | michelin 2 | no | /xiamen/luchengxuan |
| `ve_e4a5d832bc` | nanjing | Qiangye Restaurant | Qiang Ye Fan Dian | michelin 2 | no | /nanjing/qiangye-restaurant |
| `ve_e59b755e48` | wenzhou | Zhengliang Seafood | Zheng Zhengliang Seafood (Nantang Street) | michelin 2 | no | /wenzhou/zhengliang-seafood |
| `ve_e5e6bb6ea3` | guangzhou | South China Agricultural University Wisca Reataurant | Wisca (Haizhu) | michelin 2 | no | /guangzhou/south-china-agricultural-university-wisca-reataurant |
| `ve_e6415390b3` | fuzhou | Minwei Restaurant | Min Shi Fu | michelin 2 | no | /fuzhou/minwei-restaurant |
| `ve_e974046d60` | changzhou | South Garden Chinese Restaurant | South Garden | michelin 2 | no | /changzhou/south-garden-chinese-restaurant |
| `ve_ebab369dd0` | xiamen | Guogong Restaurant | Guo Gong Fan Dian | michelin 2 | no | /xiamen/guogong-restaurant |
| `ve_eca1f440c7` | suzhou | Acheng Homely Restaurant | A Cheng | michelin 2 | no | /suzhou/acheng-homely-restaurant |
| `ve_eca27cd696` | shanghai | Noodle Restaurant | A Yong Mian Guan (Dongshufang Road) | michelin 2 | no | /shanghai/noodle-restaurant |
| `ve_ecff937fc5` | xiamen | Zhongshan Road | Shan Gu Tang (Xiahe Road) | michelin 2 | no | /xiamen/zhongshan-road |
| `ve_ed743bab06` | hangzhou | Fuyuanju | Fu Yuan Ju (Shangcheng) | michelin 2 | no | /hangzhou/fuyuanju |
| `ve_ed781f677a` | suzhou | Baisheng Household | Bai Sheng Ren Jia (Wuzhong) | michelin 2 | no | /suzhou/baisheng-household |
| `ve_ed8fe96699` | beijing | Xinrongji | Xin Rong Ji (Xinyuan South Road) | asia-50-best-restaurants 2, michelin 2, la-liste 1, oad 1 | no | /beijing/xinrongji |
| `ve_eda15577f1` | ningde | Yuzhong County | Hu Yu Zhong Wu Qu Bian Rou | michelin 2 | no | /ningde/yuzhong-county |
| `ve_edc5ed438c` | beijing | Laojitang Shanghai Private Kitchens | Shanghai Cuisine | michelin 2, oad 1 | no | /beijing/laojitang-shanghai-private-kitchens |
| `ve_edd7b52006` | taizhou | Hewei Side Dish | He Wei Xiao Chao | michelin 2 | no | /taizhou/hewei-side-dish |
| `ve_f0739c29ee` | taizhou | Linhai Chaomaci | Lao Huang Chao Ma Ci | michelin 2 | no | /taizhou/linhai-chaomaci |
| `ve_f1a0a54c6d` | hangzhou | Xinliuhe Private Kitchens | Xin Liu He | michelin 2 | no | /hangzhou/xinliuhe-private-kitchens |
| `ve_f1bfe13e78` | shanghai | JadeGarden | Easeful Cuisine (Jingan) | michelin 2 | no | /shanghai/jadegarden |
| `ve_f2972577c8` | suzhou | Yaba Shengjian | Ya Ba Sheng Jian (Wenjia An) | michelin 3 | no | /suzhou/yaba-shengjian |
| `ve_f45b2bb7ce` | beijing | Baoyuan Dumplings Restaurant | Bao Yuan | michelin 2 | no | /beijing/baoyuan-dumplings-restaurant |
| `ve_f4a69bd8e0` | beijing | Chao Hotel Sanlitun | Chao Shang Chao (Chaoyang) | best-chef-awards 2, michelin 2 | no | /beijing/chao-hotel-sanlitun |
| `ve_f62c27d4bf` | quanzhou | Quanzhou Mianxian Hu & Xianfan | De Wen Xia Zai Mian | michelin 2 | no | /quanzhou/quanzhou-mianxian-hu-xianfan |
| `ve_f8917f2b64` | xiamen | Wutang Noodles With Barbeque Sauce | Wu Tang Sha Cha Mian | michelin 2 | no | /xiamen/wutang-noodles-with-barbeque-sauce |
| `ve_f9a80a0cc1` | beijing | Jinbao Tower | Lei Garden (Jinbao Tower) | michelin 2 | no | /beijing/jinbao-tower |
| `ve_fa442b75d7` | shanghai | Le Comotoir De Pierre Gagnaire | le Comptoir de Pierre Gagnaire | forbes-travel-guide 5, michelin 2, la-liste 1 | no | /shanghai/le-comotoir-de-pierre-gagnaire |
| `ve_fa7734074b` | wenzhou | Wenzhou | Ayu Renjiashao | michelin 2 | no | /wenzhou/wenzhou |
| `ve_faf602fed0` | shanghai | Mingge | Ming Court (Minhang) | michelin 2 | no | /shanghai/mingge |
| `ve_fb2d8a30a9` | beijing | Jingyi Restaurant | Jingyi (Liulichang East Street) | michelin 2 | no | /beijing/jingyi-restaurant |
| `ve_fb81fae00f` | shanghai | Jin Xuan - The Ritz-Carlton Shanghai, Pudong | Jin Xuan | forbes-travel-guide 7, michelin 2 | no | /shanghai/jin-xuan-the-ritz-carlton-shanghai-pudong |
| `ve_fbbf6d56c4` | beijing | Quick-Fried Tripe Jinshenglong | Bao Du Jin Sheng Long (Dongcheng) | michelin 2 | no | /beijing/quick-fried-tripe-jinshenglong |
| `ve_fe82420389` | taizhou | Liji Old Brand Bone Soup Shop | Li Ji Gu Tou Tang | michelin 2 | no | /taizhou/liji-old-brand-bone-soup-shop |
| `ve_feb8000925` | nanjing | Tan Fulin Xuan Vegetarian Food Restaurant | Fu Lin Xuan (Jiqingmen Street) | michelin 2 | no | /nanjing/tan-fulin-xuan-vegetarian-food-restaurant |

**The slug does not change, and neither does any URL.** Every page on the site keys on the venue id, and the slug is minted once. Changing a slug means a redirect and a decision about an address people may already have; that is a separate decision and a separate job, and this one will not make it for you.

Awards are not touched either. An award row keeps the publisher's own full string.

### Where else the name is stored

Searched, not assumed: all 91 text columns of every table in the `public` schema were counted against the 263 name(s) about to change (`venues.name` itself and the generated `venues.norm_key` excluded).

| table.column | rows holding one of these names |
|---|---|
| `city_label_source.label` | 72 |
| `venues.name_native` | 16 |
| `cities.display` | 4 |

Those are copies this job does **not** rewrite. It changes `venues.name` and nothing else; anything above is for your list.

Not searched, and named so the gap is on the record: `audit_log.new_row`, `audit_log.old_row`, `blurbs.sources`, `hours.days_open`, `ingest_rows.raw`, `ingest_rows.validation`, `rename_rows.detail`. Every one of those is a jsonb document, and every one is either history - what was true when it was written, which a rename must never rewrite - or a provenance document a substring match would misreport.

## Counts

Population: whole table, read inside the transaction before and after the writes.

| table | before | expected | actual |
|---|---|---|---|
| venues | 11,221 | 11,221 | 11,221 |
| awards | 22,493 | 22,493 | 22,493 |
| slugs | 12,034 | 12,034 | 12,034 |
| blurbs | 142 | 142 | 142 |
| source_capture_ledger | 34 | 35 | 35 |
| rename_batches | 2 | 3 | 3 |
| rename_rows | 269 | 532 | 532 |

A rename changes no count at all except this job's own two tables and the ledger. `venues`, `awards`, `slugs` and `blurbs` are in the table so that "it changed nothing else" is a measurement rather than a promise.

## Invariants

All of them checked inside the transaction. One failure rolls the whole batch back.

| check | result | detail |
|---|---|---|
| renamed venues equals the rename rows in the file | pass | 263 (expected 263) |
| every renamed venue's live name is its new_name | pass | 0 of 263 disagree |
| venue count unchanged | pass | 0 (expected 0) |
| award count unchanged | pass | 0 (expected 0) |
| slug count unchanged - a rename never changes a URL | pass | 0 (expected 0) |
| blurb count unchanged | pass | 0 (expected 0) |
| ledger rows added equals the publishers in the batch | pass | 1 (expected 1) |
| rename_rows written equals the rows in the file | pass | 263 (expected 263) |
| one rename_batches row | pass | 1 (expected 1) |
| audit_log shows exactly this batch's renames for this transaction | pass | 263 name changes (expected 263), 0 other venue updates (expected 0) |

## Sample

The first 5 of the 263 renames, in file order. Population: the `rename` rows of this batch.

| venue id | old name | new name | publisher | source URL |
|---|---|---|---|---|
| `ve_00c898a89c` | Huage Privacy Kitchen | Hua Ge Si Chu | michelin | https://guide.michelin.com/us/en/guangdong-province/guangzhou/restaurant/hua-ge-si-chu |
| `ve_015c3461ad` | Chic 1699 Yuanyang Privacy Kitchen | Chic 1699 | michelin | https://guide.michelin.com/us/en/fujian-province/xiamen_1031934/restaurant/chic-1699-1213633 |
| `ve_01b7949aea` | Quyuan | Liuyuanchun Teahouse | michelin | https://guide.michelin.com/us/en/jiang-su/yangzhou_1032329/restaurant/liuyuanchun-teahouse |
| `ve_025cd433e8` | Xiangbinxuan Restaurant | Xiang Bin Xuan (Huayuan Road) | michelin | https://guide.michelin.com/us/en/beijing-municipality/beijing/restaurant/xiang-bin-xuan-huayuan-road |
| `ve_027040b69f` | Wumingshi Noodle Restaurant | Er Ba Jiu Su Mian Guan | michelin | https://guide.michelin.com/us/en/zhe-jiang/hangzhou_1027184/restaurant/er-ba-jiu-su-mian-guan |

## Exposure ledger

One row per publisher whose spelling this batch followed, field type `name`, job `rename-apply:rename-michelin-2026-china`. Population: the `rename` rows, grouped by `source_id`.

| publisher | field type | venues renamed |
|---|---|---|
| michelin | name | 263 |

Spellings followed: michelin (263).

## Undo

Nothing to undo: this was a dry run. Untick the box to do it for real.
