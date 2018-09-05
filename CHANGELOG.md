# Messenger-Back

## MVC, ORM, TEST - update 18.09.05
>MVC sample : https://github.com/gnipbao/express-mvc-framework<br>
>ORM : sequelize(https://github.com/sequelize/sequelize)<br>
>TEST : mocha(https://mochajs.org/)<br>

## ERD - update 18.09.03
![image](https://user-images.githubusercontent.com/26675063/44985613-e5908900-afbb-11e8-8cd2-c79187116bbc.png)

>TABLE_USER_INFO : 사용자 정보 테이블
 - P_ID : 사용자 고유 PK
 - USER_ID : 사용자 계정 ID
 - USER_PW : 사용자 비밀번호 
 - USER_NICK : 사용자 닉네임
 - USER_STATE : 사용자 활성화 여부
 
<br> 
 
>TABLE_CHATTING_ROOM : 채팅방 테이블
 - C_ID : 채팅방 고유 PK
 - CREATE_DATE : 채팅방 생성 날짜
 - LAST_UPDATED : 마지막으로 보낸 메시지 날짜
 - ROOM_NAME : 채팅방 이름

<br>

>TABLE_PARTICIPANT : 참여자 정보 테이블
 - P_ID (FK_P_ID_PARTICIPANT) : USER_INFO 테이블 조인 외래키(FK)
 - C_ID (FK_C_ID_PARTICIPANT) : CHATTING_ROOM 테이블 조인 외래키(FK)
 - JOIN_DATE : 채팅방에 참여를 시작한 날짜
 - SEEN_DATE : 참여자가 채팅방에서 마지막으로 채팅을 본 날짜

<br>

>TABLE_MESSAGE : 메시지 테이블
 - M_ID : 메시지 고유 PK
 - C_ID (FK_C_ID_MESSAGE) : CHATTING_ROOM 테이블 조인 외래키(FK)
 - P_ID (FK_P_ID_MESSAGE) : USER_INFO 테이블 조인 외래키(FK)
 - CONTENT : 메시지 내용
 - REG_DATE : 메시지 전송 날짜
 
* * *
### window cmd에서 RDS 인스턴스 원격 접속하는 방법
mysql -h서버주소 -u아이디 -p패스워드<br>
ex)<br>
mysql -hrds-test.lkafj1kl2j3dkd.ap-southeast-1.rds.amazonaws.com -uroot -p1234

* * *
0828
## Node.js Express 세팅 방법
> 참고 : https://jongmin92.github.io/2017/05/17/Emily/3-make-express-project/
1. node.js 및 npm 설치
2. npm init 설정 (package.json 생성)
  ```
  $ npm init
  ```
3. express-generator 설치
  ```
  $ npm install express-generator -g
  ```
4. express 설치 및 폴더 생성
  ```
  $ express 폴더명
  ```
5. 현 프로젝트에 express 설치
  ```
  $ express
  ```
6. 기본 모듈 설치
  ```
  $ npm install
  ```


> 프로젝트 개발에 앞서 서버구축을 위한 프레임워크 및 ERD 선정
> ERD 정규화구조로 구축 (중복되거나 낭비되는 데이터가 없도록 설계)
> 서버사이드 언어로는 Node 선택
> 프레임워크는 Express

* * *
0830
### Node ORM 설정
> ORM : http://www.incodom.kr/ORM
> 참고 : https://hyunseob.github.io/2016/03/27/usage-of-sequelize-js/

***
### Node 환경변수
>참고 : http://webinformation.tistory.com/106


### Node DB 연결
>참고 : https://poiemaweb.com/nodejs-mysql
>DB종류와 분류 : http://jwprogramming.tistory.com/52

> 데이터베이스 보안을 위한 쿼리문 ORM 적용
> 서버 접속 시 계정보안을 위한 환경변수 활용
> AWS DB용 인스턴스 생성 (관계형데이터베이스 RDB)
> IAM 활용한 안전한 리소스 액세스 설정 (로그인 및 권한) (https://docs.aws.amazon.com/ko_kr/IAM/latest/UserGuide/introduction.html)
> sql tool 활용하여 DB내 테이블 및 컬 설정 (관계형)

### 웹소켓 (2018.08.29 'WEBRTC'기능으로 변경)
> 웹소켓이란 : http://victorydntmd.tistory.com/250
> 웹소켓 가이드 : https://www.zerocho.com/category/NodeJS/post/57df854f5f0b02001505fef2


### WEBRTC
> WEBRTC : https://webrtclab.herokuapp.com/   
> 예제코드 : https://webrtclab.herokuapp.com/get-user-media/
