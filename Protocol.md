### Message List

api 설명서
# Minions-Toy PROTOCOL v 1.0
​
2018-09-06
​
## 1. Protocol Requirement
​
* 통신 프로토콜
	- Development: http
	- Production: https
* 시간은 모두 EPOCH로 통일한다. 단위는 ms
	- https://en.wikipedia.org/wiki/Unix_time
	- UTC 1970년 1월 1일 0시 0분 0초 이후의 elapsed ms
	- 13자리 숫자 (예: 1439243059000)
​
## 2. REST API
* 접속 주소는 /api/v1/ 과 같이 /api/version아래에 존재.(추후 API이 전면 개편에 대비)
	- 즉, 아래 모든 REST API에서 주소는 https://ssum.chat/api/v1/login 과 같은 형태임.
* 모든 Parameter는 request의 body에 urlencoded의 형태로 전송한다.
* 모든 API의 Result Format: JSON
	- HTTP의 Response Code도 함께 확인할 필요 있음
	- 성공: 2XX
		- 200: OK
		- 201: Created (OK)
		- 202: Accepted (OK)
	- 실패: 4XX (서버 오류는 아님)
		- 400: Bad Request
		- 401: Unauthorized (로그인 실패, 혹은 로그인 필요)
				예: access_token이 invalidate 된 경우
		- 403: Forbidden (접근 안되는 곳)
		- 404: Not Found (없는 URI)
		- 422: Unprocessable Entity (잘못된 요청)
	- 실패: 5XX (서버 오류)
		- 500: Internal Error (서버 쪽 Debugging 필요)
		- 501: Not Implemented (아직 구현 안됨)
​
- 에러가 있는 경우 JSON 포멧 내부에 아래 필드 있음
	- code: 자체 에러 번호(0은 에러 없음)
	- message: 에러에 대한 설명
​
* 모든 REST API에 포함되어야 할 내용
	- apikey: 플랫폼 별로 Secret 키를 넣어서 보냄. (예: ?apikey=AHGND123T)
		+ CONG Android: bdde727068514b5f87c3bee2a0ccad6e
		+ CONG iOS: 73fa23d8dede4b7fb39d7860b9326bc6
		+ CONG web: 114034803cf8320ee1bf039e9a80314f
	- client: SSUM 클라이언트 정보
		- 형식: platform_version-app_version
		- 예: android-v17-0.1.0, ios-v8.4-0.1.0, web-chrome2.4.5-0.1.0
​
* JSON Web Token을 이용하여 사용자의 인증과 세션 관련 내용을 처리한다.
	- 참고:
		- http://jwt.io/
		- http://blog.matoski.com/articles/jwt-express-node-mongoose/
	- 인증을 완료하면 JSON으로 token이 넘어온다.
	- 이 token을 다음 중의 하나로 request에 넣어서 API를 호출
		- HTTP Header - **Authorization: Bearer xxxxxx**
		- HTTP Header - **X_ACCESS_TOKEN: xxxxxx**
		- HTTP Parameter나 Body에 **token**
	- 아래에서 << 인증 필요 없음 >> 으로 표기되지 않은 API는 모두 valid 한 access token 필요
​
### 2-1. Authorization <<개발완료>>
​
- 비밀번호 변경 요청: **POST /auth/forgot_password**
	+ Parameter
		* email: 이메일주소
	+ <<인증 필요없음>>
	* Response
		- 422 {code: 106, need email}
		- 404 {code: 105, not exist user}
	
- 이메일 찾기: **POST /auth/forgot_email**
	+ Parameter
		* tel
		* name
 	+ <<인증 필요없음>>
​
- 전화번호 변경: **POST /auth/change_tel**
	+ Parameter
		* email
		* password
		* tel: 변경할 전화번호
		* secret
		* sms
		* name
 	+ <<인증 필요없음>>
	
- SMS 인증 요청: **POST /auth/sms_token**
	- 요청을 하면 해당 전화 번호로 인증 코드 (숫자 4~6자리)가 발송됨.
  - 이제 sms자체는 실제 SMS로 발송됨. 그러므로 전화번호 넣을 때 주의해야 함!
  - 8214로 시작하는 전화번호는 테스트용 전화번호로 인식하여 항상 '06103' 을 반환함 (테스트용!)
	- << 인증 필요 없음 >>
	- Parameter
		* tel: 전화번호 국가번호까지 포함하여 숫자로만 구성
	- Response
		* secret: SMS와 함께 보내야 할 secret (예: 58ABE778)
