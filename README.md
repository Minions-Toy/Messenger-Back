# Messenger-Back

## ERD
<img width="915" alt="2018-08-28 8 42 32" src="https://user-images.githubusercontent.com/8125606/44720974-6c98b980-ab03-11e8-8253-b25f1ad985e1.png">

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
