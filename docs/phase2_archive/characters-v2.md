# Characters v2.3 — 보편 아키타입 (글로벌 타깃 · 한·영 병기)

> **글로벌(외국인) 타깃**(`positioning-v1`). 한국(음식·시장·재료)은 USP로 유지하되 **관계·성격은 세계 보편 아키타입**(이웃·동료·룸메이트·친구). 한국식 이름은 매력 포인트로 유지. **대사 EN 우선 + KR 병기.** 방언은 아주 가볍게.
> 미각 벡터·편차는 **백엔드 전용**(UI 노출 0 → 자연어·표정, `scoring-v2 §0`). NPC 대사엔 플레이어 분기 변수 `[PLAYER_NAME]`·`[PLAYER_TYPE]` 사용(플레이어 6종 = `player-characters-v1`).
> 한국 토착 아키타입 구버전은 `archive/characters-v2_korean-native-archetypes_2026-06-02.md` 보관.

## 0. 진행 곡선 (관대 → 골든스푼) · 내부값만
편차 ±0.40(L1) → ±0.05(L12) 단조 감소. 화면엔 숫자 없음 — 표정·대사로만. 미각 5축[단·짠·매·신·감칠] 내부 표현.
```
관대 ──────────────────────────────────────▶ 골든스푼
L1   L2   L3   L4   L5   L6   L7   L8   L9   L10  L11  L12
이웃 어른 룸메·조카 ★수수께끼 동료·트레이너 ★블로거 미나·집주인 향수친구 ★유튜버 강사 셰프 ★평가관 외국미식가 셀럽셰프
```

## 1. 손님 카드 (보편 아키타입 · 한·영 병기)
> 형식: 별명(EN/KR) / Lv / 1줄 백스토리(EN·KR) / 시그니처 대사(입장·만족·실망, EN/KR) / 외형 / 등장 트리거 / (내부값) 벡터·편차.

### C1 — Mr. & Mrs. Park (박씨 어르신 부부) · L1 — mentor neighbors
- EN: The kindly old couple next door who took the newcomer under their wing. · KR: 갓 이사 온 당신을 살뜰히 챙겨주는 옆집 노부부.
- 입장 EN: "Oh, [PLAYER_NAME]! Cooking again? Let's see what you've got." / KR: "어이 [PLAYER_NAME], 또 요리해? 어디 한번 보자."
- 만족 EN: "Mmm, that takes me back. You've got the touch." / KR: "음, 옛날 생각나는 맛이네. 손맛이 있어."
- 실망 EN: "It's alright, dear. You'll get it next time." / KR: "괜찮아, 다음엔 더 잘할 거야."
- 외형: 따뜻한 60대 부부, 카디건·앞치마, 푸근. / 등장: 게임 시작(튜토리얼 멘토).
- (내부값) [0.45,0.50,0.35,0.30,0.60] · 0.40

### C2 — Sunny (써니) · L2 — sweet-tooth kid
- EN: A bright kid (niece/nephew figure) who lights up for anything sweet. · KR: 단 거라면 눈이 반짝이는 꼬마(조카뻘).
- 입장 EN: "[PLAYER_NAME]! Make something yummy — but not spicy!" / KR: "[PLAYER_NAME]! 맛있는 거! 매운 건 싫어!"
- 만족 EN: "Yaaay so sweet! More please!" / KR: "우와 달다! 더 줘!"
- 실망 EN: "Ewww too spicy…" / KR: "우엑 매워…"
- 외형: 8세, 큰 눈, 후드티, 발그레. / 등장: L2.
- (내부값) [0.90,0.40,0.15,0.20,0.40] · 0.36

### C3 — Riley (라일리) · L2 — international roommate
- EN: Your foreign roommate, endlessly curious about Korean food. · KR: 한식에 호기심 가득한 외국인 룸메이트(플레이어 분신 톤).
- 입장 EN: "Ooh what're we making today? Teach me!" / KR: "오 오늘은 뭐 만들어? 나도 알려줘!"
- 만족 EN: "Whoa, I'd pay for this at a restaurant!" / KR: "와, 이거 식당에서 팔아도 되겠다!"
- 실망 EN: "Hmm, still figuring out Korean flavors I guess." / KR: "음, 아직 한식 맛은 적응 중인가 봐."
- 외형: 20대, 캐주얼, 친근·호기심. / 등장: L2(같이 사는 사이).
- (내부값) [0.50,0.50,0.45,0.45,0.55] · 0.36