- Precheck for Signup: **POST /auth/precheck_signup**
	+ 이메일 체크, 전화번호 체크, SMS 토큰 생성을 함께 처
	+ <<인증필요없음>>
	+ Parameter
		* email: 이메일. 동일한 이메일 있으면 에러
		* tel: 전화번호 동일한 전화번호 있으면 에러 (option)
	+ Response
		* OK: HTTP 200
			- 전화번호를 안 준 경우에는 sms_token은 만들지 않는다.
			- tel
			- secret: SMS 인증요청 참
		* ERROR: HTTP 422
			- Code 130: 이미 존재하는 이메일 & 전화번호 (같은 user. 이러면 로그인을 하는게 좋지 않을까?)
			- Code 131: 이미 존재하는 이메일 & 전화번호 (서로 다른 user)
			- Code 132: 이미 존재하는 이메일
			- Code 133: 이미 존재하는 전화번호
- Sign Up: **POST /auth/signup**
	- 주어진 정보로 새로운 사용자 생성.
	- sms 등이 없으면 sms_token 검증 안
	- android는 tel을 automatic으로 넣어주세요.
	- iOS는 반드시 tel, secret, sms 등을 넣어주세요.
	- 주의 tel, secret, sms는 위의 인증 요청에 의하여 발송된 내용에서 확인이 되어야 성공
	- sms_token요청 후 일정 시간 (예 5분)내에 이 콜이 오지 않으면 무효 처리 됨. 
	- << 인증 필요 없음 >>
	- Parameter
		* tel: 전화번호 (option)
		* secret: sms_token API에서 받은 비밀 문자열 (option)
		* sms: SMS로 전달받은 숫자 코드 (option)
		* name: 이름 (required)
		* married: 결혼 여부 1, 0 (혹은 1/0) (optional)
		* birthday: 생년월일 ('2015-07-26' 형태) (optional)
		* gender: 'm' or 'f' (optional)
		* agreeTerm: 약관 동의 여부. 이 값이 1이어야 함. (required)
		* email: 이메일 (required)
		* password: 비밀번호 (required)
		* recommender: 추천인 코드 (option) [org$CONG이라고 넣으면 org 유저로 생성됨. 전화번호는 자동으로 없어짐.]
		* did: ANDROID_ID (있으면 보내자) or IOS_ID_FOR_BUNDLE (있으면 보내자)
	- Response: HTTP 201
		* user: 사용자 정보 (세부 내용은 사용자 /users/:id 항목과 동일)
		* token: access token
	- Error code
		* HTTP 422
			- 100: sms, secret 인증 실패
			- 101: 존재하지 않는 추천인 코드
			- 102: 이미 존재하는 전화번호
			- 103: 이미 존재하는 이메일
			- 199: 동일한 기기로 24시간 이내에 다른 사용자가 사용한 적이 있음.
​
​
- Sign In: **POST /auth/signin**
	로그인 하고 access_token 발급
	[이메일, 비밀번호]를 가지고 signin가능. 
	tel, secret, sms이 있으면 그것까지 검사.
	<< 인증 필요 없음 >>
	- Parameter
		* tel: 전화번호 (org 사용자는 전화번호는 검사하지 않으나 sms는 맞아야 함) (option)
		* secret: sms_token API에서 받은 비밀 문자열 (option)
		* email: 이메일
		* password: 비밀번호
		* sms: SMS로 전달받은 숫자 코드 (option)
		* from: platform. 기본값은 mobile
		* did: ANDROID_ID (있으면 보내자) or IOS_ID_FOR_BUNDLE (있으면 보내자)
	- Response
		* token: 접속에 사용할 새 access token
		* user: 사용자 정보 (세부 내용은 사용자 /users/:id 항목과 동일)
	- Error code
		* HTTP 422 - 100: sms, secret 인증 실패
		* HTTP 422 - 104: 로긴 실패
		* HTTP 422 - 199: 동일한 기기로 24시간 이내에 다른 사용자가 사용한 적이 있음.
​
- Sign Out: **POST /auth/signout**
	- 현재 사용자의 token을 invalidate 시키고, 모든 세션을 종료
	- 수정 사항!!! 만일 platform정보를 주면 해당 플랫폼을 강제 로그아웃 시킴. 
		* 예를 들어 POST /auth/signout 에 mobile쪽 token을 넣고, parameter로 platform: 'web' 을 주면 강제로 웹 세션을 종료시킴!
