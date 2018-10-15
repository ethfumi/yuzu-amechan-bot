# yuzu-amechan-bot
twitter botを作ってみたかった。
完成品 https://twitter.com/yuzu_amechan
<img width="650" alt="2018-10-12 0 20 11" src="https://user-images.githubusercontent.com/2544432/46814890-a9b7c300-cdb4-11e8-9b23-0c1e6e48bc85.png">

# botの作り方(2018/10/10)

作り方というか準備というか

【第1回】Twitter APIを使うためにdeveloper accountの申請をしよう！
https://masatoshihanai.com/php-twitter-bot-01/
を参考にtwitterのbotアカウント作る

botの中身を作る(ruby)

RubyでTwitterBotを作ろう！【公開編】
https://trap.jp/post/458/
を参考にherokuにdeployする

お疲れ様でした🍬

# herokuについて

ログ見れないと落ちたときとか分からなくて不便

herokuコマンド使えるようにする
`brew install heroku/brew/heroku`
https://devcenter.heroku.com/articles/heroku-cli

herokuにログイン
`heroku login`

ログを垂れ流す
`heroku logs -a アプリ名(例yuzu-amechan-bot) --tail`

過去ログ見たい時(デフォルト100件で、1500件まで見れる)
`heroku logs -a アプリ名(例yuzu-amechan-bot) -n 1500`

タイムゾーン変更
`heroku config:add TZ=Asia/Tokyo -a yuzu-amechan-bot`