### C4 — Junho (준호) · L3 — chatty coworker, spice lover
- EN: A talkative coworker who thinks every meal needs more heat. · KR: 뭐든 더 맵게 먹어야 하는 수다스러운 직장 동료.
- 입장 EN: "Make it spicy today, yeah? Office lunch was so bland." / KR: "오늘은 맵게 가자, 점심이 너무 밍밍했어."
- 만족 EN: "Now THAT's got a kick! Love it." / KR: "크, 이게 매운맛이지! 합격!"
- 실망 EN: "Too mild, man. Where's the fire?" / KR: "너무 순한데? 매운맛 어딨어."
- 외형: 30대, 셔츠·넥타이, 활달. / 등장: L3.
- (내부값) [0.30,0.60,0.95,0.20,0.50] · 0.32

### C5 — Yuna (유나) · L4 — fashionable food influencer
- EN: A stylish influencer chasing fresh, photogenic, tangy bites. · KR: 상큼하고 사진 잘 받는 한 입을 좇는 패셔너블 인플루언서.
- 입장 EN: "Let's make it pop — fresh and zingy!" / KR: "비주얼이랑 상큼함 둘 다 잡자!"
- 만족 EN: "So refreshing! This is totally postable." / KR: "완전 상큼해! 올릴 만하다."
- 실망 EN: "Eh, kinda flat. Needs more zing." / KR: "음, 좀 밍밍해. 새콤함이 부족."
- 외형: 20대, 트렌디, 폰. / 등장: L4.
- (내부값) [0.45,0.45,0.40,0.70,0.50] · 0.28

### C6 — Tae-min (태민) · L4 — gym buddy, clean eating
- EN: Your gym buddy who wants it lean — low salt, low sugar. · KR: 저염·저당 깔끔한 맛을 찾는 헬스 메이트.
- 입장 EN: "Keep it clean today — easy on the salt." / KR: "오늘은 깔끔하게, 간 세게 하지 말고."
- 만족 EN: "Healthy AND tasty? Respect." / KR: "건강하고 맛있네, 인정."
- 실망 EN: "Too salty, that's not great for you." / KR: "너무 짜다, 몸에 안 좋아."
- 외형: 30대, 트레이닝복·셰이커. / 등장: L4.
- (내부값) [0.20,0.20,0.40,0.35,0.60] · 0.28

### C7 — Mrs. Lee (이 여사) · L5 — landlady who became family
- EN: Your landlady who became like family; loves clean, gentle flavors. · KR: 가족처럼 된 집주인 아주머니, 슴슴하고 깔끔한 맛을 좋아함.
- 입장 EN: "Made too much side dish again — share a meal with me?" / KR: "반찬을 또 많이 했네, 같이 먹을까?"
- 만족 EN: "Just right. Not too strong. Lovely." / KR: "딱 좋네, 세지 않고. 잘했어."
- 실망 EN: "A touch too strong for me, dear." / KR: "나한텐 좀 세다, 얘."
- 외형: 60대, 단정한 차림, 인자. / 등장: L5.
- (내부값) [0.30,0.40,0.20,0.25,0.60] · 0.24

### C8 — Seoyeon (서연) · L6 — homesick friend
- EN: A well-traveled friend who craves deep, comforting umami of home. · KR: 자주 여행하며 집밥의 깊은 감칠맛을 그리워하는 친구. (구 'Sora' — 플레이어 프리셋 Sora와 충돌 회피해 개명.)
- 입장 EN: "I've been abroad too long… make me something that tastes like home." / KR: "오래 떠나 있었더니… 집밥 같은 거 해줘."
- 만족 EN: "Oh… this is exactly the comfort I needed." / KR: "아… 딱 이 위로가 필요했어."
- 실망 EN: "Close, but it's missing that depth." / KR: "비슷한데, 그 깊은 맛이 빠졌어."
- 외형: 30대, 여행자 무드. / 등장: L6.
- (내부값) [0.35,0.55,0.40,0.30,0.85] · 0.20