​
- Verify Token: **POST /auth/verify_token**
	인자로 주어진 access token이 유효한지 확인
	- Parameter
		* token
	- Response (HTTP Code)
		* 200: valid
		* 401: Unauthorized
	+ Response에 IP를 함께 담아서 보낸다.
		* 예: {ip: '123.45.6.7'}
- Check Password: **POST /auth/check_password**
	+ Parameter
		* email
		* tel
		* password
	+ 해당 내용이 맞는지 검사.
	+ Response
		* HTTP 200: OK
		* HTTP 422 - 105: invalid email or tel
		* HTTP 422 - 106: invalid password
	+ TODO: 나중에는 계속 실패하면 block하는 것을 구현해야 함!
​
- Refresh Token: **POST /auth/refresh_token**
	+ 새로 Token을 만들어줌. 이전의 Token은 날려버림.
	+ Socket도 접속을 끊음. 그러므로 App에서는 새로 Socket 접속을 해야 함.
	+ Response
		* token: 새 access token
		* user: 사용자 정보 (sign in과 동일함.)
- Disconnect socket: **POST /auth/disconnect_socket**
	+ 인증 필요 (token을 보내야 함.)
	+ 주어진 사용자의 socket정보가 서버에 있으면 삭제한다.
	+ 이렇게 한다고 서버 측에서 소켓이 바로 끊어지는 것은 아니지만, msg 전송시에 socket id가 redis에 없으므로 바로 Push로 전송을 시도한다.
​
- Dual signin token 요청: **POST /auth/dual_signin_token**
	- << 인증 필요 없음 >>
	- 전화번호/email 둘 중에 하나만 있으면 됨!
	+ parameter
		* tel: 전화번호
		* email: 이메일
	+ response
		* tel (이메일을 보낸 경우 이메일이 옴. 이 값을 dual_sign_in의 전화번호 란에 넣어야 함.)
		* secret
- Dual signin: **POST /auth/dual_signin**
	- << 인증 필요 없음 >>
	+ parameter
		* tel: 전화번호 (dual_signin_token에서 email을 줬으면 전화번호를 넣지 말아야 함!)
		* sms: 콩으로 전달받은 토큰 코드(예 11111)
		* secret: dual_signin_token으로 전달받은 secret
		* email: 이메일
		* password: 비밀번호
		* from: 'web'
		* key: '467F9CDA6D6C225A7F2E85B62AD1F'
	+ response
		* token
		* user
	+ Error code
		* HTTP 422: Code 100 token실패
		* HTTP 404: code 104 로그인 실패(key등이 없는 경)
- Check session: **POST /auth/check_session**
	+ parameter
		* platform: 'mobile' or 'web'
	+ response
		* HTTP 200:
			- code: 1 - 로그인 중
			- code: 0 - 로그인 없음
			- ip: 로그인 된 IP (web인 경우만)
			- at: last accessed at (epoch time) (web인 경우만)
		
### 2-2. 사용자 정보 << Block관련 내용 외에는 개발 완료>>
​
- 이메일 사용중 확인: **GET /users/exist?email=xxxxxxxx**
	+ <<인증 필요없음>>
	+ Status
		* 200 OK: 사용
		* 404 NOT FOUND: 사용하지 않음.
- 전화번호 사용중 확인: **GET /users/exist?tel=xxxxxx**
	+ <<위와 동일>>
- recommendCode 확인: **GET /users/exist?recommendCode=xxxxx**
	+ <<위와 동일>>
- 사용자 상세 정보 받기: **GET /users/:id**
	- Response: 사용자 상세 정보. 읽을 수 있는 권한에 따라 볼 수 있는 내용만 전달
		- id
		- desc: 한줄 상태 메시지
		- name
		- avatar
		- status
		...
