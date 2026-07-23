extends Node

# English source text is used directly as the translation key (gettext-style) —
# every tr("...") call elsewhere passes the literal English string that's
# already sitting in NPC dialogue_lines/repeat_lines and UI code. Only a
# Chinese Translation is registered; when locale is "en" (the default) tr()
# calls simply fall through and return the original string unchanged, so no
# English Translation resource is needed.
const ZH_STRINGS := {
	# NPC_Baboon
	"The light changed.": "灯变了。",
	"I know.": "我知道。",
	"I'm just finishing my thought.": "我只是把这个念头想完。",
	"It's a long thought.": "这个念头有点长。",

	# NPC_Cat
	"Business has been slow.": "生意很清淡。",
	"It's the economy.": "都是经济不景气。",

	# NPC_Caveman
	"You're not supposed to be here.": "你不应该在这儿的。",
	"None of us are, really.": "其实我们谁都不应该在这儿。",
	"Still here?": "还在这儿呢？",

	# NPC_Crab
	"I was asleep.": "我当时睡着了。",
	"Something woke me up.": "有什么东西把我吵醒了。",
	"I don't know what.": "不知道是什么。",
	"It was quiet after that.": "之后就安静下来了。",
	"Very quiet.": "很安静。",

	# NPC_Deer
	"I keep coming back to this street.": "我总是不由自主地回到这条街。",
	"I don't know why.": "不知道为什么。",
	"Maybe I left something here.": "也许我把什么东西落在这儿了。",
	"I can't remember what.": "想不起来是什么了。",

	# NPC_Dog
	"I only have one.": "我只有一根。",
	"I have been deciding for forty minutes.": "我已经纠结了四十分钟。",
	"It's a big decision.": "这是个重大决定。",
	"It really is.": "确实是。",

	# NPC_FrenchBulldog
	"I've been staring at this machine for twenty minutes.": "我盯着这台机器看了二十分钟。",
	"Everything I want is sold out.": "我想要的全都卖光了。",
	"Everything I don't want is still here.": "我不想要的倒是都还在。",
	"Story of my life.": "我的人生就是这样。",

	# NPC_Giraffe
	"I got stuck here a while ago.": "我前阵子被卡在这儿了。",
	"The height didn't seem like a problem at the time.": "当时没觉得高度会是个问题。",
	"I've seen a lot of shoes.": "我看到过好多双鞋。",
	"Nice shoes, by the way.": "对了，你这双鞋不错。",

	# NPC_Goat
	"I am thinking.": "我在想事情。",
	"Still thinking.": "还在想。",

	# NPC_Goose
	"I'm on duty.": "我在值班。",
	"I was here that night too.": "那天晚上我也在这儿。",
	"I didn't see anything.": "我什么都没看见。",

	# NPC_GreatWhiteShark
	"I've been moving my whole life.": "我这辈子一直在游动。",
	"I stopped once.": "停过一次。",
	"It was fine.": "还不错。",

	# NPC_GreyAlien
	"I've been observing for years.": "我观察这里已经很多年了。",
	"I still don't understand the little one.": "我还是不明白那个小家伙。",
	"The Duck, I mean.": "我是说那只鸭子。",
	"Still observing.": "还在观察。",

	# NPC_KoiFish
	"I used to live in a pond.": "我以前住在池塘里。",
	"Someone moved me here.": "有人把我搬到这儿了。",
	"I don't remember who.": "不记得是谁了。",
	"The water is different here.": "这儿的水不太一样。",

	# NPC_Octopus
	"I sent a message that night.": "那天晚上我发了条消息。",
	"I'm still waiting.": "我还在等回复。",
	"Maybe the signal was bad.": "也许是信号不好。",

	# NPC_Penguin
	"It's not cold here.": "这儿其实不冷。",
	"I brought my own weather.": "我自带了天气。",
	"Nobody asked me to.": "也没人让我这么做。",
	"I like it better this way.": "我觉得这样更好。",

	# NPC_PrairieDog
	"I counted everyone on this street.": "我数过这条街上所有人。",
	"Twice.": "数了两遍。",
	"The number keeps changing.": "数字一直在变。",
	"I'm going to count again.": "我要再数一遍。",

	# NPC_Rat
	"I was supposed to put these up last Tuesday.": "这些东西我上周二就该贴出来了。",
	"It doesn't say anything.": "上面什么都没写。",
	"I forgot what it was supposed to say.": "我忘了本来要写什么了。",
	"Maybe it's better this way.": "也许这样更好。",

	# NPC_TRex
	"I can't reach the door.": "我够不到门。",
	"I've been trying for sixty-five million years.": "我已经试了六千五百万年了。",
	"Give or take.": "差不多吧。",
	"The door is right there.": "门就在那儿呢。",

	# NPC_Toucan
	"I won.": "我赢了。",
	"I always win.": "我一直都赢。",
	"The receipt says I lost, but the receipt is wrong.": "小票上写着我输了，但小票是错的。",
	"The receipt is wrong.": "小票是错的。",

	# Television
	"are you here": "你在吗",
	"present day.": "现今时代。",
	"present time.": "现在时刻。",
	"we are always broadcasting.": "我们一直在广播。",
	"you found all of me. every little piece.": "你找到了完整的我。每一个碎片。",
	"none of them added up to a whole person. that's alright.": "它们拼不成一个完整的人。没关系的。",
	"distance never really separated us.": "距离从来没有真正分开过我们。",

	# Yellow Duck collectibles
	"a little piece of you.": "你的一小片。",
	"some birds just draw themselves smaller than they are.": "有些鸟把自己画得比实际更小。",
	"you used to think grown-ups had it all figured out.": "你曾经以为大人们什么都想明白了。",
	"everyone crosses somewhere.": "每个人都会在某处穿行而过。",
	"not everyone arrives.": "但不是每个人都能抵达。",
	"you just wanted to disappear for a while.": "你只是想暂时消失一会儿。",
	"the last one.": "最后一片了。",
	"it's okay if it never adds up to a whole person.": "就算拼不成一个完整的人也没关系。",

	# Opening Quote (Psalm 102:6-7)
	"\"I am like a desert owl,\nlike an owl among the ruins.\nI lie awake; I have become\nlike a bird alone on a rooftop.\"\n\n-- Psalm 102:6-7":
		"「我如同荒漠的鸮鸟，\n又像废墟中的猫头鹰。\n我醒着，无法入睡；\n我像屋顶上一只孤单的麻雀。」\n\n——诗篇 102:6-7",

	# UI
	"Start": "开始",
	"Quit": "退出",
	"Paused": "已暂停",
	"Resume": "继续",
	"Main Menu": "主菜单",
	"Settings": "设置",
	"Volume": "音量",
	"Language": "语言",
	"Back": "返回",
	"All %d Yellow Ducks found.": "找到了全部 %d 只黄色小鸭。",
	"Yellow Duck found. %d / %d": "找到黄色小鸭。%d / %d",

	# Location names (SceneManager._parse_name output)
	"Convenience Store": "便利店",
	"Crossroads": "十字路口",
	"Under The Overpass": "高架桥下",
	"Arcade Alley": "街机小巷",
	"School Rooftop": "学校天台",
	"Backroom": "后室",

	# Ending credits
	"Producer / Programmer: FENG JIAQI (Jacky)\nMap & Art: LIM ZHI YUAN (Zee)":
		"制作人／程序：FENG JIAQI (Jacky)\n地图美术：LIM ZHI YUAN (Zee)",
}