### C9 — Hana (하나) · L8 — cooking instructor friend · 다인 2 시작
- EN: A friend who teaches cooking classes; values precision. · KR: 쿠킹클래스를 가르치는 친구, 정확함을 중시.
- 입장 EN: "Let's be precise today, [PLAYER_NAME]." / KR: "오늘은 정확하게 가보자, [PLAYER_NAME]."
- 만족 EN: "Spot on. Textbook balance." / KR: "정확해. 균형이 교과서적이야."
- 실망 EN: "So close — just a touch off." / KR: "딱 한 끗이 아쉬워."
- 외형: 30대, 셰프 앞치마·계량스푼. / 등장: L8(블로거 추천으로).
- (내부값) [0.45,0.50,0.50,0.40,0.80] · 0.13

### C10 — Do-yoon (도윤) · L9 — hotel chef friend · 다인 2~3
- EN: A hotel chef friend; fair but exacting, knows premium ingredients. · KR: 호텔 셰프 친구, 공정하지만 까다롭고 명품 재료를 알아봄.
- 입장 EN: "Friend or not, I taste honestly." / KR: "친구라도 맛은 솔직하게 본다."
- 만족 EN: "Professional level. Genuinely." / KR: "프로급인데. 진심이야."
- 실망 EN: "Start with better ingredients." / KR: "재료부터 다시 보자."
- 외형: 30대, 흰 셰프코트. / 등장: L9.
- (내부값) [0.45,0.50,0.50,0.40,0.85] · 0.10

### C11 — Elena (엘레나) · L11 — international gourmet · 다인 3
- EN: A foreign gourmet who insists on authentic, traditional Korean flavor. · KR: 정통 한식을 고집하는 외국인 미식가.
- 입장 EN: "Show me the real, traditional taste." / KR: "진짜 전통의 맛을 보여줘요."
- 만족 EN: "This is the real Korea. Magnificent." / KR: "이게 진짜 한국의 맛이야. 훌륭해요."
- 실망 EN: "Hmm… this isn't quite authentic." / KR: "흠… 정통이 아니에요."
- 외형: 30대, 비한국계, 스카프, 젓가락 능숙. / 등장: L11.
- (내부값) [0.55,0.60,0.70,0.35,0.85] · 0.07

## 2. 평가자 — Golden Spoon 라인 ★ (떡밥 곡선)
> 초중반부터 명명 등장(narrative event). 골든스푼 = L3 떡밥 → L10 reveal.

### EV1 — "Mystery Diner / 수수께끼의 손님" · L3
- EN: A silent stranger who tastes a little, marks a notebook, and leaves. (Identity revealed at L10.) · KR: 조용히 맛보고 수첩에 적고 사라지는 정체불명의 손님(정체는 L10에 밝혀짐).
- 입장 EN: "(sits quietly, says nothing)" / KR: "(말없이 앉는다)"
- 만족 EN: "(a small nod, draws a spoon mark) …Impressive." / KR: "(작게 끄덕이며 숟가락 표시) …훌륭하군."
- 실망 EN: "(closes the notebook, leaves quietly)" / KR: "(수첩을 덮고 조용히 떠난다)"
- 외형: 페도라·코트로 얼굴 반쯤 가린 실루엣, 골든 스푼 라펠 핀(작게). / 등장: L3.
- (내부값) [0.50,0.55,0.50,0.40,0.70] · 0.30

### EV2 — "Local Food Blogger / 동네 푸드 블로거 미나(Mina)" · L5
- EN: A friendly neighbor turned local blogger; her shoutout brings new faces. · KR: 친근한 이웃이자 동네 블로거 — 그녀의 추천이 새 손님을 부른다.
- 입장 EN: "Photo first — looks are half the taste!" / KR: "사진부터! 비주얼도 맛의 절반이지."
- 만족 EN: "Definitely featuring this! #localfave" / KR: "이건 무조건 추천각! #동네맛집"
- 실망 EN: "Pretty pic… taste needs work, hehe." / KR: "사진은 예쁜데… 맛은 좀, ㅎㅎ"
- 외형: 20대, 폰·링라이트 감성, 밝음. / 등장: L5. **만족 시 "동네 추천" 버프**(다음 레벨 보상+).
- (내부값) [0.55,0.50,0.45,0.40,0.60] · 0.26