​
- 사용자 정보 목록: **GET /users**
	- 사용자 목록을 페이지 단위로 가져옴.
	- 내가 차단한 사용자 목록도 여기서 검색을 통해 받아
	- 친구 검색, 혹은 전체 사용자에서 검색도 마찬가지
	- Parameter: 다음 중 하나로 검색 가능 (이 내용들은 URL의 Query String으로 넣어야 함)
		* q: 패턴 (이름이나 desc에서 검색)
		* tel: 전화번호
		* id: user일련번호
		* friend: 1/0 친구 여부 (default 0)
		* org: 1/0 단체 여부 (default 0) 후원단체 목록을 검색, org와 friend가 동시에 1이면 나의 후원단체 목록을 리턴
		* page: page 번호 (default 1)
		* email: 이메일
		* recommendCode: 추천인코드
		* per: 페이지 당 받을 개수 (default 30)
		* since: 마지막으로 sync한 시간. 이 시간이후의 data만 return함(예: 1443601327176) friend=1 인 경우에만 의미가 있음. 
	- Response
```
      users: [
				{
					name:
					desc:
					id:
					sys:...
					donationRate: (org 타입 유저의 친구인 경우에만 나타남)
					...
				},
				...
			],
			count: 총 인원수
```
- 자기 정보 확인: **GET /users/me**
	- Response
		- user: {.....}
		- 
- 자기 정보 변경: **PUT /users/me**
	- Parameter
		* desc
		* name
		* birthday
			- '2015-07-26' 형태
		* gender
			- 'm' or 'f'
		* avatar
		* married
			- true or false (혹은 0 or 1)
		* pushLevel 
			- 1: sender + msg
			- 2: sender only
			- 3: 콩메시지
			- 4: none
		* useAd: true or false 광고 사용여부
		* useLockScreen: true or false 잠금 화면 사용여부
			- useAd와 useLockScreen은 설정이 변경될 때 true/false의 값을 변경하여 주는 것으로 하자. 만일 GET /users/me에서 받아왔는데, 현재 설정값과 다른 것을 app이 알았을 경우에도 sync를 맞춰줘야 한다.
			- useAd와 useLockScreen을 설정한 적이 없는 경우에는 아마 GET /users/me를 하면 두 필드가 없을 것임. 이 경우는 설정한 적 없는 것!
	+ 사용자 전화 번호 변경시에는 sms와 secret이 함께 올 수도 있고, 함께 오는 경우에는 검증함. 
		* 예 {tel:xxxx, sms: xxxx, secret: xxxx}
		* sms실패시 422
	+ 비밀번호 변경시 oldPassword가 함께 와야 함.
		* 실패시 422
- 회원정보 삭제: **DELETE /users/me**
  - Parameter
    * password
- Device확인 용 ID 전송: **POST /users/me/device**
	+ Device ID가 바뀐 것을 확인했으면 보내자. 이 Device로는 다른 ID는 24시간 내에 접속할 수 없다!
	+ Parameter
		* did: ANDROID_ID (있으면 보내자) or IOS_ID_FOR_BUNDLE (있으면 보내자)
- Mycon 등록: **POST /users/me/mycons**
	- Parameter
  	- keys: [String]
  * 이미 존재하는 key를 넣어도 에러 없음. 그냥 무시
  * Return
  	- [keys]
- Mycon 삭제: **DELETE /users/me/mycons**
	- Parameter
  	- keys: [String]    
  	* 존재하지 않는 key를 넣어도 에러 없음. 그냥 무시
  	* Return
  	- [keys]
  	
### 2-3. 친구 <<구현완료: 다만, User가 새로 등록되면서 not-exist friend가 registered로 변할 때 Push 메시지 보내는 것은 구현되지 않았음>>
​
- 친구 정보 수정: **PUT /friends/:userId**
	+ 이미 서로 등록된(regitered)인 친구 관계가 이미 존재하여야 함. 그렇지 않으면 에러
	+ Parameter: 
		* name: 내가 부를 이름
		* status: 'normal', 'hidden', 'blocked', 'favorite' 값 중 하나.
		* donationRate(optional): 0이상, 1이하의 값, 0이면 후원 관계 제거. 동일한 관계가 없으면 새로 만듬. 즉, 후원단체 추가도 이 인터페이스 이용! donationRate의 합이 1을 넘으면 실패. 
	+ Response:
		* HTTP Code 200
		* {id: 'xxxx', userId: 'xxxx', friendId: 'xxxx', tel: 'xxxx', name: 'xxxx', status: 'xxx'}
	+ Error
		* HTTP Code 500: Internal Error, desc을 참조해야 함
		* HTTP Code 404: 그런 친구 없음
