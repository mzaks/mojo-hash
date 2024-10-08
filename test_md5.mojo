from md5 import md5_string
from testing import assert_equal
from wyhasher import wyhash
from wyhasher.wyhasher import wymum

alias alphabete: String = "0123456789abcdef"

fn to_hex(v: SIMD[DType.uint8, 16]) -> String:
    var result: String = ""
    for i in range(16):
        var h = v[i] >> 4
        var l = v[i] & 15
        result += alphabete[int(h)]
        result += alphabete[int(l)]
    return result

fn main() raises:
    var a: String = "Hello 🔥"
    assert_equal(to_hex(md5_string(a)), "b9735ea236e0d3103a39ad102a2e990f")
    _ = a
    var b: String = '米くを舵4物委らご氏松ハナテフ月関ソ時平ふいの博情れじフ牟万い元56園フメヤオ試図ロツヤ未備王こと傷喫羅踊んゆし。栃ユヱオ書著作ユソツロ英祉業ア大課ご権質フべ空8午キ切軟づン著郎そゃす格町採ヱオマコ処8付国ムハチア究表でなだ際無ロミヱ地兵ぴげ庭体すク発抜爆位や。楽富むゆず盛航カナセ携代ハ本高きた員59今骸ンラえぜ城解イケ穴訴ぽぎ属住ヤケトヌ抱点ト広注厚でて。 国リ出難セユメ軍手ヘカウ画形サヲシ猛85用ヲキミ心死よしと身処ケヨミオ教主ーぽ事業んく字国たさょ図能シミスヤ社8板ル岡世58次戒知院んれり。市メ誘根カ数問禁竹ゃれえみ給辺のでみき今二ぎさ裕止過こクすと無32郎所ラた生展ヌヘス成度慣葬勇厘ばてか。室ゃ下携疲ム色権がぽりっ銃週ノオ姫千テム健蔵い研手ッ放容ル告属め旅側26企サノヨ宅都福ぞ通待ちぴね種脳イど労希望義通むン。 罰しい続負せ著低たル異師ユハワ東添質コチ転集ルヤ雇聴約ヒ前統らた情厳ゆさでや真胸や有披暑棚豆ゆぼたけ。盛ワセロナ情競クるっわ講3音ずをせ少地めしぜょ手63明視れに判企ヒヌエソ求総58特本ね井比ユラキ禁頭馬るゅリす能率率かがさわ。葉サソ医郡ヱヘソ労帰ナケスミ救写ワヘ株審ネヒニミ安逮イ人画ラ涯車はラ極騒りなド件5級ンかふー劇41著ぱぐ凱討だ文世ぶづどま界善魅マ渓経競融れがや。 連ーぜらご模分ッ視外ばフく運発群ほぼづ育越一ほごクけ案募ヲイソ治会イせフ製君ぜた漢村1変リヒ構5際ツ御文ヲ臭入さドぼ代書ハケ引技ろみれ回観注倉徹ぱ。論ラづ海要サ情座ゃり齢宣ラモエ芸化エマホ覧催回ら戦69本外ト葬岳な政画か連針ぴリフず。約ル闘辺ぽ経2応掲ホサアラ塾小コラ画決クノオ上室レヌヱ勝逮ぜるえむ責豊チノ明意ひけ訟6碁草メタチエ財午召喝塊む。 決めでわ名金つけレわ続人県約ぽぼす尾腹ユサ戦載リシ護賀レモフツ重涯ニ治者むんっみ職更カタチレ提話2何ワ責東まけげふ能政ヌ供禁がびてわ提改倶れめ。読み担後ぽ安加ぎ論鹿ツ統最お気麻月つじもあ竜思いろめ判必満理トコ文連ムイウハ寄串ざほびー。文ゆこっ向27年メイ便能ノセヲ待1王スねたゆ伝派んね点過カト治読よにきべ使人スシ都言え阻8割べづえみ注引敷的岳犠眠どそ。 学用イだ医客開ロ供界もぞだ実隆モイヌ務坂ナコヲ権野ろづ初場ぱ低会づぱじ新倒コ化政レ止奮浸猪ッわえづ。形いやリ要帰ほまむだ業領スル必打さ島14巻リ集日ネヘホタ面幅ち写上そぴ円図ムタコモ報使イわざと会催ヤヲ康証をドぶレ盤岡ホハツ作29管しをめ公問懐蓄っさ。来ゆぼあぱ投秋シ語右ぐ身靖かば辛握捕家記ヘワ神岐囲づ毘観メテクツ政73夕罪57需93誌飲査仁さ。 変レめ束球よんま会特ヱコ聞重だ史純ーどる件32浦レぴよゃ上強ネラリロ査従セユヤ専棋光レ作表ひぶ予正ぜーな誉確フス函6報円ス進治ね能営済否雄でわょ。42生型ば着続ア短実ぎおめび前環闘ラヤヲル診均っとにの声公トヱテマ整試椅情久妊舌頃ざとっく。品キチトテ阿国ラら受87世ヲフセリ川86個ーょぼげ危子ヘレカメ無会ぱかへ事通んかて電条ロツ徴商ぶぞそを居暑メ害広せもがり禁応レミヲ応響割壮憶はぱ。 千れンが織財メニ況界ネトレミ学豊フオホシ近月レたやご的罪ょな菱技ちる警栗エセ提89林危氷48参ア説森クキヒヱ薬社ホコエリ負和ルび紀下ケミイ掲歳特ごず扱底ク護木連ちクを各形ばすか。変ぱなれ町7融ヌ街準以タユヘム質裕ぶで遺語俊ぎずょ事金文キ写多山ーゆに歩帯すで会世クぜよ論写ヲ達71林危氷5間続ぎぜび高怠す。 係8青け応著ミ戦条ナヘネカ思79未ぎ算伊をゃ泉人ーづ需説っ畑鹿27軽ラソツ権2促千護ルロナカ開国ケ暴嶋ご池表だ。佐フナ訪麻はてせば勝効をあ医戦画とさわぴ者両すいあ並来んば載食ぴ件友頂業へえぞ魚祝ネラ聞率スコリケ始全ンこび夫出ドふ今布うぎふゅ実克即哉循やしんな。 暮す備54依紀てッん末刊と柔称むてス無府ケイ変壌をぱ汁連フマス海世ヌ中負知問ナヘケ純推ひ読着ヒ言若私軽れ。掲けフむ王本オコ線人をっさ必和断セソヲハ図芸ちかな防長りぶは投新意相ツ並5余セ職岳ぞ端古空援そ。森ヨエチ題5東っ自兄ち暴5近鹿横ト的京ハ安氷ナキ深際ぎ並節くスむの権工ほルせ京49効タムチ処三ぞぴラ済国ずっ文経ヘトミ水分準そが。'
    assert_equal(to_hex(md5_string(b)), "168f7f85febeb19dbad38502499ea1d0")
    _ = b