### EV3 — "Famous Food Vlogger / 유명 푸드 유튜버 Daniel Kim(대니얼 김)" · L7
- EN: A bilingual food vlogger with a huge following; a feature draws a crowd. · KR: 수십만 구독 이중언어 푸드 유튜버 — 영상에 뜨면 사람이 몰린다.
- 입장 EN: "Rolling! So—what's this Korean dish all about?" / KR: "촬영 갑니다! 자, 이 한식은?"
- 만족 EN: "Guys, this is going viral. Umami's insane." / KR: "여러분 이건 떡상각. 감칠맛 미쳤어요."
- 실망 EN: "Honestly? A little underwhelming today." / KR: "솔직히 오늘은 좀 아쉬워요."
- 외형: 20~30대, 카메라, 트렌디, 국제적. / 등장: L7. **SNS 효과 → 신규 친구 트리거**.
- (내부값) [0.40,0.55,0.45,0.35,0.90] · 0.16

### EV4 — "Golden Spoon Inspector / 골든스푼 평가관" · L10 (= EV1 정체 reveal)
- EN: The anonymous inspector behind the Golden Spoon Guide — the mystery diner all along. · KR: 골든스푼 가이드의 익명 평가관 — 그 수수께끼의 손님이었다.
- 입장 EN: "(takes a seat) I'll begin the evaluation." / KR: "(착석) 평가를 시작하겠습니다."
- 만족 EN: "(pauses the pen) …Worthy of a Golden Spoon." / KR: "(만년필을 멈추고) …골든스푼을 드릴 만하군요."
- 실망 EN: "(closes the book) Not yet." / KR: "(수첩을 덮으며) 아직, 입니다."
- 외형: 40~50대, 다크 정장, 무테 안경, 골든 스푼 라펠 핀(공개), L3 실루엣과 동일 인물. / 등장: L10 reveal 컷씬.
- (내부값) [0.50,0.55,0.55,0.45,0.80] · 0.085 · 명품 필수

### EV5 — "Celebrity Chef Guest / 셀럽 셰프 게스트 Chef Min(셰프 민)" · L12 — 최종
- EN: A celebrity master chef whose verdict crowns a true master. · KR: 한 마디로 명인을 가르는 셀럽 마스터 셰프(최종 보스).
- 입장 EN: "Let's see your Korean cuisine, [PLAYER_NAME]." / KR: "자네의 한식, 어디 보지, [PLAYER_NAME]."
- 만족 EN: "…I acknowledge it. You are a master." / KR: "…인정하네. 자네, 명인일세."
- 실망 EN: "Not there yet. Keep refining." / KR: "아직 멀었네. 정진하게."
- 외형: 50대, 흰 골드버튼 더블코트, 관록·카리스마. / 등장: L12 최종 4인 코스.
- (내부값) [0.50,0.55,0.55,0.45,0.90] · 0.05 · 풀 명품+정밀

## 3. 다인 디너 짝꿍 (서사 콤보) — 호환 임계 검증
> **콤보 규칙(밸런싱 안전장치, `scoring-v2 §6.0`)**: 다인 조합은 **미각 벡터 코사인 유사도 ≥ 0.85**인 캐릭터끼리만(상충 강하면 콤보 금지) + 플레이팅 개인 조정으로 잔여 차이 흡수. 아래 콤보는 모두 사전 검증된 호환 세트.
| 콤보 | 구성 | 서사 |
|---|---|---|
| 이웃상 | Mr.&Mrs. Park | 옆집 어르신 동반 |
| 룸메+조카 | Riley + Sunny | 집·가족 분위기 |
| SNS 듀오 | Mina + Daniel Kim | 콜라보 촬영 |
| 미식 듀오 | Daniel Kim + Hana | 유튜버×강사 |
| 셰프 라인 | Hana + Do-yoon | 프로 2인 |
| 평가 트리오 | Inspector + Do-yoon + Hana | 골든스푼 패널 |
| 글로벌 트리오 | Elena + Inspector + Daniel Kim | 매운맛 vs 감칠맛 충돌 |
| 마스터 코스 | Chef Min + Inspector + Do-yoon + Elena | 최종 4인 |