- 친구 만들기: **POST /friends**
	+ 두가지 방법이 있음
	  * 전화번호를 업로드해서 친구 추가 하기(친구 추천을 위한 연락처 추가): friends에 tel, name 배열을 전송
	  * 사용자 id로 친구 추가하기: id, name을 전송
	  	- ID로 친구 추가하는 경우 status 정보 추가 가능. 'blocked' 등을 넣을 수 있음. 만일 status가 없으면 default로 'normal'로 설정됨.
	
	+ ID/NAME 전송의 경우
```js
	Parameter 예
	{id: '123312312', name: '홍길동'}
​
	Response 예
	"200 OK" {id: '12131313'}	 
	"400" 이미 친구 관계가 있는 경우 에러
	"500" 기타 에러
```
		
	+ 전화번호 업로드의 경우
	  + 업로드한 전화번호를 기준으로 나와 친구를 맺는다. 결과로 돌아오는 상태(result)
		  * registered: 요청한 전화번호의 user가 이미 존재하는 경우 해당 사용자를 친구로 등록
			  - 만일 이미 추가한 친구 정보를 새로 upload한 경우에 name이 변경되었으면 name을 수정 저장함!
		  * not-exist: 요청한 전화번호의 user가 없는 경우, 일단 not-exist로 등록해두고, 나중에 해당 전화번호로 user가 가입하면 자동으로 친구로 맺어줌.
		  * error: 해당 tel에 대한 작업 수행 중 에러 발생. 자세한 내용은 err.message 참조
			  - 자기 자신의 전화번호가 들어오는 경우에도 에러 발생!
	  - Parameter: 친구들의 전화번호 목록을 발송
	  - Response: 추가한 사용자들의 상태. 이미 친구인 경우에는 nickname, avatar_url도 넘어온다.
```
	Parameter 예
	{
		friends: [
			{tel: '82102345678', name: '내가 부르는 이름(전화번호부에 있는 이름)'},
			....
		]
	}
```
​
```
	Response 예
	{
		friends: [
			{tel: '82102345678', id:'12141', name: '내가 부르는 이름', desc: '상대방이 설정해놓은 이름', avatar: 'xxxx', result: 'registered' }, // 존재하는 사용자는 자동으로 친구로 등록
			{tel: '82102345678', result: 'not-exist' }, // 해당 사용자 없음
			...
		]
	}
```
​
- 친구 정보 삭제하기: **DELETE /friends/:friend_id**
	+ 친구 정보 삭제
	+ Response
		* 성공: 200
		* 존재하지 않는 친구: 404
		* token이 없거나 올바르지 않음: 401
​
### 2-4. 채팅방 <<구현완료>>
​
- 채팅방 목록: **GET /rooms**
	- 본인의 채팅방 목록을 한 번에 (per)개씩 페이지 단위로 리턴
	- Parameters (query):
		- page: 원하는 페이지
		- per: 페이지 당 받을 개수 (default 30)
		- **since**: 마지막으로 sync한 시간. 이 시간 이후의 Room들만 결과에 넣어서 보냄.
		- withunread: 1 이면 room 정보 속에 unread를 넣어 줌.
		
	- Response:
		- count: total number of chat room
		- rooms: [{room 정보}....]
```js
{
	count: 123
	rooms: [
		{
			id: '512351',
			at: 143352000, // 마지막 채팅 시간
			participants: [
				{id: 'id1', join: xxxxx, seen: xxxx, title: 'xxx', name: 'xxx', avatar: 'xxx', alarm: true},
				{id: 'id1', join: xxxxx, seen: xxxx, title: 'xxx', name: 'xxx', avatar: 'xxx', alarm: true},
				{id: 'id1', join: xxxxx, seen: xxxx, title: 'xxx', name: 'xxx', avatar: 'xxx', alarm: true},
			],
			invitable: true, // 초청가능여부. 2인으로 시작한 Room은 초청 불가(false)
			roomType: 'normal' // 'normal', '1:1' (2인 1:1방), 'myroom' (나혼자 방), sys (콩팀방, 추후 또 다른 형태의 시스템 방이 생길수도...)
			numParticipants: 3
			msg: {
				type: 'text',
				text: '이런저런 메시지'
			},
			title: 'title', // 없으면 '' 빈문자열,
			desc: '방에 대한 설명 글', // 없으면 빈문자열
			notice: '공지글', // 없으면 빈문자열,
			owner: 'id', // 관리자 ...
Collapse 
 This snippet was truncated for display; see it in full

Message Input

Message #minions-messenger
