## 3. WebSocket
### 인증 방법
- 처음 소켓에 접속할 때 위에서 받은 token을 넣어서 connect해야 한다. 아래의 코드 참고 

- 토큰이 올바르지 않으면 **error** 이벤트를 통해 에러가 전달된다. 아래 코드 참고해서 에러 처리

- 위의 인증과정을 통해서 서버는 어느 user가 보낸 메시지인지를 알 수 있으므로 이후 메시지에서는 token을 보낼 필요가 없다.

### Client --> Server
- **in**: 다른 사용자 추가 초대 (DEPRECATED!)
	- {room: 'roomId', users: [users' IDs]}
	- 중요한점: 2명이 있는 채팅방에 다른 사람을 추가하는 경우 invite를 하지 말고 새로운 채팅방을 전체 인원을 가지고 새로 만들어서 Join해주세요. 현재 채팅방의 인원수가 2명이 아닌 경우에만 동작합니다.
	- 2명 채팅방에 대해서는 에러 처리함.
	- 서버 response: msg로 "_invited"
- **out**: 채팅방 나가기 (DEPRECATED!)
	- {room: 'roomId'}
	- 이 메시지를 받는 순간 채팅방에서 현재 사용자를 제거합니다. 
	- 2명 채팅방에 대해서는 에러 처리함.
	- 서버 response: msg로 "_left"
- **join**: 특정한 채팅룸 broadcast 채널에 join (Subscribe). 
	- 이 이후에는 채널로 보낸 내용을 전달 받을 수 있음 
	- {room: 'roomId'}
	- 해당 room에서 invite, status, read 상태 등을 받기 위해서는 채널 청취 필
	- "leave"로 채팅룸의 채널을 빠져나갈 수도 있음.
	- 서버 response: "sub"
- **leave**: 특정 채팅룸 broadcast 채널에서 떠남 (Unsubscribe).
	+ {room: 'roomId'}
	+ 채팅방 참여자에서 나가는 것은 아님!
	+ 채팅방이 없어지는 것도 아님.
	+ 서버 response: "unsub"
- **send**: 채팅방 대화 전송
	+ **key**는 client에서 만들어 보내는 unique id로 서버는 이 key를 그냥 재 전송함.
	- {room: 'roomId', type: 'text', text: 'xxxxxxxx', key:'xxxx'}
	- {room: 'roomId', type: 'link', url: 'xxxxxxxx', title: 'xxxx', 'description': 'xxxx', 'img', 'xxxx'}
	- {room: 'roomId', type: 'img', url: 'xxxxxxxx', img: 'xxxxxx'}
	- {room: 'roomId', type: 'file', url: 'xxxxxxxxxx', title: 'xxxx'}
	- {room: 'roomId', type: 'emoticon', img: 'xxxxxxxxx'}
- **status**: 현재 상태 (일단은 글 작성 중을 위하여)
	- {room: 'roomId', status: 'typing'}
	- {room: 'roomId', status: 'idle'}
	- 서버 response: 'changed'
- **read**: 몇 번 글을 읽었음. 실제 User가 채팅방에 들어와서 앱이 메시지를 보여준 경우에 발신
	- {room: 'roomId', at: 1437468904, unread: 나의 현재 unread개수}
	- ** 추가 내용 **: acks: ['msgId', ...] 이 파라메터가 들어가면 ack 역할도 함께 할 수 있음! acks라고 이름을 보낼 때는 msg id의 array. 그냥 ack이라고 보낼 때는 msg id 하나만
	- 즉: 
		- {room: 'roomId', at: 1437468904, unread: 나의 현재 unread개수, acks: ['12131', '124145']}
		- {room: 'roomId', at: 1437468904, unread: 나의 현재 unread개수, ack: 124145'}
- **echo**: 서버 테스트 용 Event. 클라이언트에게 동일한 메시지를 재 전송한다. 
	- 서버 response: 'echoed' 
- **close**: 서버 쪽에서 강제로 socket을 close하도록 요청
- **hb**: 서버에 살아있음을 보냄. 
	- 서버와의 연결이 timeout이 되어 끊어지지 않도록 종종 이걸 보내면 좋겠다.
- **ack**: 서버로 부터 msg라는 이벤트를 받거나 msg에 해당하는 Notification을 수신한 경우 해당 room의 msg를 전달받았음을 return. 일정 시간 내에 Ack이 오지 않으면 Noti가 다시 날아갈 수도 있음.
	+ {room: 'roomId', msgs: ['msgId'...], unread: 3 }
	- unread: 해당 user의 unread count

### Server --> Client
- **msg**: 메시지
	- {room: 'roomId', msg: 'msgId', from: 'userId', key: 'xxxx', at: 1437468904, unread: 10, type: 'text', ....}
	- 메시지를 받으면 해당 내용을 서버에 ack해야 함. 그렇지 않으면 Push noti가 날아감.
- **sent**: 메시지를 전송한 사람에게 메시지 전달받았다는 것을 먼저 보냄. 
	+ {room: 'roomId', key: 'xxxx', at: xxxx}
- **changed**: channel로만 전송. 
	- {room: 'roomId', user: 'userId', status: 'typing'} // 방에서 사용자가 타이핑 중/ 중단인 것을 전달
	- {room: 'roomId', user: 'userId', status: 'idle'} // 방에서 사용자가 타이핑 중/ 중단인 것을 전달
	- {room: 'roomId', type: 'updated'} // 룸 정보가 업데이트 되었으니 다시 받으시오.
- **seen**
	+ {room: 'roomId', from: 'userId', at:1437468904}
- **updated**: 특정 리소스가 변경되었음을 전달
	+ 아직 구현하지 않을 것임.
	- {type: 'user', id: '124124', data: {실제 /users/:id 에서 얻을 수 있는 값과 동일}}
		- 특정 사용자의 친구들에게 모두 전달됨
	- {type: 'room', id: '124124', data: {실제 /rooms/:id 에서 얻을 수 있는 값과 동일}}
		- 해당 채팅방의 참여자에게 모두 전달됨. 그런데 이게 필요한가?
- **sub**: 특정 채팅 room의 broadcast 채널에 subscribe완료
	+ 이 Room 정보를 활용해서 room의 메시지 등을 가져올 지 결정할 수 있을 듯.
	- {room: room정보 전체}
- **unsub**: 특정 채팅 room의 broadcast 채널에 unsubscribe완료
	- {room: 'roomId'}
- **welcome**: 사용자가 소켓으로 접속하면 그냥 이 메시지를 보냄. 잘 들어왔다는 뜻.
	+ {at: 현재 시간}
- **echoed**: 클라이언트에게 **echo** 를 받은 경우 동일한 메시지를 재전송. 테스트 용으로 사용하시오.
	+ {at: 현재 시간}
- **err**: 서버에서 에러 메시지를 전달할 때 사용. Socket의 error와는 다른 이벤트. data로 에러 메시지가 넘어옴.
- **friend**: 전화번호만 등록해두었던 사람이 회원으로 가입하여 자동으로 친구가 되었음!
	+ {id: 'userId'}
	+ 이 메시지를 받으면 friend목록을 갱신하는게 좋을 듯!
- **notice**: 전체 공지 data 의 내용에 따라 다른 처리 필요
	+ {type: xxxx, content: xxx}
	+ type 종류 
		* config: configuration 파일을 새로 update해야 
		* notice: 공지 사항이 추가됨.
		* version: 버전정보

## 4. WebSocket 연결이 안된 경우의 처리

### 기본 동작 설명

- WebSocket으로 연결이 안된 경우 PushNotification으로 다음과 같은 메시지가 전달됨
	- {room: 'roomId', msg: 'msgId', from: 'userId', at: 1437468904, unread: 10, type: 'text', ....}
	- 메시지를 전달받고 app이 실행되면
		- WebSocket connection이 없으면 connect
		- Socket으로 원하는 room에 직접 join해야 channel로 전송되는 메시지 받을 수 있음.
		- 이미 정보를 가지고 있는 room이면, 해당 room 정보를 가지고 View를 보여줌. msg를 출력함
		- Background로 room의 정보를 update하여 반영
- iOS, Android 모두 app이 foreground인 경우 별도의 알람 없이 처리 가능함.
- 사용자가 특정 채팅방의 알람을 꺼둔 경우에도 PushNotification은 전달 됨. 다만, Alert이나 Sound는 나오지 않도록 수정 함.
  (가능한가? 가능할 듯... 최악의 경우 message 속에 silent: true 같은 값을 전달하고 클라이언트가 알아서 할 수 있지 않을까?)

### 메시지 형태
```
# ANDROID
data: {
	alert: 'ABCDE',
	badge: 12,
	category: 'chat',
	body: {
		메시지 내용...
	}
}

# iOS
{
	aps: {
		alert: 'ABCDE',
		badge: 12,
		category: 'chat'
	},
	body: {
		메시지 내용
	}
}

```
- alert: Noti로 보여질 text. Chat message의 경우 '아이유: 오빠 어디야?'와 같이 발송자 + text (일부?)로 이루어짐.
- badge: 마지막 ack 이후의 Push noti가 발송된 개수. 즉, chat message이외의 push noti를 받더라도 app이 noti를 받아서 깨어나면 비어있는 ack이라도 날리자.
- category
	- **chat**: 채팅 메시지
	- **notice**: 공지사항
- message: 상세 메시지 내용