const JA_STRINGS := {
	# NPC_Baboon
	"The light changed.": "信号が変わった。",
	"I know.": "分かってる。",
	"I'm just finishing my thought.": "今、考えをまとめてるところなんだ。",
	"It's a long thought.": "長い考えなんだよ。",

	# NPC_Cat
	"Business has been slow.": "商売が暇でね。",
	"It's the economy.": "景気のせいさ。",

	# NPC_Caveman
	"You're not supposed to be here.": "ここにいちゃいけないはずなんだが。",
	"None of us are, really.": "まあ、誰もいちゃいけないんだけどな。",
	"Still here?": "まだいたのか？",

	# NPC_Crab
	"I was asleep.": "眠っていたんだ。",
	"Something woke me up.": "何かに起こされた。",
	"I don't know what.": "何なのかは分からない。",
	"It was quiet after that.": "その後は静かだった。",
	"Very quiet.": "とても静かだった。",

	# NPC_Deer
	"I keep coming back to this street.": "何度もこの道に戻ってきてしまう。",
	"I don't know why.": "理由は分からない。",
	"Maybe I left something here.": "何か忘れ物をしたのかもしれない。",
	"I can't remember what.": "何だったかは思い出せない。",

	# NPC_Dog
	"I only have one.": "一本しか持ってない。",
	"I have been deciding for forty minutes.": "もう四十分も迷ってる。",
	"It's a big decision.": "大事な決断なんだ。",
	"It really is.": "本当にそうだね。",

	# NPC_FrenchBulldog
	"I've been staring at this machine for twenty minutes.": "この機械を二十分も見つめてる。",
	"Everything I want is sold out.": "欲しいものは全部売り切れだ。",
	"Everything I don't want is still here.": "欲しくないものは全部まだある。",
	"Story of my life.": "俺の人生そのものだよ。",

	# NPC_Giraffe
	"I got stuck here a while ago.": "少し前にここで動けなくなったんだ。",
	"The height didn't seem like a problem at the time.": "あの時は高さが問題になるとは思わなかった。",
	"I've seen a lot of shoes.": "たくさんの靴を見てきたよ。",
	"Nice shoes, by the way.": "ところで、その靴いいね。",

	# NPC_Goat
	"I am thinking.": "考え中なんだ。",
	"Still thinking.": "まだ考えてる。",

	# NPC_Goose
	"I'm on duty.": "任務中なんだ。",
	"I was here that night too.": "あの夜もここにいた。",
	"I didn't see anything.": "何も見てないよ。",

	# NPC_GreatWhiteShark
	"I've been moving my whole life.": "ずっと泳ぎ続けてきた人生だ。",
	"I stopped once.": "一度だけ止まったことがある。",
	"It was fine.": "悪くなかったよ。",

	# NPC_GreyAlien
	"I've been observing for years.": "何年も観察を続けている。",
	"I still don't understand the little one.": "あの小さいのがまだ理解できない。",
	"The Duck, I mean.": "あのアヒルのことだ。",
	"Still observing.": "まだ観察中だ。",

	# NPC_KoiFish
	"I used to live in a pond.": "昔は池に住んでいた。",
	"Someone moved me here.": "誰かがここに移したんだ。",
	"I don't remember who.": "誰だったかは覚えていない。",
	"The water is different here.": "ここの水は違う感じがする。",

	# NPC_Octopus
	"I sent a message that night.": "あの夜、メッセージを送ったんだ。",
	"I'm still waiting.": "まだ返事を待ってる。",
	"Maybe the signal was bad.": "電波が悪かったのかもしれない。",

	# NPC_Penguin
	"It's not cold here.": "ここは寒くないんだ。",
	"I brought my own weather.": "自分の天気を持ってきたから。",
	"Nobody asked me to.": "誰にも頼まれてないけどね。",
	"I like it better this way.": "この方が好きなんだ。",

	# NPC_PrairieDog
	"I counted everyone on this street.": "この通りの皆を数えたんだ。",
	"Twice.": "二回もね。",
	"The number keeps changing.": "数字がずっと変わり続けてる。",
	"I'm going to count again.": "もう一度数え直すよ。",

	# NPC_Rat
	"I was supposed to put these up last Tuesday.": "先週の火曜日に貼るはずだったんだ。",
	"It doesn't say anything.": "何も書かれてないんだよ。",
	"I forgot what it was supposed to say.": "何を書くはずだったか忘れてしまった。",
	"Maybe it's better this way.": "こっちの方がいいのかもしれない。",

	# NPC_TRex
	"I can't reach the door.": "ドアに手が届かないんだ。",
	"I've been trying for sixty-five million years.": "六千五百万年ずっと挑戦してる。",
	"Give or take.": "まあ、だいたいね。",
	"The door is right there.": "ドアはすぐそこなのに。",

	# NPC_Toucan
	"I won.": "勝ったよ。",
	"I always win.": "いつも勝ってるんだ。",
	"The receipt says I lost, but the receipt is wrong.": "レシートには負けたって書いてあるけど、レシートが間違ってる。",
	"The receipt is wrong.": "レシートが間違ってるんだ。",

	# Television
	"are you here": "そこにいるのか",
	"present day.": "現代。",
	"present time.": "現在時刻。",
	"we are always broadcasting.": "私たちはずっと放送し続けている。",
	"you found all of me. every little piece.": "君は私の全てを見つけた。小さな欠片の一つ一つまで。",
	"none of them added up to a whole person. that's alright.": "それらを集めても一人の人間にはならない。それでいいんだ。",
	"distance never really separated us.": "距離は本当の意味で私たちを引き離したことはない。",

	# Yellow Duck collectibles
	"a little piece of you.": "君のほんの小さな欠片。",
	"some birds just draw themselves smaller than they are.": "自分を実物より小さく描く鳥もいる。",
	"you used to think grown-ups had it all figured out.": "昔は大人たちが全部分かっているものだと思っていた。",
	"everyone crosses somewhere.": "誰もがどこかで道を渡る。",
	"not everyone arrives.": "でも、誰もがたどり着けるわけじゃない。",
	"you just wanted to disappear for a while.": "少しの間、消えてしまいたかっただけなんだ。",
	"the last one.": "これが最後の一つ。",
	"it's okay if it never adds up to a whole person.": "一人の人間にならなくても、それでいい。",

	# Opening Quote (Psalm 102:6-7)
	"\"I am like a desert owl,\nlike an owl among the ruins.\nI lie awake; I have become\nlike a bird alone on a rooftop.\"\n\n-- Psalm 102:6-7":
		"「わたしは荒野のふくろう、\n廃墟のみみずくのようになった。\n眠れずに目を覚まし、\n屋根の上でひとりぼっちの\n雀のようだ。」\n\n――詩篇 102:6-7",

	# UI
	"Start": "スタート",
	"Quit": "終了",
	"Paused": "一時停止",
	"Resume": "再開",
	"Main Menu": "メインメニュー",
	"Settings": "設定",
	"Volume": "音量",
	"Language": "言語",
	"Back": "戻る",
	"All %d Yellow Ducks found.": "%d羽の黄色いアヒルを全部見つけた。",
	"Yellow Duck found. %d / %d": "黄色いアヒルを見つけた。%d / %d",

	# Location names (SceneManager._parse_name output)
	"Convenience Store": "コンビニ",
	"Crossroads": "交差点",
	"Under The Overpass": "高架下",
	"Arcade Alley": "ゲームセンター横丁",
	"School Rooftop": "屋上",
	"Backroom": "裏部屋",

	# Ending credits
	"Producer / Programmer: FENG JIAQI (Jacky)\nMap & Art: LIM ZHI YUAN (Zee)":
		"プロデューサー／プログラマー：FENG JIAQI (Jacky)\nマップ＆アート：LIM ZHI YUAN (Zee)",
}

func _ready() -> void:
	var zh := Translation.new()
	zh.locale = "zh"
	for key: String in ZH_STRINGS:
		zh.add_message(key, ZH_STRINGS[key])
	TranslationServer.add_translation(zh)

	var ja := Translation.new()
	ja.locale = "ja"
	for key: String in JA_STRINGS:
		ja.add_message(key, JA_STRINGS[key])
	TranslationServer.add_translation(ja)
