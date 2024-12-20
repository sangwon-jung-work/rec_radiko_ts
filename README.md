# rec_radiko_ts
radiko 타임프리(다시듣기) 방송을 저장하는 환경을 Docker에 구현

*(서버는 일본지역 내에 있어야 하며, 타임프리 기능 사용을 위해서는 프리미엄 등록이 필요합니다)*

## 사용법
```sh
# save repository
git clone https://github.com/sangwon-jung-work/rec_radiko_ts.git
cd rec_radiko_ts

#
# install github cli or latest ffmpeg build url
#
# install github cli
# https://github.com/cli/cli#installation
#
# get url from release page
# search to ffmpeg-nx.x-latest-linux64-gpl-x.x.tar.xz (not master-latest) and copy url that
# https://github.com/yt-dlp/FFmpeg-Builds/releases/tag/latest

#
# set environment variable (for url)
#
# if install github cli
gh auth login

FFMPEG_URL=$( gh api --jq '.assets[8]."browser_download_url"' -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /repos/yt-dlp/FFmpeg-Builds/releases/latest )
#
# if just copy url
FFMPEG_URL=(paste that url)

#
# set build date
TODAY=$( date '+%Y%m%d' )

# Build image
docker build --build-arg FFMPEG_LATEST_URL=$FFMPEG_URL --build-arg BUILD_DATE=$TODAY --tag (image name):(image version) .
# Build image Example
docker build --build-arg FFMPEG_LATEST_URL=$FFMPEG_URL --build-arg BUILD_DATE=$TODAY --tag radiko_ts_recorder:1.1 .

# recording example
docker run -it --rm -v (save dir):/rec (image name):(image version) -s QRR -f 202005312100 -t 202005312130 -o "/rec/(filename).m4a" -m "(ID)" -p "(PW)"

# recording example(joqr)
docker run -it --rm -v /recorder:/rec radiko_ts_recorder:1.1 -s QRR -f 202005312100 -t 202005312130 -o "/rec/AYAKA_ts_2020-05-31-20-59.m4a" -m "(ID)" -p "(PW)"
```

| 인수 | 필수여부 | 설명 | 비고 |
|:-:|:-:|:-|:-|
|-s _STATION_|○|방송국ID|ラジコサイトの番組表から番組詳細ページへ移動したあとのURL  /#!/ts/`???`/ にあたる文字 <sup>[*1](#param_note1)</sup>|
|-f _DATETIME_|○|시작시간|프로그램 시작일시(JST). %Y%m%d%H%M 형식|
|-t _DATETIME_|△<sup>[*2](#param_note2)</sup>|종료시간| 프로그램 종료일시(JST). %Y%m%d%H%M 형식 <sup>[*3](#param_note3)</sup>|
|-d _MINUTE_|△<sup>[*2](#param_note2)</sup>|녹음시간(분)|`-f` 으로 설정한 일시에 더해 종료시간을 계산하는데 사용한다 <sup>[*3](#param_note3)</sup>|
|-u _URL_||방송URL|Radiko 사이트 편성표에서 이 URL을 기반으로 프로그램 정보를 읽어온다. `-s` `-f` `-t` 인수의 데이터 자동지정|
|-m _MAIL_||Radiko ID(이메일)||
|-p _PASSWORD_||Radiko Password||
|-o _PATH_||저장위치|저장 경로와 함께 파일명을 지정할 수 있다|

<a id="param_note1" name="param_note1">*1</a> http://radiko.jp/v3/station/region/full.xml 의 ID와 동일.  
<a id="param_note2" name="param_note2">*2</a> 최소 둘 중 하나의 인수는 지정한다. `-t` 와 `-d` 모두 지정되지 않으면, 종료시간은 길어지는 쪽에 맞춘다.  
<a id="param_note3" name="param_note3">*3</a> 종료시간은 스크립트를 실행할 일시보다 2분 이르게(-2분) 설정할 것. 미래의 일시를 지정하거나 스크립트 실행일시를 지정할 경우 오류가 발생하거나 재생할 수 없는 파일이 생성될 수 있다.


## 실행 예시

사용법 (image name):(image version) 다음에 지정 가능.

```
# IP 내 지역의 방송
$ ./rec_radiko_ts.sh -s RN1 -f 201705020825 -t 201705020835 -o "/hoge/2017-05-02 日経電子版NEWS(朝).m4a"
# IP 외 지역의 방송(エリアフリー)
$ ./rec_radiko_ts.sh -s YBC -f 201704300855 -t 201704300900 -o "/hoge/2017-04-30 ラジオで詰め将棋.m4a" -m "foo@example.com" -p "password"
# 종료시간 대신 녹음시간 지정
$ ./rec_radiko_ts.sh -s RN1 -f 201705020825 -d 10
# 방송 URL 지정
$ ./rec_radiko_ts.sh -u 'http://radiko.jp/#!/ts/YFM/20170603223000'
```

## 테스트 환경
- Ubuntu 16.04.2
    - curl 7.47.0
    - xmllint using libxml version 20903
    - ffmpeg 3.3.3-1ubuntu1~16.04.york0
- FreeBSD 11.0-RELEASE
    - curl 7.55.1
    - xmllint using libxml version 20904
    - ffmpeg 3.3.3

Windows 10 Creators Update 빌드 설치 후 사용 가능한 Windows Subsystem for Linux의 Ubuntu에서도 동작.


##  제작자(fork 에서 확인가능)
うる。 ([@uru_2](https://twitter.com/uru_2))


## License
[MIT License](LICENSE)


## 출처
아래의 출처를 참고하였습니다.

- [install github cli for linux](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)
- [yt-dlp FFmpeg pre Build repository](https://github.com/yt-dlp/FFmpeg-Builds/releases/tag/latest)
- https://github.com/ez-design/RTFree
- http://kyoshiaki.hatenablog.com/entry/2014/05/04/184748
- http://mizukifu.blog29.fc2.com/blog-entry-1429.html
- https://github.com/ShellShoccar-jpn/misc-tools/blob/master/utconv

RTFreeは実装方法および .NET Core 入れて動かすのちょっとなぁ…という気持ちにさせてくれたという意味で特に感謝しております。
