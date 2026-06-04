# Player Characters v1 — 프리셋 5종 (시작 선택)

> 게임 첫 실행 시 **5 프리셋 중 선택** → 다양한 정체성 투영(글로벌 타깃, `positioning-v1`). 연령대 **20~30대 위주**(모바일 메인 타깃). **메커닉 차이 없음**(동일 진행·보상). **서사·톤만** 분기(오프닝 컷씬·NPC 인사 톤·아바타 비주얼).
> 연동: `characters-v2 §5`(분기 변수), `GDD-v2`(시작 흐름), `onboarding-pace-v1`(첫 화면), `image_prompts_v2_characters §C`(아트).

## 1. 프리셋 5종
| ID(PLAYER_TYPE) | 이름(EN/KR) | 연령/정체 | 1줄 배경(EN · KR) | "이사 온 이유" |
|---|---|---|---|---|
| heritage_seeker | **Mia / 미아** | 20s, Korean American | Moved to Korea chasing the taste of grandma's cooking. · 할머니 손맛이 그리워 한국으로 온 교포. | 뿌리를 찾아서 |
| newcomer | **Alex / 알렉스** | 30s, international expat | Just landed in Seoul for work; total Korean-food rookie. · 발령으로 막 서울 도착한 한식 입문자. | 새 직장·새 도시 |
| local | **Jin / 진** | mid-20s, Korean local | First time living alone, first time cooking. · 처음 자취·처음 요리하는 동네 청년. | 독립 첫걸음 |
| returnee | **Sora / 소라** | 30s, Korean returnee | Back home after years abroad; a seasoned palate. · 해외 생활 후 귀국, 미식 경험 풍부. | 고향에 정착 |
| traveler | **Pat / 팻** | adult(20~30s), international foodie | A traveling food adventurer who decided to settle. · 정착을 결심한 모험심 강한 미식 여행자(중성적). | 여행 끝, 정착 |
> 성별·인종 분포(연령은 20~30대로 통일): 누구나 가까운 1명을 찾도록. 이름은 한국식/국제식 혼합.
> 참고: 친구 NPC는 이름 충돌 회피 위해 **Seoyeon(서연)**으로 명명(구 'Sora' 친구). 플레이어 귀향자 = **Sora**.

## 2. 오프닝 컷씬 텍스트 (캐릭터별 3씬, EN/KR, 각 ~30~60자)
> 씬1 도착 / 씬2 첫 부엌 / 씬3 첫 손님(옆집 어르신). 톤만 다르고 흐름 동일.
- **Mia**: ① "Grandma's kitchen smelled just like this." / "할머니 부엌이 꼭 이 냄새였지." ② "Maybe I can find that taste again." / "그 맛을 다시 찾을 수 있을까." ③ "The Parks next door already feel like family." / "옆집 박씨 어르신이 벌써 가족 같아."
- **Alex**: ① "So this is kimchi… intense first impression." / "이게 김치구나… 첫인상 강렬한데." ② "Okay, let's learn this one dish at a time." / "좋아, 한 가지씩 배워보자." ③ "The neighbors are surprisingly welcoming." / "이웃들이 의외로 따뜻하네."
- **Jin**: ① "First place of my own. Now… what do I eat?" / "첫 자취방. 근데… 뭘 먹지?" ② "How hard can ramyeon be, right?" / "라면쯤이야, 별거 있겠어?" ③ "The Parks offered to teach me. Lifesaver." / "옆집 어르신이 가르쳐주신대. 살았다."
- **Sora**: ① "Home at last. I missed these flavors." / "드디어 고향. 이 맛이 그리웠어." ② "I've eaten everywhere — time to cook it myself." / "다 먹어봤으니, 이제 직접 만들 차례." ③ "Let's see if my palate can guide my hands." / "내 입맛이 손을 이끌어줄까."
- **Pat**: ① "Of all my travels, Korea made me stop." / "수많은 여행 끝에, 한국에서 멈췄다." ② "Time to cook the food I fell for." / "반했던 그 음식을 직접 만들 시간." ③ "New neighbors, new flavors — let's go." / "새 이웃, 새 맛 — 가보자."

## 3. 시각 키워드 (아트, premium v2)
| 프리셋 | 외형 키워드(EN) |
|---|---|
| Mia | late-20s Korean American woman, casual chic, warm nostalgic vibe, tote bag |
| Alex | early-30s international expat (non-Korean), smart-casual, eager-but-lost, backpack |
| Jin | mid-20s Korean man, hoodie + apron, fresh-out-of-home energy |
| Sora | 30s Korean woman, refined traveler style, confident calm |
| Pat | 20s-30s androgynous traveler, practical layered outfit, adventurous, multi-ethnic tone |
> 5종 모두 chibi mascot 1:1.8, 흰 배경 컷아웃, 표정 3종(중립/즐거움/놀람) + 부엌 작업 포즈 1종. 아바타로 부엌·시장·디너 컷씬에 표시.

## 4. 관계망 분기 메모 (NPC 톤, `[PLAYER_TYPE]`)
- **Riley(룸메 외국인)**: newcomer/traveler → "fellow foreigner figuring out Korea together" / heritage(Mia) → "you reconnecting with your roots" / local(Jin) → "my Korean friend showing me around".
- **Mr.&Mrs. Park(옆집 어르신)**: 전원 따뜻하나 heritage엔 "you remind us of our grandkid", newcomer/traveler엔 "welcome to Korea, dear", returnee엔 "welcome home".
- **시장 상인**: 외국인 타입엔 천천히 친절 설명, local/returnee엔 구수한 단골 톤.
> 분기는 **인사·호칭 톤 위주(경량)**. 본 서사·메커닉 동일.

## 5. 커스터마이즈 (v1 단순, 정의만)
- v1: 이름 커스텀(디폴트 이름 or 입력) + 시작 인사 한 줄.
- 후속(정의만): 의상 컬러 1~2톤, 헤어/안경 옵션 1~2, 사이드 백스토리 진행 중 잠금해제. `[사용자 확인 필요: v1 범위]`

## 6. 선택 화면 흐름
첫 실행 → **캐릭터 5 캐러셀**(풀바디 + 1줄 소개 EN/KR + "이사 온 이유") → 선택 → 이름 커스텀 → 시작 인사 → **오프닝 컷씬 3씬** → 첫 라운드(R1 라면, 옆집 어르신). UI = `art-needs §캐릭터 선택`(5 slot 캐러셀).

## 7. A/B
- **[A/B] 프리셋 수**: A=5종(디폴트, 20~30대 위주 다양성) / B=4종(슬림). 디폴트 A.
- **[A/B] 분기 깊이**: A=톤만(디폴트) / B=전용 서브플롯. 디폴트 A(번역·제작 경량).
