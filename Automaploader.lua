--[[
2016/11/23 made by Politedog
2016/12/7  マップの入力を30個に制限
2016/12/7  マップの追加機能を追加
2016/12/7  サンプルのマップリストを利用可能に
--]]

--lua起動時の時間、マップを指定
	maps={}     --マップコードの集合
	time=100000 --マップの時間

	tfm.exec.setGameTime(time)
	tfm.exec.newGame("@4948659")

	tfm.exec.disableAutoTimeLeft(true)
	tfm.exec.disableAfkDeath(true)
	tfm.exec.disableAutoNewGame(true)
	tfm.exec.disableAutoScore(true)
	maploaded=false
	sw=false             --trueのときランダムにマップをロードする
	shamrot=false				--trueのときシャーマンは持ち回り
	i=1
	math.randomseed(os.time())

--最初のメッセージ
helpmsg=[[指定されたマップを自動で再生するるあです。

  F:時間設定 / G:adminを指定 / M:マップリスト入力
  O:スキップ / R:マップのリロード / U:プレイ中のラウンド時間を20秒に設定
  !help:ヘルプ（この画面）を表示
  !random on/off:マップをランダム/順番再生に切り替え
  !skill on/off:スキルの有効・非有効を切り替える
  !rot on/of:onでシャーマンは持ち回り offでadminに固定
  !map @xxxxxx:マップ@xxxxxxを再生
  !time xxx:現在のラウンドの時間をxxxに設定]]
	ui.addPopup(0,0,helpmsg,nil,200,140,400,false)


function eventNewPlayer(name)
	--入室したときにメッセージを表示
	ui.addPopup(2,0,helpmsg,name,200,140,400,false)

	--入室者もキーバインド
  tfm.exec.bindKeyboard(name, 70, true, true)
  tfm.exec.bindKeyboard(name, 71, true, true)
  tfm.exec.bindKeyboard(name, 77, true, true)
  tfm.exec.bindKeyboard(name, 79, true, true)
  tfm.exec.bindKeyboard(name, 82, true, true)
  tfm.exec.bindKeyboard(name, 85, true, true)
end


--シャーマンがゴールしたときに時間を4秒に設定
function eventPlayerWon(name)
	if tfm.get.room.playerList[name]["isShaman"] then
		tfm.exec.setGameTime(4)
	end
end


--[[
Fを押すと時間を決めるポップアップを表示
Gを押すとadminを変更
Mを押すとマップを決めるポップアップ表示
Oを押すと次のラウンドに
Rを押すとプレイ中のマップをリロード
Uを押すとプレイ中のラウンド時間を20秒にする
--]]

--キーの関連付けを行う
for name,player in pairs(tfm.get.room.playerList) do
  tfm.exec.bindKeyboard(name, 70, true, true)
  tfm.exec.bindKeyboard(name, 71, true, true)
  tfm.exec.bindKeyboard(name, 77, true, true)
  tfm.exec.bindKeyboard(name, 79, true, true)
  tfm.exec.bindKeyboard(name, 82, true, true)
  tfm.exec.bindKeyboard(name, 85, true, true)
end