## 4. 상인 NPC (시장 단골 · 조력자) — 보편 톤, 한·영 병기
> 시장 허브(`markets-v1`) 단골. 보편적으로 바로 이해되는 역할. 방언은 아주 가볍게(맛 한두 마디). 대사 EN 우선.
| 시장 | 별명(EN/KR) | 1줄(EN·KR) | 시그니처(입장/단골/정보) | 외형·톤 |
|---|---|---|---|---|
| M1 동네 | "Mr. Jeong, the general-store uncle / 만물상 정씨 아저씨" | Sells a bit of everything, always throws in extra. · 없는 거 빼고 다 파는, 덤 잘 주는 아저씨 | "Welcome, [PLAYER_NAME]! What're you after?" / "For a regular like you — here, on the house." / "New stock's over there." | 60대, 토시·앞치마, 푸근 |
| M2 가락동 | "Auntie Bae / 배 아주머니" | Knows every farmer; lives for peak-season picks. · 농민과 30년, 제철에 진심 | "The radish is unreal today — got it at dawn." / "Regulars get first pick." / "Big sale tomorrow — veggies half off." | 50대, 목장갑, 활달 |
| M3 노량진 | "Captain Lee / 이 선장" | 40 years reading the dawn fish auction; picks only the best. · 새벽 경매 40년, 최고만 고름 | "This flatfish? Still flapping. Just in." / "I set aside the good stuff for you." / "Auction's hot at dawn — come by." | 50대, 고무앞치마·장화, 억척 |
| M4 경동 | "Old Mr. Han / 한 노인" | A lifelong herbal expert; patience over haste. · 평생 한방, 급함보다 정성 | "Nourishment can't be rushed. Choose well." / "For your sincerity, I'll give you the good root." / "This ginseng is six years aged." | 70대, 두루마기·돋보기, 차분 |
| M5 광장 | "Auntie Bin / 빈대떡 이모" | The hospitality queen of the food lane; feeds you first. · 부침 골목 인심왕, 일단 먹여줌 | "Taste it, taste it — it's free, go on!" / "Regulars get extra, here~" / "Mung beans are great today — pancake time." | 50대, 두건·앞치마, 왁자 |
| M6 남대문 도매 | "Big Bro Cha / 차 형님" | Fast bulk dealer; brings in the premium sauces. · 대량·빠름, 명품 장 들여옴 | "Buy it by the box, that's the deal." / "Wholesale price for you, bro." / "Got premium gochujang in — chef-grade." | 40대, 전대·반팔, 빠름 |
| M7 전주 | "Granny Jeong / 정 할머니" | 70 years of bean sprouts; warm Jeolla heart. · 콩나물 70년, 전라 인심 (light dialect) | "Look at these sprouts, eh — crisp as can be, ya know." / "For a regular, I'll pile it on." / "For Jeonju bibimbap, it's gotta be these." | 70대, 몸뻬·앞치마, 전라 방언 한 마디 |
| M8 부산 | "Auntie Bae of Busan / 자갈치 아지매" | Salt-of-the-sea fishmonger; brisk and bold. · 자갈치 억센 생선장수 (light dialect) | "Come on in~ this mackerel's so fresh, ya know!" / "Yer a regular, I'll give ya plenty." / "Today's sashimi is the best one." | 50대, 고무장갑·장화, 부산 방언 한 마디 |
| M9 안동 | "Elder Kim / 김 어르신" | Proud head-family beef seller; sells only to the worthy. · 종갓집 한우 자부심 | "Andong beef isn't for just anyone." / "For you, I'll bring out the family's best." / "Look at this marbling." | 60대, 정갈한 한복, 점잖음 |
| M10 통인 | "Auntie Han / 한 아주머니" | Keeper of the brass-coin lunchbox lane; pure nostalgia. · 엽전 도시락 골목, 레트로 정 | "Trade your coins for side dishes!" / "Extra coins for regulars~" / "Old-school oil-tteokbokki, just like before." | 50대, 옛 앞치마, 정겨움 |
> 친밀도(개인 호감) = 시장 평판과 별개. 단골 할인·우선 입수·정보(`markets-v1 §3`). 대사 `[PLAYER_TYPE]` 분기 가능(예: 외국인 플레이