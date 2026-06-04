# Characters — Phase 1 (친구 5 + 평가자 3 + 상인 2)

> 보편 아키타입·한·영 병기·대사 EN 우선. 미각 벡터·편차 = 백엔드(UI 숫자 X). 풀 캐스트 = `docs/phase2_archive/characters-v2.md`. Phase 1은 아래만.
> NPC 대사에 `[PLAYER_NAME]`·`[PLAYER_TYPE]`(Mia/Alex/Jin/Sora/Pat) 분기(인사 톤만, 경량).

## 1. 친구 5 (등장 레벨순)
| ID | 별명(EN/KR) | Lv | 1줄(EN · KR) | 대사(입장/만족/실망, EN) | (내부)벡터·편차 |
|---|---|---|---|---|---|
| F1 | Mina / 미나 (옆집 이웃) | L2 | Curious neighbor who pops by often. · 자주 들르는 호기심 많은 이웃. | "Ooh, what're you cooking, [PLAYER_NAME]?" / "Yum, I'm telling everyone!" / "Hmm, a little off today." | [.5,.5,.4,.4,.55]·0.36 |
| F2 | Junho / 준호 (직장 동료) | L4 | Coworker who craves more heat. · 매운맛을 찾는 직장 동료. | "Make it spicy today, yeah?" / "Now THAT's a kick!" / "Too mild, man." | [.3,.6,.9,.2,.5]·0.27 |
| F3 | Riley / 라일리 (외국인 룸메) | L5 | Foreign roommate, Korean-food rookie (player surrogate). · 한식 입문 외국인 룸메(플레이어 분신 톤). | "Teach me this one!" / "Whoa, restaurant-level!" / "Still adjusting to Korean flavors." | [.5,.5,.45,.45,.55]·0.23 |
| F4 | Mrs. Lee / 이 여사 (집주인 멘토) | L6 | Landlady who became family; gentle clean flavors. (부모/옆집 어른 역 통합) · 가족 같은 집주인, 슴슴·깔끔. | "Made too much—share with me?" / "Just right. Lovely." / "A touch strong for me, dear." | [.3,.4,.2,.25,.6]·0.19 |
| F5 | Sora / 소라 (향수 친구, NPC) | L7 | Well-traveled friend craving comfort umami; guides into深い맛. · 향수에 젖어 깊은 맛을 찾는 여행 친구(한식 깊이 안내). | "Make me something that tastes like home." / "Exactly the comfort I needed." / "Close, but missing depth." | [.35,.55,.4,.3,.85]·0.14 |
> Phase 2 archive: Park 부부·Daniel Kim(친구)·Sunny·Tae-min·Yuna·Hana·Do-yoon·Elena. Mrs. Lee가 부모/옆집 어른 역을 통합.
> 플레이어 'Sora'와 NPC 'Sora' 동명 — Phase 1 한정 의도적 유지(귀향자 플레이어 ↔ 향수 친구, 서사적 거울). 혼동 우려 시 NPC를 'Seoyeon'으로 교체 가능 `[사용자 확인 필요]`.

## 2. 평가자 3 (Golden Spoon 라인)
| ID | 이름(EN/KR) | Lv | 역할 | 대사(EN) | (내부)편차 |
|---|---|---|---|---|---|
| EV1 | Mystery Diner / 수수께끼의 손님 | L3 | 정체불명, 별점만. 떡밥. | "(sits quietly)" / "(small nod, marks a spoon) …Impressive." / "(closes notebook, leaves)" | 0.31 |
| EV2 | Food Blogger (Daniel Kim) / 푸드 블로거 대니얼 김 | L5 | **친구이자 블로거**(친구 슬롯엔 미표기, 개인 서사 강화). 리뷰 시 신규 손님 트리거. | "Rolling! So, [PLAYER_NAME]'s Korean dish?" / "Guys, this is going viral!" / "Honestly? A bit underwhelming." | 0.23 |
| EV3 | Golden Spoon Inspector / 골든스푼 평가관 | **L8 보스** | Phase 1 엔딩 클라이맥스. 익명·정장·황금 숟가락 핀. | "(takes a seat) I'll begin the evaluation." / "(pauses pen) …Worthy of a Golden Spoon." / "(closes book) Not yet." | 0.10 · 특산품+ |
> Mystery Diner의 정체 reveal(=Inspector)은 Phase 1 L8에서 가볍게 암시(풀 reveal 서사는 Phase 2 L10 archive). Famous Vlogger·Celebrity Chef = Phase 2.

## 3. 상인 NPC 2 (시장 단골, 조력자)
| 시장 | 별명(EN/KR) | 1줄(EN · KR) | 대사(입장/단골/정보) |
|---|---|---|---|
| 동네 | Mr. Jeong / 만물상 정씨 | Sells a bit of everything, throws in extra. · 없는 거 빼고 다 파는, 덤 잘 주는 아저씨. | "Welcome, [PLAYER_NAME]! What're you after?" / "For a regular—here, on the house." / "New stock's over there." |
| 노량진 | Captain Lee / 이 선장 | 40 years reading the dawn fish auction. · 새벽 경매 40년, 최고 활어만. | "This one? Still flapping—just in." / "I set aside the good catch for you." / "Auction's hot at dawn." |
> 친밀도(개인 호감) → 단골 할인·우선 입수·정보. 시장 평판과 별개(`markets-phase1`).

## 4. 등장·서사 비트 (L1~8)
- L1 동네 부엌(튜토리얼, 상인 Mr. Jeong) → L2 Mina → L3 Mystery Diner(떡밥) → L4 노량진 개방·Captain Lee·Junho → L5 Riley·Daniel Kim 리뷰 → L6 Mrs. Lee 친밀도↑ → L7 Sora·Golden Spoon 떡밥("a scout is watching you") → **L8 Golden Spoon Inspector 보스 → 엔딩**.

## 5. 자연어 UI (숫자 비노출, scoring §0 준용)
식사 전 한 문장 요구("조금 더 매콤하게요")·식사 후 표정+자연어+별 1~5. 까다로운 평가자일수록 구체적 요구.