--関連付けられたキーを押したときの反応を設定
function eventKeyboard(name, key, down, x, y)
  if key==70 and name==admin then
    ui.addPopup(101,2,"時間を設定して下さい",name,330,160,140,false)

  elseif key==71 and name==admin then
    ui.addPopup(201,2,"adminを設定して下さい",name,330,160,140,false)

  elseif key==77 and (not(maploaded) or name==admin) then
    inimsg="マップコードのリストを入力して下さい\n例:@123456@234567@345678"
    ui.addPopup(301,2,inimsg,name,200,160,400,false)

  elseif key==79 and maploaded and (name==admin or tfm.get.room.playerList[name]["isShaman"]) then
 		if not(sw) then
  		tfm.exec.newGame(maps[i])
    	if i<#maps then
      	i=i+1
    	elseif i>=#maps then
     		i=1
     	end
 	 	elseif sw then
    	tfm.exec.newGame(maps[math.random(1,#maps)])
  	end

	elseif key==82 and name==admin then
		tfm.exec.newGame(tfm.get.room["currentMap"])

	elseif key==85 and (name==admin or tfm.get.room.playerList[name]["isShaman"]) then
		tfm.exec.setGameTime(20)
  end
end


--ポップアップへの値入力への対応
function eventPopupAnswer(id,name,ans)
	--Mキーによるマップリストの入力
  if id==301 and ans~="" and (not(maploaded) or name==admin) then

	--takeoverと入力するとマップリストを引き継ぐ
		if string.lower(ans)=="takeover" then
			maploaded = true
			admin = name
			tfm.exec.setNameColor(name,0xFFA500)
			if not(shamrot) then
				for namae,player in pairs(tfm.get.room.playerList) do
					if namae==admin then
						tfm.exec.setPlayerScore(namae,17,false)
					else
						tfm.exec.setPlayerScore(namae,0,false)
					end
				end
			end

    	i=1
    	tfm.exec.setGameTime(4)

		--sampleと入力するとサンプルのマップリストをロード
		elseif string.lower(ans)=="sample" then

			while #maps~=0 do
				table.remove(maps)
			end

			for i=1,#sample do
				maps[i] = sample[i]
			end

			maploaded = true
			admin = name
			tfm.exec.setNameColor(name,0xFFA500)
			if not(shamrot) then
				for namae,player in pairs(tfm.get.room.playerList) do
					if namae==admin then
						tfm.exec.setPlayerScore(namae,17,false)
					else
						tfm.exec.setPlayerScore(namae,0,false)
					end
				end
			end

    	i=1
    	tfm.exec.setGameTime(4)

		else

			--入力されたマップが30個を超える場合にエラー出力
			p,num = ans:gsub("%s*".."@".."%s*", "")
			if num>30 then
				ui.addPopup(2,0,"入力できるマップの数は30個までです",name,200,140,400,false)
			else

				--addを先頭に付加した場合はマップの追加
				tmp = split(ans,"@")
				if tmp[1]=="add" and maploaded then
					table.remove(tmp,1)
					for i=1,#tmp do
						maps[#maps+1]=tmp[i]
					end

				--addを付加しない場合はマップリストの置き換え
				else
	   			maps = split(ans,"@")     --入力されたマップコードを分割してmapsに代入
					table.remove(maps,1)      --@1@2@3をsplitしたものは{"","1","2","3"}なので最初の要素を削除
					maploaded = true
		  		admin=name
					tfm.exec.setNameColor(name,0xFFA500)

					if not(shamrot) then
						for namae,player in pairs(tfm.get.room.playerList) do
							if namae==admin then
								tfm.exec.setPlayerScore(namae,17,false)
							else
								tfm.exec.setPlayerScore(namae,0,false)
							end
						end
					end
		  		i=1
 					tfm.exec.setGameTime(4)
				end
			end
		end

	--Fキーによる時間の設定
  elseif id==101 and ans~="" and name==admin and type(tonumber(ans))=="number" then
    time=tonumber(ans)

	--Gキーによるadminの設定
  elseif id==201 and name==admin then
    for namae,player in pairs(tfm.get.room.playerList) do
      if namae==convname(ans) then
        admin=convname(ans)
				tfm.exec.setNameColor(admin,0xFFA500)
				tfm.exec.setNameColor(name,0x000000)
      end
    end

		if not(shamrot) then
			for namae,player in pairs(tfm.get.room.playerList) do
				if namae==admin then
					tfm.exec.setPlayerScore(namae,17,false)
				else
					tfm.exec.setPlayerScore(namae,0,false)
				end
			end
		end
  end
end


--時間が0になったときmapsに含まれるマップをnewGame
function eventLoop(time,remain)
 if remain<=600 then
  if not(sw) then
    tfm.exec.newGame(maps[i])
     if i<#maps then
       i=i+1
     elseif i>=#maps then
       i=1
     end
  elseif sw then
    tfm.exec.newGame(maps[math.random(1,#maps)])
  end
 end
end


--newGameしたときの時間とスコアを設定
function eventNewGame()
  tfm.exec.setGameTime(time)

	if not(shamrot) then
		for name,player in pairs(tfm.get.room.playerList) do
			if name==admin then
				tfm.exec.setPlayerScore(name,17,false)
			else
				tfm.exec.setPlayerScore(name,0,false)
			end
		end
	end

	if maploaded then
		tfm.exec.setNameColor(admin,0xFFA500)
	end
end


--adminがいなくなったときに初期状態に戻す
function eventPlayerLeft(name)
  if name==admin then
    tfm.exec.setGameTime(100000)
    tfm.exec.newGame("@4948659")
    tfm.exec.disableAutoTimeLeft(true)
    tfm.exec.disableAfkDeath(true)
    tfm.exec.disableAutoNewGame(true)
    maploaded = false
    sw=false
		shamrot=false
		i=1
  end
end


--コマンド入力時の対応を設定
function eventChatCommand(name,msg)
	local exact=false

	msg=string.lower(msg)
	cmd=split(msg," ")

	if #cmd==1 then
		--ヘルプの表示
		if cmd[1]=="help" then
			ui.addPopup(1,0,helpmsg,name,200,140,400,false)
			exact=true
		end

		--現在のadminの表示
		if cmd[1]=="nowadmin" then
			ui.addPopup(4,0,"現在のadminは "..admin.." です",name,200,140,400,false)
			exact=true
		end

		--死んでいた場合復活する
		if cmd[1]=="r" then
			tfm.exec.respawnPlayer(name)
			exact=true
		end
	end

	if #cmd==2 then
		--ランダム再生の切り替え
		if cmd[1]=="random" and cmd[2]=="on" and name==admin then
			sw=true
			exact=true
		elseif cmd[1]=="random" and cmd[2]=="off" and name==admin then
			sw=false
			exact=true
		end

		--スキルの有効非有効切り替え
		if cmd[1]=="skill" and cmd[2]=="on" and name==admin then
			tfm.exec.disableAllShamanSkills(false)
			exact=true
		elseif cmd[1]=="skill" and cmd[2]=="off" and name==admin then
			tfm.exec.disableAllShamanSkills(true)
			exact=true
		end

		--マップの読み込み
		if cmd[1]=="map" and type(tonumber(string.sub(cmd[2],2)))=="number" and name==admin then
			tfm.exec.newGame(string.sub(cmd[2],2))
			exact=true
		end

		--プレイ中のラウンドの時間設定
		if cmd[1]=="time" and type(tonumber(cmd[2]))=="number" and (name==admin or tfm.get.room.playerList[name]["isShaman"]) then
			tfm.exec.setGameTime(tonumber(cmd[2]))
			exact=true
		end

		--シャーマンの持ち回り
		if cmd[1]=="rot" and cmd[2]=="on" and name==admin then
			shamrot=true
			tfm.exec.disableAutoScore(false)
			exact=true
		elseif cmd[1]=="rot" and cmd[2]=="off" and name==admin then
			shamrot=false
			tfm.exec.disableAutoScore(true)
			exact=true
			for namae,player in pairs(tfm.get.room.playerList) do
				if namae==admin then
					tfm.exec.setPlayerScore(namae,17,false)
				else
					tfm.exec.setPlayerScore(namae,0,false)
				end
			end
		end
	end

	if not(exact) then
		ui.addPopup(3,0,"このチャットコマンドは無効かadminの人のみ有効です",name,250,160,300,false)
	end
end


--チャットコマンドの非表示
system.disableChatCommandDisplay("help",true)
system.disableChatCommandDisplay("nowadmin",true)
system.disableChatCommandDisplay("random",true)
system.disableChatCommandDisplay("skill",true)
system.disableChatCommandDisplay("rot",true)
system.disableChatCommandDisplay("map",true)
system.disableChatCommandDisplay("time",true)
system.disableChatCommandDisplay("r",true)

-------------------------------------------------------------------------------
--[[
文字列分割
例:split("aaa,bbb,ccc",",")->{"aaa","bbb","ccc"}
--]]
function split(str, del)
  p, nrep = str:gsub("%s*"..del.."%s*", "")
  return { str:match((("%s*(.-)%s*"..del.."%s*"):rep(nrep).."(.*)")) }
end

--[[
名前を正確な表示に変換
例:abCdEf->Abcdef
--]]
function convname(name)
	return string.upper(string.sub(name,1,1))..string.lower(string.sub(name,2))
end

sample={
182896,204475,237240,310702,323327,366109,385110,401137,401476,411351,421718,
421775,438596,448034,476141,477415,479608,508150,510717,511480,511482,516967,
527710,549785,557888,559622,574800,578002,581679,583934,623676,647186,690330,
696654,723675,743083,748088,760201,763690,776830,778057,783125,796976,808026,
827520,861961,868945,921628,947283,948398,963245,967780,1004996,1050116,1073256,
1087982,1092673,1105814,1130890,1134602,1143491,1149658,1150553,1156254,1182072,
1209559,1216684,1216943,1229462,1269049,1271929,1272788,1289915,1299281,1300215,
1301071,1304826,1326777,1326880,1333162,1333807,1334046,1336108,1343032,1347844,
1348694,1359541,1359698,1376596,1386266,1388745,1389410,1393387,1396171,1396179,
1398085,1411237,1413765,1419391,1420237,1422135,1422667,1423534,1428997,1429266,
1430267,1442623,1444830,1450698,1456878,1460928,1465629,1471211,1476823,1483437,
1487350,1491067,1494555,1495782,1502262,1502781,1503472,1503617,1504094,1506084,
1507970,1510042,1515500,1523085,1525227,1529282,1527376,1529262,1530317,1536780,
1539530,1542179,1542547,1554169,1554549,1555259,1557790,1557881,1558031,1559425,
1565418,1565992,1574676,1576764,1578428,1578951,1581202,1582420,1586008,1586272,
1588878,1589616,1592421,1599706,1601257,1610945,1623388,1624462,1626989,1627350,
1632797,1635599,1635638,1636725,1638600,1651979,1653663,1659600,1659815,1662903,
1670221,1671013,1671288,1674470,1678386,1681512,1683566,1693317,1715789,1716413,
1728386,1729255,1739737,1740280,1747814,1749585,1750581,1752690,1753788,1757668,
1761342,1763970,1767777,1770646,1771344,1772966,1776615,1778930,1780763,1785819,
1789245,1793876,1797025,1798640,1800727,1801370,1802453,1804898,1805168,1807169,
1812996,1826386,1830158,1833060,1833086,1837398,1839857,1850748,1852823,1856323,
1857783,1859557,1862054,1862784,1866768,1866893,1874963,1877451,1877464,1891384,
1891565,1892379,1897182,1903851,1914997,1918221,1921720,1924349,1928592,1928599,
1929601,1929909,1930007,1934347,1934778,1937289,1939527,1948490,1953670,1957362,
1960760,1975038,1975278,1975363,1977030,1979070,1981715,1981791,1982204,1982511,
1984121,1985475,1986358,1988097,1989190,1997537,1998444,1998517,1999016,2003571,
2007733,2008117,2010596,2012547,2014113,2016269,2018692,2019755,2022864,2024751,
2030798,2032876,2039283,2040226,2041020,2041115,2047122,2048692,2048809,2051203,
2054791,2055156,2062724,2062750,2064832,2073533,2074500,2074982,2079302,2082296,
2083506,2084794,2086282,2086745,2087140,2090203,2091254,2093350,2098490,2102063,
2103304,2106937,2107666,2108543,2109497,2115480,2118561,2120177,2129724,2129977,
2130185,2135561,2135779,2136058,2140319,2142013,2151708,2151832,2161166,2164853,
2164967,2167246,2169324,2173037,2173855,2177632,2179518,2183135,2183687,2184303,
2184528,2188235,2191377,2195415,2196877,2199738,2207182,2207438,2207527,2207591,
2215095,2230462,2236268,2236661,2277993,2287800,2307143,2315626,2328523,2345240,
2366877,2369038,2385317,2392528,2409960,2412791,2429625,2430807,2433899,2439540,
2441919,2443938,2450363,2454106,2458837,2459597,2461322,2463256,2463762,2475157,
2471745,2478516,2481060,2490310,2494794,2498216,2504575,2506768,2515693,2528249,
2531772,2545842,2551172,2556412,2566283,2570444,2579052,2581289,2587777,2593739,
2597751,2600101,2610016,2611641,2612485,2612987,2615977,2617940,2622787,2636869,
2651322,2658749,2676732,2685423,2686029,2691559,2700077,2707779,2709853,2710443,
2712251,2712978,2713052,2715086,2715276,2732043,2747871,2757300,2763029,2765732,
2766459,2769585,2777511,2784031,2796324,2798311,2799530,2804640,2809503,2815493,
2816408,2817862,2832926,2834296,2837169,2853151,2865489,2877982,2878706,2900645,
2905961,2915857,2924910,2925988,2939112,2941996,2943685,2947587,2955146,2963237,
2965012,2967511,2971170,2976522,2984565,2990089,2991606,2992707,3003420,3003803,
3007216,3007253,3009352,3010571,3011863,3034330,3038757,3040125,3066197,3066941,
3070391,3074411,3079636,3088028,3102266,3105582,3125267,3135612,3139627,3143857,
3148225,3167759,3202756,3231065,3233204,3233351,3236003,3238661,3247277,3249331,
3250130,3256509,3259279,3283275,3285687,3320970,3321923,3333221,3336353,3351019,
3357647,3379896,3394251,3416295,3428667,3430867,3439492,3448476,3457077,3459289,
3459372,3462515,3465644,3474498,3476765,3477132,3477414,3494965,3513794,3515351,
3522864,3524843,3526378,3529745,3531801,3543989,3557467,3561559,3576562,3586019,
3587057,3588982,3590143,3590367,3590468,3614164,3615244,3617740,3619275,3626721,
3635156,3643600,3644018,3655254,3656630,3661416,3664497,3667443,3671759,3678015,
3681317,3686429,3687060,3696112,3696190,3699061,3700592,3703372,3719719,3742591,
3748497,3753791,3759691,3760738,3773335,3775788,3776347,3777508,3777866,3780857,
3784796,3799660,3801204,3814880,3824521,3828016,3833067,3860782,3862389,3868540,
3894338,3909612,3917927,3919670,3938611,3944076,3996013,4051197,4056626,4132617,
4133152,4173433,4198913,4231080,4239532,4276657,4290970,4292420,4299790,4299999,
4434303,4453811,4457285,4509050,4535793,4545208,4547800,4607919,4625420,4658392,
4679741,4697945,4806524,4833719,4881506,4902795,4947027,4979418,5002429,5030384,
5030728,5047949,5049504,5056575,5061227,5185061,5088589,5096821,5173609,5179857,
5180237,5180404,5186430,5189652,5202179,5205058,5228127,5391079,5403032,5511030,
5513487,5591826,5641135,5716404,5716423,5799959,5806780,5920530,5921940,6051084,
6058383,6076769,6446167,6635677,6657029,6701750}
